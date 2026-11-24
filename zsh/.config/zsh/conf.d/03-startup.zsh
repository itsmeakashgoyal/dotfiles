#!/usr/bin/env zsh
#
#  ▓▓▓▓▓▓▓▓▓▓
# ░▓ author ▓ Akash Goyal
# ░▓ file   ▓ zsh/.config/zsh/conf.d/03-startup.zsh
# ░▓▓▓▓▓▓▓▓▓▓
#
# Completion system init (compinit + caching) and terminal tab/window title
# hooks.

# Completion system (lazy loading with caching)
function load_local_cache() {
    local zcompdump="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompdump-${ZSH_VERSION}"
    local compinit_args=(-C)

    # Only rebuild completion dump once per day (faster startup)
    # Use zsh builtins to avoid forking an external `find` process on every start
    zmodload zsh/datetime 2>/dev/null
    zmodload -F zsh/stat b:zstat 2>/dev/null
    local -a _mtime=(0)
    [[ -f "$zcompdump" ]] && zstat -A _mtime +mtime "$zcompdump" 2>/dev/null
    if [[ ! -f "$zcompdump" || $(( EPOCHSECONDS - _mtime[1] )) -gt 86400 ]]; then
        # -u: auto-answer "yes" to compinit's insecure-directories prompt
        # instead of leaving it unanswered. Without this, a first run on a
        # machine where any $fpath entry looks group/other-writable (some
        # package managers install completions that way) hangs forever
        # waiting on a TTY that doesn't exist in a non-interactive context
        # (CI, `zsh -c`, etc.) - and even in a real terminal it's a scary
        # prompt on someone's very first shell launch.
        compinit_args=(-u)
        mkdir -p "${zcompdump:h}"
    fi
    
    # Load completions
    autoload -Uz compinit
    compinit "${compinit_args[@]}" -d "$zcompdump"

    # Compile zcompdump for faster loading (if not already compiled or outdated)
    if [[ ! -f "${zcompdump}.zwc" || "$zcompdump" -nt "${zcompdump}.zwc" ]]; then
        zcompile "$zcompdump" &>/dev/null &|
    fi
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

# Tab/window title: "dir" at a fresh prompt, "dir • last-command" after one.
# Everything below is fork-free (results come back in $REPLY, not via $(...)):
# these run on EVERY prompt and command, where a subshell costs a few ms each.
__AKASH[HISTCMD_LOCAL]=0   # commands run in THIS shell (SHARE_HISTORY shares $HISTCMD)
__AKASH[LAST_CMD]=""

# First distinctive word of a command (for tab titles), in $REPLY.
# Mostly stolen from oh-my-zsh's lib/termsupport.zsh. With EXTENDED_GLOB:
# `[(wr)...]` picks the first word not matching the `^(...)` exclusions — env
# assignments (`*=*`), mosh/ssh/sudo and flags (`-*`); `:gs/%/%%` escapes `%`.
function -title-command() {
  emulate -L zsh
  setopt EXTENDED_GLOB
  REPLY="${1[(wr)^(*=*|mosh|ssh|sudo|-*)]:gs/%/%%}"
}

# Executed before displaying prompt.
function -update-title-precmd() {
  emulate -L zsh
  if (( __AKASH[HISTCMD_LOCAL] == 0 )); then
    -set-tab-and-window-title "${PWD:t}"
  else
    -title-command "${__AKASH[LAST_CMD]}"
    # Inside tmux, tmux prefixes the session name, so the command is enough.
    if [[ -n "$TMUX" ]]; then
      -set-tab-and-window-title "$REPLY"
    else
      -set-tab-and-window-title "${PWD:t} • $REPLY"
    fi
  fi
}
add-zsh-hook precmd -update-title-precmd

# Executed before running a command: $2 is a one-line (truncated) version of it.
function -update-title-preexec() {
  emulate -L zsh
  (( __AKASH[HISTCMD_LOCAL]++ ))
  __AKASH[LAST_CMD]="$2"
  -title-command "$2"
  if [[ -n "$TMUX" ]]; then
    -set-tab-and-window-title "$REPLY"
  else
    -set-tab-and-window-title "${PWD:t} • $REPLY"
  fi
}
add-zsh-hook preexec -update-title-preexec

typeset -F SECONDS
function -record-start-time() {
  emulate -L zsh
  ZSH_START_TIME=${ZSH_START_TIME:-$SECONDS}
}
add-zsh-hook preexec -record-start-time
