#!/usr/bin/env zsh
#                     █████
#                    ░░███
#   █████████  █████  ░███████
#  ░█░░░░███  ███░░   ░███░░███
#  ░   ███░  ░░█████  ░███ ░███
#    ███░   █ ░░░░███ ░███ ░███
#   █████████ ██████  ████ █████
#  ░░░░░░░░░ ░░░░░░  ░░░░ ░░░░░
#
#  ▓▓▓▓▓▓▓▓▓▓
# ░▓ author ▓ Akash Goyal
# ░▓ file   ▓ zsh/local/aliases.zsh
# ░▓▓▓▓▓▓▓▓▓▓
# ░░░░░░░░░░
#
#█▓▒░
# ------------------------------------------------------------------------------
# General Aliases
# ------------------------------------------------------------------------------

# Disable glob patterns for faster command execution
alias find='noglob find'
alias fd='noglob fd'

# ------------------------------------------------------------------------------
# File Listing Aliases (using eza, a modern replacement for ls)
# ------------------------------------------------------------------------------
alias l="eza -l --icons --git -a"                         # List all files with git status
alias lt="eza --tree --level=2 --long --icons --git"      # Tree view, 2 levels deep
alias ld="eza -lD"                                        # List only directories
alias lf="eza -lF --color=always | grep -v /"             # List only files
alias lh="eza -dl .* --group-directories-first"           # List hidden files
alias ll="eza -al --group-directories-first"              # List all, directories first
alias ls="eza -lF --color=always --sort=size | grep -v /" # List files by size

# ------------------------------------------------------------------------------
# File Operations and Viewing
# ------------------------------------------------------------------------------
# Use bat instead of cat for better syntax highlighting
alias cat="bat"                                    # Syntax-highlighted cat
alias catn="bat --style=plain"                     # Plain output (no line numbers)
alias preview="bat --color=always --style=numbers" # Preview with line numbers

# ------------------------------------------------------------------------------
# System Navigation and Management
# ------------------------------------------------------------------------------
alias c="clear"             # Clear terminal
alias path='print -l $path' # Print PATH entries

# ------------------------------------------------------------------------------
# Global Aliases (can be used anywhere in command line)
# ------------------------------------------------------------------------------
alias -g H=" --help"               # Show help
alias -g L="| less"                # Pipe to less
alias -g R="2>&1 | tee output.txt" # Redirect and save output
alias -g T="| tail -n +2"          # Skip first line
alias -g V=" --version"

# ------------------------------------------------------------------------------
# Development and Package Management
# ------------------------------------------------------------------------------
alias list-npm-globals="npm list -g --depth=0" # List global npm packages

# ------------------------------------------------------------------------------
# Network Utilities
# ------------------------------------------------------------------------------
# Get public IP and location information
alias myip="curl -s ipinfo.io/ip" # Get public IP address

# ------------------------------------------------------------------------------
# System Utilities
# ------------------------------------------------------------------------------
# Disk usage with sorting
alias du='du -sh * | sort -hr' # Human-readable disk usage
alias df='df -h'               # Human-readable disk free
alias top='htop'               # Better top command

# ------------------------------------------------------------------------------
# Basic Tmux Aliases
# ------------------------------------------------------------------------------
alias tn='tmux new-session -s'         # Create new session
alias tk='tmux kill-session -t'        # Kill session
alias tl='tmux list-sessions'          # List sessions
alias td='tmux detach'                 # Detach from session
alias tc='clear && tmux clear-history' # Clear tmux history

# ------------------------------------------------------------------------------
# OS-Specific Aliases
# ------------------------------------------------------------------------------
case "$(uname -s)" in
    Darwin)
        # macOS system update function (more reliable than alias)
        update_system() {
            echo "🔄 Updating macOS..."
            sudo softwareupdate -i -a
        }

        # Homebrew updates
        update_brew() {
            echo "🔄 Updating Homebrew..."
            brew update && brew upgrade && brew upgrade --cask && brew cleanup
        }

        # Combined update command
        update() {
            update_system
            update_brew
            if command -v npm >/dev/null 2>&1; then
                echo "🔄 Updating npm packages..."
                npm update -g
            fi
        }

        # Cleanup
        alias cleanup="find . -type f -name '*.DS_Store' -ls -delete"

        # Prevent system from sleeping (1 hour)
        alias caffeinate1h='caffeinate -u -t 3600'
        ;;

    Linux)
        # APT package management (Debian/Ubuntu)
        if command -v apt-get >/dev/null 2>&1; then
            alias apt_update='sudo apt-get update && sudo apt-get -y upgrade && echo "✅ System updated"'
            alias apt_clean='sudo apt-get clean && sudo apt-get autoclean && sudo apt-get autoremove && echo "✅ Cleaned"'
            alias apt_maintain='apt_update && apt_clean'
            alias apt_search='apt-cache search'
            alias apt_info='apt-cache show'
            alias apt_list='dpkg --list'
        fi

        # Homebrew updates (if installed on Linux)
        if command -v brew >/dev/null 2>&1; then
            update_brew() {
                echo "🔄 Updating Homebrew..."
                brew update && brew upgrade && brew cleanup
            }
        fi
        ;;
esac
