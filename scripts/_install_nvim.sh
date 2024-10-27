#!/usr/bin/env bash

# Enable strict mode
set -eu pipefail
IFS=$'\n\t'

# Function to log and display process steps
log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1"
}

RC='\033[0m'
RED='\033[31m'
YELLOW='\033[33m'
GREEN='\033[32m'

# Check if the home directory and linuxtoolbox folder exist, create them if they don't
LINUXTOOLBOXDIR="$HOME/linuxtoolbox"

if [[ ! -d "$LINUXTOOLBOXDIR" ]]; then
    echo -e "${YELLOW}Creating linuxtoolbox directory: $LINUXTOOLBOXDIR${RC}"
    mkdir -p "$LINUXTOOLBOXDIR"
    echo -e "${GREEN}linuxtoolbox directory created: $LINUXTOOLBOXDIR${RC}"
fi

# Backup existing neovim config and install new one
mkdir -p "$LINUXTOOLBOXDIR/backup/nvim"
[ -d ~/.config/nvim ] && cp -r ~/.config/nvim "$LINUXTOOLBOXDIR/backup/nvim/config"
[ -d ~/.local/share/nvim ] && cp -r ~/.local/share/nvim "$LINUXTOOLBOXDIR/backup/nvim/local_share"
[ -d ~/.cache/nvim ] && cp -r ~/.cache/nvim "$LINUXTOOLBOXDIR/backup/nvim/cache"
rm -rf ~/.config/nvim ~/.local/share/nvim ~/.cache/nvim

log "→ Installing Neovim"
curl -LO "https://github.com/neovim/neovim/releases/latest/download/nvim-linux64.tar.gz"
sudo rm -rf /opt/nvim
sudo tar -C /opt -xzf nvim-linux64.tar.gz
rm nvim-linux64.tar.gz

# Share system clipboard with unnamedplus
if [ -f /etc/os-release ]; then
    . /etc/os-release
    # Determine if Wayland or Xorg is being used
    if [[ $XDG_SESSION_TYPE == "wayland" ]]; then
        CLIPBOARD_PKG="wl-clipboard"
    else
        CLIPBOARD_PKG="xclip"
    fi

    case "${ID_LIKE:-$ID}" in
    debian | ubuntu)
        sudo apt install ripgrep fd-find $CLIPBOARD_PKG python3-venv luarocks golang-go shellcheck -y
        ;;
    fedora)
        sudo dnf install ripgrep fzf $CLIPBOARD_PKG neovim python3-virtualenv luarocks golang ShellCheck -y
        ;;
    arch | manjaro)
        sudo pacman -S ripgrep fzf $CLIPBOARD_PKG neovim python-virtualenv luarocks go shellcheck --noconfirm
        ;;
    opensuse)
        sudo zypper install ripgrep fzf $CLIPBOARD_PKG neovim python3-virtualenv luarocks go ShellCheck -y
        ;;
    *)
        echo -e "${YELLOW}Unsupported OS. Please install the following packages manually:${RC}"
        echo "ripgrep, fzf, $CLIPBOARD_PKG, neovim, python3-virtualenv (or equivalent), luarocks, go, shellcheck"
        ;;
    esac
else
    echo -e "${RED}Unable to determine OS. Please install required packages manually.${RC}"
fi

log "→ Installation of Neovim complete"
