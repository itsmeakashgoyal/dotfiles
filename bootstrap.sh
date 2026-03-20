#!/usr/bin/env bash
#
#  ▓▓▓▓▓▓▓▓▓▓
# ░▓ author ▓ Akash Goyal
# ░▓ file   ▓ bootstrap.sh
# ░▓▓▓▓▓▓▓▓▓▓
#
# Bootstrap: download dotfiles from GitHub then run install.sh.
# Use this for a fresh machine where the repo doesn't exist yet.
#
# Usage:
#   bash <(curl -fsSL https://raw.githubusercontent.com/itsmeakashgoyal/dotfiles/master/bootstrap.sh)

set -euo pipefail

readonly REPO="https://github.com/itsmeakashgoyal/dotfiles"
readonly TARGET="${HOME}/dotfiles"

# Minimal logging before the shared library is available
_info()    { echo -e "\033[34mINFO:\033[0m  $*"; }
_success() { echo -e "\033[32mOK:\033[0m    $*"; }
_warn()    { echo -e "\033[33mWARN:\033[0m  $*"; }
_error()   { echo -e "\033[31mERROR:\033[0m $*" >&2; }

_confirm() {
    local prompt="$1"
    read -rp "$prompt [y/N] " -n 1
    echo
    [[ $REPLY =~ ^[Yy]$ ]]
}

# ------------------------------------------------------------------------------
# Download
# ------------------------------------------------------------------------------
_download() {
    if command -v git >/dev/null 2>&1; then
        _info "Cloning with git..."
        git clone "$REPO" "$TARGET"
    elif command -v curl >/dev/null 2>&1; then
        _info "Downloading with curl..."
        mkdir -p "$TARGET"
        curl -fsSL "${REPO}/tarball/master" | tar -xz -C "$TARGET" --strip-components=1
    elif command -v wget >/dev/null 2>&1; then
        _info "Downloading with wget..."
        mkdir -p "$TARGET"
        wget -qO- "${REPO}/tarball/master" | tar -xz -C "$TARGET" --strip-components=1
    else
        _error "No download tool found (git / curl / wget). Install one and retry."
        return 1
    fi
}

# ------------------------------------------------------------------------------
# Main
# ------------------------------------------------------------------------------
main() {
    echo ""
    _info "Dotfiles Bootstrap"
    echo ""

    if [[ -d "$TARGET" ]]; then
        _warn "Dotfiles directory already exists: $TARGET"
        if _confirm "Remove it and re-download?"; then
            rm -rf "$TARGET"
        else
            if [[ ! -f "$TARGET/install.sh" ]]; then
                _error "install.sh not found in existing directory."
                exit 1
            fi
            _confirm "Run install.sh now?" && bash "$TARGET/install.sh"
            exit 0
        fi
    fi

    _download || { _error "Download failed."; exit 1; }
    _success "Dotfiles downloaded to $TARGET"

    if [[ ! -f "$TARGET/install.sh" ]]; then
        _error "install.sh not found after download."
        exit 1
    fi

    echo ""
    if _confirm "Run install.sh now?"; then
        bash "$TARGET/install.sh"
        _success "Bootstrap complete!"
    else
        _warn "Skipped. Run manually: bash $TARGET/install.sh"
    fi
}

main
