#!/usr/bin/env zsh
#
#  ▓▓▓▓▓▓▓▓▓▓
# ░▓ author ▓ Akash Goyal
# ░▓ file   ▓ zsh/.config/zsh/conf.d/04-aliases.zsh
# ░▓▓▓▓▓▓▓▓▓▓
#
# ------------------------------------------------------------------------------
# General Aliases
# ------------------------------------------------------------------------------

# Disable glob patterns for faster command execution
alias find='noglob find'
alias fd='noglob fd'

# ------------------------------------------------------------------------------
# File Listing Aliases (using eza, a modern replacement for ls)
# ------------------------------------------------------------------------------
if command -v eza >/dev/null 2>&1; then
  alias l="eza -l --icons --git -a"                         # List all files with git status
  alias lt="eza --tree --level=2 --long --icons --git"      # Tree view, 2 levels deep
  alias ld="eza -lD --icons"                                # List only directories
  alias lf="eza -l --only-files --icons"                    # List only files
  alias lh="eza -dl .* --group-directories-first"           # List hidden files
  alias ll="eza -al --icons --group-directories-first"      # List all, directories first
  alias ls="eza -l --only-files --icons --sort=size"        # List files by size (accepts paths)
else
  alias l="ls -la"
fi

# ------------------------------------------------------------------------------
# File Operations and Viewing
# ------------------------------------------------------------------------------
# Use bat instead of cat for better syntax highlighting
if command -v bat >/dev/null 2>&1; then
  alias cat="bat"                                    # Syntax-highlighted cat
  alias catn="bat --style=plain"                     # Plain output (no line numbers)
  alias preview="bat --color=always --style=numbers" # Preview with line numbers
else
  alias cat="cat"
fi

# ------------------------------------------------------------------------------
# System Navigation and Management
# ------------------------------------------------------------------------------
alias c="clear"             # Clear terminal
alias path='print -l $path' # Print PATH entries

# Typos and shortcuts seen in shell history (cd.. ×20, q ×15, cler)
alias cd..='cd ..'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias q='exit'
alias cler='clear'

# ------------------------------------------------------------------------------
# Global Aliases (can be used anywhere in command line)
# ------------------------------------------------------------------------------
alias -g C='| pbcopy'              # Copy to clipboard: `cmd C`

# Suffix aliases (auto-open files by extension)
alias -s md=nvim
alias -s txt=nvim
alias -s yaml=nvim
alias -s json=nvim

# Git root navigation
alias grt='cd "$(git rev-parse --show-toplevel)"'

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
command -v htop >/dev/null 2>&1 && alias top='htop' # Better top command
command -v fastfetch >/dev/null 2>&1 && alias sysinfo='fastfetch' # System info

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
case "$OS_TYPE" in   # Darwin|Linux, set by os-detect.sh (no uname fork)
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
