#!/usr/bin/env zsh
# ------------------------------------------------------------------------------
# Vi Mode — vim keybindings in the shell
# Loaded before atuin (10) and television (09) which re-bind Ctrl+R / Ctrl+T,
# so those shortcuts keep working even with vi mode active.
# ------------------------------------------------------------------------------

bindkey -v

# Reduce ESC delay from 400ms to 10ms
export KEYTIMEOUT=1

# ------------------------------------------------------------------------------
# Mode indicator — shows [N] in right prompt when in normal mode
# ------------------------------------------------------------------------------
_vi_mode_indicator() {
    case "$KEYMAP" in
        vicmd) echo '%F{yellow}[N]%f' ;;
        *)     echo '' ;;
    esac
}

zle-keymap-select() {
    zle reset-prompt
}
zle -N zle-keymap-select

zle-line-init() {
    zle -K viins
    zle reset-prompt
}
zle -N zle-line-init

# Add mode indicator to right prompt (appends; doesn't replace existing RPROMPT)
_vi_rprompt_hook() {
    RPROMPT='$(_vi_mode_indicator)'
}
add-zsh-hook precmd _vi_rprompt_hook

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
