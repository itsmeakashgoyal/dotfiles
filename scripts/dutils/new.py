#!/usr/bin/env python3
#
#  ▓▓▓▓▓▓▓▓▓▓
# ░▓ author ▓ Akash Goyal
# ░▓ file   ▓ scripts/dutils/new.py
# ░▓▓▓▓▓▓▓▓▓▓
#
# `dutils new <pkg>` - scaffold a new Stow package and register it in the
# Makefile's STOW_PACKAGES. Defaults to the common XDG layout
# (<pkg>/.config/<pkg>/); use --home for packages that map straight to $HOME.

import argparse
import re
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent.parent / "lib"))
from dutil import ok, info, step, fail  # noqa: E402

REPO = Path(__file__).resolve().parent.parent.parent
MAKEFILE = REPO / "Makefile"


def main() -> None:
    parser = argparse.ArgumentParser(
        prog="new",
        description="Scaffold a new Stow package and add it to STOW_PACKAGES",
    )
    parser.add_argument("package", help="package name (lowercase; letters, digits, - and _)")
    parser.add_argument(
        "--home", action="store_true",
        help="map the package to $HOME directly instead of ~/.config/<pkg>",
    )
    args = parser.parse_args()
    pkg = args.package

    if not re.fullmatch(r"[a-z0-9_-]+", pkg):
        fail("Package name must be lowercase letters, digits, '-' or '_'.")
        sys.exit(1)

    pkg_dir = REPO / pkg
    if pkg_dir.exists():
        fail(f"'{pkg}' already exists at {pkg_dir}")
        sys.exit(1)

    # Scaffold the directory structure.
    if args.home:
        pkg_dir.mkdir(parents=True)
        created = f"{pkg}/"
    else:
        (pkg_dir / ".config" / pkg).mkdir(parents=True)
        created = f"{pkg}/.config/{pkg}/"
    step(f"Created {created}")

    # Register in the Makefile's STOW_PACKAGES line.
    text = MAKEFILE.read_text()
    match = re.search(r"^STOW_PACKAGES := (.*)$", text, re.M)
    if not match:
        fail("Could not find the STOW_PACKAGES line in the Makefile.")
        sys.exit(1)

    if re.search(rf"(^|\s){re.escape(pkg)}(\s|$)", match.group(1)):
        info(f"'{pkg}' is already in STOW_PACKAGES")
    else:
        MAKEFILE.write_text(text.replace(match.group(0), f"{match.group(0)} {pkg}", 1))
        ok(f"Added '{pkg}' to STOW_PACKAGES")

    info(f"Next: drop your config in {created}, then `make stow pkg={pkg}`")


if __name__ == "__main__":
    main()
