#!/usr/bin/env bash

# Enable strict mode
set -eu pipefail
IFS=$'\n\t'

# Get current user
user=$(whoami)

# Define log file
LOG="/tmp/setup_log.txt"

# Define variables
DOTFILES_DIR="${HOME}/dotfiles-dev"
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

# Set TERM variable for non-interactive environments
if [ -n "$CI" ]; then
    export TERM=${TERM:-xterm}
fi

process "→ Bootstrap steps start here:\n------------------"

# Update and upgrade system
sudo apt-get update
sudo apt-get -y upgrade

process "→ Install git"
sudo apt install -y git

process "→ Setup git config"
# Skip setting github in CI environment
if [ -z "$CI" ]; then
    sh ${DOTFILES_DIR}/scripts/_git_config.sh
    check_command "Git config setup"
fi

process "→ Install essential packages"
sudo apt install -y vim-gtk python3-setuptools tmux locate libgraph-easy-perl stow cowsay fd-find curl ripgrep wget curl fontconfig xclip python3-venv luarocks shellcheck

process "→ Install pip"
sudo apt install -y python3-pip

process "→ Install Zsh and Oh My Zsh"
sudo apt install -y zsh
rm -rf ~/.oh-my-zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

process "→ Install Oh My Zsh plugins"
git clone https://github.com/romkatv/powerlevel10k.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
git clone https://github.com/zsh-users/zsh-autosuggestions "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions"
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting"
git clone https://github.com/Aloxaf/fzf-tab "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/fzf-tab"
git clone https://github.com/jeffreytse/zsh-vi-mode "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-vi-mode"
git clone https://github.com/marlonrichert/zsh-autocomplete.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autocomplete"

process "→ Set Zsh as default shell"
command -v zsh | sudo tee -a /etc/shells
sudo chsh -s "$(command -v zsh)" "$USER"

process "→ Install fzf"
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install --all

process "→ Install exa"
EXA_VERSION=$(curl -s "https://api.github.com/repos/ogham/exa/releases/latest" | grep -Po '"tag_name": "v\K[0-9.]+')
curl -Lo exa.zip "https://github.com/ogham/exa/releases/latest/download/exa-linux-x86_64-v${EXA_VERSION}.zip"
sudo unzip -q exa.zip bin/exa -d /usr/local
rm exa.zip

process "→ Install eza"
sudo apt install -y gpg
sudo mkdir -p /etc/apt/keyrings
wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | sudo tee /etc/apt/sources.list.d/gierens.list
sudo chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list
sudo apt update
sudo apt install -y eza

process "→ Install antidote"
git clone --depth=1 https://github.com/mattmc3/antidote.git "${ZDOTDIR:-$HOME}/.antidote"

# TODO: Uncomment this once testing completes
# process "→ Install development tools and package managers"
# sudo apt install -y cargo
# cargo install just onefetch

# process "→ Install Node.js and npm"
# sudo apt install -y nodejs npm

process "→ Install Go"
GO_VERSION="1.23.0" # Update this version as needed
curl -LO "https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz"
sudo rm -rf /usr/local/go && sudo tar -C /usr/local -xzf "go${GO_VERSION}.linux-amd64.tar.gz"
rm "go${GO_VERSION}.linux-amd64.tar.gz"

process "→ Install neovim"
sh ~/dotfiles-dev/scripts/_install_nvim.sh

process "→ Install Nix package manager"
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix >nix-installer.sh
chmod +x nix-installer.sh

# Setting --no-confirm option in CI environment to install nix
if [ -n "$CI" ]; then
    ./nix-installer.sh install --no-confirm
else
    ./nix-installer.sh install
fi
rm nix-installer.sh

# Source Nix environment script if installation succeeded
if [ -f "/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh" ]; then
    . "/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh"
else
    process "Nix environment script not found. Exiting."
    exit 1
fi

process "→ Installation complete"
