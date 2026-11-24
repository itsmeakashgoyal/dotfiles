#!/usr/bin/env zsh
#
#  ▓▓▓▓▓▓▓▓▓▓
# ░▓ author ▓ Akash Goyal
# ░▓ file   ▓ zsh/.config/zsh/conf.d/01-exports.zsh
# ░▓▓▓▓▓▓▓▓▓▓
#
function add_to_path() {
  # NOTE: zsh only

  # usage:
  # add_to_path prepend /path/to/prepend
  # add_to_path append /path/to/append

  if [ -d "$2" ]; then
    # If the given path exist, proceed...
    if [[ ":$PATH:" == *":$2:"* ]]; then
      remove_from_path "$2"
    fi

    if [ "$1" = "prepend" ]; then
      PATH="$2:$PATH"
      export PATH
    elif [ "$1" = "append" ]; then
      PATH="$PATH:$2"
      export PATH
    else
      echo "Unknown option. Use 'prepend' or 'append'."
    fi
  fi
}

function remove_from_path() {
  # NOTE: zsh only

  # usage:
  # remove_from_path /path/to/remove

  local path_to_remove="$1"
  if [[ -n "$path_to_remove" && ":$PATH:" == *":$path_to_remove:"* ]]; then
    while [[ ":$PATH:" == *":$path_to_remove:"* ]]; do
      # Remove
      PATH="${PATH/#$path_to_remove:/}"   # If it's at the beginning
      PATH="${PATH/%:$path_to_remove/}"   # If it's at the end
      PATH="${PATH//:$path_to_remove:/:}" # If it's in the middle
    done
    PATH="${PATH#:}" # Remove leading colon
    PATH="${PATH%:}" # Remove trailing colon
    export PATH
  fi
}

# ------------------------------------------------------------------------------
# Homebrew Configuration
# ------------------------------------------------------------------------------
# Core Homebrew settings
if command -v brew &>/dev/null; then
  export HOMEBREW_NO_ANALYTICS=1 # Disable analytics collection
  export HOMEBREW_AUTOREMOVE=1   # Automatically remove unused dependencies
fi

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

