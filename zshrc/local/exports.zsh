# ------------------------------------------------------------------------------
# General Exports
# ------------------------------------------------------------------------------

HOMEBREW_NO_AUTO_UPDATE=1
HOMEBREW_PREFIX="/opt/homebrew"
HOMEBREW_CELLAR="/opt/homebrew/Cellar"
HOMEBREW_REPOSITORY="/opt/homebrew"

# Make vim the default editor.
# export EDITOR=/opt/homebrew/bin/nvim

# Prefer US English and use UTF-8.
export LANG='en_US.UTF-8';
export LC_ALL='en_US.UTF-8';

# export llvm path for clang++
export PATH="/opt/homebrew/opt/llvm/bin:$PATH"

# colorful man pages
export LESS_TERMCAP_mb=$'\e[1;31m'
export LESS_TERMCAP_md=$'\e[1;31m'
export LESS_TERMCAP_me=$'\e[0m'
export LESS_TERMCAP_se=$'\e[0m'
export LESS_TERMCAP_so=$'\e[01;33m'
export LESS_TERMCAP_ue=$'\e[0m'
export LESS_TERMCAP_us=$'\e[1;4;32m'

## export PATH
export PATH=$HOME/bin:$HOME/.local/bin:/usr/local:/usr/local/bin:$PATH
export PATH=$PATH:~/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin
export PATH=$PATH:/usr/local/opt/ruby/bin:/usr/local/lib/node_modules
export PATH=$PATH:/opt/homebrew/bin

# ~/.config/tmux/plugins
export PATH=$PATH:$HOME/.config/tmux/plugins/t-smart-tmux-session-manager/bin

# the detailed meaning of the below three variable can be found in `man zshparam`.
HISTSIZE=1000000  # the number of items for the internal history list
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE  # maximum number of items for the history file
HISTDUP=erase
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups # do not put duplicated command into history list
setopt hist_save_no_dups  # do not save duplicated command
setopt hist_ignore_dups
setopt hist_find_no_dups
# setopt EXTENDED_HISTORY  # record command start time