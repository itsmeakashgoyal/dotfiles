#!/usr/bin/env python3
#
#  ▓▓▓▓▓▓▓▓▓▓
# ░▓ author ▓ Akash Goyal
# ░▓ file   ▓ scripts/dutils/theme.py
# ░▓▓▓▓▓▓▓▓▓▓
#
# Coordinated Tokyo Night theming with a light/dark switch.
#
# One palette (Tokyo Night) across the whole toolchain:
#   - ghostty   : `theme = dark:TokyoNight Night,light:TokyoNight Day` follows the
#                 macOS appearance by default; this command can PIN dark/light by
#                 writing ~/.config/ghostty/theme.local (an optional include).
#   - bat/fzf/delta : follow the terminal's ANSI palette (see 01-exports.zsh /
#                 git config), so they match whatever ghostty is showing — no
#                 per-tool switch needed.
#   - neovim    : current-theme.lua reads ~/.config/dotfiles/theme and picks
#                 tokyonight-day / tokyonight-night on next launch.
#   - starship  : intentionally left monochrome (dimmed) — palette-neutral.
#
# Usage: dutils theme [dark|light|auto|toggle|status]

import argparse
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent.parent / "lib"))
from dutil import ok, info, warn, section  # noqa: E402

HOME = Path.home()
THEME_FILE = HOME / ".config" / "dotfiles" / "theme"          # dark|light|auto
GHOSTTY_LOCAL = HOME / ".config" / "ghostty" / "theme.local"  # optional include

GHOSTTY_THEME = {"dark": "TokyoNight Night", "light": "TokyoNight Day"}


def _read_mode() -> str:
    if THEME_FILE.exists():
        m = THEME_FILE.read_text().strip()
        if m in ("dark", "light", "auto"):
            return m
    return "auto"


def _write_mode(mode: str) -> None:
    THEME_FILE.parent.mkdir(parents=True, exist_ok=True)
    THEME_FILE.write_text(mode + "\n")


def _apply_ghostty(mode: str) -> None:
    if mode == "auto":
        if GHOSTTY_LOCAL.exists():
            GHOSTTY_LOCAL.unlink()
        info("ghostty: following the macOS appearance (Night ↔ Day)")
        return
    # ~/.config/ghostty is a Stow symlink into the repo; theme.local is gitignored.
    if not GHOSTTY_LOCAL.parent.exists():
        warn("ghostty config dir not found — is the ghostty package stowed?")
        return
    GHOSTTY_LOCAL.write_text(
        f"# Pinned by `dutils theme {mode}`. Delete this file or run "
        f"`dutils theme auto` to follow the macOS appearance again.\n"
        f"theme = {GHOSTTY_THEME[mode]}\n"
    )
    info(f"ghostty: pinned to {GHOSTTY_THEME[mode]}")


def _report(mode: str) -> None:
    section("Active theme")
    print(f"  mode: {mode}  (palette: Tokyo Night)")
    if mode == "auto":
        print("  ghostty → follows macOS appearance · nvim → night (dark)")
    else:
        print(f"  ghostty → TokyoNight {'Day' if mode == 'light' else 'Night'} · "
              f"nvim → tokyonight-{'day' if mode == 'light' else 'night'}")
    print("  bat/fzf/delta → follow the terminal's ANSI palette (match automatically)")


def main() -> None:
    parser = argparse.ArgumentParser(
        prog="dutils theme",
        description="Switch the coordinated Tokyo Night theme (light/dark).")
    parser.add_argument("mode", nargs="?", default="status",
                        choices=["dark", "light", "auto", "toggle", "status"],
                        help="dark/light pin the theme, auto follows macOS, "
                             "toggle flips dark↔light, status shows current (default).")
    args = parser.parse_args()

    if args.mode == "status":
        _report(_read_mode())
        return

    mode = args.mode
    if mode == "toggle":
        mode = "light" if _read_mode() == "dark" else "dark"

    section(f"Switching theme → {mode}")
    _write_mode(mode)
    _apply_ghostty(mode)
    ok(f"Theme set to {mode}.")
    info("Reload ghostty (or open a new window) and restart nvim/shells to see it.")


if __name__ == "__main__":
    main()
