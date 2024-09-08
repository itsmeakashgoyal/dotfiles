# ------------------------------------------------------------------------------
# Aliases and functions for tmux
# ------------------------------------------------------------------------------

# Attach to session
ta() {
    if [ -n "$1" ]; then
        tmux attach -t $1
        return
    fi

    tmux ls && read tmux_session && tmux attach -t ${tmux_session:-misc} || tmux new -s ${tmux_session:-misc}
}

# Open or create tmux session with z argument
t() {
    if [ -z "$1" ]; then
        ta
        return
    fi

    local sesh=$(basename $(z -e $1) | tr . _)

    if [ -z $TMUX ]; then
        (z $1 && tmux new -A -s $sesh)
    elif tmux has-session -t=$sesh 2> /dev/null; then
        (tmux switch -t $sesh)
    else
        (z $1 && tmux new -A -s $sesh -d && tmux switch -t $sesh)
    fi
}

# Attaches tmux to a session (example: ta portal)
# alias ta='tmux attach -t'
# Creates a new session
alias tn='tmux new-session -s '
# Kill session
alias tk='tmux kill-session -t '
# Lists all ongoing sessions
alias tl='tmux list-sessions'
# Detach from session
alias td='tmux detach'
# Tmux Clear pane
alias tc='clear; tmux clear-history; clear'

function cds() {
    session=$(tmux display-message -p '#{session_path}')
    cd "$session"
}

function create_tmux_session() {
    local RESULT="$1"
    zoxide add "$RESULT" &>/dev/null
    local FOLDER=$(basename "$RESULT")
    local SESSION_NAME=$(echo "$FOLDER" | tr ' .:' '_')
    
    if [ -d "$RESULT/.git" ]; then
        SESSION_NAME+="_$(git -C "$RESULT" symbolic-ref --short HEAD 2>/dev/null)"
    fi
    
    if ! tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
        tmux new-session -d -s "$SESSION_NAME" -c "$RESULT"
    fi
    
    if [ -z "$TMUX" ]; then
        tmux attach -t "$SESSION_NAME"
    else
        tmux switch-client -t "$SESSION_NAME"
    fi
}
