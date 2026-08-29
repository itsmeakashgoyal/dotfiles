#!/usr/bin/env bash
#
#  ▓▓▓▓▓▓▓▓▓▓
# ░▓ author ▓ Akash Goyal
# ░▓ file   ▓ scripts/setup/nix.sh
# ░▓▓▓▓▓▓▓▓▓▓
#
# Install Nix (Determinate Systems installer) and apply the standalone
# Home Manager flake in nix/ — the Linux replacement for linuxbrew.
#
# This is ADDITIVE and opt-in: it does not touch your existing Homebrew/
# Stow flow. linuxbrew keeps working until you decide to remove it.
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
# Detect architecture + validate username, then build the flake attribute name
# ------------------------------------------------------------------------------
# The flake exposes homeConfigurations named "<user>-<system>" for every
# (user, system) combo. We auto-detect the host system here — there is no
# hardcoded `system` to keep in sync.
machine_arch=$(uname -m)
case "$machine_arch" in
    x86_64 | amd64) nix_system="x86_64-linux" ;;
    aarch64 | arm64) nix_system="aarch64-linux" ;;
    *) log::fatal "Unsupported architecture '$machine_arch' (expected x86_64 or aarch64)." ;;
esac
log::info "Detected system: $nix_system"

# Your $USER must be in the flake's `users` list, or the switch can't find a config.
users_line=$(grep -E '^\s*users\s*=' "$FLAKE_FILE" | head -n1)
if ! echo "$users_line" | grep -qw "\"$USER\""; then
    log::warning "Your \$USER ('$USER') is not in the flake's users list:"
    log::info "  $users_line"
    log::info "Add it in $FLAKE_FILE, e.g.:  users = [ \"$USER\" \"runner\" ];"
    log::fatal "Username not configured — add it to the list above and re-run."
fi

# The Home Manager config to apply, e.g. "runner-x86_64-linux".
flake_attr="${USER}-${nix_system}"
log::info "Using flake config: ${flake_attr}"

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
NIX_FEATURES="--extra-experimental-features nix-command --extra-experimental-features flakes"

# shellcheck disable=SC2086
if nix $NIX_FEATURES run home-manager/master -- switch -b backup --flake "${NIX_DIR}#${flake_attr}"; then
    log::success "Home Manager applied successfully."
else
    log::error "home-manager switch failed."
    log::info "Common fixes:"
    log::bullet "Open a new shell so 'nix' and the HM profile are on PATH, then re-run."
    log::bullet "Check the username/system lines in $FLAKE_FILE."
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
  │ linuxbrew still works — remove it only once you're happy with Nix.   │
  │ Full guide: docs/NIX.md                                              │
  └──────────────────────────────────────────────────────────────────────┘

EOF

log::success "Nix setup complete!"
