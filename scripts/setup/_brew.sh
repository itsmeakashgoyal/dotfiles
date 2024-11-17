#!/usr/bin/env bash

#################################################
#      File: _brew.sh                           #
#      Author: Akash Goyal                      #
#      Status: Development                      #
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

# ------------------------------------------------------------------------------
# Homebrew Functions
# ------------------------------------------------------------------------------
update_brew() {
    if ! command_exists brew; then
        return 1
    fi

    print_message "$YELLOW" "Updating Homebrew..."
    brew update
    brew upgrade
    [[ "$OS_TYPE" = "Darwin" ]] && brew upgrade --cask
    brew cleanup
}

install_homebrew() {
    # Install Homebrew if it isn't already installed
    if command_exists brew; then
        print_message "$GREEN" "Homebrew is already installed"
    else
        print_message "$YELLOW" "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        check_command "Homebrew installation"

        # Configure Homebrew PATH
        case "$OS_TYPE" in
            "Darwin")
                if [[ -x "/opt/homebrew/bin/brew" ]]; then
                    print_message "$YELLOW" "Configuring Homebrew in PATH for Apple Silicon Mac..."
                    eval "$(/opt/homebrew/bin/brew shellenv)"  # Apple Silicon
                elif [[ -x "/usr/local/bin/brew" ]]; then
                    print_message "$YELLOW" "Configuring Homebrew in PATH for Intel Mac..."
                    eval "$(/usr/local/bin/brew shellenv)"     # Intel Mac
                fi
                ;;
            "Linux")
                print_message "$YELLOW" "Configuring Homebrew in PATH for Linux..."
                eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
                ;;
        esac
    fi

    # Verify installation
    if ! command -v brew &>/dev/null; then
        print_message "$RED" "Failed to configure Homebrew in PATH"
        return 1
    fi

    # Turn off analytics
    brew analytics off

    # Update Homebrew and Upgrade any already-installed formulae
    print_message "$YELLOW" "Updating Homebrew and upgrading formulae..."
    update_brew
}

install_packages() {
    print_message "$YELLOW" "Installing packages from Brewfile..."
    local brewfile="${DOTFILES_DIR}/Brewfile"

    if [[ ! -f "$brewfile" ]]; then
        print_message "$RED" "Error: Brewfile not found at $brewfile"
        return 1
    fi

    brew bundle --file="$brewfile"
    check_command "Brewfile installation"
}

# ------------------------------------------------------------------------------
# Oh My Zsh Setup
# ------------------------------------------------------------------------------
setup_oh_my_zsh() {
    print_message "$YELLOW" "Installing Oh My Zsh..."

    # Remove existing installation
    rm -rf ~/.oh-my-zsh

    # Install Oh My Zsh
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

    # Install plugins
    print_message "$YELLOW" "Installing Oh My Zsh plugins..."
    git clone https://github.com/romkatv/powerlevel10k.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
    git clone https://github.com/zsh-users/zsh-autosuggestions "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions"
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting"
    git clone https://github.com/Aloxaf/fzf-tab "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/fzf-tab"
    git clone https://github.com/jeffreytse/zsh-vi-mode "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-vi-mode"
    git clone https://github.com/marlonrichert/zsh-autocomplete.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autocomplete"

    # Set Zsh as default shell
    print_message "$YELLOW" "Set Zsh as default shell..."
    command -v zsh | sudo tee -a /etc/shells
    sudo chsh -s "$(command -v zsh)" "$USER"
}

# ------------------------------------------------------------------------------
# FZF Installation
# ------------------------------------------------------------------------------
install_fzf() {
    if command_exists fzf; then
        print_message "$YELLOW" "Fzf already installed"
        return 0
    fi
    
    print_message "$YELLOW" "Installing fzf.."
    git clone --depth 1 https://github.com/junegunn/fzf.git ~/.config/.fzf
    ~/.config/.fzf/install
}

# Set the error trap
trap 'print_error "$LINENO" "$BASH_COMMAND" "$?"' ERR

# ------------------------------------------------------------------------------
# Main Function
# ------------------------------------------------------------------------------
main() {
    log_message "Starting Homebrew setup"

    setup_oh_my_zsh
    install_homebrew
    install_packages
    install_fzf
    update_brew

    print_message "$GREEN" "Homebrew setup completed successfully"
    log_message "Homebrew setup completed"
}

# Set error trap
trap 'print_error "$LINENO" "$BASH_COMMAND" "$?"' ERR

# Run main
main
