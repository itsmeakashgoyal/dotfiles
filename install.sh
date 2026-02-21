#!/bin/bash
#   ███                      █████              ████  ████
#  ░░░                      ░░███              ░░███ ░░███
#  ████  ████████    █████  ███████    ██████   ░███  ░███
# ░░███ ░░███░░███  ███░░  ░░░███░    ░░░░░███  ░███  ░███
#  ░███  ░███ ░███ ░░█████   ░███      ███████  ░███  ░███
#  ░███  ░███ ░███  ░░░░███  ░███ ███ ███░░███  ░███  ░███
#  █████ ████ █████ ██████   ░░█████ ░░████████ █████ █████
# ░░░░░ ░░░░ ░░░░░ ░░░░░░     ░░░░░   ░░░░░░░░ ░░░░░ ░░░░░
#
#  ▓▓▓▓▓▓▓▓▓▓
# ░▓ author ▓ Akash Goyal
# ░▓ file   ▓ install.sh
# ░▓▓▓▓▓▓▓▓▓▓
# ░░░░░░░░░░
#
#█▓▒░
# Install packages, run OS-specific setup, and stow dotfiles.
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
    echo "  iterm    - Setup iTerm2 preferences"
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
            if [ "$OS_TYPE" != "Darwin" ]; then
                error "Not on macOS - cannot run macOS setup"
                return 1
            fi
            run_script "_macOS"
            run_script "_sublime"
            run_script "_iterm"
            ;;
        "linux")
            if [ "$OS_TYPE" != "Linux" ]; then
                error "Not on Linux - cannot run Linux setup"
                return 1
            fi
            run_script "_linuxOS"
            ;;
        "sublime")
            run_script "_sublime"
            ;;
        "iterm")
            run_script "_iterm"
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

    # Confirmation prompt (skip in CI)
    if [ -n "$CI" ]; then
        info "Running in CI mode - skipping confirmation prompt"
    else
        warning "This will install & configure dotfiles on your system. It may overwrite existing files."
        read -p "Are you sure you want to proceed? (y/n) " confirm
        if [[ "$confirm" != "y" ]]; then
            error "Installation aborted."
            exit 0
        fi
    fi

    if [ -z "$CI" ]; then
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
    fi

    # Install all packages from Homebrew
    info "Installing packages from Homebrew..."
    bash ${DOTFILES_DIR}/packages/install.sh

    # Check if zsh is installed and set it as the default shell if desired
    info "Set Zsh as default shell..."
    if command -v zsh &>/dev/null; then
        if ! grep -q "$(command -v zsh)" /etc/shells; then
            substep_info "Adding zsh to available shells..."
            sudo sh -c "echo $(command -v zsh) >> /etc/shells"
        fi
        sudo chsh -s "$(command -v zsh)" "$USER"
    fi

    ## Now proceed with OS specific setup installations
    if [ "$OS_TYPE" = "Darwin" ]; then
        setupDotfiles "macos"
    elif [ "$OS_TYPE" = "Linux" ]; then
        setupDotfiles "linux"
    fi

    # Clean up old manual symlinks before stowing
    info "Cleaning up old symlinks..."
    for old_link in "$HOME/.zshenv" "$HOME/.config/nvim" "$HOME/.config/tmux" "$HOME/.config/git" "$HOME/.config/zsh" "$HOME/.config/ohmyposh"; do
        if [ -L "$old_link" ]; then
            rm "$old_link"
            substep_info "Removed old symlink: $old_link"
        fi
    done

    # Stow all dotfile packages
    info "Stowing dotfile packages..."
    for pkg in git zsh nvim tmux ohmyposh; do
        substep_info "Stowing $pkg..."
        stow --restow --dir="${DOTFILES_DIR}" --target="$HOME" "$pkg"
    done
    success "All packages stowed successfully."

    ### Hostname
    ###########################################################
    if [ -x "$(command -v figlet)" ]; then
        if [ -x "$(command -v lolcat)" ]; then
            figlet $(hostname) | lolcat -f
        else
            figlet $(hostname)
        fi
    else
        echo "$(hostname)"
    fi

    log_message "Installation Completed!"

    info "Running post-installation verification..."
    echo ""
    
    if bash "${DOTFILES_DIR}/scripts/verification/health_check.sh"; then
        success "✓ Installation verified successfully!"
    else
        warning "Some verification checks failed - review output above"
    fi

    success "
################################################################################################
#      Installation complete! Run 'exec zsh' to start using your new configuration            #
################################################################################################
"
}

# Run the main function
main "$@"
