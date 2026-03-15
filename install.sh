#!/usr/bin/env bash
#
#  ▓▓▓▓▓▓▓▓▓▓
# ░▓ author ▓ Akash Goyal
# ░▓ file   ▓ install.sh
# ░▓▓▓▓▓▓▓▓▓▓
#
# Install packages, run OS-specific setup, and stow dotfiles.

set -euo pipefail

# ------------------------------------------------------------------------------
# Bootstrap: load shared library
# ------------------------------------------------------------------------------
CORE="${HOME}/dotfiles/scripts/lib/core.sh"
if [[ ! -f "$CORE" ]]; then
    echo "Error: core library not found at $CORE" >&2
    exit 1
fi
source "$CORE"

trap 'print_error "$LINENO" "$BASH_COMMAND" "$?"' ERR
export CI="${CI:-}"

# ------------------------------------------------------------------------------
# Helpers
# ------------------------------------------------------------------------------
_confirm() {
    # Skip confirmation in CI
    [[ -n "$CI" ]] && return 0
    
    local prompt="$1"
    echo -n "$prompt [y/n] " >&2
    read -r reply
    [[ "$reply" == "y" ]]
}

_ensure_python3() {
    if command_exists python3; then
        log::success "Python 3 available: $(python3 --version 2>&1)"
        return 0
    fi

    log::info "Python 3 not found — installing..."

    if os::is_mac; then
        brew install python3
    elif os::is_linux; then
        if command_exists apt-get; then
            sudo apt-get update -qq && sudo apt-get install -y python3
        elif command_exists dnf; then
            sudo dnf install -y python3
        elif command_exists pacman; then
            sudo pacman -S --noconfirm python
        elif command_exists brew; then
            brew install python3
        else
            log::fatal "Cannot install Python 3 automatically. Install it manually and re-run."
        fi
    fi

    command_exists python3 \
        || log::fatal "Python 3 installation failed. Install it manually and re-run."

    log::success "Python 3 installed: $(python3 --version 2>&1)"
}

_stow_packages() {
    local packages=(git zsh nvim tmux ohmyposh)

    log::info "Cleaning up old symlinks..."
    local old_links=("$HOME/.zshenv" "$HOME/.config/nvim" "$HOME/.config/tmux"
                      "$HOME/.config/git" "$HOME/.config/zsh" "$HOME/.config/ohmyposh")
    for link in "${old_links[@]}"; do
        if [[ -L "$link" ]]; then
            rm "$link"
            log::substep "Removed old symlink: $link"
        fi
    done

    log::info "Stowing dotfile packages..."
    for pkg in "${packages[@]}"; do
        log::substep "Stowing $pkg..."
        stow --restow --dir="${DOTFILES_DIR}" --target="$HOME" "$pkg"
    done
    log::success "All packages stowed."
}

# ------------------------------------------------------------------------------
# Main
# ------------------------------------------------------------------------------
main() {
    log::banner "Dotfiles Installer"
    log::info "OS: $(os::detail)"

    check_required_commands

    if ! _confirm "This will install and configure dotfiles on your system. Proceed?"; then
        log::error "Installation aborted."
        exit 0
    fi

    # Keep sudo alive for the duration
    if [[ -z "$CI" ]]; then
        if sudo --validate; then
            sudo_keep_alive &
            local sudo_pid=$!
            trap '[[ -n "${sudo_pid:-}" ]] && kill "$sudo_pid" 2>/dev/null || true' EXIT
        else
            log::fatal "Sudo validation failed."
        fi
    fi

    # Packages
    log::info "Installing packages..."
    bash "${DOTFILES_DIR}/packages/install.sh"

    # Python 3 (required by dutils scripts)
    _ensure_python3

    # Default shell
    log::info "Setting Zsh as default shell..."
    if command_exists zsh; then
        local zsh_path; zsh_path=$(command -v zsh)
        if ! grep -q "$zsh_path" /etc/shells; then
            sudo sh -c "echo $zsh_path >> /etc/shells"
        fi
        sudo chsh -s "$zsh_path" "$USER"
    fi

    # OS-specific setup
    if os::is_mac; then
        run_script "sublime" || log::warning "Sublime Text setup failed (non-fatal in CI)"
        run_script "iterm" || log::warning "iTerm2 setup failed (non-fatal in CI)"
    elif os::is_linux; then
        run_script "linux" || log::warning "Linux setup failed (non-fatal in CI)"
    fi

    # Symlinks
    _stow_packages

    log::success "Installation complete!"
    log::info "Run 'exec zsh' to start using your new configuration."
    echo ""

    # Post-install health check
    log::info "Running health check..."
    if bash "${DOTFILES_DIR}/scripts/verify/check.sh" --quick; then
        log::success "Health check passed!"
    else
        log::warning "Health check reported issues (non-fatal)"
    fi
}

main "$@"
