#!/usr/bin/env bash

# Enable strict mode for better error handling
set -euo pipefail

# Set new line and tab for word splitting
IFS=$'\n\t'

# Check if running inside a tmux session
if [ -z "${TMUX:-}" ]; then
    echo "Error: This script must be run from inside a tmux session." >&2
    exit 1
fi

# Get the current tmux pane ID
TMUX_PANE=$(tmux display-message -p '#D')

# Function to send keys to the current tmux pane
send_keys() {
    tmux send-keys -t "$TMUX_PANE" "$@"
}

# Save and quit Neovim
send_keys 'Escape' C-m ':wq' C-m

# Wait for Neovim to close
sleep 0.5

# Detach the script from Neovim and wait a bit to ensure Neovim exits
# Then restart Neovim (using lvim)
(
    nohup bash -c "
        sleep 0.5
        tmux send-keys -t \"$TMUX_PANE\" 'lvim' C-m
    " &>/dev/null &
)

echo "Neovim restart initiated."