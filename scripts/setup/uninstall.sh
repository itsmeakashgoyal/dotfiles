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
#   5. If Nix is installed: removes Home Manager packages, then Nix itself
#   6. If Homebrew is installed: removes all its packages, then brew itself
#
# Both package managers are removed PACKAGES-FIRST, then the manager, so
# nothing is left half-broken. Each is a no-op if not installed.
#
# What it NEVER touches:
#   • The repo itself (your dotfiles stay on disk)
#   • Your data: shell history, ~/.ssh, ~/.gitconfig content, etc.
#
# Usage:
#   make uninstall                 # interactive
#   make uninstall dry=1           # show what would happen, change nothing
#   make uninstall force=1         # skip the initial confirm
#
# WARNING: Removal of Nix AND Homebrew is MANDATORY and total. If you installed
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

# Package list — the Makefile's STOW_PACKAGES is the single source of truth.
# `make uninstall` passes it via env; a direct invocation queries the
# Makefile instead, falling back to a snapshot only if that query fails.
STOW_PACKAGES="${STOW_PACKAGES:-$(make -s -C "${DOTFILES_DIR}" print-STOW_PACKAGES 2>/dev/null || true)}"
: "${STOW_PACKAGES:=git zsh nvim tmux television bin atuin fastfetch}"

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
    log::section "Step 5/6 — Uninstall Nix completely"

    # Detect Nix by command OR the store dir (covers non-login shells where
    # `nix` isn't on PATH but /nix exists).
    if ! command_exists nix && [[ ! -e /nix ]]; then
        log::substep "Nix not installed — nothing to remove."
        return 0
    fi

    log::warning "Removing Nix + Home Manager entirely — this deletes /nix and"
    log::warning "every package Home Manager installed."

    if [[ "$DRY_RUN" == "1" ]]; then
        log::substep "[dry-run] home-manager uninstall            (removes HM packages first)"
        log::substep "[dry-run] /nix/nix-installer uninstall ...  (then removes Nix itself)"
        log::ok "Nix removal step complete (dry-run)."
        return 0
    fi

    # Make nix / home-manager reachable even from this non-login shell.
    if [[ -e /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]]; then
        # shellcheck disable=SC1091
        source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
    fi
    export PATH="$HOME/.nix-profile/bin:/nix/var/nix/profiles/default/bin:$PATH"

    # 1) Packages first — cleanly remove the Home Manager profile/generations.
    if command_exists home-manager; then
        log::substep "Removing Home Manager profile (packages)..."
        home-manager uninstall <<< "y" 2>/dev/null \
            || log::warn "home-manager uninstall returned non-zero (continuing)."
    else
        log::substep "home-manager not on PATH — the Nix uninstaller will remove its packages."
    fi

    # 2) Then the package manager itself.
    local nc=""
    [[ -n "${CI:-}" || ! -t 0 ]] && nc="--no-confirm"
    if [[ -x /nix/nix-installer ]]; then
        log::substep "Removing Nix via the Determinate uninstaller..."
        # shellcheck disable=SC2086
        /nix/nix-installer uninstall $nc \
            || log::warn "nix-installer uninstall returned non-zero — Nix may be partially removed."
    else
        log::warn "/nix/nix-installer not found — remove Nix manually:"
        log::info "  https://nix.dev/manual/nix/latest/installation/uninstall"
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
    log::info "and COMPLETELY UNINSTALL both Nix and Homebrew if present"
    log::info "(all their packages first, then the package manager itself)."
    log::info "Your repo, shell history, and personal data are left untouched."
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
