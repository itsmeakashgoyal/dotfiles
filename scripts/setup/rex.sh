#!/bin/bash
#
#  ▓▓▓▓▓▓▓▓▓▓
# ░▓ author ▓ Akash Goyal
# ░▓ file   ▓ scripts/setup/rex.sh
# ░▓▓▓▓▓▓▓▓▓▓
#
# ------------------------------------------------------------------------------
# Rex (Superlogical) setup, macOS. Safe to re-run; iTerm2 and tmux are untouched.
#
#   1. Validate + reload rex/.config/rex/init.lua (keys, project jumper, resume)
#   2. `rex terminfo setup`: TERM=xterm-rex, with an ssh guard so hosts without
#      the entry still get xterm-256color (adds one Include to ~/.ssh/config)
#   3. App settings to match iTerm2: Gruvbox Dark theme, JetBrainsMono Nerd
#      Font, left Option = Alt, copy on select, key-sequence hints. These need
#      Rex running with Settings → General → Remote Control on; otherwise the
#      manual steps are printed.
# Docs: https://www.superlogical.com/rex/docs
# ------------------------------------------------------------------------------

if [[ -n "${CI:-}" ]]; then
    echo "Skipping Rex setup in CI environment"
    exit 0
fi

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

readonly REX_APP="/Applications/Rex.app"
readonly REX_BIN="${HOME}/Library/Application Support/com.superlogical.rex/RexServer/Versions/Current/Rex Server.app/Contents/MacOS/rex"
readonly THEMES="${HOME}/.config/rex/themes"
readonly FONT="JetBrainsMono Nerd Font Mono"

# Rex finds its server under XDG_RUNTIME_DIR when set; macOS normally has none.
unset XDG_RUNTIME_DIR

rex() { "$REX_BIN" "$@"; }
# Run a client action in the app (quoted "do": it is also a shell keyword).
rex_do() { local c="$1"; shift; rex -C "$c" "do" "$@"; }

app_client() {
    rex client ls --json 2>/dev/null \
        | python3 -c 'import json,sys; c=[x for x in json.load(sys.stdin).get("clients",[]) if (x.get("info") or {}).get("kind")=="app"]; print(c[0].get("client_id","") if c else "")' 2>/dev/null || true
}

apply_app_settings() {
    local client; client=$(app_client)
    if [[ -z "$client" ]]; then
        warning "Rex app isn't running: open Rex and re-run \`make rex\` to apply its settings"
        return 0
    fi
    if ! rex_do "$client" client.setting.terminal.selection.copy_on_select value=true >/dev/null 2>&1; then
        warning "Rex app isn't accepting CLI actions. Either turn on Settings → General → Remote Control"
        info "and re-run \`make rex\`, or set these by hand (⇧⌘P opens the command palette):"
        info "  • Import Theme File → ${THEMES}/Gruvbox Dark (and Gruvbox Light), then Dark Theme → Gruvbox Dark"
        info "  • Terminal Font → ${FONT}, size 18   • Option Key → left Option sends Alt"
        info "  • Copy on Selection → on              • Show Key Sequence Hints → on"
        return 0
    fi
    local f
    for f in "${THEMES}/Gruvbox Dark" "${THEMES}/Gruvbox Light"; do
        rex_do "$client" client.theme.import path="$f" >/dev/null 2>&1 || warning "theme import failed: $f"
    done
    rex_do "$client" client.theme.change name="Gruvbox Dark" >/dev/null 2>&1 \
        || warning "select the theme by hand: ⇧⌘P → Change Theme… → Gruvbox Dark"
    rex_do "$client" client.setting.terminal.typography.font value="$FONT" >/dev/null 2>&1 || true
    rex_do "$client" client.setting.terminal.typography.size value=18 >/dev/null 2>&1 || true
    rex_do "$client" client.setting.terminal.keyboard.option value=left >/dev/null 2>&1 || true
    rex_do "$client" client.setting.terminal.keyboard.sequence_hints value=true >/dev/null 2>&1 || true
    success "Rex app: Gruvbox theme, ${FONT} 18, Option=Alt, copy on select, key hints"
}

main() {
    log_message "Rex setup started"
    if [[ ! -d "$REX_APP" || ! -x "$REX_BIN" ]]; then
        info "Rex not installed — skipping (https://www.superlogical.com/rex)"
        return 0
    fi

    info "Checking Rex config (~/.config/rex/init.lua)..."
    if rex config check >/dev/null 2>&1; then
        if rex config reload >/dev/null 2>&1; then
            success "Rex config loaded"
        else
            info "Rex server not running yet; the config loads when Rex starts"
        fi
    else
        rex config check || true
        error "Rex config has errors (see above)"
    fi

    local tstatus; tstatus=$(rex terminfo status 2>/dev/null || true)
    if [[ "$tstatus" == *"entry: xterm-rex is not installed"* ]]; then
        if rex terminfo setup >/dev/null 2>&1; then
            success "Rex terminfo (xterm-rex) + ssh guard installed"
        else
            warning "rex terminfo setup failed (non-fatal); run it by hand to see why"
        fi
    fi

    apply_app_settings
    log_message "Rex setup completed"
}

trap 'print_error "$LINENO" "$BASH_COMMAND" "$?"' ERR

main "$@"
