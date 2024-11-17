#!/usr/bin/env zsh

#################################################
#      File: _sublime.sh                         #
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

set -eu pipefail

# Skip in CI environment
[[ -n "${CI:-}" ]] && exit 0

# ------------------------------------------------------------------------------
# Configuration
# ------------------------------------------------------------------------------
SUBLIME_APP="/Applications/Sublime Text.app"
SUBLIME_BIN="${SUBLIME_APP}/Contents/SharedSupport/bin/subl"
CONFIG_PATH="${HOME}/Library/Application Support/Sublime Text"
USER_PACKAGES_DIR="${CONFIG_PATH}/Packages/User"
MAX_WAIT=30
PACKAGE_CONTROL_URL="https://github.com/wbond/package_control/releases/latest/download/Package.Control.sublime-package"

# ------------------------------------------------------------------------------
# Helper Functions
# ------------------------------------------------------------------------------
setup_sublime_command() {
    if ! command -v subl &>/dev/null; then
        log_message "Creating 'subl' command symlink..."
        if [[ -e "${SUBLIME_BIN}" ]]; then
            sudo ln -sf "${SUBLIME_BIN}" /usr/local/bin/subl
            log_message "Symlink created successfully"
        else
            log_message "Error: Sublime Text not found at expected location" >&2
            return 1
        fi
    fi
}

wait_for_sublime() {
    local waited=0
    until [[ -d "${CONFIG_PATH}/Installed Packages" ]] || ((waited >= MAX_WAIT)); do
        log_message "Waiting for Sublime Text initialization..."
        sleep 1
        ((waited++))
    done

    if [[ ! -d "${CONFIG_PATH}/Installed Packages" ]]; then
        log_message "Error: Sublime Text initialization timeout" >&2
        return 1
    fi
}

install_package_control() {
    log_message "Installing Package Control..."
    curl -L -o "${CONFIG_PATH}/Installed Packages/Package Control.sublime-package" "${PACKAGE_CONTROL_URL}"
}

copy_settings() {
    log_message "Copying Sublime Text settings..."
    mkdir -p "${USER_PACKAGES_DIR}"
    
    local settings=(
        "Package Control.sublime-settings"
        "Preferences.sublime-settings"
        "SublimeLinter.sublime-settings"
    )

    for setting in "${settings[@]}"; do
        cp "settings/${setting}" "${USER_PACKAGES_DIR}/${setting}"
    done
}

# ------------------------------------------------------------------------------
# Main Setup
# ------------------------------------------------------------------------------
main() {
    # Setup Homebrew path if needed
    if [[ -x "/opt/homebrew/bin/brew" ]] && [[ ":$PATH:" != *":/opt/homebrew/bin:"* ]]; then
        export PATH="/opt/homebrew/bin:$PATH"
    fi

    # Setup sublime command
    setup_sublime_command

    # Initial setup
    log_message "Starting initial Sublime Text setup..."
    subl .
    wait_for_sublime
    osascript -e 'quit app "Sublime Text"'

    # Install Package Control and copy settings
    install_package_control
    copy_settings

    # Install packages
    log_message "Installing Sublime Text packages..."
    subl .
    print_message "$YELLOW" "Press Enter after packages are installed..."
    read

    # Final setup
    osascript -e 'quit app "Sublime Text"'
    subl .
    
    print_message "$GREEN" "Sublime Text setup complete!"
    print_message "$YELLOW" "Remember to activate your Sublime Text license"
}

# Set error trap
trap 'print_error "$LINENO" "$BASH_COMMAND" "$?"' ERR

# Run main
main