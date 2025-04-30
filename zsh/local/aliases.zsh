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
alias myip="curl ipinfo.io/ip"                       # Get public IP address
alias whereami='npx @rafaelrinaldi/whereami -f json' # Get location info in JSON format

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

# Per-platform settings, will override the above commands
case $(uname) in
Darwin)
  # Update macOS and all package managers
  alias update='sudo softwareupdate -i -a && \  # System updates
                brew update && \                 # Update Homebrew
                brew upgrade && \                # Upgrade formulae
                brew cleanup && \                # Clean up Homebrew
                npm update -g && \               # Update global npm packages
                gem update --system && \         # Update RubyGems
                gem update' # Update gems

  # Individual update commands
  alias update_system='sudo softwareupdate -i -a' # Only system updates
  alias update_brew='brew update && brew upgrade && \
                    brew upgrade --cask && brew cleanup' # Only Homebrew updates

  # Cleanup
  alias cleanup="find . -type f -name '*.DS_Store' -ls -delete" # Remove .DS_Store files

  # caffeinate: Prevent the system from sleeping
  alias ch='caffeinate -u -t 3600'
  ;;
Linux)
  # Update and upgrade system packages
  alias apt_update='sudo apt-get update && \
                    sudo apt-get -y upgrade && \
                    echo "✅ System updated successfully"'

  # Clean up system packages
  alias apt_clean='sudo apt-get clean && \
                    sudo apt-get autoclean && \
                    sudo apt-get autoremove && \
                    echo "✅ System cleaned successfully"'

  # Combined update and cleanup
  alias apt_maintain='apt_update && apt_clean'

  # update linux homebrew and its packages
  alias update_brew='brew update && brew upgrade && brew cleanup' # Only Homebrew updates

  # ------------------------------------------------------------------------------
  # Package Management
  # ------------------------------------------------------------------------------
  # Search for package
  alias apt_search='apt-cache search'

  # Show package info
  alias apt_info='apt-cache show'

  # List installed packages
  alias apt_list='dpkg --list'
  ;;
esac
