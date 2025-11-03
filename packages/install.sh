#!/bin/bash
#  ▓▓▓▓▓▓▓▓▓▓
# ░▓ author ▓ Akash Goyal
# ░▓ file   ▓ packages/install.sh
# ░▓▓▓▓▓▓▓▓▓▓
# ░░░░░░░░░░

# ------------------------------------------------------------------------------
# Package Installation Script
# Installs Homebrew and packages from Brewfile
# Optionally installs language-specific packages (Node, Python, Ruby, Rust)
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

# Language package files
readonly NODE_PACKAGES="${PACKAGES_DIR}/node_packages.txt"
readonly PNPM_PACKAGES="${PACKAGES_DIR}/pnpm_packages.txt"
readonly PYTHON_PACKAGES="${PACKAGES_DIR}/pipx_packages.txt"
readonly RUBY_PACKAGES="${PACKAGES_DIR}/ruby_packages.txt"
readonly RUST_PACKAGES="${PACKAGES_DIR}/rust_packages.txt"

# Installation flags (set to 1 to enable)
INSTALL_NODE="${INSTALL_NODE:-0}"
INSTALL_PYTHON="${INSTALL_PYTHON:-0}"
INSTALL_RUBY="${INSTALL_RUBY:-0}"
INSTALL_RUST="${INSTALL_RUST:-0}"

# ------------------------------------------------------------------------------
# Homebrew Functions
# ------------------------------------------------------------------------------
install_homebrew() {
    if command_exists brew; then
        success "Homebrew is already installed"
        return 0
    fi

    info "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    check_command "Homebrew installation"

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
    [[ "$OS_TYPE" == "Darwin" ]] && brew upgrade --cask
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
    success "Brewfile packages installed"
}

