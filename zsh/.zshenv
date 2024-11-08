#!/usr/bin/env zsh
# .zshenv: Zsh environment file, loaded for every shell session
# ------------------------------------------------------------------------------

# Set up XDG base directories
# Spec: https://specifications.freedesktop.org/basedir-spec/latest/index.html
# ------------------------------------------------------------------------------
export XDG_CONFIG_HOME="${HOME}/.config"
export XDG_CACHE_HOME="${HOME}/.cache"
export XDG_DATA_HOME="${HOME}/.local/share"
export XDG_STATE_HOME="${HOME}/.local/state"
export XDG_RUNTIME_DIR="${HOME}/.runtime"

# Create XDG directories if they don't exist
for dir in "$XDG_CONFIG_HOME" "$XDG_CACHE_HOME" "$XDG_DATA_HOME" "$XDG_STATE_HOME" "$XDG_RUNTIME_DIR"; do
  [[ ! -d "$dir" ]] && mkdir -p "$dir"
done

# Set default editor (uncomment if needed)
# export EDITOR="nvim"
# export VISUAL="nvim"

# Note: Moving ZDOTDIR setting to .zprofile to avoid sourcing issues
# Set ZDOTDIR if you want to reorganize zsh files
export ZDOTDIR="${XDG_CONFIG_HOME}/zsh"
