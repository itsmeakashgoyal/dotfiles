#!/bin/bash
#  ▓▓▓▓▓▓▓▓▓▓
# ░▓ author ▓ Akash Goyal
# ░▓ file   ▓ packages/install.sh
# ░▓▓▓▓▓▓▓▓▓▓
# ░░░░░░░░░░

# ------------------------------------------------------------------------------
# Simple Package Installation Script
# Installs Homebrew and all packages from Brewfile
# ------------------------------------------------------------------------------

set -euo pipefail

# Load shared library
DOTFILES_DIR="${DOTFILES_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
export DOTFILES_DIR
CORE="${DOTFILES_DIR}/scripts/lib/core.sh"
if [[ ! -f "$CORE" ]]; then
    echo "Error: core library not found at $CORE" >&2
    exit 1
fi
source "$CORE"

# ------------------------------------------------------------------------------
# Configuration
# ------------------------------------------------------------------------------
readonly PACKAGES_DIR="${DOTFILES_DIR}/packages"
readonly BREWFILE="${PACKAGES_DIR}/Brewfile"

# ------------------------------------------------------------------------------
# Homebrew Functions
#
# macOS only: install.sh's OS branch only ever invokes this script when
# os::is_mac is true (Linux goes through scripts/setup/nix.sh instead, which
# uses Nix/Home Manager — linuxbrew is not used anywhere in this repo).
# ------------------------------------------------------------------------------
install_homebrew() {
    if command_exists brew; then
        success "Homebrew is already installed"
        return 0
    fi

    info "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # Configure Homebrew PATH (install script runs in a subshell and does not modify this shell's PATH)
    if [[ -x "/opt/homebrew/bin/brew" ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [[ -x "/usr/local/bin/brew" ]]; then
        eval "$(/usr/local/bin/brew shellenv)"
    fi

    # Verify installation
    if ! command_exists brew; then
        error "Failed to configure Homebrew in PATH"
        return 1
    fi

    # Turn off analytics
    brew analytics off
    success "Homebrew installed successfully"
}

update_brew() {
    if ! command_exists brew; then
        return 1
    fi

    info "Updating Homebrew..."
    brew update
    brew upgrade
    brew upgrade --cask || true
    brew cleanup
    success "Homebrew updated"
}

install_brewfile_packages() {
    if [[ ! -f "$BREWFILE" ]]; then
        error "Brewfile not found at $BREWFILE"
        return 1
    fi

    info "Installing packages from Brewfile..."
    brew bundle --file="$BREWFILE"
    success "All packages installed from Brewfile"
}

# ------------------------------------------------------------------------------
# Main Function
# ------------------------------------------------------------------------------
main() {
    info "
##############################################
#      Package Installation                  #
##############################################
"

    # Install Homebrew
    install_homebrew || exit 1

    # Update Homebrew
    update_brew

    # Install all packages from Brewfile
    install_brewfile_packages || exit 1

    # Final cleanup
    update_brew

    success "
###################################################
#     Package Installation Completed!             #
###################################################
"
    
    info "Verifying package installation..."
    echo ""
    
    if bash "${DOTFILES_DIR}/scripts/verify/check.sh" --packages; then
        success "✓ All packages verified successfully!"
    else
        warning "Some packages may be missing - see details above"
        echo ""
        echo "To install missing packages, run:"
        echo "  brew bundle --file=${BREWFILE}"
    fi
    
    log_message "Package installation completed successfully"
}

# Set error trap
trap 'print_error "$LINENO" "$BASH_COMMAND" "$?"' ERR

# Run main
main
