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

# ==============================================================================
# 1. POWERLEVEL10K INSTANT PROMPT
# Must be the very first thing — before any console output.
# ==============================================================================
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# ==============================================================================
# 2. GLOBAL STATE
# ==============================================================================
# Hash table for globally stashing variables without polluting main scope.
typeset -A __AKASH
__AKASH[ITALIC_ON]=$'\e[3m'
__AKASH[ITALIC_OFF]=$'\e[23m'
__AKASH[ZSHRC]=$ZDOTDIR/.zshrc
__AKASH[REAL_ZSHRC]=${__AKASH[ZSHRC]:A}

# ==============================================================================
# 3. ZINIT — plugin manager bootstrap
# ==============================================================================
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
if [[ ! -d "$ZINIT_HOME" ]]; then
    mkdir -p "$(dirname $ZINIT_HOME)"
    git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi
source "${ZINIT_HOME}/zinit.zsh"

# ==============================================================================
# 4. PLUGIN CONFIGURATION
# Set before plugins load so each plugin sees its config at init time.
# ==============================================================================
# zsh-autosuggestions
# https://github.com/zsh-users/zsh-autosuggestions#disabling-automatic-widget-re-binding
ZSH_AUTOSUGGEST_STRATEGY=(match_prev_cmd completion history)
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#d33682"
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=30
ZSH_AUTOSUGGEST_USE_ASYNC=1
ZSH_AUTOSUGGEST_MANUAL_REBIND=1

# ==============================================================================
# 5. EARLY SETUP (ordering constraints)
# ==============================================================================
# select-word-style must come before zsh-syntax-highlighting loads.
autoload -U select-word-style
select-word-style bash  # only alphanumeric chars are considered WORDCHARS

# exports.zsh must run before compinit — it extends fpath with custom completions.
source "$ZDOTDIR/conf.d/exports.zsh"

# p10k config must be sourced before the theme plugin loads.
[[ -f "$ZDOTDIR/.p10k.zsh" ]] && source "$ZDOTDIR/.p10k.zsh"

# ==============================================================================
# 6. PLUGINS — ordered by load mode
# ==============================================================================

# --- 6a. Completions: extend fpath before compinit ---------------------------
zinit lucid light-mode for \
    blockf \
    zsh-users/zsh-completions

# --- 6b. Completion system init (compinit + tab/title hooks) -----------------
# startup.zsh must run after zsh-completions but before fzf-tab.
source "$ZDOTDIR/conf.d/startup.zsh"

# --- 6c. Core interactive plugins (synchronous) ------------------------------
zinit lucid light-mode for \
    zsh-users/zsh-autosuggestions \
    Aloxaf/fzf-tab

# --- 6d. Syntax highlighting — must be the last synchronous plugin -----------
zinit light zsh-users/zsh-syntax-highlighting

# --- 6e. Turbo plugins — deferred until after first prompt -------------------
zinit wait lucid for \
    OMZP::git \
    OMZP::sudo

# --- 6f. Theme ---------------------------------------------------------------
zinit ice depth=1
zinit light romkatv/powerlevel10k

# ==============================================================================
# 7. MODULAR CONFIG (conf.d)
# exports.zsh and startup.zsh already sourced above (ordering constraints).
# (N) glob qualifier silently skips if the dir is empty or pattern has no match.
# ==============================================================================
for _config in "$ZDOTDIR/conf.d"/*.zsh(N); do
    [[ "$_config" == */exports.zsh || "$_config" == */startup.zsh ]] && continue
    source "$_config"
done
unset _config

# ==============================================================================
# 8. ZLE TWEAKS
# ==============================================================================
zle_highlight+=(paste:none)  # suppress highlighting of pasted text

# ==============================================================================
# 9. CONDA (lazy init)
# ==============================================================================
if [[ -f "/opt/anaconda3/bin/conda" ]]; then
    path=("/opt/anaconda3/bin" ${path:#/opt/anaconda3/bin})

    conda() {
        unfunction conda
        local __conda_setup
        __conda_setup="$('/opt/anaconda3/bin/conda' 'shell.zsh' 'hook' 2>/dev/null)"
        if (( $? == 0 )); then
            eval "$__conda_setup"
        elif [[ -f "/opt/anaconda3/etc/profile.d/conda.sh" ]]; then
            source "/opt/anaconda3/etc/profile.d/conda.sh"
        fi
        unset __conda_setup
        conda "$@"
    }
fi

# Prefer Python.org's python3 unless a conda env is active.
# (When CONDA_PREFIX is set, keep conda's python first.)
if [[ -z "${CONDA_PREFIX:-}" && -d "/usr/local/bin" ]]; then
    path=(/usr/local/bin ${path:#/usr/local/bin})
fi
