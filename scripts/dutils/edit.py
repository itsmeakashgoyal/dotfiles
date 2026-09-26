#!/usr/bin/env python3
#
#  ▓▓▓▓▓▓▓▓▓▓
# ░▓ author ▓ Akash Goyal
# ░▓ file   ▓ scripts/dutils/edit.py
# ░▓▓▓▓▓▓▓▓▓▓
#
# `dutils edit [pkg]` - open a Stow package's directory in $EDITOR. With no
# argument, fuzzy-pick from STOW_PACKAGES (fzf if available, else a numbered
# prompt). Edits land in the repo; Stow symlinks make them live immediately.

import argparse
import os
import shutil
import subprocess
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent.parent / "lib"))
from dutil import fail  # noqa: E402
import manifest as mf  # noqa: E402
import osdetect  # noqa: E402

REPO = Path(__file__).resolve().parent.parent.parent


def _stow_packages() -> list[str]:
    # Reads packages.toml directly (the single source of truth — see
    # CLAUDE.md) instead of shelling out to `make print-STOW_PACKAGES`, which
    # doesn't work on Windows at all: Scoop's GNU Make can't run recipes
    # without a POSIX shell present (confirmed directly — even a bare
    # `@echo` target fails with "CreateProcess(NULL, echo ...) failed").
    if osdetect.is_windows():
        platform_key = "windows"
    elif osdetect.is_linux():
        platform_key = "linux"
    else:
        platform_key = "macos"
    return mf.load().stow_packages(platforms=(platform_key,))


def _package_dir(pkg: str) -> Path:
    """Top-level directory a package's files live under.

    Usually REPO/<pkg>, but a [[stow]] entry with an explicit `source` (e.g.
    `powershell`, nested under `windows/`) can point at a different top-level
    directory than its package name — derive it from the entry instead of
    assuming, so this stays correct for any future package like it.
    """
    for entry in mf.load().stow:
        if entry.package == pkg and entry.repo_path.endswith(entry.target):
            return REPO / entry.repo_path[: -len(entry.target)].rstrip("/")
    return REPO / pkg


def _pick(packages: list[str]) -> str | None:
    if shutil.which("fzf"):
        result = subprocess.run(
            ["fzf", "--prompt=edit package> ", "--height=40%", "--reverse"],
            input="\n".join(packages), capture_output=True, text=True,
        )
        choice = result.stdout.strip()
        return choice or None

    # Fallback: numbered prompt (no fzf).
    for i, name in enumerate(packages, 1):
        print(f"  {i}) {name}")
    try:
        raw = input("Select a package number: ").strip()
        return packages[int(raw) - 1]
    except (ValueError, IndexError, EOFError):
        return None


def main() -> None:
    parser = argparse.ArgumentParser(
        prog="edit",
        description="Open a Stow package's config in $EDITOR",
    )
    parser.add_argument("package", nargs="?", help="package name (fuzzy-picked if omitted)")
    args = parser.parse_args()

    packages = _stow_packages()
    if not packages:
        fail("Could not read STOW_PACKAGES from the Makefile.")
        sys.exit(1)

    pkg = args.package or _pick(packages)
    if not pkg:
        sys.exit(0)  # nothing picked

    if pkg not in packages:
        fail(f"Unknown package '{pkg}'. Available: {', '.join(packages)}")
        sys.exit(1)

    editor = os.environ.get("EDITOR", "nvim")
    os.execvp(editor, [editor, str(_package_dir(pkg))])


if __name__ == "__main__":
    main()
