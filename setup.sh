#!/usr/bin/env zsh
############################
# This script creates symlinks from the home directory to any desired dotfiles in $HOME/dotfiles
# And also installs MacOS Software
# And also installs Homebrew Packages and Casks (Apps)
# And also sets up Sublime Text
############################

# Enable strict mode for better error handling
set -euo pipefail

# Function to log messages
log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1"
}

# Define variables
DOTFILES_DIR="${HOME}/dotfiles"
CONFIG_DIR="${HOME}/.config"

# This detection only works for mac and linux.
OS_TYPE=$(uname)
if [ "$OS_TYPE" = "Darwin" ]; then
    log "------> Setting up MACOS"
    log "→ Running MacOS-specific setup script..."
    scripts=("_macOS" "_brew" "_sublime")
    for script in "${scripts[@]}"; do
        script_path="./scripts/${script}.sh"
        if [ -f "${script_path}" ]; then
            echo "Running ${script_path} script..."
            if ! "${script_path}"; then
                echo "Error: ${script} script failed. Continuing..."
            fi
        else
            echo "Warning: ${script_path} not found. Skipping..."
        fi
    done
elif [ "$OS_TYPE" = "Linux" ]; then
    log "------> Setting up LINUX"
    # Run the setup script for the current OS
    log "→ Running LinuxOS-specific setup script..."
    if [ -f "${DOTFILES_DIR}/scripts/_linuxOS.sh" ]; then
        sh "${DOTFILES_DIR}/scripts/_linuxOS.sh"
    else
        log "→ Warning: OS-specific setup script not found."
    fi
fi

log "→ Initiating symlink process..."
if [ -f "${DOTFILES_DIR}/scripts/_symlink.sh" ]; then
    sh "${DOTFILES_DIR}/scripts/_symlink.sh"
else
    log "→ Warning: _symlink.sh setup script not found."
fi

# Change to the .config/nvim directory and checkout the running branch
log "→ Changing to the ${CONFIG_DIR}/nvim directory"
cd "${CONFIG_DIR}/nvim" || {
    log "Failed to change directory to ${CONFIG_DIR}/nvim"
    exit 1
}
# Skip branch checkout in CI environment
if [ -z "$CI" ]; then
    BRANCH_NAME="akgoyal/nvim"
    git checkout "${BRANCH_NAME}"
fi

if [ "$OS_TYPE" = "Linux" ]; then
    log "→ Running nix installer..."
    if [ -f "${DOTFILES_DIR}/scripts/_install_nix.sh" ]; then
        sh "${DOTFILES_DIR}/scripts/_install_nix.sh"
    else
        log "→ Warning: _install_nix.sh setup script not found."
    fi
fi

log "→ Source Zsh configuration"
exec zsh

log "→ Installation Complete!"
