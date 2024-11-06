#!/usr/bin/env bash

# Enable strict mode for better error handling
set -euo pipefail

RC='\033[0m'
RED='\033[31m'
YELLOW='\033[33m'
GREEN='\033[32m'

# Define variables
DOTFILES_DIR="${HOME}/dotfiles"

# This detection only works for mac and linux.
OS_TYPE=$(uname)

# Function to check if a command was successful
check_command() {
    if [ $? -ne 0 ]; then
        echo "${RED}Error: $1 failed${RC}" >&2
        exit 1
    fi
}

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

brewUpdateAndCleanup() {
    if command_exists brew; then
        brew update
        brew upgrade
        brew upgrade --cask
        brew cleanup
    fi
}

installingHomebrewAndPackages() {
    # Install Homebrew if it isn't already installed
    if command_exists brew; then
        echo "${YELLOW}Homebrew is already installed.${RC}"
    else
        echo "${YELLOW}Homebrew not installed. Installing Homebrew.${RC}"
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        check_command "Homebrew installation"

        # Attempt to set up Homebrew PATH automatically for this session
        if [ "$OS_TYPE" = "Darwin" ]; then
            if [ -x "/opt/homebrew/bin/brew" ]; then
                # For Apple Silicon Macs
                echo "${YELLOW}Configuring Homebrew in PATH for Apple Silicon Mac...${RC}"
                eval "$(/opt/homebrew/bin/brew shellenv)"
            elif [ -x "/usr/local/bin/brew" ]; then
                # For Intel Macs
                echo "${YELLOW}Configuring Homebrew in PATH for Intel Mac...${RC}"
                eval "$(/usr/local/bin/brew shellenv)"
            fi
        else
            echo "${YELLOW}Configuring Homebrew in PATH for Linux...${RC}"
            eval "$(${HOME}/linuxbrew/.linuxbrew/bin/brew shellenv)"
        fi
    fi

    # Verify brew is now accessible
    if ! command -v brew &>/dev/null; then
        echo "${RED}Failed to configure Homebrew in PATH. Please add Homebrew to your PATH manually.${RC}"
        exit 1
    fi

    # Turn off analytics
    brew analytics off

    # Update Homebrew and Upgrade any already-installed formulae
    echo "${YELLOW}Updating Homebrew and upgrading formulae...${RC}"
    brewUpdateAndCleanup

    # Install packages from Brewfile
    echo "${YELLOW}Installing packages from Brewfile...${RC}"
    local brewfile=""
    case "$(uname)" in
    "Linux") brewfile="Brewfile.linux" ;;
    "Darwin") brewfile="Brewfile.mac" ;;
    *)
        echo "Unsupported OS"
        exit 1
        ;;
    esac

    if [ -f "${DOTFILES_DIR}/${brewfile}" ]; then
        brew bundle --file="${DOTFILES_DIR}/${brewfile}"
    else
        echo "Warning: ${brewfile} not found"
    fi

    check_command "Brewfile installation"

    # Add the Homebrew zsh to allowed shells
    echo "${YELLOW}Adding Homebrew zsh to allowed shells...${RC}"
    BREW_ZSH="$(brew --prefix)/bin/zsh"
    if ! grep -q "$BREW_ZSH" /etc/shells; then
        echo "$BREW_ZSH" | sudo tee -a /etc/shells >/dev/null
        check_command "Adding Homebrew zsh to /etc/shells"
    fi

    # Set the Homebrew zsh as default shell
    echo "${YELLOW}Changing default shell to Homebrew zsh...${RC}"
    if [ -z "$CI" ]; then
        chsh -s "$BREW_ZSH"
        check_command "Changing default shell"
    else
        export SHELL="$BREW_ZSH"
    fi
}

setupOhMyZsh() {
    echo "${YELLOW}Installing Oh My Zsh...${RC}"
    rm -rf ~/.oh-my-zsh
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

    echo "${YELLOW}Installing Oh My Zsh plugins...${RC}"
    git clone https://github.com/romkatv/powerlevel10k.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
    git clone https://github.com/zsh-users/zsh-autosuggestions "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions"
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting"
    git clone https://github.com/Aloxaf/fzf-tab "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/fzf-tab"
    git clone https://github.com/jeffreytse/zsh-vi-mode "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-vi-mode"
    git clone https://github.com/marlonrichert/zsh-autocomplete.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autocomplete"
}

installFzf() {
    if command_exists fzf; then
        echo "Fzf already installed"
    else
        echo "${YELLOW}Installing fzf..${RC}"
        git clone --depth 1 https://github.com/junegunn/fzf.git ~/.config/.fzf
        ~/.config/.fzf/install
    fi
}

installPrettier() {
    echo "${YELLOW}Installing Prettier...${RC}"
    npm install --global prettier
    check_command "Prettier installation"
}

installingHomebrewAndPackages
setupOhMyZsh
installFzf
installPrettier
echo "${YELLOW}Final homebrew update and cleanup...${RC}"
brewUpdateAndCleanup

echo "${GREEN}Installation setup complete!${RC}"
