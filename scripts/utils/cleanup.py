#!/usr/bin/env python3
#
#  ▓▓▓▓▓▓▓▓▓▓
# ░▓ author ▓ Akash Goyal
# ░▓ file   ▓ scripts/utils/cleanup.py
# ░▓▓▓▓▓▓▓▓▓▓
#
# Clean up dotfiles, Homebrew, Neovim, tmux configurations.

import argparse
import platform
import shutil
import subprocess
import sys
from pathlib import Path

HOME = Path.home()

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

# ──────────────────────────────────────────────────────────────────────────────
# Cleanup Functions
# ──────────────────────────────────────────────────────────────────────────────

def cleanup_dotfiles() -> None:
    print("Removing dotfile symlinks...")
    symlinks = [
        HOME / ".zshenv",
        HOME / ".config" / "nvim",
        HOME / ".config" / "tmux",
        HOME / ".config" / "git",
        HOME / ".config" / "zsh",
        HOME / ".config" / "ohmyposh",
    ]
    for link in symlinks:
        if link.is_symlink():
            link.unlink()
            _ok(f"Removed symlink: {link}")
        else:
            _info(f"Skipping (not a symlink): {link}")


def cleanup_homebrew() -> None:
    if shutil.which("brew") is None:
        _info("Homebrew not found, skipping.")
        return

    print("This will uninstall Homebrew and all installed packages.")
    if not _confirm("Uninstall Homebrew and all packages?"):
        print("Skipping Homebrew cleanup.")
        return

    # Remove all formulae
    result = subprocess.run(["brew", "list", "--formula"], capture_output=True, text=True)
    formulae = result.stdout.split()
    if formulae:
        subprocess.run(["brew", "remove", "--force"] + formulae, check=False)

    # Remove casks (macOS) or remaining packages (Linux)
    if platform.system() == "Darwin":
        result = subprocess.run(["brew", "list", "--cask"], capture_output=True, text=True)
        casks = result.stdout.split()
        if casks:
            subprocess.run(["brew", "remove", "--cask", "--force"] + casks, check=False)
    else:
        result = subprocess.run(["brew", "list"], capture_output=True, text=True)
        pkgs = result.stdout.split()
        if pkgs:
            subprocess.run(["brew", "remove", "--force"] + pkgs, check=False)

    # Uninstall Homebrew itself
    subprocess.run(
        ["/bin/bash", "-c",
         'NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/uninstall.sh)"'],
        check=False,
    )

    linuxbrew = Path("/home/linuxbrew/.linuxbrew")
    if linuxbrew.exists():
        subprocess.run(["sudo", "rm", "-rf", str(linuxbrew)], check=False)

    _ok("Homebrew uninstalled successfully")


def cleanup_nvim() -> None:
    print("Cleaning Neovim configuration...")
    dirs = [
        HOME / ".config" / "nvim",
        HOME / ".local" / "share" / "nvim",
        HOME / ".local" / "state" / "nvim",
        HOME / ".cache" / "nvim",
    ]
    for d in dirs:
        if d.exists():
            shutil.rmtree(d)
            _ok(f"Removed: {d}")


def cleanup_tmux() -> None:
    print("Cleaning tmux configuration...")
    dirs = [
        HOME / ".config" / "tmux",
        HOME / ".tmux",
    ]
    for d in dirs:
        if d.exists():
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

    # Execute
    for component in components:
        COMPONENTS[component][0]()

    print("\n\033[32m✓\033[0m Cleanup completed!")


if __name__ == "__main__":
    main()
