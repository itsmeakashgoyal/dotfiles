#!/usr/bin/env zsh

#                     █████
#                    ░░███
#   █████████  █████  ░███████    ██████  ████████   █████ █████
#  ░█░░░░███  ███░░   ░███░░███  ███░░███░░███░░███ ░░███ ░░███
#  ░   ███░  ░░█████  ░███ ░███ ░███████  ░███ ░███  ░███  ░███
#    ███░   █ ░░░░███ ░███ ░███ ░███░░░   ░███ ░███  ░░███ ███
#   █████████ ██████  ████ █████░░██████  ████ █████  ░░█████
#  ░░░░░░░░░ ░░░░░░  ░░░░ ░░░░░  ░░░░░░  ░░░░ ░░░░░    ░░░░░
#
#  ▓▓▓▓▓▓▓▓▓▓
# ░▓ author ▓ Akash Goyal
# ░▓ file   ▓ zsh/.zshenv
# ░▓▓▓▓▓▓▓▓▓▓
# ░░░░░░░░░░
#
#█▓▒░
# ------------------------------------------------------------------------------
# Zsh Environment Configuration
# ------------------------------------------------------------------------------
# .zshenv is sourced on all shell invocations
# It should contain:
# - Environment variables
# - Command search path
# - Other important environment settings
# Note: Avoid commands that produce output or assume tty attachment

# ------------------------------------------------------------------------------
# XDG Base Directory Specification
# ------------------------------------------------------------------------------
# https://specifications.freedesktop.org/basedir-spec/latest/
export XDG_CONFIG_HOME="${HOME}/.config"
export XDG_CACHE_HOME="${HOME}/.cache"
export XDG_DATA_HOME="${HOME}/.local/share"
export XDG_STATE_HOME="${HOME}/.local/state"
export XDG_RUNTIME_DIR="${HOME}/.runtime"
export XDG_DOTFILES_DIR="${HOME}/dotfiles"

# Create XDG directories if they don't exist
for dir in "$XDG_CONFIG_HOME" \
  "$XDG_CACHE_HOME" \
  "$XDG_DATA_HOME" \
  "$XDG_STATE_HOME" \
  "$XDG_RUNTIME_DIR"; do
  [[ ! -d "$dir" ]] && mkdir -p "$dir"
done

# ------------------------------------------------------------------------------
# Application Paths
# ------------------------------------------------------------------------------
export ZDOTDIR="${XDG_DOTFILES_DIR}/zsh"                  # Zsh config directory
export GIT_CONFIG_GLOBAL="${XDG_DOTFILES_DIR}/git/config" # Git config

# add a config file for wget
# export WGET_CONFIG_PATH="${XDG_DOTFILES_DIR}/config/.wgetrc"

# ------------------------------------------------------------------------------
# Editor Configuration
# ------------------------------------------------------------------------------
if command -v nvim >/dev/null 2>&1; then
  export EDITOR="nvim"
  export VISUAL="nvim"
else
  export EDITOR="vim"
  export VISUAL="vim"
fi

# ------------------------------------------------------------------------------
# History Configuration
# ------------------------------------------------------------------------------
# History file location and size
export HISTFILE="${HOME}/.zsh_history"
export HISTSIZE=1000000   # Internal history list size
export SAVEHIST=$HISTSIZE # History file size
export HISTDUP=erase      # Erase duplicates in history

# History Options
setopt appendhistory        # Append to history file
setopt sharehistory         # Share history between sessions
setopt hist_reduce_blanks   # Remove unnecessary blanks
setopt hist_ignore_space    # Ignore space-prefixed commands
setopt hist_ignore_all_dups # Remove older duplicate entries
setopt hist_save_no_dups    # Don't save duplicates
setopt hist_ignore_dups     # Don't record duplicates
setopt hist_find_no_dups    # Skip duplicates when searching
setopt hist_verify          # Show command before executing from history
setopt inc_append_history   # Add commands immediately
setopt bang_hist            # Enable history expansion

# ------------------------------------------------------------------------------
# Shell Options
# ------------------------------------------------------------------------------
setopt NO_HUP # Don't kill background jobs on exit

# ------------------------------------------------------------------------------
# Performance Optimizations
# ------------------------------------------------------------------------------
# Disable glob patterns for faster command execution
alias find='noglob find'
alias fd='noglob fd'
alias fzf='noglob fzf'

# Disable flow control (ctrl-s/ctrl-q)
setopt noflowcontrol
