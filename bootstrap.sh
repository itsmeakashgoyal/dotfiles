#!/usr/bin/env bash
#  █████                        █████             █████
# ░░███                        ░░███             ░░███
#  ░███████   ██████   ██████  ███████    █████  ███████   ████████   ██████   ████████
#  ░███░░███ ███░░███ ███░░███░░░███░    ███░░  ░░░███░   ░░███░░███ ░░░░░███ ░░███░░███
#  ░███ ░███░███ ░███░███ ░███  ░███    ░░█████   ░███     ░███ ░░░   ███████  ░███ ░███
#  ░███ ░███░███ ░███░███ ░███  ░███ ███ ░░░░███  ░███ ███ ░███      ███░░███  ░███ ░███
#  ████████ ░░██████ ░░██████   ░░█████  ██████   ░░█████  █████    ░░████████ ░███████
# ░░░░░░░░   ░░░░░░   ░░░░░░     ░░░░░  ░░░░░░     ░░░░░  ░░░░░      ░░░░░░░░  ░███░░░
#                                                                              ░███
#                                                                              █████
#                                                                             ░░░░░
#
#  ▓▓▓▓▓▓▓▓▓▓
# ░▓ author ▓ Akash Goyal
# ░▓ file   ▓ bootstrap.sh
# ░▓▓▓▓▓▓▓▓▓▓
# ░░░░░░░░░░
#
#█▓▒░
# Bootstrap script to download and install dotfiles from GitHub

set -euo pipefail

# ------------------------------------------------------------------------------
# Configuration
# ------------------------------------------------------------------------------
readonly SOURCE="https://github.com/itsmeakashgoyal/dotfiles"
readonly TARGET="$HOME/dotfiles"

# Color codes for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m' # No Color

# ------------------------------------------------------------------------------
# Helper Functions
# ------------------------------------------------------------------------------
info() {
    echo -e "${BLUE}INFO:${NC} $*"
}

success() {
    echo -e "${GREEN}SUCCESS:${NC} $*"
}

error() {
    echo -e "${RED}ERROR:${NC} $*" >&2
}

warning() {
    echo -e "${YELLOW}WARNING:${NC} $*"
}

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# ------------------------------------------------------------------------------
# Download Functions
# ------------------------------------------------------------------------------
download_with_git() {
    info "Downloading dotfiles with git..."
    git clone "$SOURCE" "$TARGET"
}

download_with_curl() {
    info "Downloading dotfiles with curl..."
    mkdir -p "$TARGET"
    curl -fsSL "$SOURCE/tarball/master" | tar -xz -C "$TARGET" --strip-components=1
}

download_with_wget() {
    info "Downloading dotfiles with wget..."
    mkdir -p "$TARGET"
    wget -qO- "$SOURCE/tarball/master" | tar -xz -C "$TARGET" --strip-components=1
}

download_dotfiles() {
    if command_exists git; then
        download_with_git
    elif command_exists curl; then
        download_with_curl
    elif command_exists wget; then
        download_with_wget
    else
        error "No download tool available (git, curl, or wget)"
        error "Please install one of these tools and try again."
        return 1
    fi
}

# ------------------------------------------------------------------------------
# Main Function
# ------------------------------------------------------------------------------
main() {
    echo ""
    info "Dotfiles Bootstrap Script"
    echo ""

    # Check if dotfiles already exist
    if [[ -d "$TARGET" ]]; then
        warning "Dotfiles directory already exists at: $TARGET"
        read -p "Do you want to remove it and re-download? [y/N] " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            info "Removing existing dotfiles..."
            rm -rf "$TARGET"
        else
            info "Keeping existing dotfiles. Skipping download."
            if [[ ! -f "$TARGET/install.sh" ]]; then
                error "install.sh not found in existing dotfiles directory"
                exit 1
            fi
            # Skip to installation
            read -p "Do you want to run the installation? [y/N] " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                info "Running install script..."
                bash "$TARGET/install.sh"
                exit 0
            else
                info "Installation skipped."
                exit 0
            fi
        fi
    fi

    # Download dotfiles
    if ! download_dotfiles; then
        error "Failed to download dotfiles"
        exit 1
    fi

    success "Dotfiles downloaded successfully!"

    # Verify install script exists
    if [[ ! -f "$TARGET/install.sh" ]]; then
        error "install.sh not found in the dotfiles repository"
        exit 1
    fi

    # Prompt for installation
    echo ""
    read -p "Do you want to continue with the installation? [y/N] " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        info "Running install script..."
        bash "$TARGET/install.sh"
        success "Bootstrap complete!"
    else
        warning "Installation skipped."
        info "You can run the installation later with: bash $TARGET/install.sh"
    fi
}

# Run main function
main
