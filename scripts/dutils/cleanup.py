#!/usr/bin/env python3
#
#  ▓▓▓▓▓▓▓▓▓▓
# ░▓ author ▓ Akash Goyal
# ░▓ file   ▓ scripts/dutils/cleanup.py
# ░▓▓▓▓▓▓▓▓▓▓
#
# Clean up dotfiles, Homebrew, Neovim, tmux configurations.

import argparse
import os
import shutil
import subprocess
import sys
from pathlib import Path

HOME = Path.home()
UNINSTALL_SH = Path(__file__).resolve().parent.parent / "setup" / "uninstall.sh"

# ──────────────────────────────────────────────────────────────────────────────
# Helpers
# ──────────────────────────────────────────────────────────────────────────────

def _ok(msg: str) -> None:
    print(f"  \033[32m✓\033[0m {msg}")

def _info(msg: str) -> None:
    print(f"  \033[34m•\033[0m {msg}")

def _confirm(prompt: str) -> bool:
    while True:
        answer = input(f"{prompt} [y/N] ").strip().lower()
        if answer in ("y", "yes"):
            return True
        if answer in ("n", "no", ""):
            return False

def _run_uninstall(steps: str, force: bool) -> None:
    """Delegate to scripts/setup/uninstall.sh for the given steps.

    Resolved by path, not by sourcing DOTFILES_DIR/XDG_DOTFILES_DIR from the
    caller's environment - uninstall.sh's own BASH_SOURCE-based self-location
    figures out the repo root correctly on its own once invoked this way.
    """
    env = os.environ.copy()
    env["STEPS"] = steps
    if force:
        env["FORCE"] = "1"
    subprocess.run(["bash", str(UNINSTALL_SH)], env=env, check=False)

# ──────────────────────────────────────────────────────────────────────────────
# Cleanup Functions
# ──────────────────────────────────────────────────────────────────────────────

def cleanup_dotfiles(force: bool = False) -> None:
    print("Removing dotfile symlinks...")
    _run_uninstall("unstow,sweep", force)


def cleanup_homebrew(force: bool = False) -> None:
    if shutil.which("brew") is None:
        _info("Homebrew not found, skipping.")
        return
    _run_uninstall("homebrew", force)


def cleanup_nvim() -> None:
    print("Cleaning Neovim configuration...")
    dirs = [
        HOME / ".config" / "nvim",
        HOME / ".local" / "share" / "nvim",
        HOME / ".local" / "state" / "nvim",
        HOME / ".cache" / "nvim",
    ]
    for d in dirs:
        if d.is_symlink():
            d.unlink()
            _ok(f"Removed symlink: {d}")
        elif d.exists():
            shutil.rmtree(d)
            _ok(f"Removed: {d}")


def cleanup_tmux() -> None:
    print("Cleaning tmux configuration...")
    dirs = [
        HOME / ".config" / "tmux",
        HOME / ".tmux",
    ]
    for d in dirs:
        if d.is_symlink():
            d.unlink()
            _ok(f"Removed symlink: {d}")
        elif d.exists():
            shutil.rmtree(d)
            _ok(f"Removed: {d}")


COMPONENTS: dict[str, tuple[callable, str]] = {
    "dotfiles": (cleanup_dotfiles, "Remove dotfile symlinks"),
    "homebrew": (cleanup_homebrew, "Uninstall Homebrew and all packages"),
    "nvim":     (cleanup_nvim,     "Remove Neovim configuration and data"),
    "tmux":     (cleanup_tmux,     "Remove tmux configuration"),
}

# ──────────────────────────────────────────────────────────────────────────────
# Main
# ──────────────────────────────────────────────────────────────────────────────

def main() -> None:
    parser = argparse.ArgumentParser(
        prog="cleanup",
        description="Clean up dotfiles configurations",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog=(
            "components:\n"
            + "".join(f"  {name:<12} {desc}\n" for name, (_, desc) in COMPONENTS.items())
            + "  all          Clean everything\n\n"
            "examples:\n"
            "  %(prog)s nvim homebrew\n"
            "  %(prog)s -y all\n"
        ),
    )
    parser.add_argument("-y", "--yes", action="store_true", help="Auto-confirm all actions")
    parser.add_argument("components", nargs="*", metavar="component")
    args = parser.parse_args()

    valid = set(COMPONENTS) | {"all"}
    components: list[str] = []
    for c in args.components:
        if c not in valid:
            parser.error(f"unknown component '{c}'. Choose from: {', '.join(sorted(valid))}")
        if c == "all":
            components = list(COMPONENTS)
            break
        components.append(c)

    # Interactive selection when nothing specified
    if not components:
        available = list(COMPONENTS) + ["all", "quit"]
        print("Select components to clean:")
        for i, name in enumerate(available, 1):
            desc = COMPONENTS[name][1] if name in COMPONENTS else ""
            print(f"  {i}) {name:<12} {desc}")
        raw = input("Enter number: ").strip()
        try:
            selected = available[int(raw) - 1]
        except (ValueError, IndexError):
            print("Invalid choice.")
            sys.exit(1)

        if selected == "quit":
            sys.exit(0)
        components = list(COMPONENTS) if selected == "all" else [selected]

    # Confirm
    if not args.yes:
        print(f"The following components will be cleaned: {', '.join(components)}")
        if not _confirm("Continue?"):
            sys.exit(0)

    # Execute. dotfiles/homebrew delegate to uninstall.sh and take the -y flag
    # as their own FORCE (skips uninstall.sh's confirm too); nvim/tmux don't
    # shell out to anything, so they have nothing to force-skip.
    for component in components:
        fn = COMPONENTS[component][0]
        if component in ("dotfiles", "homebrew"):
            fn(args.yes)
        else:
            fn()

    print("\n\033[32m✓\033[0m Cleanup completed!")


if __name__ == "__main__":
    main()
