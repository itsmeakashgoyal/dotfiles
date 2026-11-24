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
# Needs NO git and NO SSH key: it clones over public HTTPS, or downloads a
# tarball when git isn't installed yet (fresh macOS only has a git stub) and
# turns it into a real clone once install.sh has installed git. SSH keys and
# your personal/work identities come afterwards, from `dutils init`.
#
# Usage:
#   bash <(curl -fsSL https://raw.githubusercontent.com/itsmeakashgoyal/dotfiles/master/bootstrap.sh)
#
# Hands-off (no prompts, e.g. for a one-click / unattended install):
#   bash <(curl -fsSL https://raw.githubusercontent.com/itsmeakashgoyal/dotfiles/master/bootstrap.sh) --yes
#
# Note: pass flags directly. The `-s --` form belongs to `curl ... | sh -s --`,
# where sh needs to be told the remaining words are script arguments; with
# process substitution the script is a real file and its arguments are just
# appended.

set -euo pipefail

readonly REPO="https://github.com/itsmeakashgoyal/dotfiles"
readonly TARGET="${HOME}/dotfiles"

# -y/--yes runs unattended: assume "yes" for every prompt here and pass the
# flag through to install.sh so the whole chain is non-interactive.
ASSUME_YES=""
for arg in "$@"; do
    case "$arg" in
        -y | --yes) ASSUME_YES=1 ;;
    esac
done

# Minimal logging before the shared library is available
_info()    { echo -e "\033[34mINFO:\033[0m  $*"; }
_success() { echo -e "\033[32mOK:\033[0m    $*"; }
_warn()    { echo -e "\033[33mWARN:\033[0m  $*"; }
_error()   { echo -e "\033[31mERROR:\033[0m $*" >&2; }

_confirm() {
    [[ -n "$ASSUME_YES" ]] && return 0
    local prompt="$1"
    read -rp "$prompt [y/N] " -n 1
    echo
    [[ $REPLY =~ ^[Yy]$ ]]
}

# Run install.sh, forwarding --yes when unattended.
_run_install() {
    if [[ -n "$ASSUME_YES" ]]; then
        bash "$TARGET/install.sh" --yes
    else
        bash "$TARGET/install.sh"
    fi
}

# ------------------------------------------------------------------------------
# Download
# ------------------------------------------------------------------------------
# A real git on PATH? (/usr/bin/git on a fresh Mac is a stub that pops up the
# Command Line Tools installer instead of running.)
_have_git() {
    command -v git >/dev/null 2>&1 || return 1
    [[ "$(uname)" != "Darwin" ]] && return 0
    xcode-select -p >/dev/null 2>&1 || [[ "$(command -v git)" != /usr/bin/git ]]
}

# Tarball download → real clone, once install.sh has provided git.
_convert_to_clone() {
    [[ -d "$TARGET/.git" ]] && return 0
    _have_git || { _warn "git still not available; re-run bootstrap later to get a clone"; return 0; }
    _info "Turning the downloaded tarball into a git clone..."
    git -C "$TARGET" init -q
    git -C "$TARGET" symbolic-ref HEAD refs/heads/master
    git -C "$TARGET" remote add origin "$REPO.git"
    git -C "$TARGET" fetch -q origin master
    git -C "$TARGET" reset -q origin/master
    git -C "$TARGET" branch -q --set-upstream-to=origin/master 2>/dev/null || true
    _success "Clone ready (remote: $REPO.git)"
}

_download() {
    if _have_git; then
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
        # Never delete it (it may hold uncommitted work): move it aside instead.
        if _confirm "Move it to a backup and re-download?"; then
            local backup
            backup="${TARGET}.backup.$(date +%Y%m%d-%H%M%S)"
            mv "$TARGET" "$backup"
            _info "Previous copy kept at $backup"
        else
            if [[ ! -f "$TARGET/install.sh" ]]; then
                _error "install.sh not found in existing directory."
                exit 1
            fi
            _confirm "Run install.sh now?" && _run_install
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
        _run_install
        _convert_to_clone
        _success "Bootstrap complete! Next: dutils init  (git identities, SSH keys, theme)"
    else
        _warn "Skipped. Run manually: bash $TARGET/install.sh"
    fi
}

main
