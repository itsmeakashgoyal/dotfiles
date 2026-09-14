#!/usr/bin/env python3
#
#  ▓▓▓▓▓▓▓▓▓▓
# ░▓ author ▓ Akash Goyal
# ░▓ file   ▓ scripts/dutils/update.py
# ░▓▓▓▓▓▓▓▓▓▓
#
# Update packages/tools installed via this dotfiles setup: Homebrew (macOS),
# Nix + Home Manager (Linux), mise-managed runtime versions, zinit-managed
# zsh plugins, and Neovim plugins. Deliberately does NOT touch macOS system
# software updates (softwareupdate) - that stays a manual, separate decision
# since an OS update can require a restart and is a different risk tier than
# upgrading a CLI tool.

import argparse
import platform
import shutil
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent.parent / "lib"))
from dutil import ok as _ok, info as _info, fail as _fail, run as _run  # noqa: E402

REPO_ROOT = Path(__file__).resolve().parent.parent.parent

# ──────────────────────────────────────────────────────────────────────────────
# Update Functions
# ──────────────────────────────────────────────────────────────────────────────

def update_brew() -> bool:
    if platform.system() != "Darwin":
        _info("Not on macOS, skipping Homebrew.")
        return True
    if shutil.which("brew") is None:
        _info("Homebrew not found, skipping.")
        return True
    print("Updating Homebrew (formulae + casks)...")
    ok = _run(["brew", "update"])
    ok = _run(["brew", "upgrade"]) and ok
    ok = _run(["brew", "upgrade", "--cask"]) and ok
    ok = _run(["brew", "cleanup"]) and ok
    return ok


def update_nix() -> bool:
    if platform.system() != "Linux":
        _info("Not on Linux, skipping Nix.")
        return True
    if shutil.which("nix") is None:
        _info("Nix not found, skipping.")
        return True
    # Delegates to `make nix-update` rather than reimplementing flake-update +
    # home-manager-switch logic here - one source of truth for the exact
    # flake path/flags (see Makefile's nix-update/nix-switch targets).
    print("Updating Nix flake inputs + Home Manager (make nix-update)...")
    return _run(["make", "-C", str(REPO_ROOT), "nix-update"])


def update_mise() -> bool:
    if shutil.which("mise") is None:
        _info("mise not found, skipping.")
        return True
    print("Upgrading mise-managed runtime versions...")
    return _run(["mise", "upgrade"])


def update_zinit() -> bool:
    zinit_home = Path.home() / ".local" / "share" / "zinit" / "zinit.git"
    if shutil.which("zsh") is None or not zinit_home.exists():
        _info("zinit not installed, skipping.")
        return True
    # Runs inside an interactive zsh so .zshrc's zinit bootstrap actually
    # loads the `zinit` function first - `--no-pager` avoids it trying to
    # page output through something expecting a real TTY.
    print("Updating zinit-managed zsh plugins...")
    return _run(["zsh", "-i", "-c", "zinit update --all --no-pager"])


def update_nvim() -> bool:
    if shutil.which("nvim") is None:
        _info("Neovim not found, skipping.")
        return True
    print("Syncing Neovim plugins (lazy.nvim)...")
    return _run(["nvim", "--headless", "+Lazy! sync", "+qa"])


COMPONENTS: dict[str, tuple] = {
    "brew":  (update_brew,  "Homebrew: update, upgrade formulae + casks, cleanup (macOS)"),
    "nix":   (update_nix,   "Nix: update flake inputs, home-manager switch (Linux)"),
    "mise":  (update_mise,  "Upgrade mise-managed runtime versions (Python, Node, ...)"),
    "zinit": (update_zinit, "Update all zinit-managed zsh plugins"),
    "nvim":  (update_nvim,  "Sync Neovim plugins via lazy.nvim"),
}

# ──────────────────────────────────────────────────────────────────────────────
# Main
# ──────────────────────────────────────────────────────────────────────────────

def main() -> None:
    parser = argparse.ArgumentParser(
        prog="update",
        description="Update packages/tools installed via this dotfiles setup",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog=(
            "components:\n"
            + "".join(f"  {name:<8} {desc}\n" for name, (_, desc) in COMPONENTS.items())
            + "\nWith no arguments, runs every component applicable to this OS.\n"
            "Does NOT touch macOS system software updates - that stays manual.\n\n"
            "examples:\n"
            "  %(prog)s\n"
            "  %(prog)s brew mise\n"
        ),
    )
    parser.add_argument("components", nargs="*", metavar="component")
    args = parser.parse_args()

    valid = set(COMPONENTS)
    components = args.components or list(COMPONENTS)
    for c in components:
        if c not in valid:
            parser.error(f"unknown component '{c}'. Choose from: {', '.join(sorted(valid))}")

    # No confirmation prompt, unlike cleanup.py - every component here is an
    # additive/upgrade operation, not a deletion, so there's nothing to guard.
    results: dict[str, bool] = {}
    for name in components:
        results[name] = COMPONENTS[name][0]()
        print()

    print("Summary:")
    for name, success in results.items():
        (_ok if success else _fail)(name)

    if not all(results.values()):
        sys.exit(1)


if __name__ == "__main__":
    main()
