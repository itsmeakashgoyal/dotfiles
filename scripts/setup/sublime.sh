#!/bin/bash
#
#  ▓▓▓▓▓▓▓▓▓▓
# ░▓ author ▓ Akash Goyal
# ░▓ file   ▓ scripts/setup/sublime.sh
# ░▓▓▓▓▓▓▓▓▓▓
#
# Sublime Text setup for macOS and Linux: symlink the settings from this repo
# into Sublime's per-OS User packages dir (so the repo stays the live source of
# truth), and install Package Control so the packages listed in
# `Package Control.sublime-settings` auto-install on first launch. Non-interactive.
# (Windows is handled by windows/windows.ps1 via $SYMLINK_MAP.)

# Skip in CI (no GUI editor there).
if [[ -n "${CI:-}" ]]; then
    echo "Skipping Sublime Text setup in CI environment"
    exit 0
fi

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
trap 'print_error "$LINENO" "$BASH_COMMAND" "$?"' ERR

readonly SETTINGS_SRC="${DOTFILES_DIR}/settings/sublime"
readonly PC_URL="https://github.com/wbond/package_control/releases/latest/download/Package.Control.sublime-package"

# Resolve Sublime's config dir for this OS.
resolve_config_dir() {
    if os::is_mac; then
        echo "${HOME}/Library/Application Support/Sublime Text"
    elif os::is_linux; then
        echo "${HOME}/.config/sublime-text"
    else
        return 1
    fi
}

# macOS: make the `subl` CLI available (best-effort, non-fatal).
link_subl_cli() {
    os::is_mac || return 0
    command_exists subl && return 0
    local bin="/Applications/Sublime Text.app/Contents/SharedSupport/bin/subl"
    [[ -e "$bin" ]] || return 0
    local dir="/usr/local/bin"
    [[ -d "$dir" ]] || return 0
    if ln -sf "$bin" "${dir}/subl" 2>/dev/null; then
        success "Linked 'subl' CLI"
    fi
}

main() {
    log_message "Sublime Text setup started"

    if [[ ! -d "$SETTINGS_SRC" ]]; then
        warning "Sublime settings not found at ${SETTINGS_SRC} — skipping"
        exit 0
    fi

    local config user_dir installed
    if ! config="$(resolve_config_dir)"; then
        warning "Unsupported OS for Sublime setup — skipping"
        exit 0
    fi
    user_dir="${config}/Packages/User"
    installed="${config}/Installed Packages"
    mkdir -p "$user_dir" "$installed"

    # Install Package Control so the listed packages auto-install on next launch.
    if [[ ! -f "${installed}/Package Control.sublime-package" ]]; then
        info "Installing Package Control..."
        curl -fsSL -o "${installed}/Package Control.sublime-package" "$PC_URL" \
            && success "Package Control installed" \
            || warning "Could not download Package Control (install it from the Command Palette)"
    else
        info "Package Control already present"
    fi

    # Symlink every settings file (Preferences, LSP, keymap, builds, theme, …)
    # so editing the repo updates Sublime live.
    local linked=0 f
    for f in "$SETTINGS_SRC"/*; do
        [[ -f "$f" ]] || continue
        ln -sf "$f" "${user_dir}/$(basename "$f")"
        linked=$((linked + 1))
    done
    success "Linked ${linked} settings file(s) into ${user_dir}"

    link_subl_cli

    info "Launch Sublime Text — Package Control will install the listed packages."
    info "For C/C++ LSP, ensure 'clangd' is on PATH; Python LSP (pyright) needs Node."
}

main
