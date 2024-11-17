#!/usr/bin/env bash

#################################################
#      File: _install_nix.sh                     #
#      Author: Akash Goyal                       #
#      Status: Development                       #
#################################################

# ------------------------------------------------------------------------------
# Initialization
# ------------------------------------------------------------------------------
SCRIPT_DIR="${HOME}/dotfiles/scripts"
HELPER_FILE="${SCRIPT_DIR}/utils/_helper.sh"

# Source helper functions
if [[ ! -f "$HELPER_FILE" ]]; then
	echo "Error: Helper file not found at $HELPER_FILE" >&2
	exit 1
fi
source "$HELPER_FILE"

# Enable strict mode
set -eu pipefail
IFS=$'\n\t'

# ------------------------------------------------------------------------------
# Constants
# ------------------------------------------------------------------------------
readonly NIX_INSTALLER_URL="https://install.determinate.systems/nix"
readonly NIX_INSTALLER_FILE="/tmp/nix-installer.sh"
readonly NIX_ENV_FILE="/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh"

# ------------------------------------------------------------------------------
# Installation Functions
# ------------------------------------------------------------------------------
install_nix() {
	print_message "$YELLOW" "Installing Nix package manager..."

	# Download installer
	if ! curl --proto '=https' --tlsv1.2 -sSf -L "$NIX_INSTALLER_URL" -o "$NIX_INSTALLER_FILE"; then
		print_message "$RED" "Failed to download Nix installer"
		return 1
	fi

	# Make installer executable
	chmod +x "$NIX_INSTALLER_FILE"

	# Run installer
	if [ -z "${CI:-}" ]; then
		"$NIX_INSTALLER_FILE" install
	else
		"$NIX_INSTALLER_FILE" install --no-confirm
	fi

	# Cleanup installer
	rm -f "$NIX_INSTALLER_FILE"

	# Source Nix environment
	if [[ -f "$NIX_ENV_FILE" ]]; then
		source "$NIX_ENV_FILE"
	else
		print_message "$RED" "Nix environment file not found"
		return 1
	fi
}

setup_nix_config() {
	print_message "$YELLOW" "Setting up Nix configuration..."

	# Copy nix configuration
	if ! cp -rf "${DOTFILES_DIR}/nix" "$CONFIG_DIR"; then
		print_message "$RED" "Failed to copy Nix configuration"
		return 1
	fi

	# Change to nix config directory
	if ! cd "${CONFIG_DIR}/nix"; then
		print_message "$RED" "Failed to change to Nix config directory"
		return 1
	fi
}

setup_home_manager() {
	print_message "$YELLOW" "Setting up Home Manager..."

	# Restart nix-daemon
	if command -v systemctl &>/dev/null; then
		sudo systemctl restart nix-daemon.service
	fi

	# Install Home Manager if not installed
	# if ! command -v home-manager &>/dev/null; then
	#     log "→ Setting up Home Manager"
	#     nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
	#     nix-channel --update
	#     nix-shell '<home-manager>' -A install
	# fi

	# Skip Home Manager setup in CI
	if [ -z "${CI:-}" ]; then
		# This command does not set up Home Manager as a standalone package though
		# This command runs Home Manager as a temporary process in a nix shell.
		# It will initialize a Home Manager configuration and switch to it if the configuration files already exist.
		if ! nix run home-manager -- init --switch .; then
			print_message "$RED" "Failed to initialize Home Manager"
			return 1
		fi

		# Switch to Home Manager configuration
		if ! home-manager switch --flake .; then
			print_message "$RED" "Failed to switch Home Manager configuration"
			return 1
		fi
	fi
}

# ------------------------------------------------------------------------------
# Main Function
# ------------------------------------------------------------------------------
main() {
	install_nix
	setup_nix_config
	setup_home_manager

	print_message "$GREEN" "Nix installation and setup completed successfully!"
}

# Set error trap
trap 'print_error "$LINENO" "$BASH_COMMAND" "$?"' ERR

# Run main
main
