#!/usr/bin/env bash

#################################################
#      File: setup.sh                        #
#      Author: Akash Goyal                      #
#      Status: Development                      #
#################################################
# This script creates symlinks from the home directory to any desired dotfiles in $HOME/dotfiles
# It sets up both macOS and Linux configurations.
# Install necessary pacakges for both MacOS and Linux.
# Configures Sublime Text
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

# Initialize Git submodules
initGitSubmodules() {
    log_message "→ Initializing and updating git submodules..."
    git submodule update --init --recursive --remote
}

# Show available setup targets
show_targets() {
    echo "Available targets:"
    echo "  all      - Install everything"
    echo "  macos    - Setup macOS specific configurations"
    echo "  linux    - Setup Linux specific configurations"
    echo "  brew     - Install Homebrew and packages"
    echo "  sublime  - Setup Sublime Text configuration"
}

# Setup dotfiles based on specified targets
setupDotfiles() {
    local targets=("$@")

    # If no targets specified, show help
    if [ ${#targets[@]} -eq 0 ]; then
        show_targets
        return 1
    fi

    for target in "${targets[@]}"; do
        case "$target" in
        "all")
            if [ "$OS_TYPE" = "Darwin" ]; then
                run_script "_brew"
                # Uncomment if you have a macOS and Sublime setup script
                # run_script "_macOS"
                # run_script "_sublime"
            elif [ "$OS_TYPE" = "Linux" ]; then
                run_script "_linuxOS"
                run_script "_brew"
            fi
            ;;
        "macos")
            [ "$OS_TYPE" = "Darwin" ] && run_script "_brew" || print_message "$RED" "Not on macOS"
            ;;
        "linux")
            [ "$OS_TYPE" = "Linux" ] && run_script "_linuxOS" && run_script "_brew" || print_message "$RED" "Not on Linux"
            ;;
        "brew")
            run_script "_brew"
            ;;
        "sublime")
            run_script "_sublime"
            ;;
        *)
            print_message "$RED" "Unknown target: $target"
            show_targets
            return 1
            ;;
        esac
    done
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

    # Backup and initiate symlinks
    backup_existing_files "zsh/.zshenv" ".zshenv"
    symlink "zsh/.zshenv" ".zshenv"
    
    backup_existing_files "nvim" ".config/nvim"
    symlink "nvim" ".config/nvim"
    
    backup_existing_files "tmux" ".config/tmux"
    symlink "tmux" ".config/tmux"

    if [ $# -eq 0 ]; then
        setupDotfiles "all"
    else
        setupDotfiles "$@"
    fi

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
main "$@"
