#!/usr/bin/env zsh

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

#
# Hooks
#

autoload -U add-zsh-hook

function -set-tab-and-window-title() {
  emulate -L zsh
  local TITLE="${1:gs/$/\\$}"
  print -Pn "\e]0;$TITLE:q\a"
}

# $HISTCMD (the current history event number) is shared across all shells
# (due to SHARE_HISTORY). Maintain this local variable to count the number of
# commands run in this specific shell.
__AKASH[HISTCMD_LOCAL]=0

function -forkless-basename() {
  emulate -L zsh
  echo "${PWD##*/}"
}

# Show first distinctive word of command (for use in tab titles).
function -title-command() {
  emulate -L zsh
  setopt EXTENDED_GLOB

  # Mostly stolen from:
  #
  #   https://github.com/robbyrussell/oh-my-zsh/blob/master/lib/termsupport.zsh
  #
  # Via `man zshall`, $2, passed into a preexec function:
  #
  #     the second argument is a single-line, size-limited version of the
  #     command (with things like function bodies elided)
  #
  # - Due to EXTENDED_GLOB, $2 will be expanded as follows.
  # - `[(wr)...]` is for array manipulation ([w]ord split, and [r]emove).
  # - `^` exclude patterns.
  # - `*=*` will remove env vars (eg. `foo=bar`, anything containing an "=").
  # - `mosh`/`ssh`/`sudo` get removed too.
  # - `-*` removes anything starting with a hyphen.
  # - `:gs/%/%%` ensures that any "%" (rare) gets escaped as "%%".
  echo "${1[(wr)^(*=*|mosh|ssh|sudo|-*)]:gs/%/%%}"
}

# Executed before displaying prompt.
function -update-title-precmd() {
  emulate -L zsh
  setopt EXTENDED_GLOB
  setopt KSH_GLOB
  if [[ __AKASH[HISTCMD_LOCAL] -eq 0 ]]; then
    # About to display prompt for the first time; nothing interesting to show in
    # the history. Show $PWD.
    -set-tab-and-window-title "$(-forkless-basename)"
  else
    local LAST=$(fc -l -1)
    LAST="${LAST## #}" # Trim leading whitespace.
    LAST="${LAST##*([^[:space:]])}" # Remove first word (history number).
    LAST="${LAST## #}" # Trim leading whitespace.
    if [ -n "$TMUX" ]; then
      # Inside tmux, just show the last command: tmux will prefix it with the
      # session name (for context).
      -set-tab-and-window-title "$(-title-command "$LAST")"
    else
      # Outside tmux, show $PWD (for context) followed by the last command.
      -set-tab-and-window-title "$(-forkless-basename) • $(-title-command "$LAST")"
    fi
  fi
}
add-zsh-hook precmd -update-title-precmd

# Executed before executing a command: $2 is one-line (truncated) version of
# the command.
function -update-title-preexec() {
  emulate -L zsh
  __AKASH[HISTCMD_LOCAL]=$((++__AKASH[HISTCMD_LOCAL]))
  if [ -n "$TMUX" ]; then
    # Inside tmux, show the running command: tmux will prefix it with the
    # session name (for context).
    -set-tab-and-window-title "$(-title-command "$2")"
  else
    # Outside tmux, show $PWD (for context) followed by the running command.
    -set-tab-and-window-title "$(-forkless-basename) • $(-title-command "$2")"
  fi
}
add-zsh-hook preexec -update-title-preexec

typeset -F SECONDS
function -record-start-time() {
  emulate -L zsh
  ZSH_START_TIME=${ZSH_START_TIME:-$SECONDS}
}
add-zsh-hook preexec -record-start-time
