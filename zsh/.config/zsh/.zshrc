#!/usr/bin/env zsh
#
#  ▓▓▓▓▓▓▓▓▓▓
# ░▓ author ▓ Akash Goyal
# ░▓ file   ▓ zsh/.config/zsh/.zshrc
# ░▓▓▓▓▓▓▓▓▓▓
#
# ==============================================================================
# 1. PROMPT SELECTION
# One knob for the whole file: "starship" (default) or "p10k". Change the value
# here, or set DOTFILES_PROMPT in the environment before zsh starts. (It can't
# be set in 99-private.zsh - that's sourced too late, after the prompt loads.)
# The three gates below (instant prompt, p10k config, theme) all read this.
# ==============================================================================
: "${DOTFILES_PROMPT:=starship}"

# p10k's instant prompt must be the very first thing, before any output. Only
# under p10k; Starship has no equivalent.
if [[ "$DOTFILES_PROMPT" == "p10k" \
      && -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
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

# zsh-syntax-highlighting
# The 'path'/'path_prefix' highlighters stat() every path token on EVERY
# keystroke (`[[ -e ]]`, plus a glob to detect partial paths). On auto-mounting
# or network roots this is harmful: typing a path under an autofs mount
# triggers the mount (and resets its idle timer so it never expires), and a
# stat() into a dead `hard` NFS mount hangs the whole shell while you type.
# ZSH_HIGHLIGHT_DIRS_BLACKLIST makes the highlighter skip these subtrees
# entirely (it returns before any filesystem access). Add more roots as needed.
ZSH_HIGHLIGHT_DIRS_BLACKLIST=(/mnt /net)   # autofs (/mnt/auto, /net) + NFS mounts under /mnt

# ==============================================================================
# 5. EARLY SETUP (ordering constraints)
# ==============================================================================
# select-word-style must come before zsh-syntax-highlighting loads.
autoload -U select-word-style
select-word-style bash  # only alphanumeric chars are considered WORDCHARS

# exports.zsh must run before compinit — it extends fpath with custom completions.
source "$ZDOTDIR/conf.d/01-exports.zsh"

# p10k config must be sourced before the theme plugin loads (p10k only).
[[ "$DOTFILES_PROMPT" == "p10k" && -f "$ZDOTDIR/.p10k.zsh" ]] && source "$ZDOTDIR/.p10k.zsh"

# ==============================================================================
# 6. PLUGINS — ordered by load mode
# ==============================================================================

# --- 6a. Completions: extend fpath before compinit ---------------------------
zinit lucid light-mode for \
    blockf \
    zsh-users/zsh-completions

# --- 6b. Completion system init (compinit + tab/title hooks) -----------------
source "$ZDOTDIR/conf.d/03-startup.zsh"

# --- 6c. Core interactive plugins (synchronous) ------------------------------
# Kept synchronous on purpose: deferring them saved only ~5ms and left the first
# keystrokes of a new tab unhighlighted/unsuggested (zsh-bench then also
# reports them as missing).
zinit lucid light-mode for \
    zsh-users/zsh-autosuggestions

# --- 6d. Syntax highlighting — must be the last synchronous plugin -----------
zinit light zsh-users/zsh-syntax-highlighting

# --- 6e. Turbo plugins — deferred until after first prompt -------------------
zinit wait lucid for \
    OMZP::git \
    OMZP::sudo

# --- 6f. Theme (Starship by default, or Powerlevel10k) -----------------------
# Selection is the DOTFILES_PROMPT knob from section 1.
if [[ "$DOTFILES_PROMPT" == "p10k" ]]; then
    zinit ice depth=1
    zinit light romkatv/powerlevel10k
else
    export STARSHIP_CONFIG="$HOME/.config/starship/starship.toml"
    # Light terminal (`dutils theme light|auto`): the same config with the
    # gruvbox_light palette, regenerated only when starship.toml changes.
    if [[ "$DOTFILES_THEME" == light ]]; then
        _starship_light="${XDG_CACHE_HOME:-$HOME/.cache}/dotfiles/starship-light.toml"
        if [[ ! -r $_starship_light || $STARSHIP_CONFIG -nt $_starship_light ]]; then
            mkdir -p "${_starship_light:h}"
            print -r -- "${$(<$STARSHIP_CONFIG)//palette = \"gruvbox_dark\"/palette = \"gruvbox_light\"}" \
                >| "$_starship_light"
        fi
        export STARSHIP_CONFIG=$_starship_light
        unset _starship_light
    fi
    cached_init starship starship init zsh
fi

# ==============================================================================
# 7. MODULAR CONFIG (conf.d)
# exports.zsh and startup.zsh already sourced above (ordering constraints).
# (N) glob qualifier silently skips if the dir is empty or pattern has no match.
# ==============================================================================
for _config in "$ZDOTDIR/conf.d"/*.zsh(N); do
    [[ "$_config" == */01-exports.zsh || "$_config" == */03-startup.zsh ]] && continue
    source "$_config"
done
unset _config

# 99-private.zsh (gitignored) holds work exports/tokens: keep it owner-only.
# Glob qualifiers A/R = group/world-readable, so this forks chmod only when needed.
_private=("$ZDOTDIR"/conf.d/99-private.zsh(N.A,N.R))
(( $#_private )) && chmod 600 "${_private[@]}"
unset _private
# ==============================================================================
# 8. ZLE TWEAKS
# ==============================================================================
zle_highlight+=(paste:none)  # suppress highlighting of pasted text

# ==============================================================================
# 9. CONDA (lazy init)
# ==============================================================================
# Anaconda stays at the END of PATH (01-exports.zsh) so its python never shadows
# the standard mise-managed 3.14; `conda activate <env>` still puts an env first.
if [[ -f "/opt/anaconda3/bin/conda" ]]; then
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

