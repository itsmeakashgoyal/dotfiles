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

# Load helper functions
SCRIPT_DIR="${HOME}/dotfiles/scripts"
HELPER_FILE="${SCRIPT_DIR}/utils/_helper.sh"

if [[ ! -f "$HELPER_FILE" ]]; then
    echo "Error: Helper file not found at $HELPER_FILE" >&2
    exit 1
fi

source "$HELPER_FILE"

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
    # Verify brew exists (the install script may not modify PATH for this shell)
    check_command brew

    # Configure Homebrew PATH
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
    
    if bash "${DOTFILES_DIR}/scripts/verification/check_packages.sh"; then
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
