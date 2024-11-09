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

brewUpdateAndCleanup() {
    if command_exists brew; then
        brew update
        brew upgrade
        if [ "$OS_TYPE" = "Darwin" ]; then
            brew upgrade --cask
        fi
        brew cleanup
    fi
}

installingHomebrewAndPackages() {
    # Install Homebrew if it isn't already installed
    if command_exists brew; then
        print_message "$GREEN" "Homebrew is already installed"
    else
        print_message "$YELLOW" "Homebrew not installed. Installing Homebrew."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        check_command "Homebrew installation"

        # Attempt to set up Homebrew PATH automatically for this session
        if [ "$OS_TYPE" = "Darwin" ]; then
            if [ -x "/opt/homebrew/bin/brew" ]; then
                # For Apple Silicon Macs
                print_message "$YELLOW" "Configuring Homebrew in PATH for Apple Silicon Mac..."
                eval "$(/opt/homebrew/bin/brew shellenv)"
            elif [ -x "/usr/local/bin/brew" ]; then
                # For Intel Macs
                print_message "$YELLOW" "Configuring Homebrew in PATH for Intel Mac..."
                eval "$(/usr/local/bin/brew shellenv)"
            fi
        else
            print_message "$YELLOW" "Configuring Homebrew in PATH for Linux..."
            eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
        fi
    fi

    # Verify brew is now accessible
    if ! command -v brew &>/dev/null; then
        print_message "$RED" "Failed to configure Homebrew in PATH. Please add Homebrew to your PATH manually."
        exit 1
    fi

    # Turn off analytics
    brew analytics off

    # Update Homebrew and Upgrade any already-installed formulae
    print_message "$YELLOW" "Updating Homebrew and upgrading formulae..."
    brewUpdateAndCleanup

    # Install packages from Brewfile
    print_message "$YELLOW" "Installing packages from Brewfile..."
    local brewfile=""
    case "$(uname)" in
    "Linux") brewfile="Brewfile.linux" ;;
    "Darwin") brewfile="Brewfile.mac" ;;
    *)
        print_message "$RED" "Unsupported OS"
        exit 1
        ;;
    esac

    if [ -f "${DOTFILES_DIR}/${brewfile}" ]; then
        brew bundle --file="${DOTFILES_DIR}/${brewfile}"
    else
        print_message "$RED" "Warning: ${brewfile} not found"
    fi

    check_command "Brewfile installation"
}

setupOhMyZsh() {
    print_message "$YELLOW" "Installing Oh My Zsh..."
    rm -rf ~/.oh-my-zsh
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

    print_message "$YELLOW" "Installing Oh My Zsh plugins..."
    git clone https://github.com/romkatv/powerlevel10k.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
    git clone https://github.com/zsh-users/zsh-autosuggestions "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions"
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting"
    git clone https://github.com/Aloxaf/fzf-tab "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/fzf-tab"
    git clone https://github.com/jeffreytse/zsh-vi-mode "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-vi-mode"
    git clone https://github.com/marlonrichert/zsh-autocomplete.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autocomplete"

    print_message "$YELLOW" "Set Zsh as default shell..."
    command -v zsh | sudo tee -a /etc/shells
    sudo chsh -s "$(command -v zsh)" "$USER"
}

installFzf() {
    if command_exists fzf; then
        print_message "$YELLOW" "Fzf already installed"
    else
        print_message "$YELLOW" "Installing fzf.."
        git clone --depth 1 https://github.com/junegunn/fzf.git ~/.config/.fzf
        ~/.config/.fzf/install
    fi
}

# Set the error trap
trap 'print_error "$LINENO" "$BASH_COMMAND" "$?"' ERR

# Main function
main() {
    setupOhMyZsh
    installingHomebrewAndPackages
    installFzf
    brewUpdateAndCleanup

    print_message "$GREEN" "
##############################################
#      Installation Completed for _brew.sh   #
##############################################
"
    log_message "Installation Completed. Proceeding with other steps"
}

# Run the main function
main
