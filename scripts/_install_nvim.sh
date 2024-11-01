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

if [ ! -d "$LINUXTOOLBOXDIR" ]; then
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

log "→ Installation of Neovim complete"
