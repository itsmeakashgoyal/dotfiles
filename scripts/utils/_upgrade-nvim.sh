#!/usr/bin/env bash

#################################################
#      File: _upgrade-nvim.sh                    #
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
NVIM_APPIMAGE_URL="https://github.com/neovim/neovim/releases/latest/download/nvim.appimage"
NVIM_INSTALL_PATH="/usr/local/bin/nvim"
TEMP_APPIMAGE="/tmp/nvim.appimage"

# ------------------------------------------------------------------------------
# Backup Function
# ------------------------------------------------------------------------------
backup_existing_nvim() {
    if [[ -f "$NVIM_INSTALL_PATH" ]]; then
        print_message "$YELLOW" "Backing up existing Neovim..."
        sudo mv "$NVIM_INSTALL_PATH" "${NVIM_INSTALL_PATH}.backup"
        log_message "Backed up existing Neovim to ${NVIM_INSTALL_PATH}.backup"
    fi
}

# ------------------------------------------------------------------------------
# Download Function
# ------------------------------------------------------------------------------
download_nvim() {
    print_message "$YELLOW" "Downloading latest Neovim AppImage..."
    if ! curl -L "$NVIM_APPIMAGE_URL" -o "$TEMP_APPIMAGE"; then
        print_message "$RED" "Failed to download Neovim AppImage"
        return 1
    fi
    log_message "Downloaded Neovim AppImage successfully"
}

# ------------------------------------------------------------------------------
# Install Function
# ------------------------------------------------------------------------------
install_nvim() {
    print_message "$YELLOW" "Installing Neovim..."

    # Make AppImage executable
    if ! sudo chmod u+x "$TEMP_APPIMAGE"; then
        print_message "$RED" "Failed to make AppImage executable"
        return 1
    fi

    # Move to installation directory
    if ! sudo mv "$TEMP_APPIMAGE" "$NVIM_INSTALL_PATH"; then
        print_message "$RED" "Failed to install Neovim"
        return 1
    fi

    print_message "$GREEN" "Neovim upgrade completed successfully"
    log_message "Neovim upgrade completed"
}

# ------------------------------------------------------------------------------
# Cleanup Function
# ------------------------------------------------------------------------------
cleanup() {
    # Remove temporary files if they exist
    rm -f "$TEMP_APPIMAGE" 2>/dev/null || true
}

# ------------------------------------------------------------------------------
# Main Function
# ------------------------------------------------------------------------------
main() {
    log_message "Starting Neovim upgrade"

    backup_existing_nvim
    download_nvim
    install_nvim
    cleanup

    # Verify installation
    if command -v nvim >/dev/null 2>&1; then
        print_message "$GREEN" "Neovim $(nvim --version | head -n1) installed successfully"
    else
        print_message "$RED" "Neovim installation verification failed"
        return 1
    fi
}

# Set error trap
trap 'print_error "$LINENO" "$BASH_COMMAND" "$?"' ERR
trap cleanup EXIT

# Run main
main
