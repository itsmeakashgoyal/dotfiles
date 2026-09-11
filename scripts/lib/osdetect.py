#!/usr/bin/env python3
#
#  ▓▓▓▓▓▓▓▓▓▓
# ░▓ author ▓ Akash Goyal
# ░▓ file   ▓ scripts/lib/osdetect.py
# ░▓▓▓▓▓▓▓▓▓▓
#
# OS detection only, mirroring scripts/lib/os-detect.sh's API for this
# repo's standalone Python scripts (check.py, cleanup.py, install_nvim.py).

import platform


def is_mac() -> bool:
    return platform.system() == "Darwin"


def is_linux() -> bool:
    return platform.system() == "Linux"


def is_windows() -> bool:
    return platform.system() == "Windows"


def detail() -> str:
    system = platform.system()
    machine = platform.machine()
    if system == "Linux":
        return "Linux (ARM)" if machine == "aarch64" or machine.startswith("arm") else "Linux (x86_64)"
    if system == "Darwin":
        return "macOS (Apple Silicon)" if machine == "arm64" else "macOS (Intel)"
    if system == "Windows":
        # ARM64 Windows reports "ARM64"; x64 reports "AMD64".
        return "Windows (ARM)" if machine.upper().startswith("ARM") else "Windows (x86_64)"
    return f"Unknown: {system} on {machine}"
