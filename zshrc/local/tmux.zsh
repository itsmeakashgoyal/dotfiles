# ------------------------------------------------------------------------------
# Aliases and functions for tmux
# ------------------------------------------------------------------------------

# Function to attach to an existing tmux session or create a new one
ta() {
    if [ -n "$1" ]; then
        # If a session name is provided, attach to it
        tmux attach -t "$1"
        return
    fi

    # If no session name is provided, list sessions and prompt for selection
    tmux ls && read "tmux_session?Enter session name or number: " && tmux attach -t "${tmux_session:-misc}" || tmux new -s "${tmux_session:-misc}"
}

# Open or create tmux session with z argument
t() {
    if [ -z "$1" ]; then
        # If no argument is provided, call the 'ta' function
        ta
        return
    fi

    # Use zoxide to get the directory and create a session name
    local sesh=$(basename $(z -e $1) | tr . _)

    if [ -z $TMUX ]; then
        # If not in a tmux session, create a new one
        (z $1 && tmux new -A -s $sesh)
    elif tmux has-session -t=$sesh 2> /dev/null; then
        # If the session exists, switch to it
        (tmux switch -t $sesh)
    else
        # If the session does not exist, create it and switch to it
        (z $1 && tmux new -A -s $sesh -d && tmux switch -t $sesh)
    fi
}

# Tmux session management aliases
alias tn='tmux new-session -s '  # Create a new session
alias tk='tmux kill-session -t ' # Kill a session
alias tl='tmux list-sessions'    # List all ongoing sessions
alias td='tmux detach'           # Detach from current session
alias tc='clear; tmux clear-history; clear'  # Clear tmux pane and history

# Function to change to the current tmux session's directory
function cds() {
    local session_path=$(tmux display-message -p '#{session_path}')
    cd "$session_path"
}

# Function to create a new tmux session with enhanced naming
function create_tmux_session() {
    local RESULT="$1"
    zoxide add "$RESULT" &>/dev/null
    local FOLDER=$(basename "$RESULT")
    local SESSION_NAME=$(echo "$FOLDER" | tr ' .:' '_')
    
    # Append git branch name to session name if it's a git repository
    if [ -d "$RESULT/.git" ]; then
        SESSION_NAME+="_$(git -C "$RESULT" symbolic-ref --short HEAD 2>/dev/null)"
    fi
    
    # Create a new session if it doesn't exist
    if ! tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
        tmux new-session -d -s "$SESSION_NAME" -c "$RESULT"
    fi
    
    # Attach to the session or switch to it if already in tmux
    if [ -z "$TMUX" ]; then
        tmux attach -t "$SESSION_NAME"
    else
        tmux switch-client -t "$SESSION_NAME"
    fi
}

# ------------------------------------------------------------------------------
# Additional tmux-related configurations (if needed)
# ------------------------------------------------------------------------------

# Add any other tmux-specific configurations, functions, or aliases here
# For example:
# - Custom tmux key bindings
# - Tmux plugin configurations
# - Additional tmux-related utility functions

# Example: Function to list tmux sessions with a preview
# function tls() {
#     tmux list-sessions -F "#{session_name}" | 
#     fzf --preview 'tmux list-windows -t {}'
# }