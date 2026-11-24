#!/usr/bin/env zsh
#
#  ▓▓▓▓▓▓▓▓▓▓
# ░▓ author ▓ Akash Goyal
# ░▓ file   ▓ zsh/.config/zsh/.zprofile
# ░▓▓▓▓▓▓▓▓▓▓
#
# ------------------------------------------------------------------------------
# Login Shell Configuration
# ------------------------------------------------------------------------------
# .zprofile is sourced on login shells and before .zshrc
# It should only contain environment setup and path modifications

# ------------------------------------------------------------------------------
# OS Detection and Homebrew Setup
# ------------------------------------------------------------------------------
# OS-specific Homebrew setup
# No `eval "$(brew shellenv)"` here: it forked brew on every login shell (every
# new macOS terminal tab, ~27ms) to produce values that are fixed per machine.
# 01-exports.zsh already sets HOMEBREW_* and PATH; only the man/info paths
# brew shellenv would add are set here.
if [[ $OSTYPE == darwin* && -d /opt/homebrew ]]; then
    [[ -n ${MANPATH-} ]] && export MANPATH=":${MANPATH#:}"   # leading ':' = also search default paths
    export INFOPATH="/opt/homebrew/share/info:${INFOPATH:-}"
fi

# ------------------------------------------------------------------------------
# First-run environment setup for login shells
# ------------------------------------------------------------------------------
# Ensure XDG directories exist (safe here; avoid in .zshenv)
# (Only forks mkdir when one is actually missing, i.e. on a fresh machine.)
() {
    local d
    for d in "$XDG_CONFIG_HOME" "$XDG_CACHE_HOME" "$XDG_DATA_HOME" "$XDG_STATE_HOME" "$XDG_RUNTIME_DIR"; do
        [[ -n $d && ! -d $d ]] && mkdir -p "$d" 2>/dev/null
    done
}

# Sensible default permissions for created files/dirs
umask 022
