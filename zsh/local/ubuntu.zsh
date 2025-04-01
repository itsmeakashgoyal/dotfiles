#!/usr/bin/env zsh
#                     █████
#                    ░░███
#   █████████  █████  ░███████
#  ░█░░░░███  ███░░   ░███░░███
#  ░   ███░  ░░█████  ░███ ░███
#    ███░   █ ░░░░███ ░███ ░███
#   █████████ ██████  ████ █████
#  ░░░░░░░░░ ░░░░░░  ░░░░ ░░░░░
#
#  ▓▓▓▓▓▓▓▓▓▓
# ░▓ author ▓ Akash Goyal
# ░▓ file   ▓ zsh/local/ubuntu.zsh
# ░▓▓▓▓▓▓▓▓▓▓
# ░░░░░░░░░░
#
#█▓▒░
# ------------------------------------------------------------------------------
# Ubuntu-specific Configuration
# ------------------------------------------------------------------------------

# Exit if not running on Linux
[[ "$(uname)" != "Linux" ]] && return 0

# ------------------------------------------------------------------------------
# System Update Aliases
# ------------------------------------------------------------------------------
# Update and upgrade system packages
alias apt_update='sudo apt-get update && \
                sudo apt-get -y upgrade && \
                echo "✅ System updated successfully"'

# Clean up system packages
alias apt_clean='sudo apt-get clean && \
                sudo apt-get autoclean && \
                sudo apt-get autoremove && \
                echo "✅ System cleaned successfully"'

# Combined update and cleanup
alias apt_maintain='apt_update && apt_clean'

# update linux homebrew and its packages
alias update_brew='brew update && brew upgrade && brew cleanup' # Only Homebrew updates

# ------------------------------------------------------------------------------
# Package Management
# ------------------------------------------------------------------------------
# Search for package
alias apt_search='apt-cache search'

# Show package info
alias apt_info='apt-cache show'

# List installed packages
alias apt_list='dpkg --list'

# ------------------------------------------------------------------------------
# System Information
# ------------------------------------------------------------------------------
# Show system information
system_info() {
    echo "System Information:"
    echo "------------------"
    echo "OS: $(lsb_release -ds)"
    echo "Kernel: $(uname -r)"
    echo "Memory: $(free -h | awk '/^Mem:/ {print $3 "/" $2}')"
    echo "Disk Usage: $(df -h / | awk 'NR==2 {print $5 " (" $3 "/" $2 ")"}')"
    echo "CPU Load: $(uptime | awk -F'load average:' '{print $2}')"
}
