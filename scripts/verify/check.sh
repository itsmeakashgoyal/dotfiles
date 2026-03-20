#!/usr/bin/env bash
#
#  ▓▓▓▓▓▓▓▓▓▓
# ░▓ author ▓ Akash Goyal
# ░▓ file   ▓ scripts/verify/check.sh
# ░▓▓▓▓▓▓▓▓▓▓
#
# Thin shim — delegates to check.py (Python OOP implementation).
# All Makefile targets and callers continue to work unchanged.

exec python3 "$(dirname "$0")/check.py" "$@"
