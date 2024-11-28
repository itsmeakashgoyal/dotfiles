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

# Smart session creation/attachment using zoxide
t() {
    if [[ -z "$1" ]]; then
        ta
        return
    fi

    # Generate session name from directory
    local dir_path=$(z -e "$1")
    local sesh=$(basename "$dir_path" | tr '. ' '_')

    if [[ -z "$TMUX" ]]; then
        # Outside tmux: create/attach to session
        (cd "$dir_path" && tmux new -A -s "$sesh")
    elif tmux has-session -t="$sesh" 2>/dev/null; then
        # Inside tmux: switch to existing session
        tmux switch -t "$sesh"
    else
        # Inside tmux: create and switch to new session
        (cd "$dir_path" &&
            tmux new -A -s "$sesh" -d &&
            tmux switch -t "$sesh")
    fi
}

# Create enhanced tmux session with git branch info
create_tmux_session() {
    local dir_path="$1"
    [[ -z "$dir_path" ]] && {
        echo "Error: No directory specified"
        return 1
    }

    # Add to zoxide database
    zoxide add "$dir_path" &>/dev/null

    # Generate session name
    local folder=$(basename "$dir_path")
    local session_name=$(echo "$folder" | tr ' .:' '_')

    # Append git branch if available
    if [[ -d "$dir_path/.git" ]]; then
        local branch=$(git -C "$dir_path" symbolic-ref --short HEAD 2>/dev/null)
        [[ -n "$branch" ]] && session_name+="_${branch}"
    fi

    # Create or attach to session
    if ! tmux has-session -t "$session_name" 2>/dev/null; then
        tmux new-session -d -s "$session_name" -c "$dir_path"
    fi

    # Attach or switch to session
    if [[ -z "$TMUX" ]]; then
        tmux attach -t "$session_name"
    else
        tmux switch-client -t "$session_name"
    fi
}

# Change to current tmux session directory
cds() {
    local session_path=$(tmux display-message -p '#{session_path}')
    [[ -n "$session_path" ]] && cd "$session_path"
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
