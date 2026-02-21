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
# ░▓ file   ▓ zsh/.config/zsh/.zshrc
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

# Enable Powerlevel10k instant prompt (makes shell appear instantly)
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
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

# Load Powerlevel10k theme
zinit ice depth=1
zinit light romkatv/powerlevel10k

# For speed:
# https://github.com/zsh-users/zsh-autosuggestions#disabling-automatic-widget-re-binding
ZSH_AUTOSUGGEST_STRATEGY=(match_prev_cmd completion history)
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#d33682"
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=30
ZSH_AUTOSUGGEST_USE_ASYNC=1
ZSH_AUTOSUGGEST_MANUAL_REBIND=1

# Source modular configurations
if [[ -d "$ZDOTDIR/conf.d" ]]; then
    for config in "$ZDOTDIR/conf.d"/*.zsh; do
        [[ -f "$config" ]] && source "$config"
    done
fi

# Fix Paste Behavior
zle_highlight+=(paste:none)

# To customize prompt, run `p10k configure` or edit $ZDOTDIR/.p10k.zsh
[[ ! -f "$ZDOTDIR/.p10k.zsh" ]] || source "$ZDOTDIR/.p10k.zsh"
# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/opt/anaconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/opt/anaconda3/etc/profile.d/conda.sh" ]; then
        . "/opt/anaconda3/etc/profile.d/conda.sh"
    else
        export PATH="/opt/anaconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<

