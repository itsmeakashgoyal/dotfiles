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
DOTFILES_DIR="${DOTFILES_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)}"
export DOTFILES_DIR
CORE="${DOTFILES_DIR}/scripts/lib/core.sh"
if [[ ! -f "$CORE" ]]; then
    echo "Error: core library not found at $CORE" >&2
    exit 1
fi
# shellcheck source=scripts/lib/core.sh
source "$CORE"

trap 'print_error "$LINENO" "$BASH_COMMAND" "$?"' ERR
export CI="${CI:-}"

# ------------------------------------------------------------------------------
# Options
# ------------------------------------------------------------------------------
# DRY_RUN mirrors scripts/setup/uninstall.sh: print every mutating action
# instead of performing it, so a fresh machine can be previewed before it's
# touched. Set via --dry-run or `make install dry=1`.
DRY_RUN="${DRY_RUN:-0}"

# ------------------------------------------------------------------------------
# Helpers
# ------------------------------------------------------------------------------

# Execute a command, or just print it in dry-run mode.
run() {
    if [[ "$DRY_RUN" == "1" ]]; then
        log::substep "[dry-run] $*"
    else
        "$@"
    fi
}

_confirm() {
    # Skip confirmation in CI, in dry-run, or when a non-interactive run was
    # requested (-y/--yes)
    { [[ -n "$CI" ]] || [[ -n "${ASSUME_YES:-}" ]] || [[ "$DRY_RUN" == "1" ]]; } && return 0

    local prompt="$1"
    echo -n "$prompt [y/n] " >&2
    read -r reply
    [[ "$reply" == "y" ]]
}

# Python >= 3.14 is the repo standard (dutils, health checks). packages.toml
# already installs it (brew python@3.14 / nix python314 / scoop python); this is
# the safety net. At runtime scripts/lib/pyreq.py picks a >= 3.14 interpreter
# even when plain `python3` is older (e.g. macOS's /usr/bin/python3).
_python_ok() { "$1" -c 'import sys; sys.exit(sys.version_info < (3, 14))' 2>/dev/null; }

_find_python() {
    local py
    for py in python3.14 python3.15 python3.16 python3; do
        command_exists "$py" && _python_ok "$py" && { command -v "$py"; return 0; }
    done
    return 1
}

_ensure_python3() {
    local py
    if py=$(_find_python); then
        log::success "Python available: $("$py" --version 2>&1) ($py)"
        return 0
    fi

    log::info "Python >= 3.14 not found — installing..."
    if os::is_mac && command_exists brew; then
        run brew install python@3.14
    else
        # uv ships prebuilt CPython for every distro/arch, so this works even
        # where the distro's own python3 is older than 3.14.
        if ! command_exists uv; then
            run sh -c 'curl -LsSf https://astral.sh/uv/install.sh | sh'
            export PATH="$HOME/.local/bin:$PATH"
        fi
        run uv python install 3.14
        export PATH="$HOME/.local/bin:$PATH"
    fi

    [[ "$DRY_RUN" == "1" ]] && return 0

    py=$(_find_python) || log::fatal "Python >= 3.14 installation failed. Install it manually and re-run."
    log::success "Python installed: $("$py" --version 2>&1) ($py)"
}

_stow_packages() {
    log::info "Cleaning up old symlinks..."
    local old_links=("$HOME/.zshenv" "$HOME/.config/nvim" "$HOME/.config/tmux"
                      "$HOME/.config/git" "$HOME/.config/zsh")
    for link in "${old_links[@]}"; do
        if [[ -L "$link" ]]; then
            run rm "$link"
            [[ "$DRY_RUN" == "1" ]] || log::substep "Removed old symlink: $link"
        fi
    done

    # Delegate to `make run` so the Makefile's STOW_PACKAGES list stays the
    # single source of truth for which packages get stowed.
    log::info "Stowing dotfile packages..."
    run make -s -C "${DOTFILES_DIR}" run
    log::success "All packages stowed."
}

# ------------------------------------------------------------------------------
# Main
# ------------------------------------------------------------------------------
main() {
    # Parse flags. -y/--yes enables a hands-off, non-interactive install
    # (used by `bootstrap.sh --yes` for one-click provisioning).
    ASSUME_YES=""
    for arg in "$@"; do
        case "$arg" in
            -y | --yes) ASSUME_YES=1 ;;
            -n | --dry-run) DRY_RUN=1 ;;
            -h | --help)
                cat <<'EOF'
Usage: install.sh [OPTIONS]

Options:
  -y, --yes       Non-interactive: assume "yes" for every prompt
  -n, --dry-run   Print every mutating action without performing it
  -h, --help      Show this help
