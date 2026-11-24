#!/bin/bash
#
#  ▓▓▓▓▓▓▓▓▓▓
# ░▓ author ▓ Akash Goyal
# ░▓ file   ▓ scripts/setup/tmux.sh
# ░▓▓▓▓▓▓▓▓▓▓
#
# ------------------------------------------------------------------------------
# tmux plugins: install TPM and every `set -g @plugin` from tmux.conf, so tmux
# is fully set up before it is first started. Idempotent: re-running only
# installs plugins that are missing. Run by install.sh (after stowing) and by
# `make tmux`; `--update` also updates the installed plugins.
#
# Uses a throwaway tmux server started WITHOUT tmux.conf: TPM's installer only
# needs a running server + TMUX_PLUGIN_MANAGER_PATH (it reads the plugin list
# from tmux.conf itself), and loading the real config would let tmux-continuum
# restore/overwrite your saved sessions on that temporary server.
# ------------------------------------------------------------------------------

DOTFILES_DIR="${DOTFILES_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"
export DOTFILES_DIR
CORE_FILE="${DOTFILES_DIR}/scripts/lib/core.sh"

if [[ ! -f "$CORE_FILE" ]]; then
    echo "Error: Core library not found at $CORE_FILE" >&2
    exit 1
fi

# shellcheck source=scripts/lib/core.sh
source "$CORE_FILE"
set -euo pipefail

readonly TMUX_CONF="${XDG_CONFIG_HOME:-$HOME/.config}/tmux/tmux.conf"
readonly PLUGIN_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/tmux/plugins"
readonly TPM_DIR="${PLUGIN_DIR}/tpm"
readonly TPM_REPO="https://github.com/tmux-plugins/tpm"
readonly SOCKET="dotfiles-setup-$$"

cleanup() {
    tmux -L "$SOCKET" kill-server >/dev/null 2>&1 || true
    rm -f "${TMUX_TMPDIR:-/tmp}/tmux-$(id -u)/${SOCKET}" 2>/dev/null || true
}
trap cleanup EXIT

main() {
    local update=0
    [[ "${1:-}" == "--update" ]] && update=1

    if ! command_exists tmux || ! command_exists git; then
        warning "tmux or git not installed — skipping tmux plugin setup"
        return 0
    fi
    if [[ ! -f "$TMUX_CONF" ]]; then
        warning "$TMUX_CONF not found (stow the tmux package first) — skipping"
        return 0
    fi

    info "Setting up tmux plugins (TPM)..."
    if [[ ! -d "$TPM_DIR" ]]; then
        git clone -q --depth=1 "$TPM_REPO" "$TPM_DIR"
        success "TPM installed to $TPM_DIR"
    fi

    tmux -L "$SOCKET" -f /dev/null new-session -d -s setup
    tmux -L "$SOCKET" set-environment -g TMUX_PLUGIN_MANAGER_PATH "${PLUGIN_DIR}/"
    local socket_path
    socket_path=$(tmux -L "$SOCKET" display-message -p '#{socket_path}')

    # TPM's scripts call plain `tmux`; $TMUX points them at the throwaway server.
    TMUX="${socket_path},0,0" "${TPM_DIR}/bin/install_plugins" | sed 's/^/    /'
    if (( update )); then
        TMUX="${socket_path},0,0" "${TPM_DIR}/bin/update_plugins" all | sed 's/^/    /'
    fi

    local wanted installed=0 name
    wanted=$(grep -cE "^[[:space:]]*set(-option)? +-g +@plugin" "$TMUX_CONF" || true)
    for name in $(grep -E "^[[:space:]]*set(-option)? +-g +@plugin" "$TMUX_CONF" \
                  | sed -E "s/.*@plugin +['\"]?([^'\"]+)['\"]?.*/\1/" | xargs -n1 basename); do
        [[ -d "${PLUGIN_DIR}/${name}" ]] && installed=$((installed + 1))
    done
    if (( installed == wanted )); then
        success "tmux plugins ready (${installed}/${wanted}) in ${PLUGIN_DIR}"
    else
        warning "tmux plugins: ${installed}/${wanted} installed — start tmux and press prefix + I"
        return 1
    fi
}

main "$@"
