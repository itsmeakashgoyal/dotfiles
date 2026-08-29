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
# ------------------------------------------------------------------------------
install_homebrew_prereqs_linux() {
    [[ "$OS_TYPE" == "Linux" ]] || return 0

    if ! command_exists apt-get; then
        warning "apt-get not found; skipping Homebrew prerequisites install"
        return 0
    fi

    if ! command_exists sudo; then
        warning "sudo not found; cannot install Homebrew prerequisites automatically"
        return 0
    fi

    info "Installing Homebrew prerequisites (Ubuntu/Debian)..."
    sudo apt-get update
    sudo apt-get install -y build-essential procps curl file git
    success "Homebrew prerequisites installed"
}

install_homebrew() {
    if command_exists brew; then
        success "Homebrew is already installed"
        return 0
    fi

    install_homebrew_prereqs_linux

    info "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # Configure Homebrew PATH (install script runs in a subshell and does not modify this shell's PATH)
    case "$OS_TYPE" in
    "Darwin")
        if [[ -x "/opt/homebrew/bin/brew" ]]; then
            eval "$(/opt/homebrew/bin/brew shellenv)"
        elif [[ -x "/usr/local/bin/brew" ]]; then
            eval "$(/usr/local/bin/brew shellenv)"
        fi
        ;;
    "Linux")
        eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
        ;;
    esac

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
    [[ "$OS_TYPE" == "Darwin" ]] && brew upgrade --cask || true
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

# Install television on Linux via .deb (Homebrew may not have it on Linux)
install_television_linux() {
    [[ "$OS_TYPE" == "Linux" ]] || return 0
    command_exists tv && { success "television is already installed"; return 0; }

    info "Installing television (tv) from GitHub releases..."
    local ver
    ver=$(curl -s "https://api.github.com/repos/alexpasmantier/television/releases/latest" \
        | grep '"tag_name":' | sed -E 's/.*"tag_name": "([^"]+)".*/\1/')

    if [[ -z "$ver" ]]; then
        warning "Could not determine latest television version"
        return 1
    fi

    local deb="tv-${ver}-x86_64-unknown-linux-musl.deb"
    curl -LO "https://github.com/alexpasmantier/television/releases/download/${ver}/${deb}"
    sudo dpkg -i "$deb"
    rm -f "$deb"
    success "television ${ver} installed"
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

    # Install television on Linux (may not be in Homebrew)
    install_television_linux

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
