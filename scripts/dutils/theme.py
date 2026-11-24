#!/usr/bin/env python3
#
#  ▓▓▓▓▓▓▓▓▓▓
# ░▓ author ▓ Akash Goyal
# ░▓ file   ▓ scripts/dutils/theme.py
# ░▓▓▓▓▓▓▓▓▓▓
#
# Gruvbox everywhere, with one switch for the terminal.
#
# Gruvbox Dark everywhere by default (see docs/THEME.md). Sublime Text is
# static config (Gruvbox Dark; Gruvbox Light ships alongside it). The TERMINAL
# is switchable: this command pins it to dark/light, or lets it follow the OS
# (auto). The mode lives in
#     ~/.config/dotfiles/theme and is read by:
#       iTerm2   : the Dynamic Profile rendered here (separate light/dark colors
#                  in auto mode); iTerm2 reloads it live, no restart needed
#       zsh      : 01-exports.zsh → $DOTFILES_THEME, $BAT_THEME (bat + delta),
#                  starship's gruvbox_light palette
#       Neovim   : current-theme.lua → gruvbox + 'background'
#     tmux, fzf and yazi use ANSI colours, so they follow the terminal palette.
#
# Usage: dutils theme [dark|light|auto|toggle|apply|status]

import argparse
import copy
import json
import platform
import subprocess
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent.parent / "lib"))
from dutil import ok, info, warn, section  # noqa: E402

HOME = Path.home()
REPO = Path(__file__).resolve().parent.parent.parent
THEME_FILE = HOME / ".config" / "dotfiles" / "theme"  # dark|light|auto
MODES = ("dark", "light", "auto")
DEFAULT_MODE = "dark"

IS_MAC = platform.system() == "Darwin"
ITERM_PROFILE_SRC = REPO / "settings" / "iterm" / "profile.json"
ITERM_DYNAMIC_DIR = HOME / "Library" / "Application Support" / "iTerm2" / "DynamicProfiles"
ITERM_DYNAMIC_FILE = ITERM_DYNAMIC_DIR / "dotfiles-gruvbox.json"

# ── Gruvbox (morhetz, medium contrast) ─────────────────────────────────────────
# ANSI 0-15 + UI colours, as used by the official gruvbox-contrib terminal themes.
GRUVBOX = {
    "dark": {
        "ansi": ["#282828", "#cc241d", "#98971a", "#d79921", "#458588", "#b16286", "#689d6a", "#a89984",
                 "#928374", "#fb4934", "#b8bb26", "#fabd2f", "#83a598", "#d3869b", "#8ec07c", "#ebdbb2"],
        "Background": "#282828", "Foreground": "#ebdbb2", "Bold": "#fbf1c7",
        "Cursor": "#ebdbb2", "Cursor Text": "#282828", "Cursor Guide": "#3c3836",
        "Selection": "#504945", "Selected Text": "#fbf1c7", "Link": "#83a598",
        "Match Background": "#d79921", "Badge": "#fb4934",
    },
    "light": {
        "ansi": ["#fbf1c7", "#cc241d", "#98971a", "#d79921", "#458588", "#b16286", "#689d6a", "#7c6f64",
                 "#928374", "#9d0006", "#79740e", "#b57614", "#076678", "#8f3f71", "#427b58", "#3c3836"],
        "Background": "#fbf1c7", "Foreground": "#3c3836", "Bold": "#282828",
        "Cursor": "#3c3836", "Cursor Text": "#fbf1c7", "Cursor Guide": "#ebdbb2",
        "Selection": "#d5c4a1", "Selected Text": "#282828", "Link": "#076678",
        "Match Background": "#fabd2f", "Badge": "#9d0006",
    },
}


# ── state ─────────────────────────────────────────────────────────────────────
def read_mode() -> str:
    if THEME_FILE.exists():
        m = THEME_FILE.read_text().strip()
        if m in MODES:
            return m
    return DEFAULT_MODE


def write_mode(mode: str) -> None:
    THEME_FILE.parent.mkdir(parents=True, exist_ok=True)
    THEME_FILE.write_text(mode + "\n")


def os_appearance() -> str:
    """The OS light/dark setting right now (best effort; 'dark' if unknown)."""
    try:
        if IS_MAC:
            r = subprocess.run(["defaults", "read", "-g", "AppleInterfaceStyle"],
                               capture_output=True, text=True)
            return "dark" if r.stdout.strip() == "Dark" else "light"
        if platform.system() == "Windows":
            import winreg  # type: ignore[import-not-found]
            key = winreg.OpenKey(winreg.HKEY_CURRENT_USER,
                                 r"Software\Microsoft\Windows\CurrentVersion\Themes\Personalize")
            return "light" if winreg.QueryValueEx(key, "AppsUseLightTheme")[0] else "dark"
        r = subprocess.run(["gsettings", "get", "org.gnome.desktop.interface", "color-scheme"],
                           capture_output=True, text=True)
        return "dark" if "dark" in r.stdout else "light"
    except (OSError, subprocess.SubprocessError):
        return "dark"


