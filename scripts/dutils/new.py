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
import subprocess
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent.parent / "lib"))
from dutil import ok, info, step, fail  # noqa: E402
import osdetect  # noqa: E402

REPO = Path(__file__).resolve().parent.parent.parent
MAKEFILE = REPO / "Makefile"
PACKAGES_TOML = REPO / "packages.toml"
MANIFEST_PY = Path(__file__).resolve().parent / "manifest.py"


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

    # Register in packages.toml — the actual source of truth. STOW_PACKAGES in
    # the Makefile (below) and windows.ps1's $SYMLINK_MAP are both *generated*
    # from this file; writing only into the Makefile (the old behavior) meant
    # the new package never reached windows.ps1 at all, and the next
    # `dutils manifest generate`/`check` (a CI gate) would detect the
    # hand-edited Makefile line as drift and revert or fail on it.
    if args.home:
        info(
            f"'{pkg}' maps straight to $HOME (--home) — packages.toml's [[stow]] "
            "schema needs one explicit target per file/dir to symlink, which isn't "
            f"knowable yet for an empty scaffold. Add your own [[stow]] entry for "
            f"'{pkg}' once you know what you're dropping in, then run "
            "`dutils manifest generate`."
        )
    else:
        # Explicit encoding: packages.toml has UTF-8 box-drawing chars in its
        # section headers, and Python defaults to the system codepage (cp1252
        # on Windows) without one — confirmed directly, this raised
        # UnicodeDecodeError on this exact file on Windows otherwise.
        toml_text = PACKAGES_TOML.read_text(encoding="utf-8")
        if re.search(rf'^package\s*=\s*"{re.escape(pkg)}"$', toml_text, re.M):
            info(f"'{pkg}' already has a [[stow]] entry in packages.toml")
        else:
            entry = (
                f'\n[[stow]]\npackage   = "{pkg}"\ntarget    = ".config/{pkg}"\n'
                f'desc      = ""\nplatforms = ["macos", "linux"]\n'
            )
            PACKAGES_TOML.write_text(toml_text.rstrip("\n") + "\n" + entry, encoding="utf-8")
            ok(f"Added '{pkg}' to packages.toml (macOS/Linux — see note below for Windows)")

        step("Regenerating STOW_PACKAGES / windows.ps1 from packages.toml...")
        result = subprocess.run([sys.executable, str(MANIFEST_PY), "generate"], check=False)
        if result.returncode != 0:
            fail("`dutils manifest generate` failed — check packages.toml by hand.")

    if osdetect.is_windows():
        info(
            f"Next: drop your config in {created}. This new package isn't wired up "
            "for Windows yet — add `platforms = [\"windows\"]` (and a `windows_target` "
            f"if '.config/{pkg}' isn't right there) to its [[stow]] entry in "
            "packages.toml, run `dutils manifest generate`, then re-run windows.ps1."
        )
    else:
        info(f"Next: drop your config in {created}, then `make stow pkg={pkg}`")


if __name__ == "__main__":
    main()
