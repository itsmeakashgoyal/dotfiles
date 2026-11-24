#!/usr/bin/env zsh
#
#  ▓▓▓▓▓▓▓▓▓▓
# ░▓ author ▓ Akash Goyal
# ░▓ file   ▓ zsh/.config/zsh/conf.d/05-functions.zsh
# ░▓▓▓▓▓▓▓▓▓▓
#
# Shell functions: tmux session helpers (aliases tn/tk/td/tl in 04-aliases.zsh).

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
