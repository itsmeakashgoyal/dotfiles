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

# Locale and TTY (safe in all shells)
export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"
export GPG_TTY="$(tty 2>/dev/null || true)"

# ------------------------------------------------------------------------------
# Application Paths
# ------------------------------------------------------------------------------
export ZDOTDIR="${XDG_CONFIG_HOME}/zsh"