# ── iTerm2 Dynamic Profile ────────────────────────────────────────────────────
def _iterm_color(hex_rgb: str, alpha: float = 1.0) -> dict:
    h = hex_rgb.lstrip("#")
    r, g, b = (int(h[i:i + 2], 16) / 255 for i in (0, 2, 4))
    return {"Red Component": r, "Green Component": g, "Blue Component": b,
            "Alpha Component": alpha, "Color Space": "sRGB"}


def _iterm_colors(variant: str, suffix: str = "") -> dict:
    p = GRUVBOX[variant]
    out = {f"Ansi {i} Color{suffix}": _iterm_color(c) for i, c in enumerate(p["ansi"])}
    for name in ("Background", "Foreground", "Bold", "Cursor", "Cursor Text", "Cursor Guide",
                 "Selection", "Selected Text", "Link", "Match Background"):
        out[f"{name} Color{suffix}"] = _iterm_color(p[name])
    out[f"Badge Color{suffix}"] = _iterm_color(p["Badge"], 0.5)
    out[f"Use Selected Text Color{suffix}"] = True
    out[f"Use Bright Bold{suffix}"] = True
    out[f"Brighten Bold Text{suffix}"] = True
    out[f"Smart Cursor Color{suffix}"] = False
    out[f"Minimum Contrast{suffix}"] = 0.0
    return out


def render_iterm_profiles(mode: str) -> dict:
    """settings/iterm/profile.json (shared settings) + Gruvbox colours for `mode`."""
    src = json.loads(ITERM_PROFILE_SRC.read_text())
    profiles = []
    for overrides in src["profiles"]:
        prof = copy.deepcopy(src["common"])
        prof.update({k: v for k, v in overrides.items() if not k.startswith("_")})
        if mode == "auto":
            prof["Use Separate Colors for Light and Dark Mode"] = True
            prof.update(_iterm_colors("dark"))  # fallback for older iTerm2 builds
            prof.update(_iterm_colors("dark", " (Dark)"))
            prof.update(_iterm_colors("light", " (Light)"))
        else:
            prof["Use Separate Colors for Light and Dark Mode"] = False
            prof.update(_iterm_colors(mode))
        profiles.append(prof)
    return {"Profiles": profiles}


def apply_iterm(mode: str) -> None:
    if not IS_MAC:
        return
    if not ITERM_PROFILE_SRC.exists():
        warn(f"iTerm2 profile template missing: {ITERM_PROFILE_SRC}")
        return
    ITERM_DYNAMIC_DIR.mkdir(parents=True, exist_ok=True)
    data = render_iterm_profiles(mode)
    ITERM_DYNAMIC_FILE.write_text(json.dumps(data, indent=2) + "\n")
    names = ", ".join(p["Name"] for p in data["Profiles"])
    info(f"iTerm2: wrote Dynamic Profile(s) {names} → {ITERM_DYNAMIC_FILE.name} "
         "(iTerm2 reloads it live)")


# ── commands ──────────────────────────────────────────────────────────────────
def describe(mode: str) -> str:
    if mode == "auto":
        return f"follows the OS (currently {os_appearance()})"
    return f"Gruvbox {mode.capitalize()}"


def report() -> None:
    mode = read_mode()
    section("Theme: Gruvbox")
    print(f"  terminal : {mode:<5} → {describe(mode)}")
    print("  Sublime  : dark  → Gruvbox Dark (settings/sublime/Preferences.sublime-settings)")
    print("  change   : dutils theme dark | light | auto | toggle")


def apply(mode: str) -> None:
    write_mode(mode)
    apply_iterm(mode)


def main() -> None:
    parser = argparse.ArgumentParser(
        prog="dutils theme",
        description="Gruvbox everywhere (dark by default). Sets the TERMINAL mode: "
                    "dark, light, or auto (follow the OS).")
    parser.add_argument("mode", nargs="?", default="status",
                        choices=[*MODES, "toggle", "apply", "status"],
                        help="dark/light pin the terminal, auto follows the OS, toggle flips "
                             "dark↔light, apply re-renders from the saved mode, status (default).")
    args = parser.parse_args()

    if args.mode == "status":
        report()
        return

    if args.mode == "apply":
        mode = read_mode()
    elif args.mode == "toggle":
        mode = "light" if read_mode() == "dark" else "dark"
    else:
        mode = args.mode

    section(f"Terminal theme → {mode} ({describe(mode)})")
    apply(mode)
    ok(f"Saved to {THEME_FILE}")
    info("Open a new shell (or `exec zsh`) and restart Neovim to pick it up.")


if __name__ == "__main__":
    main()
