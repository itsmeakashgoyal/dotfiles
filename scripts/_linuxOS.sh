#!/usr/bin/env bash

# Enable strict mode
set -eu pipefail
IFS=$'\n\t'

RC='\033[0m'
RED='\033[31m'
YELLOW='\033[33m'
GREEN='\033[32m'

# Get current user
user=$(whoami)

# Define log file
LOG="/tmp/setup_log.txt"

# Define variables
DOTFILES_DIR="${HOME}/dotfiles"
CONFIG_DIR="${HOME}/.config"

# Function to log and display process steps
process() {
    echo "$(date) PROCESSING:  $@" >>"$LOG"
    printf "$(tput setaf 6) [STEP ${STEP:-0}] %s...$(tput sgr0)\n" "$@"
    STEP=$((STEP + 1))
}

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

installDepend() {
    echo "${YELLOW}Installing dependencies...${RC}"
    sudo apt install -y build-essential libc++-15-dev clang-format-15 libkrb5-dev procps file git zsh vim-gtk python3-setuptools tmux locate libgraph-easy-perl stow cowsay fd-find curl ripgrep wget fontconfig xclip python3-venv python3-pip luarocks shellcheck nodejs npm
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

    echo "${YELLOW}Set Zsh as default shell...${RC}"
    command -v zsh | sudo tee -a /etc/shells
    sudo chsh -s "$(command -v zsh)" "$USER"
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

installEzaAndExa() {
    if command_exists exa; then
        echo "exa already installed"
    else
        echo "${YELLOW}Installing exa..${RC}"
        EXA_VERSION=$(curl -s "https://api.github.com/repos/ogham/exa/releases/latest" | grep -Po '"tag_name": "v\K[0-9.]+')
        curl -Lo exa.zip "https://github.com/ogham/exa/releases/latest/download/exa-linux-x86_64-v${EXA_VERSION}.zip"
        sudo unzip -q exa.zip bin/exa -d /usr/local
        rm exa.zip
    fi

    if command_exists eza; then
        echo "eza already installed"
    else
        echo "${YELLOW}Installing eza..${RC}"
        sudo apt install -y gpg
        sudo mkdir -p /etc/apt/keyrings
        wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
        echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | sudo tee /etc/apt/sources.list.d/gierens.list
        sudo chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list
        sudo apt update
        sudo apt install -y eza
    fi
}

installAntidote() {
    if command_exists antidote; then
        echo "antidote already installed"
    else
        echo "${YELLOW}Installing antidote..${RC}"
        git clone --depth=1 https://github.com/mattmc3/antidote.git "${ZDOTDIR:-$HOME}/.antidote"
    fi
}

installLatestGo() {
    if command_exists go; then
        echo "go already installed"
    else
        echo "${YELLOW}Installing go..${RC}"
        GO_VERSION="1.23.0" # Update this version as needed
        curl -LO "https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz"
        sudo rm -rf /usr/local/go && sudo tar -C /usr/local -xzf "go${GO_VERSION}.linux-amd64.tar.gz"
        rm "go${GO_VERSION}.linux-amd64.tar.gz"
    fi
}

installCargoPackageManager() {
    if command_exists cargo; then
        echo "cargo already installed"
    else
        echo "${YELLOW}Installing cargo package manager..${RC}"
        sudo apt install -y cargo
        cargo install just onefetch
    fi
}

installNvim() {
    if command_exists nvim; then
        echo "nvim already installed"
    else
        echo "${YELLOW}Installing nvim..${RC}"
        sh ~/dotfiles/scripts/_install_nvim.sh
    fi
}

installZoxide() {
    if command_exists zoxide; then
        echo "Zoxide already installed"
        return
    fi

    if ! curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh; then
        echo "${RED}Something went wrong during zoxide install!${RC}"
        exit 1
    fi
}

echo "${YELLOW}Bootstrap steps start here...\n${RC}"

# Dont run system upgrade on CI environment
if [ -z "$CI" ]; then
    # Update and upgrade system
    sudo apt-get update
    sudo apt-get -y upgrade
fi

installDepend
setupOhMyZsh
installFzf
installEzaAndExa
installAntidote
installLatestGo
installCargoPackageManager
installNvim
installZoxide

echo "${GREEN}Installation Completed...${RC}"
