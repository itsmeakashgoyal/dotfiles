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
# ░▓ file   ▓ zsh/local/env.zsh
# ░▓▓▓▓▓▓▓▓▓▓
# ░░░░░░░░░░
#
#█▓▒░

# ------------------------------------------------------------------------------
# Shell Options
# ------------------------------------------------------------------------------
setopt glob_dots     # Include dotfiles in globbing
setopt no_auto_menu  # Require extra TAB for menu
setopt extended_glob # Extended globbing capabilities
setopt NO_HUP        # Don't kill background jobs on exit
setopt noflowcontrol # Disable flow control (ctrl-s/ctrl-q)
setopt autocd              # change directory just by typing its name
setopt correct             # auto correct mistakes
setopt interactivecomments # allow comments in interactive mode
setopt magicequalsubst     # enable filename expansion for arguments of the form ‘anything=expression’
setopt nonomatch           # hide error message if there is no match for the pattern
setopt notify              # report the status of background jobs immediately
setopt numericglobsort     # sort filenames numerically when it makes sense
setopt promptsubst         # enable command substitution in prompt

#######################################################
# ZSH Keybindings
#######################################################

bindkey -v
# bindkey '^p' history-search-backward
# bindkey '^n' history-search-forward
# bindkey '^[w' kill-region
# bindkey ' ' magic-space                           # do history expansion on space
bindkey "^[[A" history-beginning-search-backward  # search history with up key
bindkey "^[[B" history-beginning-search-forward   # search history with down key

# ------------------------------------------------------------------------------
# Performance Optimizations
# ------------------------------------------------------------------------------
# Disable glob patterns for faster command execution
alias find='noglob find'
alias fd='noglob fd'
alias fzf='noglob fzf'

# Eza colors: https://github.com/eza-community/eza/blob/main/man/eza_colors.5.md
EZA_COLORS="reset:$LS_COLORS"                      # Reset default colors, like making everything yellow
EZA_COLORS+="da=36:"                               # Timestamps
EZA_COLORS+="ur=0:uw=0:ux=0:ue=0:"                 # User permissions
EZA_COLORS+="gr=0:gw=0:gx=0:"                      # Group permissions
EZA_COLORS+="tr=0:tw=0:tx=0:"                      # Other permissions
EZA_COLORS+="xa=0:"                                # Extended attribute marker ('@')
EZA_COLORS+="xx=38;5;240:"                         # Punctuation ('-')
EZA_COLORS+="nb=38;5;240:"                         # Files under 1 KB
EZA_COLORS+="nk=0:"                                # Files under 1 MB
EZA_COLORS+="nm=37:"                               # Files under 1 GB
EZA_COLORS+="ng=38;5;250:"                         # Files under 1 TB
EZA_COLORS+="nt=38;5;255:"                         # Files over 1 TB
EZA_COLORS+="do=32:*.md=32:"                       # Documents
EZA_COLORS+="co=35:*.zip=35:"                      # Archives
EZA_COLORS+="tm=38;5;242:cm=38;5;242:.*=38;5;242:" # Hidden and temporary files
export EZA_COLORS

# ------------------------------------------------------------------------------
# Homebrew Configuration
# ------------------------------------------------------------------------------
# Core Homebrew settings
if command -v brew &> /dev/null; then
    export HOMEBREW_INSTALL_BADGE='☕'    # Homebrew install badge: beer sucks, coffee rules
    export HOMEBREW_NO_ANALYTICS=1       # Disable analytics collection
    export HOMEBREW_AUTOREMOVE=1         # Automatically remove unused dependencies
fi

# ------------------------------------------------------------------------------
# Language and Locale Settings
# ------------------------------------------------------------------------------
export LC_COLLATE=en_US.UTF-8
export LC_CTYPE=en_US.UTF-8
export LC_MESSAGES=en_US.UTF-8
export LC_MONETARY=en_US.UTF-8
export LC_NUMERIC=en_US.UTF-8
export LC_TIME=en_US.UTF-8
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
export LANGUAGE=en_US.UTF-8
export LESSCHARSET=utf-8

export MANPATH="/usr/local/man:$MANPATH"

