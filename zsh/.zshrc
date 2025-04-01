#                     █████
#                    ░░███
#   █████████  █████  ░███████   ████████   ██████
#  ░█░░░░███  ███░░   ░███░░███ ░░███░░███ ███░░███
#  ░   ███░  ░░█████  ░███ ░███  ░███ ░░░ ░███ ░░░
#    ███░   █ ░░░░███ ░███ ░███  ░███     ░███  ███
#   █████████ ██████  ████ █████ █████    ░░██████
#  ░░░░░░░░░ ░░░░░░  ░░░░ ░░░░░ ░░░░░      ░░░░░░
#
#  ▓▓▓▓▓▓▓▓▓▓
# ░▓ author ▓ Akash Goyal
# ░▓ file   ▓ zsh/.zshrc
# ░▓▓▓▓▓▓▓▓▓▓
# ░░░░░░░░░░
#
#█▓▒░

# Load profiling tool
# zmodload zsh/zprof
# zmodload zsh/mapfile # Bring mapfile functionality similar to bash

# Create a hash table for globally stashing variables without polluting main
# scope with a bunch of identifiers.
typeset -A __AKASH

__AKASH[ITALIC_ON]=$'\e[3m'
__AKASH[ITALIC_OFF]=$'\e[23m'
__AKASH[ZSHRC]=$ZDOTDIR/.zshrc
__AKASH[REAL_ZSHRC]=${__AKASH[ZSHRC]:A}

# ------------------------------------------------------------------------------
# zinit setup
# ------------------------------------------------------------------------------
# Set the directory we want to store zinit and plugins
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

# Download Zinit, if it's not there yet
if [ ! -d "$ZINIT_HOME" ]; then
    mkdir -p "$(dirname $ZINIT_HOME)"
    git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

# Source/Load zinit
source "${ZINIT_HOME}/zinit.zsh"

# Disable unnecessary security checks
# ZSH_DISABLE_COMPFIX=true

# NOTE: must come before zsh-syntax-highlighting.
autoload -U select-word-style
select-word-style bash # only alphanumeric chars are considered WORDCHARS

# add zsh plugins using zinit
zinit lucid light-mode for \
    zsh-users/zsh-syntax-highlighting \
    zsh-users/zsh-completions \
    zsh-users/zsh-autosuggestions \
    Aloxaf/fzf-tab

# Load OMZ plugins (turbo mode)
zinit wait lucid for \
    OMZP::git \
    OMZP::sudo \
    OMZP::command-not-found

# For speed:
# https://github.com/zsh-users/zsh-autosuggestions#disabling-automatic-widget-re-binding
ZSH_AUTOSUGGEST_MANUAL_REBIND=1
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=59'
ZSH_AUTOSUGGEST_STRATEGY=(match_prev_cmd completion)

# Source local configurations (lazy loading)
function load_local_configs() {
    local config_dir="$ZDOTDIR/local"
    [[ -d "$config_dir" ]] || return

    for config in "$config_dir"/*.zsh; do
        [[ -f "$config" ]] && source "$config"
    done
}
load_local_configs

if command -v oh-my-posh &>/dev/null; then
    eval "$(oh-my-posh init zsh --config ${XDG_DOTFILES_DIR}/ohmyposh/emodipt.json)"
fi

# Fix Paste Behavior
zle_highlight+=(paste:none)

#
# /etc/motd
#

# if [ -e /etc/motd ]; then
#   if ! cmp -s $HOME/.hushlogin /etc/motd; then
#     tee $HOME/.hushlogin < /etc/motd
#   fi
# fi
if [[ -f /etc/motd ]]; then
    catn /etc/motd
fi
