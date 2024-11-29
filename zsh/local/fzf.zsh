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
[[ -f ~/.fzf.zsh ]] && source ~/.fzf.zsh
zvm_after_init_commands+=('[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh')
eval "$(zoxide init --cmd cd zsh)"

# ------------------------------------------------------------------------------
# Color Scheme (Catppuccin Mocha)
# ------------------------------------------------------------------------------
local color_scheme=(
    '--color=bg+:#313244'         # Selected background
    '--color=bg:#1e1e2e'          # Normal background
    '--color=spinner:#f5e0dc'     # Loading spinner
    '--color=hl:#f38ba8'          # Highlighted substrings
    '--color=fg:#cdd6f4'          # Text
    '--color=header:#f38ba8'      # Header text
    '--color=info:#cba6f7'        # Info text
    '--color=pointer:#f5e0dc'     # Pointer arrow
    '--color=marker:#b4befe'      # Multi-select marker
    '--color=fg+:#cdd6f4'         # Selected text
    '--color=prompt:#cba6f7'      # Prompt
    '--color=hl+:#f38ba8'         # Selected highlighted
    '--color=selected-bg:#45475a' # Selected item background
)

# ------------------------------------------------------------------------------
# Preview Configuration
# ------------------------------------------------------------------------------
# Define preview command with proper file type handling
export FZF_PREVIEW_COMMAND="([[ -f {} ]] && (bat --style=numbers --color=always {} || cat {}) || \
                           ([[ -d {} ]] && tree -C {} || echo {} 2> /dev/null) || \
                           echo {} 2> /dev/null)"

local fzf_default_opts=(
    '--preview-window right:50%:noborder:hidden'
    '--color "preview-bg:234"'
    '--bind "alt-p:toggle-preview"'
    '--color "prompt:green,header:grey,spinner:grey,info:grey,hl:blue,hl+:blue,pointer:red"'
)

# ------------------------------------------------------------------------------
# Core FZF Configuration
# ------------------------------------------------------------------------------
# Default command for file search (using fd)
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git --strip-cwd-prefix'

# Default options combining color scheme, preview, and behavior
export FZF_DEFAULT_OPTS="
    ${color_scheme[*]}
    --multi
    --height=80%
    --layout=reverse
    --border=block
    --border-label-pos=0
    --preview-window=border-sharp
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
# CTRL-T configuration (file search)
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_CTRL_T_OPTS="
    --preview='${FZF_PREVIEW_COMMAND}'
    --bind='enter:execute(nvim {})'
"

# ALT-C configuration (directory search)
export FZF_ALT_C_COMMAND="fd --type=d --hidden --strip-cwd-prefix --exclude .git"
export FZF_ALT_C_OPTS="
    --preview='tree -C {} | head -200'
    --bind='enter:execute(cd {} && ls)'
"

# ------------------------------------------------------------------------------
# Path and Completion Setup
# ------------------------------------------------------------------------------
# Add FZF to PATH if not already present
if [[ ! "$PATH" == *${HOME}/.config/.fzf/bin* ]]; then
    export PATH="${PATH:+${PATH}:}/${HOME}/.config/.fzf/bin"
fi

# Load auto-completion
[[ $- == *i* ]] && source "${HOME}/.config/.fzf/shell/completion.zsh" 2>/dev/null

# Load key bindings
source "${HOME}/.config/.fzf/shell/key-bindings.zsh"

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

# ------------------------------------------------------------------------------
# Custom Keybindings and Aliases
# ------------------------------------------------------------------------------

# Aliases
alias of="fzf --preview 'bat --style=numbers --color=always --line-range :500 {}' | xargs nvim"
alias fh="history 1 | fzf --tac | cut -c 8-" # Search command history

# ------------------------------------------------------------------------------
# Navigation Functions
# ------------------------------------------------------------------------------
# Change directory and list contents
cx() {
    cd "$@" && l
}

# Fuzzy find directory and cd into it
fcd() {
    local dir
    dir=$(find . -type d -not -path '*/\.*' | fzf --preview 'tree -C {} | head -200')
    if [[ -n "$dir" ]]; then
        cd "$dir" && l
    fi
}

# Fuzzy find file and copy path to clipboard
f() {
    local file
    file=$(find . -type f -not -path '*/\.*' | fzf --preview 'bat --style=numbers --color=always {}')
    if [[ -n "$file" ]]; then
        echo "$file" | pbcopy
        echo "Path copied to clipboard: $file"
    fi
}

# Fuzzy find file and open in neovim
fv() {
    local file
    file=$(find . -type f -not -path '*/\.*' | fzf --preview 'bat --style=numbers --color=always {}')
    if [[ -n "$file" ]]; then
        nvim "$file"
    fi
}
