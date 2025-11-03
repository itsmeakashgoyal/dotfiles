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
