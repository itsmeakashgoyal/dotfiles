# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time Oh My Zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
# ZSH_THEME="robbyrussell"

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
zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
zstyle ':omz:update' frequency 13

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=$HOME/dotfiles-dev/zshrc

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
    zsh-autocomplete
)
source $ZSH/custom/plugins/fzf-tab/fzf-tab.plugin.zsh
source $ZSH/oh-my-zsh.sh

# Zsh Vi Mode configuration
ZVM_INIT_MODE=sourcing

export ZSHRCDIR="$HOME/dotfiles-dev/zshrc"

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

# Set personal aliases, overriding those provided by Oh My Zsh libs,
# plugins, and themes. Aliases can be placed here, though Oh My Zsh
# users are encouraged to define aliases within a top-level file in
# the $ZSH_CUSTOM folder, with .zsh extension. Examples:
# - $ZSH_CUSTOM/aliases.zsh
# - $ZSH_CUSTOM/macos.zsh
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Set shell options: http://zsh.sourceforge.net/Doc/Release/Options.html.
setopt glob_dots     # no special treatment for file names with a leading dot
setopt no_auto_menu  # require an extra TAB press to open the completion menu
setopt extended_glob

# Key bindings
bindkey '^w' autosuggest-execute
bindkey '^e' autosuggest-accept
bindkey '^u' autosuggest-toggle
bindkey '^L' vi-forward-word
bindkey '^k' up-line-or-search
bindkey '^j' down-line-or-search

# autocompletion using arrow keys (based on history)
bindkey "^[[A" history-beginning-search-backward
bindkey "^[[B" history-beginning-search-forward

zle -N menu-search
zle -N recent-paths

# Completion styles
zstyle ':completion:*:directory-stack' list-colors '=(#b) #([0-9]#)*( *)==95=38;5;12'

# disable sort when completing `git checkout`
zstyle ':completion:*:git-checkout:*' sort false
# set descriptions format to enable group support
# NOTE: don't use escape sequences here, fzf-tab will ignore them
zstyle ':completion:*:descriptions' format '[%d]'
# set list-colors to enable filename colorizing
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
# force zsh not to show completion menu, which allows fzf-tab to capture the unambiguous prefix
zstyle ':completion:*' menu no
zstyle ':completion:*' list-max-items 20

# preview directory's content with eza when completing cd
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'eza -1 --color=always $realpath'

# switch group using `<` and `>`
# zstyle ':fzf-tab:*' switch-group '<' '>'
# zstyle ':fzf-tab:*' fzf-command ftb-tmux-popup

# Set Up Completion
# ------------------------------------------------------------------------------
# Problems with insecure directories under macOS?
# -> see https://stackoverflow.com/a/13785716/149220 for a solution
cache_directory="$XDG_CACHE_HOME/zsh"

## Use cache
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "$cache_directory/completion-cache"

## These were created by `compinstall`
zstyle ':completion:*' completer _complete _ignored _approximate
zstyle ':completion:*' matcher-list 'm:{[:lower:]}={[:upper:]} r:|[._-]=* r:|=*' 'm:{[:lower:]}={[:upper:]}' 'm:{[:lower:]}={[:upper:]}' 'm:{[:lower:]}={[:upper:]}'
zstyle ':completion:*' max-errors 2
zstyle :compinstall filename "$ZDOTDIR/.zshrc"

## Initialize completion system
### Set location for compinit's dumpfile.
autoload -Uz compinit && compinit -d "$cache_directory/compinit-dumpfile"

# FZF and Zoxide integration
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
zvm_after_init_commands+=('[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh')
eval "$(zoxide init --cmd cd zsh)"

# Detect OS type
OS_TYPE=$(uname)
if [ "$OS_TYPE" = "Darwin" ]; then
    # macOS specific zsh configs
    ZSH_THEME="robbyrussell"
    # Prompt
    # eval "$(oh-my-posh init zsh --config $HOME/.config/ohmyposh/zen.toml)"
    eval "$(oh-my-posh init zsh --config /opt/homebrew/opt/oh-my-posh/themes/emodipt-extend.omp.json)"

    export ANTIDOTE_DIR="/opt/homebrew/opt/antidote/share/antidote"

elif [ "$OS_TYPE" = "Linux" ]; then
    # Linux specific zsh configs
    ZSH_THEME="powerlevel10k/powerlevel10k"
    export NVM_DIR="${HOME}/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"  # This loads nvm

    # Nix
    if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
    . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
    # . /etc/profile.d/nix.sh
    fi
    # End Nix
    export LOCALE_ARCHIVE="/usr/lib/locale/locale-archive"

    export ANTIDOTE_DIR="${HOME}/.antidote"
fi

# ------------------------------------------------------------------
## Antidote plugin manager setup
# ------------------------------------------------------------------

# Set the root name of the plugins files (.txt and .zsh) antidote will use.
zsh_plugins=${ZSHRCDIR}/.zsh_plugins

# Ensure the .zsh_plugins.txt file exists so you can add plugins.
[[ -f ${zsh_plugins}.txt ]] || touch ${zsh_plugins}.txt

# Lazy-load antidote from its functions directory.
fpath=(${ANTIDOTE_DIR}/functions $fpath)
autoload -Uz antidote
source ${ANTIDOTE_DIR}/antidote.zsh

# Helper function to compile bundles and source zshrc
function compile_antidote() {
    sh ${ZSHRCDIR}/bundle_compile
    exec zsh
    echo 'Sourced zshrc'
}

alias update_antidote='antidote bundle < ${ZSHRCDIR}/.zsh_plugins.txt >| ${ZSHRCDIR}/zsh_plugins.zsh'

# Source compiled antidote bundles and configs
[ -f ${ZSHRCDIR}/zsh_plugins.zsh ] && source ${ZSHRCDIR}/zsh_plugins.zsh
