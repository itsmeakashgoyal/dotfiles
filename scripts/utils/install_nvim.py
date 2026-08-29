#!/usr/bin/env python3
#
#  ▓▓▓▓▓▓▓▓▓▓
# ░▓ author ▓ Akash Goyal
# ░▓ file   ▓ scripts/utils/install_nvim.py
# ░▓▓▓▓▓▓▓▓▓▓
#
# Install the latest Neovim from GitHub releases (Linux only).
# Supports x86_64 and ARM64. Backs up existing config before installing.

import platform
import shutil
import subprocess
import sys
import tempfile
import urllib.request
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent.parent / "lib"))
import osdetect  # noqa: E402

HOME            = Path.home()
NVIM_BACKUP_DIR = HOME / "linuxtoolbox" / "backup" / "nvim"
NVIM_INSTALL_DIR = Path("/opt/nvim")
NVIM_DIRS = [
    HOME / ".config" / "nvim",
    HOME / ".local" / "share" / "nvim",
    HOME / ".cache" / "nvim",
]

RELEASES_BASE = "https://github.com/neovim/neovim/releases/latest/download"
ARCH_TARBALL: dict[str, str] = {
    "x86_64": "nvim-linux-x86_64.tar.gz",
    "aarch64": "nvim-linux-arm64.tar.gz",
    "arm64":   "nvim-linux-arm64.tar.gz",
}

# ──────────────────────────────────────────────────────────────────────────────
# Helpers
# ──────────────────────────────────────────────────────────────────────────────

def _ok(msg: str) -> None:
    print(f"  \033[32m✓\033[0m {msg}")

def _info(msg: str) -> None:
    print(f"  \033[34m→\033[0m {msg}")

# ──────────────────────────────────────────────────────────────────────────────
# Steps
# ──────────────────────────────────────────────────────────────────────────────

def backup_config() -> None:
    NVIM_BACKUP_DIR.mkdir(parents=True, exist_ok=True)
    for d in NVIM_DIRS:
        if d.exists():
            dest = NVIM_BACKUP_DIR / d.name
            if dest.exists():
                shutil.rmtree(dest)
            shutil.copytree(d, dest)
            _ok(f"Backed up {d} → {dest}")


def remove_existing() -> None:
    for d in NVIM_DIRS:
        if d.exists():
            shutil.rmtree(d)
            _ok(f"Removed {d}")
    if NVIM_INSTALL_DIR.exists():
        subprocess.run(["sudo", "rm", "-rf", str(NVIM_INSTALL_DIR)], check=True)
        _ok(f"Removed {NVIM_INSTALL_DIR}")


def install() -> None:
    machine = platform.machine()
    tarball = ARCH_TARBALL.get(machine)
    if tarball is None:
        print(f"Error: unsupported architecture '{machine}'", file=sys.stderr)
        sys.exit(1)

    url = f"{RELEASES_BASE}/{tarball}"
    _info(f"Downloading {url} ...")

    with tempfile.TemporaryDirectory() as tmp:
        dest = Path(tmp) / tarball
        urllib.request.urlretrieve(url, dest)
        _info("Extracting to /opt ...")
        subprocess.run(["sudo", "tar", "-C", "/opt", "-xzf", str(dest)], check=True)

    _ok("Neovim installed to /opt/nvim")

# ──────────────────────────────────────────────────────────────────────────────
# Main
# ──────────────────────────────────────────────────────────────────────────────

def main() -> None:
    if not osdetect.is_linux():
        print("Error: install-nvim is Linux-only.", file=sys.stderr)
        print("On macOS use: brew install neovim", file=sys.stderr)
        sys.exit(1)

    print("=== Neovim Installer ===\n")

    print("Backing up existing configuration...")
    backup_config()

    print("\nRemoving old installation...")
    remove_existing()

    print("\nInstalling Neovim...")
    install()

    print("\n\033[32m✓\033[0m Done!")
    print('  Ensure /opt/nvim/bin is in PATH:')
    print('  export PATH="/opt/nvim/bin:$PATH"')


if __name__ == "__main__":
    main()
