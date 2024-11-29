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
# ░▓ file   ▓ zsh/local/autocompletion.zsh
# ░▓▓▓▓▓▓▓▓▓▓
# ░░░░░░░░░░
#
#█▓▒░
# ------------------------------------------------------------------------------
# Zsh Completion Configuration
# ------------------------------------------------------------------------------
# autocompletion systems
loc=${ZDOTDIR:-"${HOME}/dotfiles/zsh"}
fpath=($loc/completion $fpath)
autoload bashcompinit && bashcompinit
autoload -Uz compinit && compinit -d "$XDG_CACHE_HOME"/zsh/zcompdump-"$ZSH_VERSION"

# sources
[[ $commands[gh] ]] && source <(gh completion -s zsh)

# ------------------------------------------------------------------------------
# Basic Completion Settings
# ------------------------------------------------------------------------------
# Enable caching
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "$XDG_CACHE_HOME"

# Prevent tab completion on paste
zstyle ':completion:*' insert-tab pending

# Set completion display limits
zstyle ':completion:*' list-max-items 20
zstyle ':completion:*' menu select=long
zstyle ':completion:*' verbose yes      # Verbose output
zstyle ':completion:*' group-name ''    # Group by categories
zstyle ':completion:*' use-compctl false
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'
zstyle ':completion:*:kill:*' command 'ps -u $USER -o pid,%cpu,tty,cputime,cmd'
# hide parents
zstyle ':completion:*' ignored-patterns '.|..|.DS_Store|**/.|**/..|**/.DS_Store|**/.git'

# ------------------------------------------------------------------------------
# Completion Formatting
# ------------------------------------------------------------------------------
# Set descriptions and messages
zstyle ':completion:*:descriptions' format '[%d]'
zstyle ':completion:*:messages' format '%d'
zstyle ':completion:*:warnings' format 'No matches for: %d'
zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s

# Colors and styling
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*:directory-stack' list-colors '=(#b) #([0-9]#)*( *)==95=38;5;12'

# ------------------------------------------------------------------------------
# Matching Configuration
# ------------------------------------------------------------------------------
# Completion matching rules
zstyle ':completion:*' completer _expand _complete _correct _approximate
zstyle ':completion:*' matcher-list \
    'm:{a-z}={A-Z}' \
    'm:{[:lower:]}={[:upper:]} r:|[._-]=* r:|=*' \
    'm:{[:lower:]}={[:upper:]}' \
    'm:{[:lower:]}={[:upper:]}'

# Error tolerance
zstyle ':completion:*' max-errors 2

# ------------------------------------------------------------------------------
# Git-specific Settings
# ------------------------------------------------------------------------------
# Disable sorting for git checkout
zstyle ':completion:*:git-checkout:*' sort false

# ------------------------------------------------------------------------------
# FZF-tab Configuration
# ------------------------------------------------------------------------------
# Directory preview
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'eza -1 --color=always $realpath'

# switch groups using `[` and `]`
zstyle ':fzf-tab:*' switch-group '[' ']'

# use the same layout as others and respect my default
local fzf_flags
zstyle -a ':fzf-tab:*' fzf-flags fzf_flags
fzf_flags=( "${fzf_flags[@]}" '--layout=reverse-list' )
zstyle ':fzf-tab:*' fzf-flags $fzf_flags
zstyle ':fzf-tab:*' fzf-command ftb-tmux-popup
