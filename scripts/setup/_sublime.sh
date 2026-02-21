#!/usr/bin/env bash
#                    █████
#                   ░░███
#   █████   ██████  ███████   █████ ████ ████████
#  ███░░   ███░░███░░░███░   ░░███ ░███ ░░███░░███
# ░░█████ ░███████   ░███     ░███ ░███  ░███ ░███
#  ░░░░███░███░░░    ░███ ███ ░███ ░███  ░███ ░███
#  ██████ ░░██████   ░░█████  ░░████████ ░███████
# ░░░░░░   ░░░░░░     ░░░░░    ░░░░░░░░  ░███░░░
#                                        ░███
#                                        █████
#                                       ░░░░░
#
#  ▓▓▓▓▓▓▓▓▓▓
# ░▓ author ▓ Akash Goyal
# ░▓ file   ▓ scripts/setup/_sublime.sh
# ░▓▓▓▓▓▓▓▓▓▓
# ░░░░░░░░░░

# ------------------------------------------------------------------------------
# Sublime Text Setup Script for macOS
# Installs Package Control and configures Sublime Text settings
# ------------------------------------------------------------------------------

# Skip in CI environment (before loading anything)
if [[ -n "${CI:-}" ]]; then
    echo "Skipping Sublime Text setup in CI environment"
    exit 0
fi

# Load helper functions
SCRIPT_DIR="${HOME}/dotfiles/scripts"
HELPER_FILE="${SCRIPT_DIR}/utils/_helper.sh"

if [[ ! -f "$HELPER_FILE" ]]; then
    echo "Error: Helper file not found at $HELPER_FILE" >&2
    exit 1
fi

source "$HELPER_FILE"
set -euo pipefail

# ------------------------------------------------------------------------------
# Configuration
# ------------------------------------------------------------------------------
readonly SUBLIME_APP="/Applications/Sublime Text.app"
readonly SUBLIME_BIN="${SUBLIME_APP}/Contents/SharedSupport/bin/subl"
readonly CONFIG_PATH="${HOME}/Library/Application Support/Sublime Text"
readonly USER_PACKAGES_DIR="${CONFIG_PATH}/Packages/User"
readonly MAX_WAIT=30
readonly PACKAGE_CONTROL_URL="https://github.com/wbond/package_control/releases/latest/download/Package.Control.sublime-package"

# ------------------------------------------------------------------------------
# Helper Functions
# ------------------------------------------------------------------------------
check_sublime_installed() {
    if [[ ! -e "${SUBLIME_APP}" ]]; then
        error "Sublime Text not found at ${SUBLIME_APP}"
        info "Please install Sublime Text first: https://www.sublimetext.com/"
        return 1
    fi
    return 0
}

setup_sublime_command() {
    if command -v subl &>/dev/null; then
        info "subl command already available"
        return 0
    fi

    log_message "Creating 'subl' command symlink..."
    
    if [[ ! -e "${SUBLIME_BIN}" ]]; then
        error "Sublime Text binary not found at ${SUBLIME_BIN}"
        return 1
    fi

    sudo ln -sf "${SUBLIME_BIN}" /usr/local/bin/subl
    success "subl command symlink created"
}

wait_for_sublime_init() {
    local waited=0
    
    log_message "Waiting for Sublime Text initialization..."
    
    until [[ -d "${CONFIG_PATH}/Installed Packages" ]] || ((waited >= MAX_WAIT)); do
        sleep 1
        ((waited++))
    done

    if [[ ! -d "${CONFIG_PATH}/Installed Packages" ]]; then
        error "Sublime Text initialization timeout after ${MAX_WAIT} seconds"
        return 1
    fi
    
    success "Sublime Text initialized"
}

install_package_control() {
    local install_dir="${CONFIG_PATH}/Installed Packages"
    local package_file="${install_dir}/Package Control.sublime-package"

    if [[ -f "${package_file}" ]]; then
        info "Package Control already installed"
        return 0
    fi

    log_message "Installing Package Control..."
    
    mkdir -p "${install_dir}"
    
    if ! curl -fsSL -o "${package_file}" "${PACKAGE_CONTROL_URL}"; then
        error "Failed to download Package Control"
        return 1
    fi
    
    success "Package Control installed"
}

copy_settings() {
    local settings_source="${DOTFILES_DIR}/settings/sublime"

    if [[ ! -d "${settings_source}" ]]; then
        warning "Settings directory not found at ${settings_source}"
        return 0
    fi

    log_message "Copying Sublime Text settings..."
    mkdir -p "${USER_PACKAGES_DIR}"
    
    local settings=(
        "Package Control.sublime-settings"
        "Preferences.sublime-settings"
        "SublimeLinter.sublime-settings"
    )

    local copied=0
    for setting in "${settings[@]}"; do
        if [[ -f "${settings_source}/${setting}" ]]; then
            cp "${settings_source}/${setting}" "${USER_PACKAGES_DIR}/${setting}"
            ((copied++))
        else
            warning "Setting file not found: ${setting}"
        fi
    done

    if ((copied > 0)); then
        success "Copied ${copied} setting file(s)"
    else
        warning "No settings files were copied"
    fi
}

quit_sublime() {
    osascript -e 'quit app "Sublime Text"' 2>/dev/null || true
    sleep 1
}

# ------------------------------------------------------------------------------
# Main Setup
# ------------------------------------------------------------------------------
main() {
    log_message "Sublime Text setup started"
    
    info "
##############################################
#      Sublime Text Setup                    #
##############################################
"

    # Verify Sublime Text is installed
    check_sublime_installed || exit 1

    # Setup Homebrew path if needed (for Apple Silicon Macs)
    if [[ -x "/opt/homebrew/bin/brew" ]] && [[ ":$PATH:" != *":/opt/homebrew/bin:"* ]]; then
        export PATH="/opt/homebrew/bin:$PATH"
    fi

    # Setup subl command
    setup_sublime_command || exit 1

    # Initial launch to initialize config directory
    info "Launching Sublime Text for initial setup..."
    subl . &
    wait_for_sublime_init || exit 1
    quit_sublime

    # Install Package Control
    install_package_control || exit 1

    # Copy settings
    copy_settings

    # Final launch for package installation
    info "
##############################################
#  Sublime Text is now opening.              #
#  Please wait for packages to install.      #
##############################################
"
    subl . &
    
    info "Press Enter after packages are installed..."
    read

    # Final restart
    quit_sublime
    subl . &

    success "
###################################################
#     Sublime Text Setup Completed!              #
#     Remember to activate your license.          #
###################################################
"
    log_message "Sublime Text setup completed successfully"
}

# Set error trap
trap 'print_error "$LINENO" "$BASH_COMMAND" "$?"' ERR

# Run main
main
