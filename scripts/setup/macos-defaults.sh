#!/usr/bin/env bash
#
#  ▓▓▓▓▓▓▓▓▓▓
# ░▓ author ▓ Akash Goyal
# ░▓ file   ▓ scripts/setup/macos-defaults.sh
# ░▓▓▓▓▓▓▓▓▓▓
#
# ------------------------------------------------------------------------------
# macOS system defaults (`defaults write`) for Finder, input, screenshots, etc.
# A curated, broadly-sensible subset - the opinionated/personal bits (hiding
# desktop icons, Dock size/animation, spaces behavior) are deliberately left
# out. Run manually and re-log in (or the killall at the end applies most of it
# immediately). Not part of the default install flow - invoke it yourself when
# setting up a Mac.
# ------------------------------------------------------------------------------

# Skip in CI (before loading anything)
if [[ -n "${CI:-}" ]]; then
    echo "Skipping macOS defaults in CI environment"
    exit 0
fi

# Load helper functions
DOTFILES_DIR="${DOTFILES_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"
export DOTFILES_DIR
CORE_FILE="${DOTFILES_DIR}/scripts/lib/core.sh"

if [[ ! -f "$CORE_FILE" ]]; then
    echo "Error: Core library not found at $CORE_FILE" >&2
    exit 1
fi

# shellcheck source=/dev/null
source "$CORE_FILE"
set -euo pipefail

# macOS only
if [[ "$(uname -s)" != "Darwin" ]]; then
    warning "macos-defaults.sh is macOS-only - skipping on $(uname -s)"
    exit 0
fi

apply_finder_defaults() {
    info "Finder..."
    # Show the path bar and status bar at the bottom of Finder windows.
    defaults write com.apple.finder ShowPathbar -bool true
    defaults write com.apple.finder ShowStatusBar -bool true
    # Show hidden (dotfile) files - a dotfiles maintainer wants these visible.
    defaults write com.apple.finder AppleShowAllFiles -bool true
    # Don't nag when changing a file's extension.
    defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false
    # Don't scatter .DS_Store files onto network shares.
    defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
}

apply_input_defaults() {
    info "Keyboard & trackpad..."
    # Enable key repeat (hold-to-repeat) instead of the accent-picker popover -
    # essential for holding hjkl in vim/nvim.
    defaults write -g ApplePressAndHoldEnabled -bool false
    # Fast key-repeat rate once repeating starts, with a short initial delay.
    defaults write -g KeyRepeat -int 2
    defaults write -g InitialKeyRepeat -int 15
    # Three-finger drag on the trackpad.
    defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerDrag -bool true
}

apply_misc_defaults() {
    info "Screenshots & updates..."
    # Save screenshots as PNG (default already, set explicitly for portability).
    defaults write com.apple.screencapture type -string "png"
    # Save screenshots to ~/Screenshots instead of cluttering the Desktop
    # (create the dir first - screencapture silently ignores a missing path).
    mkdir -p "$HOME/Screenshots"
    defaults write com.apple.screencapture location -string "$HOME/Screenshots"
    # Check for software updates weekly rather than daily.
    # defaults write com.apple.SoftwareUpdate ScheduleFrequency -int 7
    # Stop offering every new external drive as a Time Machine backup volume.
    # defaults write com.apple.TimeMachine DoNotOfferNewDisksForBackup -bool true
}

restart_affected_apps() {
    info "Restarting Finder and the input service to apply changes..."
    # killall returns non-zero if the process isn't running - not an error here.
    killall Finder 2>/dev/null || true
    killall SystemUIServer 2>/dev/null || true
}

main() {
    log_message "macOS defaults started"

    info "
##############################################
#      macOS System Defaults                 #
##############################################
"

    apply_finder_defaults
    apply_input_defaults
    apply_misc_defaults
    restart_affected_apps

    success "macOS defaults applied. A few (key-repeat rate) need a re-login to fully take effect."
    log_message "macOS defaults completed successfully"
}

trap 'print_error "$LINENO" "$BASH_COMMAND" "$?"' ERR

main
