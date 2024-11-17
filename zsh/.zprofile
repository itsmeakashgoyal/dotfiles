#!/usr/bin/env zsh

# ------------------------------------------------------------------------------
# Login Shell Configuration
# ------------------------------------------------------------------------------
# .zprofile is sourced on login shells and before .zshrc
# It should only contain environment setup and path modifications

# ------------------------------------------------------------------------------
# OS Detection and Homebrew Setup
# ------------------------------------------------------------------------------
case "$(uname)" in
    "Darwin")
        # macOS: Configure Homebrew based on architecture
        if [[ -x "/opt/homebrew/bin/brew" ]]; then
            # Apple Silicon path
            eval "$(/opt/homebrew/bin/brew shellenv)"
        elif [[ -x "/usr/local/bin/brew" ]]; then
            # Intel Mac path
            eval "$(/usr/local/bin/brew shellenv)"
        fi
        ;;
        
    "Linux")
        # Linux: Configure Linuxbrew if available
        if [[ -x "/home/linuxbrew/.linuxbrew/bin/brew" ]]; then
            eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
        fi
        ;;
esac

# ------------------------------------------------------------------------------
# Path Safety Check
# ------------------------------------------------------------------------------
# Ensure critical paths exist
typeset -U path PATH  # Remove duplicates in PATH

# Add common local binary paths if they exist
local -a local_paths=(
    "$HOME/.local/bin"
    "$HOME/bin"
)

for local_path in $local_paths; do
    [[ -d "$local_path" ]] && path=("$local_path" $path)
done