#!/usr/bin/env zsh
#                     █████
#                    ░░███
#   █████████  █████  ░███████
#  ░█░░░░███  ███░░   ░███░░███
#  ░   ███░  ░░█████  ░███ ░███
#    ███░   █ ░░░░███ ░███ ░███
#   █████████ ██████  ████ █████
#  ░░░░░░░░░ ░░░░░░  ░░░░ ░░░░░
#
#  ▓▓▓▓▓▓▓▓▓▓
# ░▓ author ▓ Akash Goyal
# ░▓ file   ▓ zsh/local/tmux.zsh
# ░▓▓▓▓▓▓▓▓▓▓
# ░░░░░░░░░░
#
#█▓▒░
# ------------------------------------------------------------------------------
# Tmux Configuration: Aliases and Functions
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Basic Tmux Aliases
# ------------------------------------------------------------------------------
alias tn='tmux new-session -s'         # Create new session
alias tk='tmux kill-session -t'        # Kill session
alias tl='tmux list-sessions'          # List sessions
alias td='tmux detach'                 # Detach from session
alias tc='clear && tmux clear-history' # Clear tmux history

# ------------------------------------------------------------------------------
# Session Management Functions
# ------------------------------------------------------------------------------
# Attach to existing session or create new one
ta() {
    if [[ -n "$1" ]]; then
        tmux attach -t "$1"
        return
    fi

    # Interactive session selection
    tmux ls 2>/dev/null &&
        read "tmux_session?Session name/number (default: misc): " &&
        tmux attach -t "${tmux_session:-misc}" ||
        tmux new -s "${tmux_session:-misc}"
}

# ------------------------------------------------------------------------------
# Enhanced Session Management
# ------------------------------------------------------------------------------
# Interactive session selection with preview
tls() {
    local session=$(tmux list-sessions -F "#{session_name}" |
        fzf --preview 'tmux list-windows -t {}' \
            --preview-window=right:50% \
            --prompt="Select session: ")

    [[ -n "$session" ]] && tmux switch-client -t "$session"
}

# Kill selected session interactively
tks() {
    local session=$(tmux list-sessions -F "#{session_name}" |
        fzf --preview 'tmux list-windows -t {}' \
            --preview-window=right:50% \
            --prompt="Select session to kill: ")

    [[ -n "$session" ]] && tmux kill-session -t "$session"
}
