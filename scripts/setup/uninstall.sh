#!/usr/bin/env bash
#
#  ▓▓▓▓▓▓▓▓▓▓
# ░▓ author ▓ Akash Goyal
# ░▓ file   ▓ scripts/setup/uninstall.sh
# ░▓▓▓▓▓▓▓▓▓▓
#
# Gracefully uninstall the dotfiles setup on macOS and Ubuntu/Linux.
#
# What it ALWAYS does (after one confirmation):
#   1. Restores your login shell to the OS default (before removing tools)
#   2. Unstows every Stow package (removes the dotfile symlinks)
#   3. Sweeps any dangling symlinks that still point into the repo
#   4. Clears generated caches (zcompdump, stow backups)
#   6. Uninstalls Homebrew COMPLETELY — brew itself + every package it
#      installed (not just the Brewfile entries). Runs everywhere, incl. CI.
#
# What it does ONLY if you opt in (prompted, default No):
#   5. Removes Nix + Home Manager (Linux) — isolated to /nix
#
# What it NEVER touches:
#   • The repo itself (your dotfiles stay on disk)
#   • Your data: shell history, ~/.ssh, ~/.gitconfig content, etc.
#   • Nix, unless you explicitly opt in (REMOVE_NIX=1 or the prompt)
#
# Usage:
#   make uninstall                 # interactive (removes Homebrew entirely)
#   make uninstall dry=1           # show what would happen, change nothing
#   make uninstall force=1         # skip the initial confirm
#   REMOVE_NIX=1 make uninstall    # also remove Nix non-interactively
#
# WARNING: Homebrew removal is now MANDATORY and total. If you installed
# packages outside these dotfiles, they will be removed too. Use dry=1 first
# if unsure.

set -euo pipefail

CORE="${HOME}/dotfiles/scripts/lib/core.sh"
if [[ ! -f "$CORE" ]]; then
    echo "Error: core library not found at $CORE" >&2
    exit 1
fi
# shellcheck disable=SC1090
source "$CORE"

trap 'print_error "$LINENO" "$BASH_COMMAND" "$?"' ERR

# ------------------------------------------------------------------------------
# Options (from env / Makefile)
# ------------------------------------------------------------------------------
DRY_RUN="${DRY_RUN:-0}"
FORCE="${FORCE:-0}"
REMOVE_NIX="${REMOVE_NIX:-0}"

# Package list — passed from the Makefile to stay a single source of truth.
# Falls back to a sane default if invoked directly.
STOW_PACKAGES="${STOW_PACKAGES:-git zsh nvim tmux television bin atuin fastfetch}"

# ------------------------------------------------------------------------------
# Helpers
# ------------------------------------------------------------------------------

# Execute a simple command, or just print it in dry-run mode.
run() {
    if [[ "$DRY_RUN" == "1" ]]; then
        log::substep "[dry-run] $*"
    else
        "$@"
    fi
}

# Initial gate confirmation. Honors FORCE and DRY_RUN.
confirm_gate() {
    local prompt="$1"
    [[ "$DRY_RUN" == "1" ]] && { log::substep "[dry-run] would ask: $prompt"; return 0; }
    [[ "$FORCE" == "1" ]] && return 0
    if [[ ! -t 0 ]]; then
        log::warning "Non-interactive shell and FORCE not set — aborting."
        return 1
    fi
    local yn
    read -r -p "$(printf '  %b?%b %s [y/N] ' "$LOG_YELLOW" "$LOG_NC" "$prompt")" yn
    [[ "$yn" =~ ^[Yy]$ ]]
}

# Opt-in prompt for destructive package/Nix removal. Default No.
# Enabled by: matching env flag = 1, or an interactive "y". FORCE never auto-enables.
ask_optional() {
    local prompt="$1" envflag="$2"
    [[ "${!envflag:-0}" == "1" ]] && return 0
    [[ "$DRY_RUN" == "1" ]] && { log::substep "[dry-run] optional step (set ${envflag}=1 to enable): $prompt"; return 0; }
    [[ "$FORCE" == "1" ]] && return 1
    [[ ! -t 0 ]] && return 1
    local yn
    read -r -p "$(printf '  %b?%b %s [y/N] ' "$LOG_YELLOW" "$LOG_NC" "$prompt")" yn
    [[ "$yn" =~ ^[Yy]$ ]]
}

# Current login shell, cross-platform.
get_login_shell() {
    if os::is_mac; then
        dscl . -read "/Users/${USER}" UserShell 2>/dev/null | awk '{print $2}'
    else
        getent passwd "$USER" 2>/dev/null | cut -d: -f7
    fi
}

