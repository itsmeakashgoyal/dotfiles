#!/usr/bin/env zsh
# .zprofile is sourced on login shells and before .zshrc. As a general rule, it should not change the
# shell environment at all.

# Detect OS type
OS_TYPE=$(uname)

if [ "$OS_TYPE" = "Darwin" ]; then
    # macOS specific settings
    if [ -x "/opt/homebrew/bin/brew" ]; then
        # For Apple Silicon Macs
        export PATH="/opt/homebrew/bin:$PATH"
        eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [ -x "/usr/local/bin/brew" ]; then
        # For Intel Macs
        eval "$(/usr/local/bin/brew shellenv)"
    fi

elif [ "$OS_TYPE" = "Linux" ]; then
    # Linux specific settings
    # Add any Linux-specific PATH or environment variables here
    if [ -x "/home/linuxbrew/.linuxbrew/bin/brew" ]; then
        export PATH="/home/linuxbrew/.linuxbrew/bin:$PATH"
        eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
    fi
fi
