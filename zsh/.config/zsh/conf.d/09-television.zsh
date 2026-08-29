#!/usr/bin/env zsh
#
#  ▓▓▓▓▓▓▓▓▓▓
# ░▓ author ▓ Akash Goyal
# ░▓ file   ▓ zsh/.config/zsh/conf.d/09-television.zsh
# ░▓▓▓▓▓▓▓▓▓▓
#
# Television (https://github.com/alexpasmantier/television) — sole fuzzy
# finder, replaces fzf entirely. Provides:
#   Ctrl+T  — smart autocomplete (context-aware: files/dirs/branches)
#   Ctrl+R  — shell history search
#   Tab     — tv after space, zsh built-in completion mid-word

# Initialize zoxide if available
if command -v zoxide >/dev/null 2>&1; then
    eval "$(zoxide init zsh --cmd cd --hook prompt)"
fi

# Clipboard helper (used by other scripts)
_clipcopy() {
    if command -v pbcopy >/dev/null 2>&1; then cat | pbcopy
    elif command -v xclip >/dev/null 2>&1; then cat | xclip -selection clipboard
    elif command -v xsel >/dev/null 2>&1; then cat | xsel --clipboard --input
    else cat >/dev/null; fi
}

# Check if television is installed
if ! command -v tv >/dev/null 2>&1; then
    return 0
fi

# Initialize television shell integration (sets up Ctrl+T and Ctrl+R)
eval "$(tv init zsh)"

# ------------------------------------------------------------------------------
# Tab Key Override
# After a space → television smart autocomplete (context-aware)
# Mid-word     → zsh built-in completion (expand-or-complete)
# Empty line   → zsh built-in completion
# ------------------------------------------------------------------------------
_tv_or_complete() {
    if [[ -z "$LBUFFER" ]]; then
        zle expand-or-complete
    elif [[ "${LBUFFER[-1]}" == " " ]]; then
        zle tv-smart-autocomplete
    else
        zle expand-or-complete
    fi
}
zle -N _tv_or_complete
bindkey '^I' _tv_or_complete

# ------------------------------------------------------------------------------
# Helper Functions
# ------------------------------------------------------------------------------
# Open selected file in $EDITOR
tve() { local file; file=$(tv "$@") && [[ -n "$file" ]] && ${EDITOR:-nvim} "$file"; }

# cd into selected directory
tvd() { local dir; dir=$(tv dirs "$@") && [[ -n "$dir" ]] && cd "$dir" && l; }

# Interactive process killer
tv-kill() {
    local pid
    pid=$(ps -ef | sed 1d | tv | awk '{print $2}')
    [[ -n "$pid" ]] && kill -${1:-9} "$pid"
}
alias fk='tv-kill'
