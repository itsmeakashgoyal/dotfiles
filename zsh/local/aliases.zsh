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
# Custom Functions
# ------------------------------------------------------------------------------

# Navigate up multiple directories
# Usage: up 3 (goes up 3 directories)
up() {
    local d=""
    limit=$1
    for ((i = 1; i <= limit; i++)); do
        d=$d/..
    done
    d=$(echo $d | sed 's/^\///')
    if [ -z "$d" ]; then
        d=..
    fi
    cd $d
}
