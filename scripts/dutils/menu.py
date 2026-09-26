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
import platform
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


def _current_platform() -> str:
    system = platform.system()
    if system == "Darwin":
        return "macos"
    if system == "Linux":
        return "linux"
    if system == "Windows":
        return "windows"
    return "macos"


def pick_with_tv(entries: list[str]) -> str:
    """Fuzzy-pick through television, previewing each command's own --help.

    macOS/Linux only — main() exits before this is ever called on Windows
    (tv as an interactive TUI corrupts the terminal there, confirmed
    directly; not something fixable by adjusting this command string).
    """
    # {0} is tv's own first-field extraction (done internally before the
    # command string is built), so this is plain "program arg1 arg2" with
    # no pipes/$()/|| — simpler and less fragile than the previous
    # `$(echo {} | cut -d" " -f1)` / `||` fallback.
    preview = f'"{sys.executable}" "{DUTILS}" {{0}} --help'
    args = ["tv", "--input-header", "dutils — pick a command",
            "--preview-command", preview, "--preview-header", "{}"]
    try:
        result = subprocess.run(
            args,
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
    # Confirmed directly (not just the source/preview bugs fixed earlier):
    # tv as an interactive TUI here corrupts the terminal on Windows — Tab/
    # Up/Down stop responding and the picker leaves the terminal broken
    # after it closes. This isn't a syntax issue fixable by adjusting
    # commands; it's tv needing raw console/keyboard access while stdin is
    # simultaneously being fed piped entries via subprocess, which Windows'
    # console handling doesn't seem to separate the way a Unix tty does.
    # Removed entirely rather than left half-working — use `dutils --help`
    # or `dutils <command> --help` directly instead.
    if _current_platform() == "windows":
        print("dutils menu isn't available on Windows — its interactive picker")
        print("corrupts the terminal there (confirmed directly, not a guess).")
        print("Use `dutils --help` to browse commands, or `dutils <command> --help`")
        print("for a specific one.")
        sys.exit(1)

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
    parser.add_argument("--all", action="store_true",
                        help="also list commands not tagged for this platform "
                             "(they may error or no-op — see docs/WINDOWS.md)")
    args, passthrough = parser.parse_known_args()

    commands = load_commands()
    current = _current_platform()
    width = max(len(name) for name in commands)
    entries = [f"{name.ljust(width)}  {desc}" for name, (_, desc, platforms) in commands.items()
               if name != "menu" and (args.all or current in platforms)]

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
