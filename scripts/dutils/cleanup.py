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

sys.path.insert(0, str(Path(__file__).resolve().parent.parent / "lib"))
from dutil import ok as _ok, info as _info, confirm as _confirm  # noqa: E402
import osdetect  # noqa: E402

HOME = Path.home()
UNINSTALL_SH = Path(__file__).resolve().parent.parent / "setup" / "uninstall.sh"
WINDOWS_PS1 = Path(__file__).resolve().parent.parent.parent / "windows" / "windows.ps1"

# ──────────────────────────────────────────────────────────────────────────────
# Helpers
# ──────────────────────────────────────────────────────────────────────────────

def _run_uninstall(steps: str, force: bool) -> None:
    """Delegate to scripts/setup/uninstall.sh (macOS/Linux) or
    windows/windows.ps1 -Uninstall (native Windows) for the given steps.

    Resolved by path, not by sourcing DOTFILES_DIR/XDG_DOTFILES_DIR from the
    caller's environment - each script's own self-location figures out the
    repo root correctly on its own once invoked this way.
    """
    if osdetect.is_windows():
        pwsh = shutil.which("pwsh") or shutil.which("powershell")
        if pwsh is None:
            _info("Neither 'pwsh' nor 'powershell' found on PATH — cannot run windows.ps1 -Uninstall.")
            return
        args = [pwsh, "-NoLogo", "-ExecutionPolicy", "Bypass", "-File", str(WINDOWS_PS1), "-Uninstall"]
        if force:
            args.append("-Force")
        # "unstow,sweep" is cleanup_dotfiles's step set — its own description
        # promises just "Remove dotfile symlinks", not the full teardown
        # (Scoop packages, terminal theme, modules) windows.ps1 -Uninstall
        # does by default. -SymlinksOnly keeps that promise on Windows too;
        # the full teardown stays reachable only via a direct, explicit
        # windows.ps1 -Uninstall call (see docs/WINDOWS.md), not through here.
        if steps == "unstow,sweep":
            args.append("-SymlinksOnly")
        subprocess.run(args, check=False)
        return

    # Without this check, subprocess.run raises an uncaught FileNotFoundError
    # when bash is absent — e.g. a from-source Python install with no shell
    # environment set up yet. check=False only covers a non-zero *exit code*,
    # it doesn't stop the executable-not-found case from raising at all.
    if shutil.which("bash") is None:
        _info(
            "'bash' not found — uninstall.sh needs it. Use WSL2 or Git Bash "
            "if this is meant to be a POSIX shell."
        )
        return
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
    if osdetect.is_windows():
        # Neovim's config/data/state/cache all live under different paths on
        # Windows than the XDG dirs below (see windows.ps1's $NVIM_CONFIG/
        # $NVIM_DATA) — none of those four hardcoded Unix paths ever existed
        # there, so this silently did nothing on Windows while still
        # reporting success. Reuse check.py's own manifest-driven resolution
        # (already fixed for OneDrive KFM) instead of a third hardcoded copy.
        sys.path.insert(0, str(Path(__file__).resolve().parent.parent / "verify"))
        from check import nvim_config_dir  # noqa: E402

        dirs = [
            nvim_config_dir(),
            Path(os.environ.get("LOCALAPPDATA", str(HOME))) / "nvim-data",
        ]
    else:
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
