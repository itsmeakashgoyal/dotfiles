# ------------------------------------------------------------------------------
# General Exports
# ------------------------------------------------------------------------------

# Detect OS type
OS_TYPE=$(uname)

if [ "$OS_TYPE" = "Darwin" ]; then
    # macOS specific exports
    HOMEBREW_NO_AUTO_UPDATE=1
    HOMEBREW_PREFIX="/opt/homebrew"
    HOMEBREW_CELLAR="/opt/homebrew/Cellar"
    HOMEBREW_REPOSITORY="/opt/homebrew"
    
    # macOS specific paths
    export PATH="$PATH:/opt/homebrew/bin"
    export PATH="$PATH:/opt/homebrew/opt/llvm/bin"
    export PATH="$PATH:/usr/local/opt/ruby/bin"

elif [ "$OS_TYPE" = "Linux" ]; then
    # Linux specific exports
    export PATH="$PATH:/usr/local/go/bin"
    export PATH="$PATH:/usr/local/bin/clang-15:/usr/local/compilers/clang15/bin"
    export PATH="$PATH:$HOME/.local/share/gem/ruby/3.0.0/bin"
    export PATH="$PATH:/snap/bin"
fi

# ------------------------------------------------------------------------------
# Common Exports (for both OS)
# ------------------------------------------------------------------------------

# Locale Settings
export LANG='en_US.UTF-8'
export LC_ALL='en_US.UTF-8'

# Common Path Exports
export PATH="$HOME/bin:$HOME/.local/bin:/usr/local:/usr/local/bin:$PATH"
export PATH="$PATH:~/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin"
export PATH="$PATH:$HOME/.fzf/bin"
export PATH="$PATH:/usr/local/lib/node_modules"
export PATH="$PATH:$HOME/.config/tmux/plugins/t-smart-tmux-session-manager/bin"

# Colorful man pages
export LESS_TERMCAP_mb=$'\e[1;31m'
export LESS_TERMCAP_md=$'\e[1;31m'
export LESS_TERMCAP_me=$'\e[0m'
export LESS_TERMCAP_se=$'\e[0m'
export LESS_TERMCAP_so=$'\e[01;33m'
export LESS_TERMCAP_ue=$'\e[0m'
export LESS_TERMCAP_us=$'\e[1;4;32m'

# History Configuration
# the detailed meaning of the below three variable can be found in `man zshparam`.
export HISTSIZE=1000000 # Number of items for the internal history list
export HISTFILE=~/.zsh_history
export SAVEHIST=$HISTSIZE # Maximum number of items for the history file

# History Options
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups # Don't put duplicated command into history list
setopt hist_save_no_dups    # Don't save duplicated command
setopt hist_ignore_dups
setopt hist_find_no_dups
# setopt EXTENDED_HISTORY   # Record command start time (uncomment if needed)

# Other Options
export HISTDUP=erase
