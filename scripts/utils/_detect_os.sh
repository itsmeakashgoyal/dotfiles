#!/usr/bin/env bash

#################################################
#      File: _detect_os.sh                       #
#      Description: OS Detection Utility         #
#      Status: Development                       #
#################################################

# Enable error handling
set -eo pipefail

# ------------------------------------------------------------------------------
# OS Detection Function
# ------------------------------------------------------------------------------
detect_os() {
    # Get system architecture
    local arch=$(uname -m)
    # Get OS type without version info
    local os_type=$(echo "$OSTYPE" | cut -d"-" -f1)

    # Detect OS and architecture combination
    case "${os_type},${arch}" in
    "linux,arm" | "linux,arm64" | "linux,x86_64")
        echo "linux"
        ;;
    "darwin,arm64")
        echo "M1"
        ;;
    "darwin,x86_64")
        echo "mac"
        ;;
    *)
        echo "Unsupported OS: ${os_type} on ${arch}" >&2
        return 1
        ;;
    esac
}

# Run detection if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    detect_os
fi
