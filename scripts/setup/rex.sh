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
#   3. App settings to match iTerm2: Gruvbox themes (imported once), font,
#      spacing, cursor, left Option = Alt, copy on select, key hints. Needs Rex
#      running with Settings → General → Remote Control on (`rex.client.
#      remoteControl`; this script turns it on while Rex is closed).
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
readonly FONT="JetBrainsMonoNL Nerd Font Mono"

# Rex finds its server under XDG_RUNTIME_DIR when set; macOS normally has none.
unset XDG_RUNTIME_DIR

rex() { "$REX_BIN" "$@"; }
# Run a client action in the app (quoted "do": it is also a shell keyword).
rex_do() { local c="$1"; shift; rex -C "$c" "do" "$@"; }

app_client() {
    rex client ls --json 2>/dev/null \
        | python3 -c 'import json,sys; c=[x for x in json.load(sys.stdin).get("clients",[]) if (x.get("info") or {}).get("kind")=="app"]; print(c[0].get("client_id","") if c else "")' 2>/dev/null || true
}

# Names of the custom themes already imported into the app (avoids duplicates).
imported_themes() {
    defaults export com.superlogical.rex - 2>/dev/null | python3 -c '
import json, plistlib, sys
d = plistlib.loads(sys.stdin.buffer.read())
for t in json.loads(d.get("Workspace.customThemes", "[]")): print(t.get("name", ""))' 2>/dev/null || true
}

# Terminal light/dark follows `dutils theme` (~/.config/dotfiles/theme), like iTerm2.
theme_scheme() {
    local m; m=$(cat "${HOME}/.config/dotfiles/theme" 2>/dev/null || echo dark)
    case "$m" in light) echo light ;; auto) echo auto ;; *) echo dark ;; esac
}

apply_app_settings() {
    local client; client=$(app_client)
    if [[ -z "$client" ]]; then
        warning "Rex app isn't running: open Rex and re-run \`make rex\` to apply its settings"
        return 0
    fi
    if ! rex_do "$client" client.setting.terminal.selection.copy_on_select value=true >/dev/null 2>&1; then
        warning "Rex app isn't accepting CLI actions: turn on Settings → General → Remote Control,"
        info "then re-run \`make rex\`."
        return 0
    fi

    local have f name
    have=$(imported_themes)
    for f in "${THEMES}/Gruvbox Dark" "${THEMES}/Gruvbox Light"; do
        name=$(basename "$f")
        grep -qxF "$name" <<<"$have" && continue
        rex_do "$client" client.theme.import path="$f" >/dev/null 2>&1 || warning "theme import failed: $f"
    done

    # Same look as the iTerm2 profile (settings/iterm/profile.json):
    # JetBrainsMonoNL Nerd Font Mono 18, 0.9 char width (-10%), 1.09 line
    # height (+9%), no ligatures, blinking block cursor, left ⌥ = Alt (Esc+).
    local s=client.setting failed=0 kv
    for kv in \
        "interface.appearance.scheme value=$(theme_scheme)" \
        "interface.appearance.tint value=true" \
        "terminal.typography.font value=${FONT}" \
        "terminal.typography.size value=18" \
        "terminal.typography.line_height value=9" \
        "terminal.advanced_fonts.character_spacing value=-10%" \
        "terminal.advanced_fonts.ligatures value=false" \
        "terminal.cursor.style value=block" \
        "terminal.cursor.blink value=normal" \
        "terminal.keyboard.option value=left_sends_alt" \
        "terminal.keyboard.sequence_hints value=true"; do
        rex_do "$client" "${s}.${kv%% *}" "${kv#* }" >/dev/null 2>&1 || { warning "could not set ${kv%% *}"; failed=1; }
    done
    (( failed )) || success "Rex app: Gruvbox ($(theme_scheme)), ${FONT} 18, iTerm2 spacing, block cursor, ⌥=Alt"
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

    # Let `rex do` drive the app (local socket, same user only). Rex rewrites
    # its prefs on quit, so only write this while the app is closed.
    if ! pgrep -xq Rex; then
        defaults write com.superlogical.rex rex.client.remoteControl -bool true
    fi

    apply_app_settings
    log_message "Rex setup completed"
}

trap 'print_error "$LINENO" "$BASH_COMMAND" "$?"' ERR

main "$@"
