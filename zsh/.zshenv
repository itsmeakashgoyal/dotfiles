#!/usr/bin/env zsh
# .zshenv: Zsh environment file, loaded for every shell session
# .zshenv is sourced on all invocations of the shell, unless the -f option is set.
# It should contain commands to set the command search path, plus other important environment variables.
# .zshenv' should not contain commands that produce output or assume the shell is attached to a tty.
# ------------------------------------------------------------------------------

# Set up XDG base directories
# Spec: https://specifications.freedesktop.org/basedir-spec/latest/index.html
# ------------------------------------------------------------------------------
export XDG_CONFIG_HOME="${HOME}/.config"
export XDG_CACHE_HOME="${HOME}/.cache"
export XDG_DATA_HOME="${HOME}/.local/share"
export XDG_STATE_HOME="${HOME}/.local/state"
export XDG_RUNTIME_DIR="${HOME}/.runtime"
export XDG_DOTFILES_DIR="${HOME}/dotfiles"

# Set ZDOTDIR if you want to reorganize zsh files
export ZDOTDIR="${XDG_DOTFILES_DIR}/zsh"

# Set for GIT_CONFIG_GLOBAL
export GIT_CONFIG_GLOBAL="${XDG_DOTFILES_DIR}/git/config"

# add a config file for wget
# export WGET_CONFIG_PATH="${XDG_DOTFILES_DIR}/config/.wgetrc"

# Create XDG directories if they don't exist
for dir in "$XDG_CONFIG_HOME" "$XDG_CACHE_HOME" "$XDG_DATA_HOME" "$XDG_STATE_HOME" "$XDG_RUNTIME_DIR"; do
  [[ ! -d "$dir" ]] && mkdir -p "$dir"
done

# Set default editor (uncomment if needed)
export EDITOR="nvim"
export VISUAL="nvim"

# History Configuration
# the detailed meaning of the below three variable can be found in `man zshparam`.
export HISTSIZE=1000000   # Number of items for the internal history list
export SAVEHIST=$HISTSIZE # Maximum number of items for the history file

# History Options
setopt appendhistory
setopt sharehistory         # share hist between sessions
setopt hist_reduce_blanks   # trim blanks
setopt hist_ignore_space    # ignore space prefixed commands
setopt hist_ignore_all_dups # Don't put duplicated command into history list
setopt hist_save_no_dups    # Don't save duplicated command
setopt hist_ignore_dups
setopt hist_find_no_dups
setopt hist_verify        # show before executing history commands
setopt inc_append_history # add commands as they are typed, don't wait until shell exit
setopt bang_hist          # !keyword
# setopt EXTENDED_HISTORY   # Record command start time (uncomment if needed)

# Other Options
export HISTFILE="${HOME}/.zsh_history"
export HISTDUP=erase

setopt NO_HUP # don't kill background jobs when the shell exits
