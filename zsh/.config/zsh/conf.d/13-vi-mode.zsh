#!/usr/bin/env zsh
#
#  ▓▓▓▓▓▓▓▓▓▓
# ░▓ author ▓ Akash Goyal
# ░▓ file   ▓ zsh/.config/zsh/conf.d/13-vi-mode.zsh
# ░▓▓▓▓▓▓▓▓▓▓
#
# Vi keybindings in the shell. Loaded before atuin (10) and television (09)
# which re-bind Ctrl+R / Ctrl+T, so those shortcuts keep working even with
# vi mode active.

bindkey -v

# Reduce ESC delay from 400ms to 10ms
export KEYTIMEOUT=1

# ------------------------------------------------------------------------------
# Mode indicator — shows [N] in right prompt when in normal mode
# ------------------------------------------------------------------------------
# A parameter expansion (not a `$(function)` call), so rendering it forks
# nothing: (M) keeps $KEYMAP only when it is `vicmd`, and :+ turns that into [N].
_VI_MODE_INDICATOR='${${(M)KEYMAP:#vicmd}:+%F{yellow}[N]%f}'

zle-keymap-select() {
    zle reset-prompt
}
zle -N zle-keymap-select

# Every line starts in insert mode. No `zle reset-prompt` here: the prompt was
# just drawn, and redrawing it re-ran starship on every Enter (~20ms per prompt).
zle-line-init() {
    zle -K viins
}
zle -N zle-line-init

# Append the mode indicator to the RIGHT prompt WITHOUT clobbering it.
#
# The prompt engine (Starship by default, or p10k) sets $RPROMPT once at init
# to a `promptsubst` template — Starship's is `$(starship prompt --right ...)`,
# which renders the conda/venv module. A plain `RPROMPT='$(_vi_mode_indicator)'`
# (what this used to do, on a precmd hook) overwrote that template every prompt,
# so the right side went blank. Instead, append our own `$(...)` template once;
# both re-evaluate on every render and on the `zle reset-prompt` fired by
# zle-keymap-select below, so the [N] indicator still updates live on mode
# switch while Starship's right prompt survives.
#
# Guarded so re-sourcing the file (e.g. a manual `source ~/.zshrc`) doesn't
# stack duplicate copies of the indicator.
if [[ "$RPROMPT" != *"(M)KEYMAP:#vicmd"* ]]; then
    RPROMPT="${RPROMPT:+$RPROMPT }$_VI_MODE_INDICATOR"
fi

# ------------------------------------------------------------------------------
# Preserve useful Emacs bindings in insert mode
# ------------------------------------------------------------------------------
bindkey '^A' beginning-of-line
bindkey '^E' end-of-line
bindkey '^K' kill-line
bindkey '^U' backward-kill-line
bindkey '^W' backward-kill-word
bindkey '^L' clear-screen
bindkey '^?' backward-delete-char   # Backspace works after ESC→insert
# iTerm2 profile sends ESC b / ESC f for ⌥← / ⌥→ (word jumps; see settings/iterm)
bindkey '^[b' backward-word
bindkey '^[f' forward-word

# ------------------------------------------------------------------------------
# Normal-mode extras
# ------------------------------------------------------------------------------
# jk / kj as ESC alternative in insert mode
bindkey -M viins 'jk' vi-cmd-mode
bindkey -M viins 'kj' vi-cmd-mode

# History search with j/k in normal mode
bindkey -M vicmd 'k' up-line-or-history
bindkey -M vicmd 'j' down-line-or-history

# / searches history in normal mode (like vim command-mode search)
bindkey -M vicmd '/' history-incremental-search-backward
bindkey -M vicmd '?' history-incremental-search-forward

# Edit current command in $EDITOR with v in normal mode
autoload -Uz edit-command-line
zle -N edit-command-line
bindkey -M vicmd 'v' edit-command-line
