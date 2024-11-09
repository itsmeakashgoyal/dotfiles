#!/usr/bin/env bash

#################################################
#      File: _install_nix.sh                    #
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

# Enable strict mode
set -eu pipefail
IFS=$'\n\t'

# Set the error trap
trap 'print_error "$LINENO" "$BASH_COMMAND" "$?"' ERR

# Check if the home directory and linuxtoolbox folder exist, create them if they don't
LINUXTOOLBOXDIR="$HOME/linuxtoolbox"

if [ ! -d "$LINUXTOOLBOXDIR" ]; then
    print_message "$YELLOW" "→ Creating linuxtoolbox directory: $LINUXTOOLBOXDIR"
    mkdir -p "$LINUXTOOLBOXDIR"
    print_message "$GREEN" "→ linuxtoolbox directory created: $LINUXTOOLBOXDIR"
fi

# Backup existing neovim config and install new one
mkdir -p "$LINUXTOOLBOXDIR/backup/nvim"
[ -d ~/.config/nvim ] && cp -r ~/.config/nvim "$LINUXTOOLBOXDIR/backup/nvim/config"
[ -d ~/.local/share/nvim ] && cp -r ~/.local/share/nvim "$LINUXTOOLBOXDIR/backup/nvim/local_share"
[ -d ~/.cache/nvim ] && cp -r ~/.cache/nvim "$LINUXTOOLBOXDIR/backup/nvim/cache"
rm -rf ~/.config/nvim ~/.local/share/nvim ~/.cache/nvim

print_message "$YELLOW" "→ Installing Neovim"
curl -LO "https://github.com/neovim/neovim/releases/latest/download/nvim-linux64.tar.gz"
sudo rm -rf /opt/nvim
sudo tar -C /opt -xzf nvim-linux64.tar.gz
rm nvim-linux64.tar.gz

print_message "$YELLOW" "→ Installation of Neovim complete"
