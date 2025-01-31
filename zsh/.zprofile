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
case "$(uname)" in
"Darwin")
    # macOS: Configure Homebrew based on architecture
    if [[ -x "/opt/homebrew/bin/brew" ]]; then
        # Apple Silicon path
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
    ;;

"Linux")
    # Linux: Configure Linuxbrew if available
    if [[ -x "/home/linuxbrew/.linuxbrew/bin/brew" ]]; then
        eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
    fi
    ;;
esac
