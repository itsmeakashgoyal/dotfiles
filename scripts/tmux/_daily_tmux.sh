#!/usr/bin/env bash

#################################################
#      File: _daily_tmux.sh                      #
#      Description: Daily tmux session setup      #
#      Status: Development                       #
#################################################

# ------------------------------------------------------------------------------
# Configuration
# ------------------------------------------------------------------------------
SESSION="Daily"
WINDOW_NAME="daily"

# ------------------------------------------------------------------------------
# Helper Functions
# ------------------------------------------------------------------------------
create_session() {
    # Create new session in detached state with 256 color support
    tmux -2 new-session -d -s "$SESSION"
}

setup_layout() {
    # Rename the default window
    tmux rename-window -t "$SESSION:0" "$WINDOW_NAME"

    # Create horizontal split
    tmux split-window -h

    # Configure left pane
    tmux select-pane -t 0
    tmux send-keys "echo 'Left pane initialized'" Enter

    # Create and configure bottom-right pane
    tmux split-window -v
    tmux select-pane -t 1
    tmux send-keys "echo 'Right pane initialized'" Enter
}

# ------------------------------------------------------------------------------
# Main Function
# ------------------------------------------------------------------------------
main() {
    # Check if session already exists
    if tmux has-session -t "$SESSION" 2>/dev/null; then
        echo "Session '$SESSION' already exists. Attaching..."
        tmux -2 attach-session -t "$SESSION"
        exit 0
    fi

    # Create and configure new session
    create_session
    setup_layout

    # Select default window and attach to session
    tmux select-window -t "$SESSION:0"
    tmux -2 attach-session -t "$SESSION"
}

# Run main function
main
