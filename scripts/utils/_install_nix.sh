#!/usr/bin/env bash

# Enable strict mode for better error handling
set -eu pipefail
IFS=$'\n\t'

# Function to log messages
log() {
	echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1"
}

# Define variables
DOTFILES_DIR="${HOME}/dotfiles"
CONFIG_DIR="${HOME}/.config"

log "→ Install Nix package manager"
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix >nix-installer.sh
chmod +x nix-installer.sh

# Setting --no-confirm option in CI environment to install nix
if [ -z "$CI" ]; then
	./nix-installer.sh install
else
	./nix-installer.sh install --no-confirm
fi
rm nix-installer.sh

# Source Nix environment script if installation succeeded
. "/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh"

log "→ Copy nix folder into CONFIG_DIR dir"
cp -rf "${DOTFILES_DIR}/nix" "${CONFIG_DIR}"

log "→ Installing Nix packages"
# Change to the .config/nix directory
# Define CONFIG_DIR if not set
CONFIG_DIR="${CONFIG_DIR:-$HOME/.config}"
log "→ Changing to the ${CONFIG_DIR}/nvim directory"
cd "${CONFIG_DIR}/nix" || {
	log "Failed to change directory to ${CONFIG_DIR}/nix"
	exit 1
}

# Restart nix-daemon to apply changes
sudo systemctl restart nix-daemon.service

if [ -z "$CI" ]; then
	# Install Home Manager if not installed
	# if ! command -v home-manager &>/dev/null; then
	#     log "→ Setting up Home Manager"
	#     nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
	#     nix-channel --update
	#     nix-shell '<home-manager>' -A install
	# fi

	# This command does not set up Home Manager as a standalone package though
	# This command runs Home Manager as a temporary process in a nix shell.
	# It will initialize a Home Manager configuration and switch to it if the configuration files already exist.
	nix run home-manager -- init --switch .

	# Initialize and switch to the Home Manager configuration
	log "→ Switching Home Manager configuration"
	home-manager switch --flake .
fi