# ------------------------------------------------------------------------------
# Language-Specific Package Managers (Optional)
# ------------------------------------------------------------------------------
install_node_packages() {
    [[ "$INSTALL_NODE" != "1" ]] && return 0

    info "Setting up Node.js environment..."

    # Install/verify Node (should be in Brewfile)
    if ! command_exists node; then
        warning "Node.js not found. Install it via: brew install node"
        return 1
    fi

    # Enable corepack for pnpm/yarn
    if command_exists corepack; then
        info "Enabling corepack..."
        corepack enable
        
        # Setup pnpm if not already configured
        if command_exists pnpm; then
            info "Setting up pnpm..."
            pnpm setup 2>/dev/null || true
            
            # Add pnpm to PATH for current session
            export PNPM_HOME="${HOME}/.local/share/pnpm"
            export PATH="${PNPM_HOME}:${PATH}"
        fi
    fi

    # Install pnpm packages if file exists
    if [[ -f "$PNPM_PACKAGES" ]]; then
        # Verify pnpm is available and configured
        if ! command_exists pnpm; then
            warning "pnpm not found. Packages will be installed via npm instead."
            # Fall back to npm for these packages
            if [[ -f "$NODE_PACKAGES" ]]; then
                while IFS= read -r package; do
                    [[ -z "$package" || "$package" =~ ^# ]] && continue
                    if ! npm list -g "$package" &>/dev/null; then
                        npm install -g "$package" || warning "Failed to install: $package"
                    fi
                done < "$PNPM_PACKAGES"
            fi
        else
            info "Installing pnpm packages..."
            while IFS= read -r package; do
                [[ -z "$package" || "$package" =~ ^# ]] && continue
                
                # Check if already installed globally
                if pnpm list -g 2>/dev/null | grep -q "$package"; then
                    substep_info "✓ $package already installed (skipping)"
                else
                    pnpm add -g "$package" 2>/dev/null || warning "Failed to install: $package"
                fi
            done < "$PNPM_PACKAGES"
            success "pnpm packages checked/installed"
        fi
    fi

    # Install npm packages if file exists
    if [[ -f "$NODE_PACKAGES" ]]; then
        info "Installing npm packages..."
        while IFS= read -r package; do
            [[ -z "$package" || "$package" =~ ^# ]] && continue
            
            # Check if already installed globally
            if npm list -g "$package" &>/dev/null; then
                substep_info "✓ $package already installed (skipping)"
            else
                npm install -g "$package" || warning "Failed to install: $package"
            fi
        done < "$NODE_PACKAGES"
        success "npm packages checked/installed"
    fi
}

install_python_packages() {
    [[ "$INSTALL_PYTHON" != "1" ]] && return 0

    info "Setting up Python environment..."

    # Verify Python (should be in Brewfile)
    if ! command_exists python3; then
        warning "Python 3 not found. Install it via: brew install python3"
        return 1
    fi

    # Verify pipx (should be in Brewfile)
    if ! command_exists pipx; then
        warning "pipx not found. Install it via: brew install pipx"
        return 1
    fi

    # Install packages with pipx
    if [[ -f "$PYTHON_PACKAGES" ]]; then
        info "Installing Python packages with pipx..."
        while IFS= read -r package; do
            [[ -z "$package" || "$package" =~ ^# ]] && continue
            
            # Extract package name (handle "package[extras]" format)
            local pkg_name="${package%%\[*}"
            
            # Check if already installed
            if pipx list 2>/dev/null | grep -q "package $pkg_name"; then
                substep_info "✓ $pkg_name already installed (skipping)"
            else
                pipx install "$package" 2>/dev/null || warning "Failed to install: $package"
            fi
        done < "$PYTHON_PACKAGES"
        success "Python packages checked/installed"
    fi
}

install_ruby_packages() {
    [[ "$INSTALL_RUBY" != "1" ]] && return 0

    info "Setting up Ruby environment..."

    # Verify rbenv (should be in Brewfile for macOS)
    if ! command_exists rbenv; then
        warning "rbenv not found. Install it via: brew install rbenv ruby-build"
        return 1
    fi

    # Install Ruby 3.1.3 if not present
    if ! rbenv versions | grep -q "3.1.3"; then
        info "Installing Ruby 3.1.3..."
        rbenv install 3.1.3
        rbenv global 3.1.3
        rbenv rehash
    fi

    # Install gems
    if [[ -f "$RUBY_PACKAGES" ]]; then
        info "Installing Ruby gems..."
        eval "$(rbenv init - zsh)"
        while IFS= read -r package; do
            [[ -z "$package" || "$package" =~ ^# ]] && continue
            
            # Check if already installed
            if gem list -i "^${package}$" &>/dev/null; then
                substep_info "✓ $package already installed (skipping)"
            else
                gem install "$package" || warning "Failed to install: $package"
            fi
        done < "$RUBY_PACKAGES"
        success "Ruby gems checked/installed"
    fi
}

install_rust_packages() {
    [[ "$INSTALL_RUST" != "1" ]] && return 0

    info "Setting up Rust environment..."

    # Verify Rust (should be in Brewfile for macOS)
    if ! command_exists cargo; then
        warning "Rust not found. Install it via: brew install rust"
        return 1
    fi

    # Update Rust
    rustup update stable || true

    # Install Rust packages
    if [[ -f "$RUST_PACKAGES" ]]; then
        info "Installing Rust packages..."
        while IFS= read -r package; do
            [[ -z "$package" || "$package" =~ ^# ]] && continue
            
            # Check if already installed
            if cargo install --list 2>/dev/null | grep -q "^${package} "; then
                substep_info "✓ $package already installed (skipping)"
            else
                cargo install "$package" || warning "Failed to install: $package"
            fi
        done < "$RUST_PACKAGES"
        success "Rust packages checked/installed"
    fi
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

    # Install Brewfile packages (core packages)
    install_brewfile_packages || exit 1

    # Optional: Install language-specific packages
    install_node_packages
    install_python_packages
    install_ruby_packages
    install_rust_packages

    # Final cleanup
    update_brew

    success "
###################################################
#     Package Installation Completed!             #
###################################################
"
    log_message "Package installation completed successfully"
}

# Set error trap
trap 'print_error "$LINENO" "$BASH_COMMAND" "$?"' ERR

# Run main
main
