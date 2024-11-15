#!/usr/bin/env bash

#################################################
#      File: _linuxOS.sh                        #
#      Author: Akash Goyal                      #
#      Status: Development                      #
#################################################
# This script creates symlinks from the home directory to any desired dotfiles in $HOME/dotfiles
# This is used to setup both macOS and LinuxOS.
# And also installs MacOS and Linux packages.
# And also installs Homebrew Packages and Casks (Apps)
# And also sets up Sublime Text
#################################################

# ------------------------------
#          INITIALIZE
# ------------------------------
# Load Helper functions persistently
SCRIPT_DIR="${HOME}/dotfiles/scripts"
HELPER_FILE="${SCRIPT_DIR}/utils/_helper.sh"
# Check if helper file exists and source it
if [[ ! -f "$HELPER_FILE" ]]; then
    echo "Error: Helper file not found at $HELPER_FILE" >&2
    exit 1
fi

# Source the helper file
source "$HELPER_FILE"

# Enable strict mode for better error handling
set -euo pipefail

# Set CI environment variable if not already set
export CI="${CI:-}"

initGitSubmodules() {
    log_message "→ Initializing and updating git submodules..."
    git submodule update --init --recursive --remote
}

setupDotfiles() {
    if [ "$OS_TYPE" = "Darwin" ]; then
        log_message "------> Setting up MACOS"
        log_message "→ Running MacOS-specific setup script..."
        # scripts=("_macOS" "_brew" "_sublime")
        scripts=("_brew")
        for script in "${scripts[@]}"; do
            script_path="./scripts/setup/${script}.sh"
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
        log_message "------> Setting up LINUX"
        # Run the setup script for the current OS
        log_message "→ Running LinuxOS-specific setup script..."
        scripts=("_linuxOS" "_brew")
        for script in "${scripts[@]}"; do
            script_path="./scripts/setup/${script}.sh"
            if [ -f "${script_path}" ]; then
                echo "Running ${script_path} script..."
                if ! "${script_path}"; then
                    echo "Error: ${script} script failed. Continuing..."
                fi
            else
                echo "Warning: ${script_path} not found. Skipping..."
            fi
        done
    fi
}

setupNvim() {
    # Change to the .config/nvim directory and checkout the running branch
    log_message "→ Changing to the ${CONFIG_DIR}/nvim directory"
    cd "${CONFIG_DIR}/nvim" || {
        log_message "Failed to change directory to ${CONFIG_DIR}/nvim"
        exit 1
    }
    BRANCH_NAME="akgoyal/nvim"
    git checkout "${BRANCH_NAME}"
}

setupNix() {
    if [ "$OS_TYPE" = "Linux" ]; then
        log_message "→ Running nix installer..."
        if [ -f "${DOTFILES_DIR}/scripts/utils/_install_nix.sh" ]; then
            sh "${DOTFILES_DIR}/scripts/utils/_install_nix.sh"
        else
            log_message "→ Warning: _install_nix.sh setup script not found."
        fi
    fi
}

# Set the error trap
trap 'print_error "$LINENO" "$BASH_COMMAND" "$?"' ERR

# Main function
main() {
    log_message "Script started"
    print_message "$BLUE" "
You're running ${OS_TYPE}.
##############################################
#      We will begin applying updates,       #
#      and securing the system.              #
##############################################
#      You will be prompted for your         #
#      sudo password.                        #
##############################################
"

    if [ "$OS_TYPE" = "Darwin" ]; then
        print_message "$GREEN" "
##############################################
#      MacOS system detected.                #
#      Proceeding with setup...              #
##############################################
"
        log_message "MacOS system detected. Proceeding with setup."
    else
        print_message "$GREEN" "
##############################################
#      Ubuntu-based system detected.         #
#      Proceeding with setup...              #
##############################################
"
        log_message "Ubuntu-based system detected. Proceeding with setup."
    fi

    initGitSubmodules

    # initiate symlink
    symlink "zsh/.zshenv" ".zshenv"
    symlink "nvim" ".config/nvim"
    symlink "tmux" ".config/tmux"

    setupDotfiles
    setupNvim

    print_message "$GREEN" "
##############################################
#      Installation Completed                #
##############################################
"
    log_message "Installation Completed!"

    print_message "$GREEN" "
############################################################################
#      At last, do source your zsh configuration using 'exec zsh'          #
############################################################################
"
}

# Run the main function
main
