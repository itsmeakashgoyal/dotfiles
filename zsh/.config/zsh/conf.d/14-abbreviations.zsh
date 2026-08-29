#!/usr/bin/env zsh
#
#  ▓▓▓▓▓▓▓▓▓▓
# ░▓ author ▓ Akash Goyal
# ░▓ file   ▓ zsh/.config/zsh/conf.d/14-abbreviations.zsh
# ░▓▓▓▓▓▓▓▓▓▓
#
# Space-triggered abbreviations — type the trigger then press space to expand.
# Adapted from Piotr1215/dotfiles
#
# Usage examples:
#   cp file.txt _bak<space>     → cp -a file.txt{,.bak-20260331-1930}
#   echo hello _xrg wc<space>  → echo hello | xargs -I {} wc {}
#   newdir _ind<space>          → mkdir -p newdir && <previous cmd>
#   _chmo<space>                → chmod +x <fzf-selected file>

# ------------------------------------------------------------------------------
# Abbreviation registry
# ------------------------------------------------------------------------------
typeset -A abbrevs
abbrevs=(
    "_bak"  '__abbrev_backup'
    "_xrg"  '__abbrev_xargs'
    "_ind"  '__abbrev_into_new_dir'
    "_chmo" '__abbrev_chmod_file'
)

# ------------------------------------------------------------------------------
# Expansion functions
# ------------------------------------------------------------------------------

# _bak — create a timestamped backup of a file
# Usage: cp file.txt _bak<space>
__abbrev_backup() {
    local cmd="$LBUFFER"
    cmd=${cmd%% bak}
    local words=("${(z)cmd}")
    local last_arg="${words[-1]}"
    LBUFFER="cp -a $last_arg{,.bak-$(date +%Y%m%d-%H%M)}"
}

# _xrg — pipe previous command through xargs
# Usage: echo hello _xrg wc<space>
__abbrev_xargs() {
    local cmd="$LBUFFER"
    local words=("${(z)cmd}")
    local xargs_cmd="${words[-1]}"
    cmd=${cmd% * *}
    LBUFFER="$cmd | xargs -I {} $xargs_cmd {}"
}

# _ind — mkdir and run command into the new directory
# Usage: newdir _ind<space>
__abbrev_into_new_dir() {
    local cmd="$LBUFFER"
    local words=("${(z)cmd}")
    local last_arg="${words[-1]}"
    cmd=${cmd%% $last_arg ind}
    cmd=${cmd%%[[:space:]]}
    LBUFFER="mkdir -p $last_arg && $cmd"
}

# _chmo — chmod +x a file selected via fzf
# Usage: _chmo<space>
__abbrev_chmod_file() {
    local selected_file
    selected_file=$(fd --type f | fzf --height 40% --reverse)
    if [[ -n "$selected_file" ]]; then
        LBUFFER="chmod +x $selected_file"
        zle accept-line
    fi
}

# ------------------------------------------------------------------------------
# Expansion engine — intercepts space key
# ------------------------------------------------------------------------------
expand-abbrev() {
    local MATCH
    LBUFFER=${LBUFFER%%(#m)[_a-zA-Z0-9]#}
    if [[ -n "${abbrevs[$MATCH]}" ]]; then
        ${abbrevs[$MATCH]}
        zle self-insert
    else
        LBUFFER+=$MATCH
        zle self-insert
    fi
}

zle -N expand-abbrev
bindkey " " expand-abbrev
bindkey -M isearch " " self-insert
