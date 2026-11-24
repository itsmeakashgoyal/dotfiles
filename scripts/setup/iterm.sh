#!/usr/bin/env bash
#
#  ▓▓▓▓▓▓▓▓▓▓
# ░▓ author ▓ Akash Goyal
# ░▓ file   ▓ scripts/setup/iterm.sh
# ░▓▓▓▓▓▓▓▓▓▓
#
# ------------------------------------------------------------------------------
# iTerm2 Setup Script for macOS
#
# iTerm2 is configured through a Dynamic Profile instead of a synced plist:
#   1. `dutils theme apply` renders settings/iterm/profile.json + Gruvbox colours
#      into ~/Library/Application Support/iTerm2/DynamicProfiles/ (iTerm2 hot-
#      reloads it). Profiles: "Gruvbox" (default) and "Gruvbox Hotkey" (⌥Space
#      drop-down window).
#   2. A short list of global preferences is applied with `defaults write`
#      (default profile, tab style, tmux integration, …).
#   3. One-time migration off the old "load prefs from the dotfiles folder"
#      setup: imports that plist into the normal prefs so nothing is lost.
#   4. Installs iTerm2 shell integration (sourced by conf.d/16-iterm.zsh).
#
# Steps 2 and 3 write iTerm2's preferences, which iTerm2 overwrites on quit, so
# they only run while iTerm2 is NOT running (run from Terminal.app, or quit
# iTerm2 first). Step 1 and 4 are safe any time.
# ------------------------------------------------------------------------------

if [[ -n "${CI:-}" ]]; then
    echo "Skipping iTerm2 setup in CI environment"
    exit 0
fi

DOTFILES_DIR="${DOTFILES_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"
export DOTFILES_DIR
SCRIPT_DIR="${DOTFILES_DIR}/scripts"
CORE_FILE="${SCRIPT_DIR}/lib/core.sh"

if [[ ! -f "$CORE_FILE" ]]; then
    echo "Error: Core library not found at $CORE_FILE" >&2
    exit 1
fi

# shellcheck source=scripts/lib/core.sh
source "$CORE_FILE"
set -euo pipefail

# ------------------------------------------------------------------------------
# Configuration
# ------------------------------------------------------------------------------
readonly ITERM_APP="/Applications/iTerm.app"
readonly ITERM_DOMAIN="com.googlecode.iterm2"
readonly ITERM_PREFS_DIR="${DOTFILES_DIR}/settings/iterm"
readonly ITERM_LEGACY_PLIST="${ITERM_PREFS_DIR}/com.googlecode.iterm2.plist"
readonly ITERM_SHELL_INTEGRATION_SRC="${ITERM_APP}/Contents/Resources/iterm2_shell_integration.zsh"
readonly ITERM_SHELL_INTEGRATION_DEST="${HOME}/.iterm2_shell_integration.zsh"
readonly DUTILS="${SCRIPT_DIR}/dutils/dutils"   # picks Python >= 3.14 itself

iterm_running() { pgrep -xq iTerm2; }

# ------------------------------------------------------------------------------
# Steps
# ------------------------------------------------------------------------------
install_dynamic_profile() {
    info "Rendering the Gruvbox Dynamic Profile (dutils theme apply)..."
    if python3 "$DUTILS" theme apply; then
        success "Dynamic Profile installed"
    else
        warning "dutils theme apply failed — iTerm2 keeps its current profile"
    fi
}

# Import the plist that used to be synced from the repo into iTerm2's normal
# preferences, then stop loading prefs from the dotfiles folder.
migrate_from_custom_folder() {
    local load_custom custom_dir
    load_custom=$(defaults read "$ITERM_DOMAIN" LoadPrefsFromCustomFolder 2>/dev/null || echo 0)
    custom_dir=$(defaults read "$ITERM_DOMAIN" PrefsCustomFolder 2>/dev/null || echo "")
    [[ "$load_custom" == "1" && "$custom_dir" == "$ITERM_PREFS_DIR" ]] || return 0

    info "Migrating iTerm2 off the synced plist in ${ITERM_PREFS_DIR}..."
    if [[ -f "$ITERM_LEGACY_PLIST" ]]; then
        defaults import "$ITERM_DOMAIN" "$ITERM_LEGACY_PLIST"
        success "Imported your existing iTerm2 preferences"
    fi
    defaults write "$ITERM_DOMAIN" LoadPrefsFromCustomFolder -bool false
    defaults delete "$ITERM_DOMAIN" PrefsCustomFolder 2>/dev/null || true
    success "iTerm2 now uses its normal preferences; the repo plist is no longer read"
    info "You can delete ${ITERM_LEGACY_PLIST} once you're happy (it's untracked)."
}

apply_global_prefs() {
    local guid
    # profiles[0] is the "_default" profile; plutil reads JSON natively.
    guid=$(plutil -extract profiles.0.Guid raw -o - "${ITERM_PREFS_DIR}/profile.json" 2>/dev/null || true)
    if [[ -n "$guid" ]]; then
        defaults write "$ITERM_DOMAIN" "Default Bookmark Guid" -string "$guid"
    fi
    # Minimal tab style: tab bar takes the profile's Gruvbox background.
    defaults write "$ITERM_DOMAIN" TabStyleWithAutomaticOption -int 5
    # tmux -CC integration: open tmux windows as native tabs, hide the client.
    defaults write "$ITERM_DOMAIN" OpenTmuxWindowsIn -int 2
    defaults write "$ITERM_DOMAIN" AutoHideTmuxClientSession -bool true
    # Let apps (tmux, nvim, ssh sessions) set the clipboard via OSC 52, so
    # copying inside tmux lands in the macOS clipboard like it does outside.
    defaults write "$ITERM_DOMAIN" AllowClipboardAccess -bool true
    # Copy on select; keep updates automatic.
    defaults write "$ITERM_DOMAIN" CopySelection -bool true
    defaults write "$ITERM_DOMAIN" SUEnableAutomaticChecks -bool true
    success "Applied iTerm2 global preferences (default profile: Gruvbox)"
}

install_shell_integration() {
    if [[ -f "${ITERM_SHELL_INTEGRATION_SRC}" ]]; then
        cp "${ITERM_SHELL_INTEGRATION_SRC}" "${ITERM_SHELL_INTEGRATION_DEST}"
        success "iTerm2 shell integration installed to ${ITERM_SHELL_INTEGRATION_DEST}"
    else
        warning "iTerm2 shell integration script not found in app bundle — skipping"
    fi
}

# ------------------------------------------------------------------------------
# Main
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

    install_dynamic_profile
    install_shell_integration

    if iterm_running; then
        warning "iTerm2 is running, so its global preferences were left untouched"
        info "Quit iTerm2 and run this from Terminal.app to finish: make iterm"
        info "(or set Profiles → Gruvbox → Other Actions → Set as Default by hand)"
    else
        migrate_from_custom_folder
        apply_global_prefs
    fi

    log_message "iTerm2 setup completed successfully"
}

trap 'print_error "$LINENO" "$BASH_COMMAND" "$?"' ERR

main
