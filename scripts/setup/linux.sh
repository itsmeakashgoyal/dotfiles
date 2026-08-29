#!/usr/bin/env bash
#
#  ▓▓▓▓▓▓▓▓▓▓
# ░▓ author ▓ Akash Goyal
# ░▓ file   ▓ scripts/setup/linux.sh
# ░▓▓▓▓▓▓▓▓▓▓
#
# ------------------------------------------------------------------------------
# Linux System Setup Script
#
# Installs ONLY system-level apt dependencies for Ubuntu/Debian.
# CLI tools (eza, bat, fd, zoxide, ripgrep, neovim, …) come from Nix +
# Home Manager instead — see nix/ and scripts/setup/nix.sh. No Homebrew or
# linuxbrew anywhere on Linux.
# ------------------------------------------------------------------------------

# Load helper functions
DOTFILES_DIR="${DOTFILES_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"
export DOTFILES_DIR
SCRIPT_DIR="${DOTFILES_DIR}/scripts"
CORE_FILE="${SCRIPT_DIR}/lib/core.sh"

if [[ ! -f "$CORE_FILE" ]]; then
    echo "Error: Core library not found at $CORE_FILE" >&2
    exit 1
fi

source "$CORE_FILE"
set -euo pipefail

# ------------------------------------------------------------------------------
# Configuration
# ------------------------------------------------------------------------------
readonly OS_NAME=$(grep ^NAME /etc/os-release 2>/dev/null | cut -d '"' -f 2 || echo "Unknown Linux")

# ------------------------------------------------------------------------------
# System Detection
# ------------------------------------------------------------------------------
check_ubuntu() {
    if [[ -f /etc/os-release ]]; then
        . /etc/os-release
        [[ "$ID" == "ubuntu" || "$ID_LIKE" == *"ubuntu"* ]] && return 0
    elif [[ -f /etc/lsb-release ]]; then
        . /etc/lsb-release
        [[ "$DISTRIB_ID" == "Ubuntu" ]] && return 0
    fi
    return 1
}

# ------------------------------------------------------------------------------
# Package Management
# ------------------------------------------------------------------------------
update_and_install() {
    info "
##############################################
#   System Update & Package Installation     #
##############################################
"
    log_message "Starting system update and package installation"

    # Skip update in CI environments
    if [[ -z "${CI:-}" ]]; then
        sudo apt-get update
        sudo apt-get -y upgrade
    fi

    # System-level packages only. Everything else is provided by Nix.
    # These are the deps needed to install Nix, run Stow, and use zsh.
    local packages=(
        # Build tools + Nix installer prerequisites
        build-essential
        ca-certificates
        curl
        wget
        xz-utils
        file
        procps

        # Core system tools
        git
        stow
        zsh
        unzip
        fontconfig
    )

    # Optional packages (install if available, don't fail if not)
    local optional_packages=(
        figlet
        lolcat
        entr
        strace
    )

    # Install essential packages
    sudo apt-get -y install "${packages[@]}"
    success "Essential packages installed"
    
    # Install optional packages (ignore failures)
    for pkg in "${optional_packages[@]}"; do
        if sudo apt-get -y install "$pkg" 2>/dev/null; then
            info "✓ Installed optional package: $pkg"
        else
            warning "⊘ Skipped unavailable package: $pkg"
        fi
    done
    
    success "Package installation complete"
    log_message "Completed system update and package installation"
}

cleanup() {
    info "
##############################################
#         Cleanup & Optimization             #
##############################################
"
    log_message "Starting cleanup process"
    
    sudo apt-get -y autoclean
    sudo apt-get -y autoremove
    sudo apt-get -y clean
    
    success "Cleanup completed!"
    log_message "Cleanup completed"
}

# ------------------------------------------------------------------------------
# Main Function
# ------------------------------------------------------------------------------
main() {
    log_message "Linux setup script started"
    
    info "
##############################################
#        Linux System Setup                  #
#        OS: ${OS_NAME}                      #
##############################################
#  You will be prompted for your sudo        #
#  password to install packages.             #
##############################################
"

    # Verify this is an Ubuntu-based system
    if ! check_ubuntu; then
        error "
##############################################
#  This script is for Ubuntu-based systems  #
#  Detected: ${OS_NAME}                     #
#  Exiting...                               #
##############################################
"
        log_message "Non-Ubuntu system detected. Script execution aborted."
        exit 1
    fi

    success "Ubuntu-based system detected. Proceeding with setup..."
    log_message "Ubuntu-based system confirmed"

    # Run installation steps (system deps only — CLI tools come from Nix)
    update_and_install
    cleanup

    success "
###################################################
#     Linux System Deps Installed!                #
#     CLI tools are managed by Nix (see nix/).     #
###################################################
"
    log_message "Linux setup completed successfully"
}

# Set error trap
trap 'print_error "$LINENO" "$BASH_COMMAND" "$?"' ERR

# Run main
main
