#!/usr/bin/env bash

#################################################
#      File: install.sh                         #
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
PACKAGES_FILE="${SCRIPT_DIR}/setup/packages.sh"
# Check if helper and packages file exists and source it
if [[ ! -f "$HELPER_FILE" && ! -f "$PACKAGES_FILE" ]]; then
    echo "Error: Helper files not found" >&2
    exit 1
fi

# Source the helper and packages file
source "$HELPER_FILE"
source "$PACKAGES_FILE"

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
        "macos")
            [ "$OS_TYPE" = "Darwin" ] && run_script "_macOS" && run_script "_sublime" || error "Not on macOS"
            ;;
        "linux")
            [ "$OS_TYPE" = "Linux" ] && run_script "_linuxOS" || error "Not on Linux"
            ;;
        "sublime")
            run_script "_sublime"
            ;;
        *)
            error "Unknown target: $target"
            show_targets
            return 1
            ;;
        esac
    done
}

# Set the error trap
trap 'print_error "$LINENO" "$BASH_COMMAND" "$?"' ERR

# Main function
main() {
    log_message "Script started"
    info "
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
        success "
##############################################
#      MacOS system detected.                #
#      Proceeding with setup...              #
##############################################
"
        log_message "MacOS system detected. Proceeding with setup."
    else
        success "
##############################################
#      Ubuntu-based system detected.         #
#      Proceeding with setup...              #
##############################################
"
        log_message "Ubuntu-based system detected. Proceeding with setup."
    fi

    # check for required commands
    check_required_commands

    # Confirmation prompt
    warning "This will install & configure dotfiles on your system. It may overwrite existing files."
    read -p "Are you sure you want to proceed? (y/n) " confirm
    if [[ "$confirm" != "y" ]]; then
        error "${RED}Installation aborted."
        exit 0
    fi

    # Check for sudo password and keep alive
    if sudo --validate; then
        sudo_keep_alive &
        SUDO_PID=$!
        trap 'kill "$SUDO_PID"' EXIT
        substep_info "Sudo password saved. Continuing with script."
    else
        substep_error "Incorrect sudo password. Exiting script."
        exit 1
    fi

    # update and fetch git submodules latest updates
    initGitSubmodules

    # install homebrew and packages
    sh ${DOTFILES_DIR}/packages/install.sh

    # Install Stow packages
    declare -a stow_dirs=("dots" "nvim" "config" "ohmyposh")
    for dir in "${stow_dirs[@]}"; do
      stow "$dir"
    done

    # installing oh-my-zsh and its packages
    install_oh_my_zsh

    # Check if zsh is installed and set it as the default shell if desired
    if command -v zsh &>/dev/null; then
      if ! grep -q "$(command -v fish)" /etc/shells; then
        substep_info "Adding zsh to available shells..."
        sudo sh -c "echo $(command -v zsh) >> /etc/shells"
      fi
      read -p "Do you want to set zsh as your default shell? (y/N): " -n 1 -r
      echo # Move to a new line
      if [[ $REPLY =~ ^[Yy]$ ]]; then
        chsh -s "$(command -v zsh)"
      fi
    fi

    # installing fzf
    install_fzf

    ## Now proceed with OS specific setup installations
    if [ "$OS_TYPE" = "Darwin" ]; then
        setupDotfiles "macos"
    elif [ "$OS_TYPE" = "Linux" ]; then
        setupDotfiles "linux"
    fi

    success "
##############################################
#      Installation Completed                #
##############################################
"
    log_message "Installation Completed!"

    success "
############################################################################
#      At last, do source your zsh configuration using 'exec zsh'          #
############################################################################
"
}

# Run the main function
main "$@"