# ------------------------------------------------------------------------------
# Terminal and Editor Settings
# ------------------------------------------------------------------------------
if command -v nvim >/dev/null 2>&1; then
    export EDITOR="nvim"
    export VISUAL="nvim"
    alias vi="nvim"
else
    export EDITOR="vim"
    export VISUAL="vim"
fi

# Colorful man pages
export LESS_TERMCAP_mb=$'\e[1;31m'   # begin bold
export LESS_TERMCAP_md=$'\e[1;31m'   # begin double-bright mode
export LESS_TERMCAP_me=$'\e[0m'      # end all mode
export LESS_TERMCAP_se=$'\e[0m'      # end standout-mode
export LESS_TERMCAP_so=$'\e[01;33m'  # begin standout-mode
export LESS_TERMCAP_ue=$'\e[0m'      # end underline
export LESS_TERMCAP_us=$'\e[1;4;32m' # begin underline

# Bat: https://github.com/sharkdp/bat
# export BAT_THEME="Squirrelsong Dark"

# Ripgrep config file location
# export RIPGREP_CONFIG_PATH="$XDG_DOTFILES_DIR/dots/.ripgreprc"

# Config file for wget
# export WGET_CONFIG_PATH="${XDG_DOTFILES_DIR}/dots/.wgetrc"

# ------------------------------------------------------------------------------
# History Configuration
# ------------------------------------------------------------------------------
# History file location and size
export HISTFILE="${HOME}/.zsh_history"
export HISTSIZE=130000 # Internal history list size
export SAVEHIST=100000 # History file size
export HISTDUP=erase   # Erase duplicates in history
export LESSHISTFILE=-
# HIST_STAMPS=yyyy/mm/dd

# History Options
setopt append_history # Append to history file
setopt extended_history
setopt hist_expire_dups_first
setopt share_history        # Share history between sessions
setopt hist_reduce_blanks   # Remove unnecessary blanks
setopt hist_ignore_space    # Ignore space-prefixed commands
setopt hist_ignore_all_dups # Remove older duplicate entries
setopt hist_save_no_dups    # Don't save duplicates
setopt hist_ignore_dups     # Don't record duplicates
setopt hist_find_no_dups    # Skip duplicates when searching
setopt hist_verify          # Show command before executing from history
setopt inc_append_history   # Add commands immediately
setopt bang_hist            # Enable history expansion

# ------------------------------------------------------------------------------
# Zsh Completion Configuration
# ------------------------------------------------------------------------------
# Set up completion system
loc=${ZDOTDIR:-"${HOME}/dotfiles/zsh"}
fpath=($loc/completion $fpath)

# Load completion system efficiently
autoload -Uz compinit
if [[ -f "$XDG_CACHE_HOME/zsh/zcompdump-$ZSH_VERSION" ]]; then
    compinit -C -d "$XDG_CACHE_HOME/zsh/zcompdump-$ZSH_VERSION"
else
    compinit -d "$XDG_CACHE_HOME/zsh/zcompdump-$ZSH_VERSION"
fi

# Load bash completion only if needed
if [[ -n "$BASH_COMPLETION" ]]; then
    autoload -Uz bashcompinit && bashcompinit
fi

# ------------------------------------------------------------------------------
# Basic Completion Settings
# ------------------------------------------------------------------------------
# Enable caching
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "$XDG_CACHE_HOME"
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle :compinstall filename "$ZDOTDIR/.zshrc"

# Hide unnecessary files
zstyle ':completion:*' ignored-patterns '.|..|.DS_Store|**/.|**/..|**/.DS_Store|**/.git'

# Set descriptions and messages
zstyle ':completion:*:descriptions' format '[%d]'
zstyle ':completion:*:messages' format '%d'
zstyle ':completion:*:warnings' format 'No matches for: %d'
zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s

# ------------------------------------------------------------------------------
# FZF-tab Configuration
# ------------------------------------------------------------------------------
# Directory preview
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'eza -1 --color=always $realpath'
zstyle ':fzf-tab:*' fzf-command ftb-tmux-popup

### Set location for compinit's dumpfile.
autoload -Uz compinit && compinit -d "$XDG_CACHE_HOME/zsh/compinit-dumpfile"
