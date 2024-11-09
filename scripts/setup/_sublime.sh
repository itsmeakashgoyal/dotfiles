#!/usr/bin/env zsh

#################################################
#      File: _sublime.sh                        #
#      Author: Akash Goyal                      #
#      Status: Development                      #
#################################################

# Added set -euo pipefail for better error handling and script termination on errors.
set -eu pipefail

# Skip osx config setup in CI environment
if [ -n "$CI" ]; then
    exit 0
fi

SUBLIME_APP="/Applications/Sublime Text.app"
SUBLIME_BIN="${SUBLIME_APP}/Contents/SharedSupport/bin/subl"
CONFIG_PATH="${HOME}/Library/Application Support/Sublime Text"
USER_PACKAGES_DIR="${CONFIG_PATH}/Packages/User"
MAX_WAIT=30

# Check if Homebrew's bin exists and if it's not already in the PATH
if [ -x "/opt/homebrew/bin/brew" ] && [[ ":$PATH:" != *":/opt/homebrew/bin:"* ]]; then
    export PATH="/opt/homebrew/bin:$PATH"
fi

# Create symlink for 'subl' command if not available
if ! command -v subl &>/dev/null; then
    echo "'subl' command not found. Creating symlink for Sublime Text."
    if [ -e "${SUBLIME_BIN}" ]; then
        sudo ln -sf "${SUBLIME_BIN}" /usr/local/bin/subl
        echo "Symlink created successfully."
    else
        echo "Error: Sublime Text application not found in the expected location." >&2
        exit 1
    fi
else
    echo "'subl' command is already available."
fi

# Function to open Sublime Text and wait for initialization
open_and_wait_sublime() {
    subl .
    waited=0
    until [[ -d "${CONFIG_PATH}/Installed Packages" ]] || ((waited >= MAX_WAIT)); do
        echo "Waiting for Sublime Text to initialize..."
        sleep 1
        ((waited++))
    done

    if [[ -d "${CONFIG_PATH}/Installed Packages" ]]; then
        echo "Sublime Text initialized."
    else
        echo "Error: Sublime Text did not initialize within ${MAX_WAIT} seconds." >&2
        exit 1
    fi
}

# Open Sublime Text to create necessary folders
open_and_wait_sublime

# Quit Sublime after folders are created
osascript -e 'quit app "Sublime Text"'

# Install latest version of Package Control
PACKAGE_CONTROL_URL="https://github.com/wbond/package_control/releases/latest/download/Package.Control.sublime-package"
curl -L -o "${CONFIG_PATH}/Installed Packages/Package Control.sublime-package" "${PACKAGE_CONTROL_URL}"

# Copy packages that should be installed
mkdir -p "${USER_PACKAGES_DIR}"
cp "settings/Package Control.sublime-settings" "${USER_PACKAGES_DIR}/Package Control.sublime-settings"

# Open Sublime Text to install packages
echo "Opening Sublime to automatically install packages"
open_and_wait_sublime
echo "Press Enter after Packages are all installed..."
read

# Quit Sublime after packages are installed
osascript -e 'quit app "Sublime Text"'

# Copy custom settings, keymaps, and other configurations
cp "settings/Preferences.sublime-settings" "${USER_PACKAGES_DIR}/Preferences.sublime-settings"
cp "settings/SublimeLinter.sublime-settings" "${USER_PACKAGES_DIR}/SublimeLinter.sublime-settings"

echo "Custom Sublime Text settings and packages have been copied."

# Open Sublime Text to check for errors and to enter your license key
subl .
echo "You can view potential Sublime Text errors by pressing Ctrl + backtick"
echo "If there are no errors, activate your Sublime license."
echo "Press enter to continue..."
read
