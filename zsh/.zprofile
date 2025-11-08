#!/usr/bin/env zsh

#                                             ██████   ███  ████
#                                            ███░░███ ░░░  ░░███
#   █████████ ████████  ████████   ██████   ░███ ░░░  ████  ░███   ██████
#  ░█░░░░███ ░░███░░███░░███░░███ ███░░███ ███████   ░░███  ░███  ███░░███
#  ░   ███░   ░███ ░███ ░███ ░░░ ░███ ░███░░░███░     ░███  ░███ ░███████
#    ███░   █ ░███ ░███ ░███     ░███ ░███  ░███      ░███  ░███ ░███░░░
#   █████████ ░███████  █████    ░░██████   █████     █████ █████░░██████
#  ░░░░░░░░░  ░███░░░  ░░░░░      ░░░░░░   ░░░░░     ░░░░░ ░░░░░  ░░░░░░
#             ░███
#             █████
#            ░░░░░
#
#  ▓▓▓▓▓▓▓▓▓▓
# ░▓ author ▓ Akash Goyal
# ░▓ file   ▓ zsh/.zprofile
# ░▓▓▓▓▓▓▓▓▓▓
# ░░░░░░░░░░
#
#█▓▒░

# ------------------------------------------------------------------------------
# Login Shell Configuration
# ------------------------------------------------------------------------------
# .zprofile is sourced on login shells and before .zshrc
# It should only contain environment setup and path modifications

# ------------------------------------------------------------------------------
# OS Detection and Homebrew Setup
# ------------------------------------------------------------------------------
# OS-specific Homebrew setup
case "$(uname -s)" in
    Darwin)
        [[ -x "/opt/homebrew/bin/brew" ]] && eval "$(/opt/homebrew/bin/brew shellenv)"
        ;;
    Linux)
        [[ -x "/home/linuxbrew/.linuxbrew/bin/brew" ]] && eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
        ;;
esac

# ------------------------------------------------------------------------------
# First-run environment setup for login shells
# ------------------------------------------------------------------------------
# Ensure XDG directories exist (safe here; avoid in .zshenv)
mkdir -p "$XDG_CONFIG_HOME" "$XDG_CACHE_HOME" "$XDG_DATA_HOME" "$XDG_STATE_HOME" "$XDG_RUNTIME_DIR" 2>/dev/null

# Sensible default permissions for created files/dirs
umask 022