# ------------------------------------------------------------------------------
# Step 1 — restore login shell (BEFORE removing any tools that provide it)
# ------------------------------------------------------------------------------
restore_shell() {
    log::section "Step 1/6 — Restore login shell"

    # OS default shell
    local target
    if os::is_mac; then
        target="/bin/zsh"
    else
        target="/bin/bash"
    fi

    local current
    current="$(get_login_shell || true)"
    log::kvp "Current login shell" "${current:-unknown}"
    log::kvp "OS default" "$target"

    if [[ ! -x "$target" ]]; then
        log::warn "OS default shell $target not found — skipping shell restore."
        return 0
    fi

    if [[ "$current" == "$target" ]]; then
        log::ok "Login shell is already the OS default — nothing to do."
        return 0
    fi

    if confirm_gate "Reset login shell to $target?"; then
        if run chsh -s "$target"; then
            log::ok "Login shell reset to $target (open a new terminal to apply)."
        else
            log::warn "chsh failed — your login shell was not changed."
        fi
    else
        log::substep "Skipped shell restore."
    fi
}

# ------------------------------------------------------------------------------
# Step 2 — unstow all packages
# ------------------------------------------------------------------------------
unstow_packages() {
    log::section "Step 2/6 — Remove dotfile symlinks (unstow)"

    if ! command_exists stow; then
        log::warn "stow not installed — will rely on the dangling-link sweep (Step 3)."
        return 0
    fi

    for pkg in $STOW_PACKAGES; do
        if [[ -d "${DOTFILES_DIR}/${pkg}" ]]; then
            log::substep "Unstowing ${pkg}..."
            if [[ "$DRY_RUN" == "1" ]]; then
                log::substep "[dry-run] stow --delete --dir=$DOTFILES_DIR --target=$HOME $pkg"
            else
                stow --delete --dir="$DOTFILES_DIR" --target="$HOME" "$pkg" 2>/dev/null \
                    || log::warn "Could not cleanly unstow ${pkg} (may already be removed)."
            fi
        else
            log::substep "Package ${pkg} not present — skipping."
        fi
    done
    log::ok "Stow packages processed."
}

# ------------------------------------------------------------------------------
# Step 3 — sweep dangling symlinks that point back into the repo
# ------------------------------------------------------------------------------
sweep_symlinks() {
    log::section "Step 3/6 — Sweep leftover symlinks into the repo"

    # Scan $HOME and $HOME/.config (maxdepth 2) for symlinks; the roots overlap,
    # so collect and de-duplicate before processing to avoid double-counting.
    local removed=0
    local all_links
    all_links="$( { find "$HOME" -maxdepth 2 -type l 2>/dev/null; \
                    find "$HOME/.config" -maxdepth 2 -type l 2>/dev/null; } | sort -u )"

    while IFS= read -r link; do
        [[ -z "$link" ]] && continue
        local resolved
        resolved="$(readlink "$link" 2>/dev/null || true)"
        # Match symlinks resolving into the dotfiles dir (relative or absolute)
        if [[ "$resolved" == *"dotfiles/"* || "$resolved" == "$DOTFILES_DIR"* ]]; then
            log::substep "Removing dangling link: $link -> $resolved"
            run rm -f "$link"
            removed=$((removed + 1))
        fi
    done <<< "$all_links"

    if [[ "$removed" -eq 0 ]]; then
        log::ok "No leftover symlinks found."
    else
        log::ok "Removed ${removed} leftover symlink(s)."
    fi
}

# ------------------------------------------------------------------------------
# Step 4 — clear generated caches (NOT user data)
# ------------------------------------------------------------------------------
clean_generated() {
    log::section "Step 4/6 — Clear generated caches"

    # Zsh completion dump cache
    local cache_zsh="${XDG_CACHE_HOME:-$HOME/.cache}/zsh"
    [[ -d "$cache_zsh" ]] && { log::substep "Removing $cache_zsh"; run rm -rf "$cache_zsh"; }

    # Stray compdumps in $HOME
    while IFS= read -r f; do
        log::substep "Removing $f"
        run rm -f "$f"
    done < <(find "$HOME" -maxdepth 1 -name ".zcompdump*" 2>/dev/null)

    # Stow backup files (*.~) in $HOME
    while IFS= read -r f; do
        log::substep "Removing stow backup $f"
        run rm -f "$f"
    done < <(find "$HOME" -maxdepth 1 -name ".*~" -type f 2>/dev/null)

    log::ok "Generated caches cleared (history and personal data left intact)."
}

