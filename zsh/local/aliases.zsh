#!/usr/bin/env zsh
# ------------------------------------------------------------------------------
# General Aliases
# ------------------------------------------------------------------------------

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

# Tree command with sensible defaults
alias tree="tree -a -I '.git|node_modules|vendor'" # Ignore common directories

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
alias c="clear"                     # Clear terminal
alias reload="exec ${SHELL} -l"     # Reload shell
alias path='print -l $path'         # Print PATH entries
alias sshp="sshpass -p welcome ssh" # Quick SSH with password

# Directory navigation
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."

# ------------------------------------------------------------------------------
# Global Aliases (can be used anywhere in command line)
# ------------------------------------------------------------------------------
alias -g H=" --help"                                                                               # Show help
alias -g L="| less"                                                                                # Pipe to less
alias -g R="2>&1 | tee output.txt"                                                                 # Redirect and save output
alias -g T="| tail -n +2"                                                                          # Skip first line
alias -g V=" --version"                                                                            # Show version
alias -g W='| nvim -c "setlocal buftype=nofile bufhidden=wipe" -c "nnoremap <buffer> q :q!<CR>" -' # View in Neovim

# ------------------------------------------------------------------------------
# Development and Package Management
# ------------------------------------------------------------------------------
alias list-npm-globals="npm list -g --depth=0" # List global npm packages

# ------------------------------------------------------------------------------
# Custom Functions
# ------------------------------------------------------------------------------

# Search for text in files (improved grep)
# Usage: ftext "search term"
ftext() {
    # -i case-insensitive
    # -I ignore binary files
    # -H causes filename to be printed
    # -r recursive search
    # -n causes line number to be printed
    # optional: -F treat search term as a literal, not a regular expression
    # optional: -l only print filenames and not the matching lines ex. grep -irl "$1" *
    local search_term="$1"
    if [[ -z "$search_term" ]]; then
        echo "Usage: ftext 'search term'"
        return 1
    fi

    grep -iIHrn --color=always "$search_term" . | less -R
}

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

# Trim whitespace from string
# Usage: trim "  string with spaces  "
trim() {
    if [[ -z "$1" ]]; then
        echo "Usage: trim 'string to trim'"
        return 1
    fi
    local var="$*"
    # Remove leading whitespace
    var="${var#"${var%%[![:space:]]*}"}"
    # Remove trailing whitespace
    var="${var%"${var##*[![:space:]]}"}"
    echo -n "$var"
}

# Update fzf installation
# Usage: update-fzf
update-fzf() {
    local FZF_DIR="${HOME}/.config/.fzf"

    if [[ ! -d "$FZF_DIR" ]]; then
        echo "Error: fzf directory not found at $FZF_DIR"
        return 1
    fi

    echo "Updating fzf..."
    (cd "$FZF_DIR" && {
        git pull &&
            ./install --all &&
            echo "✓ fzf updated successfully!"
    }) || echo "✗ Failed to update fzf"
}
