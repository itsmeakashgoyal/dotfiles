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
# ░▓ file   ▓ zsh/local/fzf.zsh
# ░▓▓▓▓▓▓▓▓▓▓
# ░░░░░░░░░░
#
#█▓▒░
# ------------------------------------------------------------------------------
# FZF Configuration
# https://github.com/junegunn/fzf
# ------------------------------------------------------------------------------
# Set up fzf key bindings and fuzzy completion
FZF_BASE_PATH="$(brew --prefix fzf)" # This will automatically get the current version
FZF_SHELL_PATH="$FZF_BASE_PATH/shell"
FZF_BIN_PATH="$FZF_BASE_PATH/bin"
source <(fzf --zsh)
eval "$(zoxide init --cmd cd zsh)"

# ------------------------------------------------------------------------------
# Color Scheme (Gruvbox Material)
# ------------------------------------------------------------------------------
local color_scheme=(
    '--color=bg+:#3c3836'         # Selected background
    '--color=bg:#282828'          # Normal background
    '--color=spinner:#d65d0e'     # Loading spinner (bright orange)
    '--color=hl:#fe8019'          # Highlighted substrings (orange)
    '--color=fg:#ebdbb2'          # Text (light text)
    '--color=header:#b8bb26'      # Header text (green)
    '--color=info:#83a598'        # Info text (blue)
    '--color=pointer:#fabd2f'     # Pointer arrow (yellow)
    '--color=marker:#d3869b'      # Multi-select marker (pinkish magenta)
    '--color=fg+:#fbf1c7'         # Selected text (lightest text)
    '--color=prompt:#b8bb26'      # Prompt (green)
    '--color=hl+:#fabd2f'         # Selected highlighted (yellow)
    '--color=selected-bg:#504945' # Selected item background (dark gray)
)

# ------------------------------------------------------------------------------
# Core FZF Configuration
# ------------------------------------------------------------------------------
# Enhanced preview command with syntax highlighting and file type handling
export FZF_PREVIEW_COMMAND="([[ -f {} ]] && (bat --style=numbers,changes --color=always {} || cat {}) || \
                           ([[ -d {} ]] && (eza --tree --icons --level=2 --color=always {} || ls -la {})) || \
                           echo {} 2> /dev/null)"

# Default command using fd for better performance and respecting .gitignore
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git --exclude node_modules --strip-cwd-prefix'

# Default options combining color scheme, preview, and behavior
export FZF_DEFAULT_OPTS="
    ${color_scheme[*]}
    --multi
    --height=80%
    --layout=reverse
    --border=rounded
    --padding=0
    --margin=1
    --prompt='∷ ' 
    --pointer='▶ '
    --marker='✔ '
    --separator='~'
    --scrollbar='▌ '
    --cycle
    --scroll-off=4
    --info=right
    --bind='ctrl-/:toggle-preview'
    --bind='ctrl-y:execute-silent(echo {} | pbcopy)'
    --bind='ctrl-space:toggle+down'
"

# ------------------------------------------------------------------------------
# FZF Command-specific Configurations
# ------------------------------------------------------------------------------
# CTRL-T - File search
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_CTRL_T_OPTS="
    --preview='$FZF_PREVIEW_COMMAND'
    --bind='enter:execute(nvim {})'
    --header='Enter to edit, CTRL-Y to copy path'
"

# ALT-C - Directory search
export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git --exclude node_modules'
export FZF_ALT_C_OPTS="
    --preview='eza --tree --icons --level=2 --color=always {}'
    --header='Enter to cd, CTRL-Y to copy path'
"

# ------------------------------------------------------------------------------
# Custom Keybindings and Aliases
# ------------------------------------------------------------------------------

# Aliases
alias fzf="fzf --preview='$FZF_PREVIEW_COMMAND'"
alias fk='fzf-kill'

# ------------------------------------------------------------------------------
# fzf Functions
# ------------------------------------------------------------------------------
# Process management
fzf-kill() {
    local pid
    pid=$(ps -ef | sed 1d | fzf -m --header='Select process(es) to kill' | awk '{print $2}')
    [ -n "$pid" ] && echo $pid | xargs kill -${1:-9}
}

# Load auto-completion and key bindings
[[ $- == *i* ]] && source "${FZF_SHELL_PATH}/shell/completion.zsh" 2>/dev/null
source "${FZF_SHELL_PATH}/key-bindings.zsh"

# Use fd to respect .gitignore, include hidden files and exclude `.git` folders
# - The first argument to the function ($1) is the base path to start traversal
_fzf_compgen_path() {
    fd --hidden --exclude ".git" . "$1"
}

# Use fd to generate the list for directory completion
_fzf_compgen_dir() {
    fd --type d --hidden --exclude ".git" . "$1"
}

# Advanced customization of fzf options via _fzf_comprun function
# - The first argument to the function is the name of the command.
# - Make sure to pass the rest of the arguments to fzf.
_fzf_comprun() {
    local command=$1
    shift

    case "$command" in
    cd) fzf --preview 'eza --tree --color=always {} | head -200' "$@" ;;
    tree) fzf --preview 'tree -C {}' "$@" ;;
    nvim) fzf --preview 'bat --style=numbers --color=always {}' "$@" ;;
    *) fzf --preview 'bat -n --color=always {}' "$@" ;;
    esac
}
