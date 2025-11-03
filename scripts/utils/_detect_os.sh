#!/usr/bin/env bash
#              █████     ███  ████
#             ░░███     ░░░  ░░███
#  █████ ████ ███████   ████  ░███   █████
# ░░███ ░███ ░░░███░   ░░███  ░███  ███░░
#  ░███ ░███   ░███     ░███  ░███ ░░█████
#  ░███ ░███   ░███ ███ ░███  ░███  ░░░░███
#  ░░████████  ░░█████  █████ █████ ██████
#   ░░░░░░░░    ░░░░░  ░░░░░ ░░░░░ ░░░░░░
#
#  ▓▓▓▓▓▓▓▓▓▓
# ░▓ author ▓ Akash Goyal
# ░▓ file   ▓ scripts/utils/_detect_os.sh
# ░▓▓▓▓▓▓▓▓▓▓
# ░░░░░░░░░░
#
#█▓▒░

# Enable error handling
set -eo pipefail

# ------------------------------------------------------------------------------
# OS Detection Function
# ------------------------------------------------------------------------------
detect_os() {
    # Get system architecture
    local arch=$(uname -m)
    # Get OS type (remove version numbers)
    local os_type=$(uname -s)

    # Detect OS and architecture combination
    case "${os_type},${arch}" in
    "Linux,arm"* | "Linux,aarch64")
        echo "Linux (ARM)"
        ;;
    "Linux,x86_64" | "Linux,amd64")
        echo "Linux (x86_64)"
        ;;
    "Darwin,arm64")
        echo "macOS (Apple Silicon)"
        ;;
    "Darwin,x86_64")
        echo "macOS (Intel)"
        ;;
    *)
        echo "Unknown: ${os_type} on ${arch}"
        return 1
        ;;
    esac
}

# Run detection if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    detect_os
fi
