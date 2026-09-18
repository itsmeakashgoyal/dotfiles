#!/usr/bin/env python3
#
#  ▓▓▓▓▓▓▓▓▓▓
# ░▓ author ▓ Akash Goyal
# ░▓ file   ▓ scripts/dutils/sync.py
# ░▓▓▓▓▓▓▓▓▓▓
#
# `dutils sync` - refresh the whole setup in one go: pull the latest dotfiles,
# re-stow all packages (picks up new/renamed files), then upgrade packages.
# git uses --ff-only so it never auto-merges over local/unpushed work; a
# divergence just reports as a failed step.

import argparse
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent.parent / "lib"))
from dutil import ok, fail, run, section  # noqa: E402

REPO = Path(__file__).resolve().parent.parent.parent


def main() -> None:
    parser = argparse.ArgumentParser(
        prog="sync",
        description="Pull latest dotfiles, re-stow, and update packages",
    )
    parser.add_argument(
        "--no-update", action="store_true",
        help="skip the package/tool upgrade step (just pull + re-stow)",
    )
    args = parser.parse_args()

    results: dict[str, bool] = {}

    section("Pulling latest dotfiles")
    results["git pull"] = run(["git", "-C", str(REPO), "pull", "--ff-only"])

    section("Re-stowing packages")
    results["make run"] = run(["make", "-C", str(REPO), "run"])

    # Best-effort: keep the compiled .zwc in step with any pulled/re-stowed zsh
    # changes. Not gated — a compile hiccup shouldn't fail the whole sync (zsh
    # falls back to the plain source anyway).
    section("Compiling zsh config (faster startup)")
    run([sys.executable, str(REPO / "scripts" / "dutils" / "zcompile.py")])

    if not args.no_update:
        section("Updating packages")
        results["update"] = run([sys.executable, str(REPO / "scripts" / "dutils" / "update.py")])

    print("\nSummary:")
    for name, success in results.items():
        (ok if success else fail)(name)

    if not all(results.values()):
        sys.exit(1)


if __name__ == "__main__":
    main()
