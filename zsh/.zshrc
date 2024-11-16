# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time Oh My Zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="robbyrussell"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
zstyle ':omz:update' mode reminder # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
zstyle ':omz:update' frequency 13

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=$HOME/dotfiles/zsh

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
    git
    sudo
    history-substring-search
    colored-man-pages
    zsh-vi-mode
    ruby
    fzf-tab
    zsh-syntax-highlighting
    zsh-autosuggestions
    # zsh-autocomplete
)
source $ZSH/custom/plugins/fzf-tab/fzf-tab.plugin.zsh
source $ZSH/oh-my-zsh.sh

# Zsh Vi Mode configuration
ZVM_INIT_MODE=sourcing

# https://github.com/jeffreytse/zsh-vi-mode
function zvm_config() {
    ZVM_LINE_INIT_MODE=$ZVM_MODE_INSERT
    ZVM_VI_INSERT_ESCAPE_BINDKEY=\;\;
    ZVM_CURSOR_STYLE_ENABLED=false
    ZVM_VI_EDITOR=nvim
}

function zvm_after_init() {
    zvm_bindkey viins '^Q' push-line
}

# User configuration
export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
export LANG=en_US.UTF-8

# Set shell options: http://zsh.sourceforge.net/Doc/Release/Options.html.
setopt glob_dots    # no special treatment for file names with a leading dot
setopt no_auto_menu # require an extra TAB press to open the completion menu
setopt extended_glob

zle -N menu-search
zle -N recent-paths

# FZF and Zoxide integration
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
zvm_after_init_commands+=('[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh')
eval "$(zoxide init --cmd cd zsh)"

# Detect OS type
OS_TYPE=$(uname)
if [ "$OS_TYPE" = "Darwin" ]; then
    export ANTIDOTE_DIR="/opt/homebrew/opt/antidote/share/antidote"
    export OHMYPOSH_THEMES_DIR="/opt/homebrew/opt/oh-my-posh/themes"

elif [ "$OS_TYPE" = "Linux" ]; then
    # Linux specific zsh configs
    export NVM_DIR="${HOME}/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh" # This loads nvm

    # # Nix
    # if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
    # . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
    # # . /etc/profile.d/nix.sh
    # fi
    # # End Nix
    # export LOCALE_ARCHIVE="/usr/lib/locale/locale-archive"

    export ANTIDOTE_DIR="/home/linuxbrew/.linuxbrew/opt/antidote/share/antidote"
    export OHMYPOSH_THEMES_DIR="/home/linuxbrew/.linuxbrew/opt/oh-my-posh/themes"
fi

# Prompt
eval "$(oh-my-posh init zsh --config ${XDG_DOTFILES_DIR}/ohmyposh/emodipt.json)"

# Key Bindings
[[ -f "$HOME/dotfiles/zsh/config/keybindings.zsh" ]] && builtin source "$HOME/dotfiles/zsh/config/keybindings.zsh"

# Completion Configuration
[[ -f "$HOME/dotfiles/zsh/config/completion.zsh" ]] && builtin source "$HOME/dotfiles/zsh/config/completion.zsh"

# Antidote Plugin Manager
[[ -f "$HOME/dotfiles/zsh/config/antidote.zsh" ]] && builtin source "$HOME/dotfiles/zsh/config/antidote.zsh"
