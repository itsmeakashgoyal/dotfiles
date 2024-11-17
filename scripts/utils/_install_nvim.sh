#!/usr/bin/env bash

#################################################
#      File: _install_nvim.sh                    #
#      Author: Akash Goyal                       #
#      Status: Development                       #
#################################################

# ------------------------------------------------------------------------------
# Initialization
# ------------------------------------------------------------------------------
SCRIPT_DIR="${HOME}/dotfiles/scripts"
HELPER_FILE="${SCRIPT_DIR}/utils/_helper.sh"

# Source helper functions
if [[ ! -f "$HELPER_FILE" ]]; then
    echo "Error: Helper file not found at $HELPER_FILE" >&2
    exit 1
fi
source "$HELPER_FILE"

# Enable strict mode
set -eu pipefail
IFS=$'\n\t'

# ------------------------------------------------------------------------------
# Constants
# ------------------------------------------------------------------------------
BACKUP_DIR="${HOME}/linuxtoolbox/backup/nvim"
NVIM_DIRS=(
    "${HOME}/.config/nvim"
    "${HOME}/.local/share/nvim"
    "${HOME}/.cache/nvim"
)
NVIM_DOWNLOAD_URL="https://github.com/neovim/neovim/releases/latest/download/nvim-linux64.tar.gz"
NVIM_INSTALL_DIR="/opt/nvim"

# ------------------------------------------------------------------------------
# Backup Function
# ------------------------------------------------------------------------------
backup_nvim_config() {
    print_message "$YELLOW" "Backing up existing Neovim configuration..."

    # Create backup directory
    mkdir -p "$BACKUP_DIR"

    # Backup existing directories
    for dir in "${NVIM_DIRS[@]}"; do
        if [[ -d "$dir" ]]; then
            local backup_name=$(basename "$dir")
            cp -r "$dir" "${BACKUP_DIR}/${backup_name}"
            log_message "Backed up ${dir} to ${BACKUP_DIR}/${backup_name}"
        fi
    done
}

# ------------------------------------------------------------------------------
# Cleanup Function
# ------------------------------------------------------------------------------
cleanup_nvim() {
    print_message "$YELLOW" "Cleaning up existing Neovim installation..."

    # Remove existing directories
    for dir in "${NVIM_DIRS[@]}"; do
        rm -rf "$dir"
        log_message "Removed ${dir}"
    done

    # Remove existing installation
    sudo rm -rf "$NVIM_INSTALL_DIR"
}

# ------------------------------------------------------------------------------
# Install Function
# ------------------------------------------------------------------------------
install_nvim() {
    print_message "$YELLOW" "Installing Neovim..."

    # Download latest Neovim
    if ! curl -LO "$NVIM_DOWNLOAD_URL"; then
        print_message "$RED" "Failed to download Neovim"
        return 1
    fi

    # Install Neovim
    if ! sudo tar -C /opt -xzf nvim-linux64.tar.gz; then
        print_message "$RED" "Failed to extract Neovim"
        return 1
    fi

    # Cleanup downloaded file
    rm nvim-linux64.tar.gz

    print_message "$GREEN" "Neovim installation completed successfully"
    log_message "Neovim installation completed"
}

# ------------------------------------------------------------------------------
# Main Function
# ------------------------------------------------------------------------------
main() {
    log_message "Starting Neovim installation"

    backup_nvim_config
    cleanup_nvim
    install_nvim
}

# Set error trap
trap 'print_error "$LINENO" "$BASH_COMMAND" "$?"' ERR

# Run main
main
