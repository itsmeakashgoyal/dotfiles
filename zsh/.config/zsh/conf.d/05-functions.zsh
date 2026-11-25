#!/usr/bin/env zsh
#
#  ▓▓▓▓▓▓▓▓▓▓
# ░▓ author ▓ Akash Goyal
# ░▓ file   ▓ zsh/.config/zsh/conf.d/05-functions.zsh
# ░▓▓▓▓▓▓▓▓▓▓
#
# Shell functions: tmux session helpers (aliases tn/tk/td/tl in 04-aliases.zsh)
# and the project jumper (p / ⌃G).

# Attach to a session (or pick one; creates `misc` if none given).
ta() {
    if [[ -n "$1" ]]; then
        tmux attach -t "$1"
        return
    fi
    tmux ls 2>/dev/null &&
        read "tmux_session?Session name/number (default: misc): " &&
        tmux attach -t "${tmux_session:-misc}" ||
        tmux new -s "${tmux_session:-misc}"
}

# Switch to a session picked with tv.
tls() {
    local session
    session=$(tmux list-sessions -F "#{session_name}" | tv)
    [[ -n "$session" ]] && tmux switch-client -t "$session"
}

# Kill a session picked with tv.
tks() {
    local session
    session=$(tmux list-sessions -F "#{session_name}" | tv)
    [[ -n "$session" ]] && tmux kill-session -t "$session"
}

# Project jumper (bin/.local/bin/proj): pick a git repo, most-visited first.
# Outside tmux: cd there. Inside tmux: switch to (or create) a session for it.
p() {
    if [[ -n "$TMUX" ]]; then
        proj --tmux
    else
        local dir
        dir=$(proj) && [[ -n "$dir" ]] && cd "$dir"
    fi
}

# ⌃G anywhere on the command line runs `p`, then redraws the prompt.
_dotfiles_proj_widget() {
    zle -I
    p </dev/tty
    zle reset-prompt
}
zle -N _dotfiles_proj_widget
bindkey -M viins '^G' _dotfiles_proj_widget
bindkey -M vicmd '^G' _dotfiles_proj_widget