# Theme: Gruvbox everywhere. `dutils theme` stores the TERMINAL mode in
# ~/.config/dotfiles/theme — dark (default) | light | auto (follow the OS; costs
# one `defaults` call at startup, only in auto mode). Resolved once here into
# $DOTFILES_THEME=dark|light, which drives bat + delta ($BAT_THEME), starship's
# palette (.zshrc 6f) and Neovim (current-theme.lua). See docs/THEME.md.
() {
    local f="${XDG_CONFIG_HOME:-$HOME/.config}/dotfiles/theme" mode=dark
    [[ -r $f ]] && mode=${$(<$f)//[[:space:]]/}
    if [[ $mode == auto ]]; then
        if [[ $OSTYPE == darwin* ]]; then
            [[ $(defaults read -g AppleInterfaceStyle 2>/dev/null) == Dark ]] && mode=dark || mode=light
        elif (( $+commands[gsettings] )); then
            [[ $(gsettings get org.gnome.desktop.interface color-scheme 2>/dev/null) == *dark* ]] \
                && mode=dark || mode=light
        fi
    fi
    [[ $mode == light ]] || mode=dark
    export DOTFILES_THEME=$mode
    export BAT_THEME="gruvbox-$mode"
}

# fzf: styled with ANSI colour *indices* (0-15, and -1 = terminal default) rather
# than hex, so the picker likewise follows the terminal palette in light or dark.
export FZF_DEFAULT_OPTS="--height=50% --layout=reverse --border=rounded --cycle \
--bind=ctrl-j:down,ctrl-k:up \
--color=fg:-1,bg:-1,hl:4,fg+:-1,bg+:-1,hl+:4,border:8,prompt:6,pointer:5,marker:2,info:8,spinner:6,header:8"

# ------------------------------------------------------------------------------
# Cached tool initialization
# ------------------------------------------------------------------------------
# `eval "$(tool init zsh)"` spawns the tool on every shell start (starship,
# zoxide, atuin, tv…). Cache that output once and re-source it instead,
# regenerating only when the tool's binary changes — keyed by path + mtime via
# the zstat *builtin* and `command -v` (both in-process), so the hot path spawns
# nothing. Small win here, big win where process spawns are pricey (Windows).
zmodload -F zsh/stat b:zstat 2>/dev/null
_dotfiles_init_cache="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/init"
cached_init() {
    local name="$1"; shift
    local bin=${commands[$1]}; [[ -n $bin ]] || return 0
    local cache="${_dotfiles_init_cache}/${name}.zsh"
    local -a st; zstat -A st +mtime "$bin" 2>/dev/null
    # Args are part of the key, so changing them (e.g. zoxide's --hook) re-caches.
    local key="${bin}:${st[1]:-0}:${ZSH_VERSION}:v2:$*"
    if [[ ! -r "$cache" || "$(<"${cache}.key" 2>/dev/null)" != "$key" ]]; then
        mkdir -p "${_dotfiles_init_cache}"
        local out; out=$("$@" 2>/dev/null)
        # Bake out the process spawns the generated scripts still do at EVERY
        # shell start (measured: atuin uuid ~19ms, starship PROMPT2 ~11ms).
        case "$name" in
            atuin)
                out=${out//'export ATUIN_SESSION=$(atuin uuid)'/'_dotfiles_uuid7; export ATUIN_SESSION=$REPLY'} ;;
            starship)
                local p2; p2=$(starship prompt --continuation 2>/dev/null)
                out=${out//PROMPT2=\"\$\(*--continuation\)\"/PROMPT2=${(qq)p2}} ;;
        esac
        print -r -- "$out" >| "$cache"
        print -r -- "$key" >| "${cache}.key"
    fi
    source "$cache"
}

# UUIDv7 (atuin's session id format: 32 hex chars) without forking `atuin uuid`:
# 48-bit ms timestamp, version 7, RFC 4122 variant, random bits. Result in $REPLY.
zmodload zsh/datetime 2>/dev/null
_dotfiles_uuid7() {
    local -i ms=$(( ${EPOCHREALTIME%.*} * 1000 + 10#${${EPOCHREALTIME#*.}[1,3]} ))
    local r; printf -v r '%04x%04x%04x%04x%04x' $RANDOM $RANDOM $RANDOM $RANDOM $RANDOM
    printf -v REPLY '%012x7%s%x%s%s' $ms ${r[1,3]} $(( 8 + RANDOM % 4 )) ${r[4,6]} ${r[7,18]}
}

# Ripgrep config file location
# export RIPGREP_CONFIG_PATH="$XDG_DOTFILES_DIR/dots/.ripgreprc"

# Config file for wget
# export WGET_CONFIG_PATH="${XDG_DOTFILES_DIR}/dots/.wgetrc"

# ------------------------------------------------------------------------------
# Zsh Completion Configuration
# ------------------------------------------------------------------------------
# Add custom completions directory to fpath if it exists
if [[ -d "$ZDOTDIR/completion" ]]; then
    fpath=("$ZDOTDIR/completion" $fpath)
fi

# ------------------------------------------------------------------------------
# Environment Detection and Base Configuration
# ------------------------------------------------------------------------------
source "${XDG_DOTFILES_DIR}/scripts/lib/os-detect.sh"

# Common paths for both OS types
COMMON_PATHS=(
  "/usr/bin"
  "/usr/sbin"
  "/bin"
  "/sbin"
  "/usr/local/bin"
  "/usr/local/sbin"
)

# OS-specific paths. Linux has no Homebrew/linuxbrew at all — CLI tools come
# from Nix + Home Manager instead (see 15-nix.zsh for its PATH setup).
if os::is_mac; then
  # macOS Homebrew paths
  HOMEBREW_PREFIX="/opt/homebrew"
  HOMEBREW_CELLAR="/opt/homebrew/Cellar"
  HOMEBREW_REPOSITORY="/opt/homebrew"
  export HOMEBREW_PREFIX HOMEBREW_CELLAR HOMEBREW_REPOSITORY
  # Completions for Homebrew-installed tools (what `brew shellenv` adds;
  # this file runs before compinit).
  fpath=("${HOMEBREW_PREFIX}/share/zsh/site-functions" ${fpath:#${HOMEBREW_PREFIX}/share/zsh/site-functions})

  # macOS specific paths
  OS_PATHS=(
    "/opt/homebrew/bin"
    "/opt/homebrew/sbin"
    "/opt/homebrew/opt/llvm/bin"
    "/Library/Frameworks/Python.framework/Versions/Current/bin"
    "${HOME}/Library/Python/3.14/bin"
    "${HOME}/.local/bin"
  )
elif os::is_linux; then
  # Linux specific paths (system-level only; Nix packages are on PATH via
  # the Home Manager profile, wired up separately by 15-nix.zsh)
  OS_PATHS=(
    "/usr/local/bin"
    "/usr/local/sbin"
    "/usr/lib/jvm/java-11-openjdk-amd64"
    "/usr/local/lib/pkgconfig"
    "/usr/local/lib"
  )
fi

# Combine the common and OS-specific paths and ensure uniqueness in the final path
# mise shims first: `python`/`python3` is the mise-managed 3.14 (the standard,
# see mise/.config/mise/config.toml) even before mise's lazy activation runs and
# in non-interactive shells. Anaconda goes LAST so its tools stay reachable but
# its python never shadows the standard one (use `conda activate` for that).
typeset -U path
path=(
  "${XDG_DATA_HOME:-$HOME/.local/share}/mise/shims"
  "${OS_PATHS[@]}"
  "${COMMON_PATHS[@]}"
  $path
)
[[ -d /opt/anaconda3/bin ]] && path=(${path:#/opt/anaconda3/bin} /opt/anaconda3/bin)

# ------------------------------------------------------------------------------
# Export Environment Variables
# ------------------------------------------------------------------------------
export PATH

# Set parallel make flags based on OS
# CPU count cached once per machine: `nproc`/`sysctl` would fork on every start.
() {
    local f="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/ncpu"
    if [[ ! -s $f ]]; then
        mkdir -p "${f:h}"
        { (( $+commands[nproc] )) && nproc || sysctl -n hw.ncpu; } >| "$f" 2>/dev/null
    fi
    [[ -s $f ]] && export MAKEFLAGS="-j$(<$f)"
}

# ------------------------------------------------------------------------------
# Third-Party Toolchain PATH Additions
# ------------------------------------------------------------------------------
# rustup (cargo/rustc)
[[ -f "$HOME/.cargo/env" ]] && source "$HOME/.cargo/env"

# uv / other installers that drop a PATH shim in ~/.local/bin
[[ -f "$HOME/.local/bin/env" ]] && source "$HOME/.local/bin/env"

# Installers that append to ~/.zshrc (never read here: ZDOTDIR is ~/.config/zsh)
# need their PATH lines here instead. Only added when present on this machine.
[[ -d "$HOME/.lmstudio/bin" ]] && path+=("$HOME/.lmstudio/bin")   # LM Studio CLI (lms)
