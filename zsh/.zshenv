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

## Make sure directories actually exist
xdg_dirs=("$XDG_CONFIG_HOME" "$XDG_CACHE_HOME" "$XDG_DATA_HOME" "$XDG_STATE_HOME" "$XDG_RUNTIME_DIR")
for dir in "${xdg_dirs[@]}"; do
    if [[ ! -d "$dir" ]]; then
        mkdir -p "$dir"
    fi
done

# ------------------------------------------------------------------------------
# Application Paths
# ------------------------------------------------------------------------------
export ZDOTDIR="${XDG_DOTFILES_DIR}/zsh"                  # Zsh config directory
export GIT_CONFIG_GLOBAL="${XDG_DOTFILES_DIR}/git/config" # Git config
