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
zmodload zsh/zprof
# zmodload zsh/mapfile # Bring mapfile functionality similar to bash

# Disable unnecessary security checks
ZSH_DISABLE_COMPFIX=true
DISABLE_MAGIC_FUNCTIONS=true

# add zsh plugins using zinit
zinit ice depth=1
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit light Aloxaf/fzf-tab

# Load OMZ plugins (turbo mode)
zinit wait lucid for \
    OMZP::git \
    OMZP::sudo \
    OMZP::command-not-found


# Completion system (lazy loading with caching)
() {
    local zcompdump="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompdump-${ZSH_VERSION}"
    local compinit_args=(-C)
    
    # Only rebuild completion dump once per day
    if [[ ! -f "$zcompdump" || -n "$(find "$zcompdump" -mtime +1)" ]]; then
        compinit_args=()
        mkdir -p "${zcompdump:h}"
    fi
    
    autoload -Uz compinit 
    compinit "${compinit_args[@]}" -d "$zcompdump"
}

# Source local configurations (lazy loading)
function load_local_configs() {
    local config_dir="$ZDOTDIR/local"
    [[ -d "$config_dir" ]] || return
    
    for config in "$config_dir"/*.zsh; do
        [[ -f "$config" ]] && source "$config"
    done
}

# Defer loading of local configs
zinit wait lucid atload"load_local_configs" for zdharma-continuum/null

# Clean up
zinit cdreplay -q
zle_highlight+=(paste:none)