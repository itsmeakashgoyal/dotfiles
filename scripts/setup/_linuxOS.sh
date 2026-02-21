#!/usr/bin/env bash
#                    █████
#                   ░░███
#   █████   ██████  ███████   █████ ████ ████████
#  ███░░   ███░░███░░░███░   ░░███ ░███ ░░███░░███
# ░░█████ ░███████   ░███     ░███ ░███  ░███ ░███
#  ░░░░███░███░░░    ░███ ███ ░███ ░███  ░███ ░███
#  ██████ ░░██████   ░░█████  ░░████████ ░███████
# ░░░░░░   ░░░░░░     ░░░░░    ░░░░░░░░  ░███░░░
#                                        ░███
#                                        █████
#                                       ░░░░░
#
#  ▓▓▓▓▓▓▓▓▓▓
# ░▓ author ▓ Akash Goyal
# ░▓ file   ▓ scripts/setup/_linuxOS.sh
# ░▓▓▓▓▓▓▓▓▓▓
# ░░░░░░░░░░

# ------------------------------------------------------------------------------
# Linux System Setup Script
# Installs essential packages and tools for Ubuntu/Debian-based systems
# ------------------------------------------------------------------------------

# Load helper functions
SCRIPT_DIR="${HOME}/dotfiles/scripts"
HELPER_FILE="${SCRIPT_DIR}/utils/_helper.sh"

if [[ ! -f "$HELPER_FILE" ]]; then
    echo "Error: Helper file not found at $HELPER_FILE" >&2
    exit 1
fi

source "$HELPER_FILE"
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

    # Core development and utility packages
    # Only including essential, universally available packages
    local packages=(
        # Build tools
        build-essential
        
        # Essential utilities
        curl
        wget
        unzip
        
        # Development tools
        vim
        tmux
        git
        stow
        
        # Shell tools
        shellcheck
        fd-find
        
        # Miscellaneous
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
# Tool Installation Functions
# ------------------------------------------------------------------------------
install_eza() {
    if command_exists eza; then
        info "eza already installed"
        return 0
    fi

    info "Installing eza..."
    sudo apt-get install -y gpg
    sudo mkdir -p /etc/apt/keyrings
    
    wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | \
        sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
    
    echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | \
        sudo tee /etc/apt/sources.list.d/gierens.list
    
    sudo chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list
    sudo apt-get update
    sudo apt-get install -y eza
    
    success "eza installed successfully"
}

install_cargo() {
    if command_exists cargo; then
        info "Cargo already installed"
        return 0
    fi

    info "Installing Rust and Cargo..."
    sudo apt-get install -y cargo
    success "Cargo installed successfully"
}

install_zoxide() {
    if command_exists zoxide; then
        info "Zoxide already installed"
        return 0
    fi

    info "Installing zoxide..."
    if curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh; then
        success "Zoxide installed successfully"
    else
        error "Zoxide installation failed"
        return 1
    fi
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

    # Run installation steps
    update_and_install
    install_eza
    install_cargo
    install_zoxide
    cleanup

    success "
###################################################
#     Linux Setup Completed Successfully!         #
###################################################
"
    log_message "Linux setup completed successfully"
}

# Set error trap
trap 'print_error "$LINENO" "$BASH_COMMAND" "$?"' ERR

# Run main
main
