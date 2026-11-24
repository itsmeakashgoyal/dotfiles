#
#  ▓▓▓▓▓▓▓▓▓▓
# ░▓ author ▓ Akash Goyal
# ░▓ file   ▓ scripts/lib/pyreq.py
# ░▓▓▓▓▓▓▓▓▓▓
#
# Python >= 3.14 is the standard for every Python script in this repo.
#
# `ensure()` runs first thing in every entry point (dutils, check.py,
# manifest.py, and dutil.py, which every subcommand imports). On an older
# interpreter (e.g. macOS's /usr/bin/python3 3.9) it re-execs the same command
# under a suitable one instead of failing halfway through:
#   python3.15 / python3.14 on PATH → mise's python → uv's managed python
#   → `uv python install 3.14` as a last resort.
# Keep this file syntax-compatible with old Pythons: it must load before the
# version check can run.

import os
import shutil
import subprocess
import sys

MIN_VERSION = (3, 14)
MIN_STR = ".".join(map(str, MIN_VERSION))
_GUARD = "_DOTFILES_PY_REEXEC"


def _version_ok(python):
    try:
        out = subprocess.run(
            [python, "-c", "import sys; print(sys.version_info >= %r)" % (MIN_VERSION,)],
            capture_output=True, text=True, timeout=10,
        ).stdout.strip()
        return out == "True"
    except (OSError, subprocess.SubprocessError):
        return False


def _uv_find():
    uv = shutil.which("uv")
    if not uv:
        return None
    for cmd in ([uv, "python", "find", ">=" + MIN_STR], None):
        if cmd is None:
            sys.stderr.write("Python >= %s not found; installing it with uv...\n" % MIN_STR)
            subprocess.run([uv, "python", "install", MIN_STR], check=False)
            cmd = [uv, "python", "find", ">=" + MIN_STR]
        r = subprocess.run(cmd, capture_output=True, text=True)
        if r.returncode == 0 and r.stdout.strip():
            return r.stdout.strip()
    return None


def find_python():
    """Path of an interpreter >= MIN_VERSION, or None."""
    for name in ("python3.14", "python3.15", "python3.16"):  # the standard first
        path = shutil.which(name)
        if path and _version_ok(path):
            return path
    mise = shutil.which("mise")
    if mise:
        r = subprocess.run([mise, "which", "python"], capture_output=True, text=True)
        path = r.stdout.strip()
        if r.returncode == 0 and path and _version_ok(path):
            return path
    for name in ("python3", "python"):
        path = shutil.which(name)
        if path and _version_ok(path):
            return path
    return _uv_find()


def ensure():
    if sys.version_info >= MIN_VERSION:
        return
    current = "%d.%d" % sys.version_info[:2]
    if not os.environ.get(_GUARD):
        python = find_python()
        if python:
            os.environ[_GUARD] = "1"
            if os.name == "nt":
                # Windows has no real exec: execv returns control to the shell
                # before the child finishes. Run it and pass the exit code on.
                sys.exit(subprocess.call([python] + sys.argv))
            os.execv(python, [python] + sys.argv)
    sys.stderr.write(
        "Error: this needs Python >= %s (running %s from %s).\n"
        "Install it with one of:\n"
        "  macOS   : brew install python@%s\n"
        "  Linux   : nix profile install nixpkgs#python314   (or: uv python install %s)\n"
        "  Windows : scoop install python\n"
        "  any     : mise use -g python@%s\n" % (MIN_STR, current, sys.executable,
                                                  MIN_STR, MIN_STR, MIN_STR))
    sys.exit(1)
