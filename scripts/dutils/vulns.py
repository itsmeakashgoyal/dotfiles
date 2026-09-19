#!/usr/bin/env python3
#
#  ▓▓▓▓▓▓▓▓▓▓
# ░▓ author ▓ Akash Goyal
# ░▓ file   ▓ scripts/dutils/vulns.py
# ░▓▓▓▓▓▓▓▓▓▓
#
# Scan installed Homebrew packages for known vulnerabilities (OSV.dev-backed
# advisory database, built into Homebrew 7.0+). macOS only — Linux installs
# tools via Nix, not brew. Extra args pass straight through to `brew vulns`
# (e.g. `dutils vulns --severity high`, or a formula name to scan just one).
#
# Exit code mirrors `brew vulns`: nonzero when vulnerabilities are found, so it's
# scriptable — but note the advisory DB changes over time, so don't wire it into
# CI as a pass/fail gate (it would fail green builds on newly disclosed CVEs).

import os
import platform
import subprocess
import sys
from shutil import which


def main() -> None:
    args = sys.argv[1:]

    if platform.system() != "Darwin":
        print("brew vulns is macOS-only (Linux uses Nix, not Homebrew) — skipping.")
        return

    if which("brew") is None:
        print("Error: Homebrew not found.", file=sys.stderr)
        sys.exit(1)

    # `brew vulns` needs Homebrew >= 7.0. Probe before running so an older brew
    # gives a clear message instead of "Unknown command: vulns".
    if subprocess.run(["brew", "vulns", "--help"],
                      capture_output=True).returncode != 0:
        print("Error: `brew vulns` requires Homebrew 7.0+. Update with: brew update",
              file=sys.stderr)
        sys.exit(1)

    # Replace this process so brew's output streams live and its exit code
    # propagates unchanged.
    os.execvp("brew", ["brew", "vulns", *args])


if __name__ == "__main__":
    main()
