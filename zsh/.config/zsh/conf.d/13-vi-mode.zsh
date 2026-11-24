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
# Mode indicator
# ------------------------------------------------------------------------------
# p10k (the default prompt) shows the mode itself: its prompt_char turns into ❮
# in normal mode and redraws on mode switches through its own zle hooks, which
# overriding zle-keymap-select / zle-line-init here would break. So the code
# below is only for starship (DOTFILES_PROMPT=starship).
if [[ "$DOTFILES_PROMPT" != "p10k" ]]; then
    zle-keymap-select() {
        zle reset-prompt
    }
    zle -N zle-keymap-select

    # Every line starts in insert mode. No `zle reset-prompt` here: the prompt
    # was just drawn; redrawing re-ran starship on every Enter (~20ms each).
    zle-line-init() {
        zle -K viins
    }
    zle -N zle-line-init

    # [N] in the right prompt in normal mode, appended to (not replacing)
    # starship's right prompt. A parameter expansion, not $(function), so it
    # forks nothing: (M) keeps $KEYMAP only when it is `vicmd`, :+ turns that
    # into [N]. %3F = yellow; NOT %F{yellow}: its `}` would close ${...} early.
    # Guarded so re-sourcing doesn't stack copies.
    _VI_MODE_INDICATOR='${${(M)KEYMAP:#vicmd}:+%3F[N]%f}'
    if [[ "$RPROMPT" != *"(M)KEYMAP:#vicmd"* ]]; then
        RPROMPT="${RPROMPT:+$RPROMPT }$_VI_MODE_INDICATOR"
    fi
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
