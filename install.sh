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
    log::info "Cleaning up old symlinks..."
    local old_links=("$HOME/.zshenv" "$HOME/.config/nvim" "$HOME/.config/tmux"
                      "$HOME/.config/git" "$HOME/.config/zsh")
    for link in "${old_links[@]}"; do
        if [[ -L "$link" ]]; then
            rm "$link"
            log::substep "Removed old symlink: $link"
        fi
    done

    # Delegate to `make run` so the Makefile's STOW_PACKAGES list stays the
    # single source of truth for which packages get stowed.
    log::info "Stowing dotfile packages..."
    make -s -C "${DOTFILES_DIR}" run
    log::success "All packages stowed."
}

# ------------------------------------------------------------------------------
# Main
# ------------------------------------------------------------------------------
main() {
    log::banner "Dotfiles Installer"
    log::info "OS: $(os::detail)"

    log::info "[STEP 1/8] Checking required commands..."
    check_required_commands
    log::success "[STEP 1/8] Required commands OK"

    log::info "[STEP 2/8] Confirming installation..."
    if ! _confirm "This will install and configure dotfiles on your system. Proceed?"; then
        log::error "Installation aborted."
        exit 0
    fi
    log::success "[STEP 2/8] Confirmed"

    # Keep sudo alive for the duration
    log::info "[STEP 3/8] Setting up sudo..."
    if [[ -z "$CI" ]]; then
        if sudo --validate; then
            sudo_keep_alive &
            local sudo_pid=$!
            trap '[[ -n "${sudo_pid:-}" ]] && kill "$sudo_pid" 2>/dev/null || true' EXIT
        else
            log::fatal "Sudo validation failed."
        fi
    else
        log::info "[STEP 3/8] CI mode — skipping sudo keep-alive"
    fi
    log::success "[STEP 3/8] Sudo setup done"

    # Packages — macOS uses Homebrew; Linux uses Nix (replaces linuxbrew)
    log::info "[STEP 4/8] Installing packages (DOTFILES_DIR=${DOTFILES_DIR})..."
    if os::is_mac; then
        bash "${DOTFILES_DIR}/packages/install.sh"
    elif os::is_linux; then
        # 1) apt: system-level deps only (build-essential, stow, zsh, curl, …)
        run_script "linux"
        # 2) Nix + Home Manager: all CLI tools (eza, bat, fd, nvim, tv, …)
        bash "${DOTFILES_DIR}/scripts/setup/nix.sh"
    fi
    log::success "[STEP 4/8] Packages installed"

    # Python 3 (required by dutils scripts)
    log::info "[STEP 5/8] Ensuring Python 3..."
    _ensure_python3
    log::success "[STEP 5/8] Python 3 OK"

    # Default shell
    log::info "[STEP 6/8] Setting Zsh as default shell..."
    if command_exists zsh; then
        local zsh_path; zsh_path=$(command -v zsh)
        log::info "[STEP 6/8] zsh found at: $zsh_path"
        if ! grep -q "$zsh_path" /etc/shells; then
            log::info "[STEP 6/8] Adding $zsh_path to /etc/shells..."
            sudo sh -c "echo $zsh_path >> /etc/shells"
        fi
        sudo chsh -s "$zsh_path" "$USER" || log::warning "Could not change default shell (non-fatal in CI)"
    else
        log::warning "[STEP 6/8] zsh not found — skipping shell change"
    fi
    log::success "[STEP 6/8] Default shell step done"

    # OS-specific setup
    log::info "[STEP 7/8] Running OS-specific setup (OS: $(os::detail))..."
    if os::is_mac; then
        run_script "sublime" || log::warning "Sublime Text setup failed (non-fatal in CI)"
        run_script "iterm" || log::warning "iTerm2 setup failed (non-fatal in CI)"
    fi
    # Linux package + system setup is handled in STEP 4 (apt system deps + Nix).
    log::success "[STEP 7/8] OS-specific setup done"

    # Symlinks
    log::info "[STEP 8/8] Stowing dotfile packages..."
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
