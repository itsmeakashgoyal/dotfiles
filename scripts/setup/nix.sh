#!/usr/bin/env bash
#
#  ▓▓▓▓▓▓▓▓▓▓
# ░▓ author ▓ Akash Goyal
# ░▓ file   ▓ scripts/setup/nix.sh
# ░▓▓▓▓▓▓▓▓▓▓
#
# Install Nix (Determinate Systems installer) and apply the standalone
# Home Manager flake in nix/ — the only package manager used on Linux.
# Dotfiles themselves are still symlinked separately by GNU Stow.
#
# Run via: make nix-setup

set -euo pipefail

DOTFILES_DIR="${DOTFILES_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"
export DOTFILES_DIR
CORE="${DOTFILES_DIR}/scripts/lib/core.sh"
if [[ ! -f "$CORE" ]]; then
    echo "Error: core library not found at $CORE" >&2
    exit 1
fi
# shellcheck disable=SC1090
source "$CORE"

trap 'print_error "$LINENO" "$BASH_COMMAND" "$?"' ERR

readonly NIX_DIR="${DOTFILES_DIR}/nix"
readonly FLAKE_FILE="${NIX_DIR}/flake.nix"

# ------------------------------------------------------------------------------
# Guards
# ------------------------------------------------------------------------------
if ! os::is_linux; then
    log::warning "This Nix flow targets Linux. On macOS you are still using Homebrew."
    log::info "Skipping. (Migrate macOS to Nix later once the Linux setup is proven.)"
    exit 0
fi

if [[ ! -f "$FLAKE_FILE" ]]; then
    log::fatal "Flake not found at $FLAKE_FILE"
fi

# ------------------------------------------------------------------------------
# Step 1 — install Nix (Determinate Systems installer; enables flakes by default)
# ------------------------------------------------------------------------------
_source_nix_env() {
    # Make `nix` available in this shell after install (installer can't touch our PATH)
    if [[ -e /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]]; then
        # shellcheck disable=SC1091
        source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
    elif [[ -e "$HOME/.nix-profile/etc/profile.d/nix.sh" ]]; then
        # shellcheck disable=SC1091
        source "$HOME/.nix-profile/etc/profile.d/nix.sh"
    fi
}

if command_exists nix; then
    log::success "Nix already installed: $(nix --version)"
else
    log::info "Installing Nix via the Determinate Systems installer..."
    log::substep "This enables flakes by default and supports a clean uninstall."
    # Use --no-confirm when running unattended (CI, or piped stdin like
    # `echo y | ./install.sh`) so the installer never blocks on a prompt.
    if [[ -n "${CI:-}" || ! -t 0 ]]; then
        curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix \
            | sh -s -- install --no-confirm
    else
        curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix \
            | sh -s -- install
    fi
    _source_nix_env
    command_exists nix || log::fatal "Nix install finished but 'nix' is not on PATH. Open a new shell and re-run."
    log::success "Nix installed: $(nix --version)"
fi

# Ensure nix is usable even if it was already installed in a prior shell
command_exists nix || _source_nix_env

# ------------------------------------------------------------------------------
# Step 2 — flakes need files tracked by git; stage the nix dir
# ------------------------------------------------------------------------------
if git -C "$DOTFILES_DIR" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    if [[ -n "$(git -C "$DOTFILES_DIR" status --porcelain -- nix/ 2>/dev/null)" ]]; then
        log::substep "Staging nix/ so the flake can see it (git add nix/)..."
        git -C "$DOTFILES_DIR" add nix/
    fi
fi

# ------------------------------------------------------------------------------
# Step 3 — apply the Home Manager flake (first run bootstraps home-manager)
# ------------------------------------------------------------------------------
log::info "Applying Home Manager configuration (this may take a few minutes the first time)..."

# Defensive: pass flake features in case the installer didn't enable them globally.
# --impure: the flake reads $USER and the current system dynamically instead
# of maintaining a list of them (see nix/flake.nix) — always applies the one
# "default" config, on any machine or username.
NIX_FEATURES="--extra-experimental-features nix-command --extra-experimental-features flakes"

# shellcheck disable=SC2086
if nix $NIX_FEATURES run home-manager/master -- switch -b backup --flake "${NIX_DIR}#default" --impure; then
    log::success "Home Manager applied successfully."
else
    log::error "home-manager switch failed."
    log::info "Common fix: open a new shell so 'nix' and the HM profile are on PATH, then re-run."
    exit 1
fi

# ------------------------------------------------------------------------------
# Done
# ------------------------------------------------------------------------------
cat <<EOF

  ┌──────────────────────────────────────────────────────────────────────┐
  │ Nix + Home Manager is set up for packages on Linux.                  │
  │                                                                      │
  │ Open a NEW shell (or run: exec zsh) so the Nix profile is on PATH.   │
  │                                                                      │
  │ Daily workflow:                                                      │
  │   • Edit packages:   nix/home.nix                                    │
  │   • Apply changes:   make nix-switch                                 │
  │   • Update versions: make nix-update                                 │
  │                                                                      │
  │ Full guide: docs/NIX.md                                              │
  └──────────────────────────────────────────────────────────────────────┘

EOF

log::success "Nix setup complete!"
