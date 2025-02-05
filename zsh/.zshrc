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

# Load profiling tool
# zmodload zsh/zprof
# zmodload zsh/mapfile # Bring mapfile functionality similar to bash

# Disable unnecessary security checks
ZSH_DISABLE_COMPFIX=true

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

# Completion system (lazy loading with caching)
function load_local_cache() {
    local zcompdump="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompdump-${ZSH_VERSION}"
    local compinit_args=(-C)
    
    # Only rebuild completion dump once per day
    if [[ ! -f "$zcompdump" || -n "$(find "$zcompdump" -mtime +1)" ]]; then
        compinit_args=()
        mkdir -p "${zcompdump:h}"
    fi
    
    # Load completions
    autoload -Uz compinit
    compinit "${compinit_args[@]}" -d "$zcompdump"
}
load_local_cache

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
    export OHMYPOSH_THEMES_DIR="${HOMEBREW_PREFIX}/opt/oh-my-posh/themes"
    eval "$(oh-my-posh init zsh --config ${XDG_DOTFILES_DIR}/ohmyposh/emodipt.json)"
fi

# Fix Paste Behavior
zle_highlight+=(paste:none)
