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

# Load profiling tool (uncomment to profile startup time)
# zmodload zsh/zprof

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

# NOTE: must come before zsh-syntax-highlighting.
autoload -U select-word-style
select-word-style bash # only alphanumeric chars are considered WORDCHARS

# Add zsh plugins using zinit
zinit lucid light-mode for \
    blockf \
    zsh-users/zsh-completions \
    zsh-users/zsh-autosuggestions \
    Aloxaf/fzf-tab

# Load syntax highlighting last (must be loaded after other plugins)
zinit light zsh-users/zsh-syntax-highlighting

# Load OMZ plugins (turbo mode)
zinit wait lucid for \
    OMZP::git \
    OMZP::sudo

# For speed:
# https://github.com/zsh-users/zsh-autosuggestions#disabling-automatic-widget-re-binding
ZSH_AUTOSUGGEST_STRATEGY=(match_prev_cmd completion history)
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#d33682"
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=30
ZSH_AUTOSUGGEST_USE_ASYNC=1
ZSH_AUTOSUGGEST_MANUAL_REBIND=1

# Source local configurations
if [[ -d "$ZDOTDIR/local" ]]; then
    for config in "$ZDOTDIR/local"/*.zsh; do
        [[ -f "$config" ]] && source "$config"
    done
fi

if command -v oh-my-posh &>/dev/null; then
    eval "$(oh-my-posh init zsh --config ${XDG_DOTFILES_DIR}/ohmyposh/emodipt.json)"
fi

# Fix Paste Behavior
zle_highlight+=(paste:none)
