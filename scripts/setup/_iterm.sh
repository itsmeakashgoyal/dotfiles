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
# ░▓ file   ▓ scripts/setup/_iterm.sh
# ░▓▓▓▓▓▓▓▓▓▓
# ░░░░░░░░░░

# ------------------------------------------------------------------------------
# iTerm2 Setup Script for macOS
# Points iTerm2 at the dotfiles settings folder so preferences stay in sync.
# ------------------------------------------------------------------------------

if [[ -n "${CI:-}" ]]; then
    echo "Skipping iTerm2 setup in CI environment"
    exit 0
fi

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
readonly ITERM_APP="/Applications/iTerm.app"
readonly ITERM_PREFS_DIR="${DOTFILES_DIR}/settings/iterm"
readonly ITERM_PLIST="${ITERM_PREFS_DIR}/com.googlecode.iterm2.plist"

# ------------------------------------------------------------------------------
# Main Setup
# ------------------------------------------------------------------------------
main() {
    log_message "iTerm2 setup started"

    info "
##############################################
#      iTerm2 Setup                          #
##############################################
"

    if [[ ! -e "${ITERM_APP}" ]]; then
        warning "iTerm2 not found at ${ITERM_APP} — skipping"
        return 0
    fi

    if [[ ! -f "${ITERM_PLIST}" ]]; then
        error "iTerm2 plist not found at ${ITERM_PLIST}"
        return 1
    fi

    info "Configuring iTerm2 to load preferences from dotfiles..."

    # Tell iTerm2 to read/write prefs from the dotfiles folder.
    # On next launch it will pick up com.googlecode.iterm2.plist from there.
    defaults write com.googlecode.iterm2 PrefsCustomFolder -string "${ITERM_PREFS_DIR}"
    defaults write com.googlecode.iterm2 LoadPrefsFromCustomFolder -bool true

    success "iTerm2 preferences folder set to: ${ITERM_PREFS_DIR}"
    info "Changes made in iTerm2 Preferences will save back to the dotfiles repo."

    log_message "iTerm2 setup completed successfully"
}

trap 'print_error "$LINENO" "$BASH_COMMAND" "$?"' ERR

main
