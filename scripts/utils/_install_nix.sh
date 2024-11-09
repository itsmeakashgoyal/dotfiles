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

# Enable strict mode for better error handling
set -eu pipefail
IFS=$'\n\t'

# Set the error trap
trap 'print_error "$LINENO" "$BASH_COMMAND" "$?"' ERR

print_message "$YELLOW" "→ Install Nix package manager"
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

print_message "$YELLOW" "→ Copy nix folder into CONFIG_DIR dir"
cp -rf "${DOTFILES_DIR}/nix" "${CONFIG_DIR}"

print_message "$YELLOW" "→ Installing Nix packages"
# Change to the .config/nix directory
# Define CONFIG_DIR if not set
CONFIG_DIR="${CONFIG_DIR:-$HOME/.config}"
print_message "$YELLOW" "→ Changing to the ${CONFIG_DIR}/nvim directory"
cd "${CONFIG_DIR}/nix" || {
	print_message "$YELLOW" "→ Failed to change directory to ${CONFIG_DIR}/nix"
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
	print_message "$YELLOW" "→ Switching Home Manager configuration"
	home-manager switch --flake .
fi
