#!/usr/bin/env zsh

# ------------------------------------------------------------------------------
# FZF Configuration
# https://github.com/junegunn/fzf
# ------------------------------------------------------------------------------

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

# Default preview window configuration
local preview_opts=(
    # '--preview-window=right:50%:noborder:hidden'
    # '--preview=${FZF_PREVIEW_COMMAND}'
    # '--bind=alt-p:toggle-preview'
)

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
    ${preview_opts[*]}
    --multi
    --height=80%
    --layout=reverse
    --border=rounded
    --cycle
    --scroll-off=4
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

# Custom completion function
_fzf_comprun() {
    local command=$1
    shift

    case "$command" in
    cd) fzf --preview 'tree -C {} | head -200' "$@" ;;
    tree) fzf --preview 'tree -C {}' "$@" ;;
    nvim) fzf --preview 'bat --style=numbers --color=always {}' "$@" ;;
    *) fzf "$@" ;;
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
