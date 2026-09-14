#!/usr/bin/env python3
#
#  ▓▓▓▓▓▓▓▓▓▓
# ░▓ author ▓ Akash Goyal
# ░▓ file   ▓ scripts/lib/dutil.py
# ░▓▓▓▓▓▓▓▓▓▓
#
# Shared output/util helpers for the repo's Python scripts - the Python analog
# of scripts/lib/core.sh. Consolidates the _ok/_info/_fail/_confirm/_run helpers
# that dutils subcommands used to each redefine. Colour is auto-disabled when
# stdout isn't a TTY or NO_COLOR is set.
#
# Import from a sibling script under scripts/:
#     import sys; from pathlib import Path
#     sys.path.insert(0, str(Path(__file__).resolve().parent.parent / "lib"))
#     import dutil

import os
import subprocess
import sys

_USE_COLOR = sys.stdout.isatty() and os.environ.get("NO_COLOR") is None


def _c(code: str, text: str) -> str:
    return f"\033[{code}m{text}\033[0m" if _USE_COLOR else text


# ── Status lines (two-space indented, glyph-prefixed) ─────────────────────────

def ok(msg: str) -> None:
    print(f"  {_c('32', '✓')} {msg}")


def info(msg: str) -> None:
    print(f"  {_c('34', '•')} {msg}")


def step(msg: str) -> None:
    print(f"  {_c('34', '→')} {msg}")


def warn(msg: str) -> None:
    print(f"  {_c('33', '⚠')} {msg}")


def fail(msg: str) -> None:
    print(f"  {_c('31', '✗')} {msg}", file=sys.stderr)


def section(title: str) -> None:
    print(f"\n{_c('34', title)}")


# ── Interaction / process ─────────────────────────────────────────────────────

def confirm(prompt: str) -> bool:
    """Yes/no prompt defaulting to No (empty answer == No)."""
    while True:
        answer = input(f"{prompt} [y/N] ").strip().lower()
        if answer in ("y", "yes"):
            return True
        if answer in ("n", "no", ""):
            return False


def run(cmd: list[str], **kwargs) -> bool:
    """Run a command, streaming its output live; return True on success."""
    print(f"  $ {' '.join(cmd)}")
    return subprocess.run(cmd, **kwargs).returncode == 0