# ------------------------------------------------------------------------------
# Step 5 — optional: remove Nix + Home Manager (Linux)
# ------------------------------------------------------------------------------
remove_nix() {
    log::section "Step 5/6 — Remove Nix (optional)"

    if ! os::is_linux; then
        log::substep "Not on Linux — skipping Nix removal."
        return 0
    fi
    if ! command_exists nix; then
        log::substep "Nix not installed — nothing to remove."
        return 0
    fi

    if ! ask_optional "Remove Nix + Home Manager entirely? (isolated to /nix)" "REMOVE_NIX"; then
        log::substep "Keeping Nix installed."
        return 0
    fi

    # Remove the Home Manager generation first (best-effort), then uninstall Nix.
    if command_exists home-manager; then
        run bash -c "home-manager uninstall || true"
    fi

    if [[ -x /nix/nix-installer ]]; then
        log::substep "Using Determinate uninstaller..."
        run /nix/nix-installer uninstall
    else
        log::warn "/nix/nix-installer not found."
        log::info "Remove manually per your installer's docs (e.g. official: /nix/var/nix/profiles cleanup)."
    fi
    log::ok "Nix removal step complete."
}

# ------------------------------------------------------------------------------
# Step 6 — mandatory: uninstall Homebrew COMPLETELY (brew + ALL its packages)
# ------------------------------------------------------------------------------
# Uses Homebrew's official uninstall script, which removes the brew prefix and
# every formula/cask it installed — not just the Brewfile entries.
remove_homebrew() {
    log::section "Step 6/6 — Uninstall Homebrew completely"

    if ! command_exists brew; then
        log::substep "Homebrew not installed — nothing to remove."
        return 0
    fi

    log::warning "Removing Homebrew ENTIRELY — this deletes brew and EVERY package"
    log::warning "it installed, including any you added outside these dotfiles."

    if [[ "$DRY_RUN" == "1" ]]; then
        log::substep "[dry-run] would run Homebrew's official uninstall.sh with --force"
        log::substep "[dry-run]   (removes the brew prefix + all formulae/casks)"
        log::ok "Homebrew removal step complete (dry-run)."
        return 0
    fi

    # Official uninstaller. --force skips its own confirmation prompt (the user
    # already confirmed at the start of this script).
    if /bin/bash -c \
        "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/uninstall.sh)" \
        -- --force; then
        log::ok "Homebrew fully removed."
    else
        log::warn "Homebrew uninstaller returned non-zero — it may be partially removed."
        log::info "You can re-run, or finish manually per https://github.com/homebrew/install#uninstall-homebrew"
    fi

    # Tidy leftover shellenv lines / empty prefix dirs the uninstaller may leave.
    for leftover in /opt/homebrew /home/linuxbrew/.linuxbrew; do
        if [[ -d "$leftover" ]] && [[ -z "$(ls -A "$leftover" 2>/dev/null)" ]]; then
            log::substep "Removing empty leftover dir: $leftover"
            run rmdir "$leftover" 2>/dev/null || true
        fi
    done
}

# ------------------------------------------------------------------------------
# Main
# ------------------------------------------------------------------------------
main() {
    log::banner "Dotfiles Uninstaller"
    log::info "OS: $(os::detail)"
    [[ "$DRY_RUN" == "1" ]] && log::warning "DRY-RUN MODE — nothing will actually be changed."

    log::newline
    log::info "This will reset your login shell, remove dotfile symlinks, clear caches,"
    log::info "and UNINSTALL HOMEBREW COMPLETELY (brew + all packages it installed)."
    log::info "Your repo, shell history, and personal data are left untouched."
    log::info "Nix removal (Linux) stays opt-in (you'll be asked, default No)."
    [[ "$DRY_RUN" != "1" && -z "${CI:-}" ]] && \
        log::warning "Tip: run 'make uninstall dry=1' first to preview every action."
    log::newline

    if ! confirm_gate "Proceed with uninstall?"; then
        log::error "Uninstall aborted."
        exit 0
    fi

    restore_shell
    unstow_packages
    sweep_symlinks
    clean_generated
    remove_nix
    remove_homebrew

    log::newline
    if [[ "$DRY_RUN" == "1" ]]; then
        log::success "Dry-run complete — no changes were made."
        log::info "Re-run without dry=1 to perform the uninstall."
    else
        log::success "Dotfiles uninstalled."
        log::info "Open a new terminal for the shell change to take effect."
        log::info "The repo is still at: $DOTFILES_DIR (delete it manually if you want it gone)."
    fi
}

main "$@"
