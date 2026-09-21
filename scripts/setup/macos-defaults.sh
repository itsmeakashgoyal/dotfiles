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

# ------------------------------------------------------------------------------
# The settings table — the single source of truth for apply AND undo.
#
# Every entry stores the value we write next to the value we found, so both
# directions read this one table and `--undo` can never drift out of step with
# what apply actually did.
#
# Format:  domain|key|type|value
# ------------------------------------------------------------------------------
DEFAULTS=(
    # Finder — show the path bar and status bar at the bottom of windows.
    "com.apple.finder                 |ShowPathbar                   |bool  |true"
    "com.apple.finder                 |ShowStatusBar                 |bool  |true"
    # Show hidden (dotfile) files — a dotfiles maintainer wants these visible.
    "com.apple.finder                 |AppleShowAllFiles             |bool  |true"
    # Don't nag when changing a file's extension.
    "com.apple.finder                 |FXEnableExtensionChangeWarning|bool  |false"
    # Don't scatter .DS_Store files onto network shares.
    "com.apple.desktopservices        |DSDontWriteNetworkStores      |bool  |true"

    # Enable key repeat (hold-to-repeat) instead of the accent-picker popover —
    # essential for holding hjkl in vim/nvim.
    "NSGlobalDomain                   |ApplePressAndHoldEnabled      |bool  |false"
    # Fast key-repeat rate once repeating starts, with a short initial delay.
    "NSGlobalDomain                   |KeyRepeat                     |int   |2"
    "NSGlobalDomain                   |InitialKeyRepeat              |int   |15"
    # Three-finger drag on the trackpad.
    "com.apple.AppleMultitouchTrackpad|TrackpadThreeFingerDrag       |bool  |true"

    # Save screenshots as PNG (already the default; set explicitly).
    "com.apple.screencapture          |type                          |string|png"
    # Save screenshots to ~/Screenshots instead of cluttering the Desktop.
    "com.apple.screencapture          |location                      |string|${HOME}/Screenshots"
)

# Where the pre-change values are recorded. One line per setting:
#   domain|key|type|<original value>   (or the __MISSING__ sentinel)
STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/dotfiles"
SNAPSHOT="${SNAPSHOT:-$STATE_DIR/macos-defaults.snapshot}"
DRY_RUN="${DRY_RUN:-0}"

# Sentinel for "this key did not exist before we touched it", so undo deletes
# the key rather than writing a bogus default back.
readonly MISSING="__MISSING__"

run() {
    if [[ "$DRY_RUN" == "1" ]]; then
        log::substep "[dry-run] $*"
    else
        "$@"
    fi
}

# ------------------------------------------------------------------------------
# Snapshot
# ------------------------------------------------------------------------------
take_snapshot() {
    if [[ -f "$SNAPSHOT" ]]; then
        info "Snapshot already exists ($SNAPSHOT) — keeping the original pre-dotfiles values."
        return 0
    fi

    info "Recording current values to $SNAPSHOT ..."
    if [[ "$DRY_RUN" == "1" ]]; then
        log::substep "[dry-run] would snapshot ${#DEFAULTS[@]} settings to $SNAPSHOT"
        return 0
    fi

    mkdir -p "$STATE_DIR"
    : >"$SNAPSHOT"
    local entry domain key type current
    for entry in "${DEFAULTS[@]}"; do
        IFS="|" read -r domain key type _ <<<"$entry"
        domain="${domain// /}" key="${key// /}" type="${type// /}"
        if current=$(defaults read "$domain" "$key" 2>/dev/null); then
            # The snapshot is one line per setting, so a structured (multi-line)
            # value can't be represented. Skip it rather than record something
            # undo would mis-restore — undo then simply leaves that key alone.
            if [[ "$current" == *$'\n'* ]]; then
                warning "Skipping snapshot of $domain $key (multi-line value)"
                continue
            fi
            printf '%s|%s|%s|%s\n' "$domain" "$key" "$type" "$current" >>"$SNAPSHOT"
        else
            printf '%s|%s|%s|%s\n' "$domain" "$key" "$type" "$MISSING" >>"$SNAPSHOT"
        fi
    done
    success "Snapshot saved — revert any time with: make macos-defaults undo=1"
}

# ------------------------------------------------------------------------------
# Apply / undo
# ------------------------------------------------------------------------------
apply_defaults() {
    info "Applying macOS defaults..."
    # screencapture silently ignores a missing directory.
    run mkdir -p "$HOME/Screenshots"

    local entry domain key type value
    for entry in "${DEFAULTS[@]}"; do
        IFS="|" read -r domain key type value <<<"$entry"
        domain="${domain// /}" key="${key// /}" type="${type// /}"
        run defaults write "$domain" "$key" "-$type" "$value"
    done
}

undo_defaults() {
    if [[ ! -f "$SNAPSHOT" ]]; then
        error "No snapshot at $SNAPSHOT — nothing to revert."
        error "A snapshot is only written the first time this script applies defaults."
        return 1
    fi

    info "Reverting macOS defaults from $SNAPSHOT ..."
    local domain key type value
    while IFS="|" read -r domain key type value; do
        [[ -z "$domain" ]] && continue
        if [[ "$value" == "$MISSING" ]]; then
            # The key didn't exist before — remove it so macOS falls back to
            # its own built-in default.
            run defaults delete "$domain" "$key" 2>/dev/null || true
        else
            run defaults write "$domain" "$key" "-$type" "$value"
        fi
    done <"$SNAPSHOT"

    success "Reverted. The snapshot is kept at $SNAPSHOT."
}

restart_affected_apps() {
    info "Restarting Finder and the input service to apply changes..."
    # killall returns non-zero if the process isn't running - not an error here.
    run killall Finder 2>/dev/null || true
    run killall SystemUIServer 2>/dev/null || true
}

usage() {
    cat <<'EOF'
Usage: macos-defaults.sh [OPTIONS]

Options:
  --undo        Restore the values recorded before defaults were first applied
  -n, --dry-run Print every change without making it
  -h, --help    Show this help

The first apply writes a snapshot of the previous values to
$XDG_STATE_HOME/dotfiles/macos-defaults.snapshot so --undo has something to
restore. Re-applying never overwrites that snapshot.
EOF
}

main() {
    local mode="apply"
    for arg in "$@"; do
        case "$arg" in
            --undo) mode="undo" ;;
            -n | --dry-run) DRY_RUN=1 ;;
            -h | --help) usage; exit 0 ;;
            *) warning "Unknown argument: $arg" ;;
        esac
    done

    log_message "macOS defaults started (mode=$mode)"

    info "
##############################################
#      macOS System Defaults                 #
##############################################
"
    [[ "$DRY_RUN" == "1" ]] && warning "DRY-RUN MODE — nothing will actually be changed."

    if [[ "$mode" == "undo" ]]; then
        undo_defaults
    else
        take_snapshot
        apply_defaults
    fi

    restart_affected_apps

    if [[ "$mode" == "apply" && "$DRY_RUN" != "1" ]]; then
        success "macOS defaults applied. A few (key-repeat rate) need a re-login to fully take effect."
    elif [[ "$DRY_RUN" == "1" ]]; then
        success "Dry run complete — no changes were made."
    fi
    log_message "macOS defaults completed successfully (mode=$mode)"
}

trap 'print_error "$LINENO" "$BASH_COMMAND" "$?"' ERR

main "$@"
