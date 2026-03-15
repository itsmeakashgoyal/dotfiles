#!/usr/bin/env python3
#
#  ▓▓▓▓▓▓▓▓▓▓
# ░▓ author ▓ Akash Goyal
# ░▓ file   ▓ scripts/utils/print_functions.py
# ░▓▓▓▓▓▓▓▓▓▓
#
# List all custom zsh functions with their descriptions.
# Parses functions.zsh and extracts (name, comment) pairs where a comment
# line immediately precedes the function definition.

import re
import sys
from pathlib import Path

FUNCTIONS_FILE = (
    Path.home() / "dotfiles" / "zsh" / ".config" / "zsh" / "conf.d" / "functions.zsh"
)

# ──────────────────────────────────────────────────────────────────────────────
# Parser
# ──────────────────────────────────────────────────────────────────────────────

COMMENT_RE = re.compile(r"^\s*#\s*(.*)")
FUNC_RE    = re.compile(r"^\s*(?:function\s+)?([a-zA-Z0-9_-]+)\s*\(\)")


def parse_functions(filepath: Path) -> list[tuple[str, str]]:
    """Return sorted list of (name, description) from a zsh functions file."""
    lines = filepath.read_text().splitlines()
    results: list[tuple[str, str]] = []

    for i, line in enumerate(lines[:-1]):
        cm = COMMENT_RE.match(line)
        if not cm:
            continue
        fm = FUNC_RE.match(lines[i + 1])
        if not fm:
            continue
        desc = cm.group(1).strip()
        name = fm.group(1)
        if desc and name:
            results.append((name, desc))

    return sorted(results)

# ──────────────────────────────────────────────────────────────────────────────
# Main
# ──────────────────────────────────────────────────────────────────────────────

def main() -> None:
    if not FUNCTIONS_FILE.exists():
        print(f"Error: functions file not found: {FUNCTIONS_FILE}", file=sys.stderr)
        sys.exit(1)

    functions = parse_functions(FUNCTIONS_FILE)

    if not functions:
        print("No documented functions found.")
        return

    col = max(len(name) for name, _ in functions) + 2
    print(f"\033[1m{'Function':<{col}} Description\033[0m")
    print(f"{'─' * col} {'─' * 40}")
    for name, desc in functions:
        print(f"\033[36m{name:<{col}}\033[0m {desc}")


if __name__ == "__main__":
    main()
