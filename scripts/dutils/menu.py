#!/usr/bin/env python3
#
#  ▓▓▓▓▓▓▓▓▓▓
# ░▓ author ▓ Akash Goyal
# ░▓ file   ▓ scripts/dutils/menu.py
# ░▓▓▓▓▓▓▓▓▓▓
#
# `dutils menu` — an interactive picker for every dutils command.
#
# Browse the commands, preview exactly what the selected one does before
# committing to it, then confirm. The command registry in `dutils` is the single
# source of truth — nothing is duplicated here, so a new command shows up in the
# menu automatically.
#
# Uses television (`tv`) when it's installed, since this repo already depends on
# it; falls back to a plain numbered prompt everywhere else (fresh machines,
# CI, Windows without tv).
#
# Usage:
#   dutils menu               # pick a command, confirm, run it
#   dutils menu --dry-run     # print the command instead of running it
#   dutils menu --no-confirm  # skip the confirmation step

from __future__ import annotations

import argparse
import importlib.machinery
import importlib.util
import os
import shutil
import subprocess
import sys
from pathlib import Path

SCRIPT_DIR = Path(__file__).resolve().parent
DUTILS     = SCRIPT_DIR / "dutils"

# Commands that are interactive, destructive or long-running enough that the
# menu should always confirm, even under --no-confirm.
ALWAYS_CONFIRM = {"cleanup", "update", "sync", "init", "ssh-setup", "secrets", "zcompile"}


def load_commands() -> dict[str, tuple]:
    """Import the extension-less `dutils` script to read its COMMANDS registry."""
    spec = importlib.util.spec_from_loader(
        "dutils_cli", importlib.machinery.SourceFileLoader("dutils_cli", str(DUTILS))
    )
    if spec is None or spec.loader is None:
        sys.exit(f"error: cannot load command registry from {DUTILS}")
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module.COMMANDS


def pick_with_tv(entries: list[str]) -> str:
    """Fuzzy-pick through television, previewing each command's own --help."""
    preview = (
        f'{sys.executable} {DUTILS} '
        '"$(echo {} | cut -d" " -f1)" --help 2>&1 '
        f'|| {sys.executable} {DUTILS} --help'
    )
    try:
        result = subprocess.run(
            [
                "tv",
                "--source-command",  "cat",
                "--preview-command", preview,
                "--input-header",    "dutils — pick a command",
                "--preview-header",  "{}",
            ],
            input="\n".join(entries),
            # Only stdout is captured (that's where the selection comes back).
            # television draws its TUI on stderr, so stderr must stay attached
            # to the terminal — capturing it renders an invisible, apparently
            # hung picker.
            stdout=subprocess.PIPE,
            text=True,
        )
    except OSError:
        return ""
    return (result.stdout or "").strip()


def pick_with_prompt(entries: list[str]) -> str:
    """Numbered fallback picker for machines without television."""
    print("\n  dutils — pick a command\n")
    for index, entry in enumerate(entries, start=1):
        print(f"  {index:>2}. {entry}")
    print()
    try:
        raw = input("  Number (or name, empty to cancel): ").strip()
    except (EOFError, KeyboardInterrupt):
        print()
        return ""
    if not raw:
        return ""
    if raw.isdigit() and 1 <= int(raw) <= len(entries):
        return entries[int(raw) - 1]
    # Allow typing the command name directly.
    for entry in entries:
        if entry.split()[0] == raw:
            return entry
    print(f"  Unknown selection: {raw}")
    return ""


def confirm(command: str) -> bool:
    print(f"\n  About to run:  dutils {command}\n")
    try:
        reply = input("  Proceed? [y/N] ").strip().lower()
    except (EOFError, KeyboardInterrupt):
        print()
        return False
    return reply in ("y", "yes")


def main() -> None:
    parser = argparse.ArgumentParser(
        prog="dutils menu",
        description="Interactive picker for every dutils command",
    )
    parser.add_argument("--dry-run", action="store_true",
                        help="print the chosen command instead of running it")
    parser.add_argument("--no-confirm", action="store_true",
                        help="run immediately (destructive commands still confirm)")
    parser.add_argument("--no-tv", action="store_true",
                        help="force the numbered prompt even when television is installed")
    args, passthrough = parser.parse_known_args()

    commands = load_commands()
    width = max(len(name) for name in commands)
    entries = [f"{name.ljust(width)}  {desc}" for name, (_, desc) in commands.items()
               if name != "menu"]

    interactive = sys.stdin.isatty() and sys.stdout.isatty()
    if not interactive:
        # Non-interactive (CI, pipes): list the commands and exit cleanly rather
        # than blocking on input that will never arrive.
        print("\n".join(entries))
        return

    use_tv = shutil.which("tv") is not None and not args.no_tv
    selection = pick_with_tv(entries) if use_tv else pick_with_prompt(entries)
    if not selection:
        print("  Cancelled.")
        return

    command = selection.split()[0]
    if command not in commands:
        sys.exit(f"error: unknown command: {command}")

    if args.dry_run:
        print(f"dutils {command}")
        return

    if (not args.no_confirm or command in ALWAYS_CONFIRM) and not confirm(command):
        print("  Cancelled.")
        return

    os.execvp(sys.executable, [sys.executable, str(DUTILS), command] + passthrough)


if __name__ == "__main__":
    main()