EOF
                exit 0
                ;;
            *) log::warning "Unknown argument: $arg" ;;
        esac
    done

    log::banner "Dotfiles Installer"
    log::info "OS: $(os::detail)"
    [[ -n "$ASSUME_YES" ]] && log::info "Non-interactive mode (--yes)"
    [[ "$DRY_RUN" == "1" ]] && log::warning "DRY-RUN MODE — nothing will actually be changed."

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
    if [[ -z "$CI" && "$DRY_RUN" != "1" ]]; then
        if sudo --validate; then
            sudo_keep_alive &
            local sudo_pid=$!
            trap '[[ -n "${sudo_pid:-}" ]] && kill "$sudo_pid" 2>/dev/null || true' EXIT
        else
            log::fatal "Sudo validation failed."
        fi
    elif [[ "$DRY_RUN" == "1" ]]; then
        log::substep "[dry-run] sudo --validate + keep-alive"
    else
        log::info "[STEP 3/8] CI mode — skipping sudo keep-alive"
    fi
    log::success "[STEP 3/8] Sudo setup done"

    # Packages — macOS uses Homebrew; Linux uses Nix (no linuxbrew anywhere)
    log::info "[STEP 4/8] Installing packages (DOTFILES_DIR=${DOTFILES_DIR})..."
    if os::is_mac; then
        run bash "${DOTFILES_DIR}/scripts/setup/macos.sh"
    elif os::is_linux; then
        # 1) apt: system-level deps only (build-essential, stow, zsh, curl, …)
        if [[ "$DRY_RUN" == "1" ]]; then
            log::substep "[dry-run] scripts/setup/linux.sh"
        else
            run_script "linux"
        fi
        # 2) Nix + Home Manager: all CLI tools (eza, bat, fd, nvim, tv, …)
        run bash "${DOTFILES_DIR}/scripts/setup/nix.sh"
    fi
    log::success "[STEP 4/8] Packages installed"

    # Python >= 3.14 (required by dutils scripts)
    log::info "[STEP 5/8] Ensuring Python >= 3.14..."
    _ensure_python3
    log::success "[STEP 5/8] Python OK"

    # Default shell
    log::info "[STEP 6/8] Setting Zsh as default shell..."
    if command_exists zsh; then
        local zsh_path; zsh_path=$(command -v zsh)
        log::info "[STEP 6/8] zsh found at: $zsh_path"
        if ! grep -q "$zsh_path" /etc/shells; then
            log::info "[STEP 6/8] Adding $zsh_path to /etc/shells..."
            run sudo sh -c "echo $zsh_path >> /etc/shells"
        fi
        run sudo chsh -s "$zsh_path" "$USER" || log::warning "Could not change default shell (non-fatal in CI)"
    else
        log::warning "[STEP 6/8] zsh not found — skipping shell change"
    fi
    log::success "[STEP 6/8] Default shell step done"

    # OS-specific setup
    log::info "[STEP 7/8] Running OS-specific setup (OS: $(os::detail))..."
    # Sublime Text is a cross-platform editor — set it up on macOS and Linux
    # (the script itself no-ops in CI and picks the per-OS User dir).
    if [[ "$DRY_RUN" == "1" ]]; then
        log::substep "[dry-run] scripts/setup/sublime.sh"
        os::is_mac && log::substep "[dry-run] scripts/setup/iterm.sh"
    else
        run_script "sublime" || log::warning "Sublime Text setup failed (non-fatal in CI)"
        if os::is_mac; then
            run_script "iterm" || log::warning "iTerm2 setup failed (non-fatal in CI)"
        fi
    fi
    # Linux package + system setup is handled in STEP 4 (apt system deps + Nix).
    log::success "[STEP 7/8] OS-specific setup done"

    # Symlinks
    log::info "[STEP 8/8] Stowing dotfile packages..."
    _stow_packages

    # tmux plugins (TPM): needs ~/.config/tmux linked, so it runs after stowing.
    if [[ "$DRY_RUN" == "1" ]]; then
        log::substep "[dry-run] scripts/setup/tmux.sh (TPM + tmux plugins)"
    else
        run_script "tmux" || log::warning "tmux plugin setup failed (non-fatal): start tmux and press prefix + I"
        # Rex terminal (macOS, only if installed): config, terminfo, app settings
        os::is_mac && { run_script "rex" || log::warning "Rex setup failed (non-fatal): make rex"; }
        # yazi flavor/plugins pinned in yazi/.config/yazi/package.toml
        if command_exists ya; then
            if ya pkg install >/dev/null 2>&1; then
                log::success "yazi packages installed"
            else
                log::warning "yazi packages not installed (non-fatal): run 'ya pkg install'"
            fi
        fi
    fi
    if [[ "$DRY_RUN" == "1" ]]; then
        log::success "Dry run complete — no changes were made."
        log::info "Re-run without --dry-run to apply."
        return 0
    fi

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
