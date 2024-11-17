# ------------------------------------------------------------------------------
# Oh My Zsh Configuration
# ------------------------------------------------------------------------------
# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"
zstyle ':omz:update' mode reminder  # Update reminders
zstyle ':omz:update' frequency 13   # Check every 13 days

# Core plugins
plugins=(
    git                         # Git integration
    sudo                        # Sudo support
    history-substring-search    # Better history search
    colored-man-pages          # Colored man pages
    zsh-vi-mode                # Vi mode
    ruby                       # Ruby support
    fzf-tab                    # FZF tab completion
    zsh-syntax-highlighting    # Syntax highlighting
    zsh-autosuggestions        # Command suggestions
    # zsh-autocomplete
)

# ------------------------------------------------------------------------------
# Plugin Configuration
# ------------------------------------------------------------------------------
# FZF-tab
source $ZSH/custom/plugins/fzf-tab/fzf-tab.plugin.zsh
source $ZSH/oh-my-zsh.sh

# Zsh Vi Mode
# https://github.com/jeffreytse/zsh-vi-mode
ZVM_INIT_MODE=sourcing
function zvm_config() {
    ZVM_LINE_INIT_MODE=$ZVM_MODE_INSERT
    ZVM_VI_INSERT_ESCAPE_BINDKEY=\;\;
    ZVM_CURSOR_STYLE_ENABLED=false
    ZVM_VI_EDITOR=nvim
}

function zvm_after_init() {
    zvm_bindkey viins '^Q' push-line
}

# ------------------------------------------------------------------------------
# Core Configuration
# ------------------------------------------------------------------------------
# Set shell options
setopt glob_dots         # Include dotfiles in globbing
setopt no_auto_menu     # Require extra TAB for menu
setopt extended_glob    # Extended globbing capabilities

# Environment setup
export LANG=en_US.UTF-8
export MANPATH="/usr/local/man:$MANPATH"

# ------------------------------------------------------------------------------
# OS-Specific Configuration
# ------------------------------------------------------------------------------
case "$(uname)" in
"Darwin")
    export ANTIDOTE_DIR="/opt/homebrew/opt/antidote/share/antidote"
    export OHMYPOSH_THEMES_DIR="/opt/homebrew/opt/oh-my-posh/themes"
    ;;
"Linux")
    export ANTIDOTE_DIR="/home/linuxbrew/.linuxbrew/opt/antidote/share/antidote"
    export OHMYPOSH_THEMES_DIR="/home/linuxbrew/.linuxbrew/opt/oh-my-posh/themes"

    # NVM setup
    export NVM_DIR="${HOME}/.nvm"
    [[ -s "$NVM_DIR/nvm.sh" ]] && source "$NVM_DIR/nvm.sh"

    # # Nix
    # if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
    # . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
    # # . /etc/profile.d/nix.sh
    # fi
    # # End Nix
    # export LOCALE_ARCHIVE="/usr/lib/locale/locale-archive"
    ;;
esac

# ------------------------------------------------------------------------------
# Tool Integration
# ------------------------------------------------------------------------------
# FZF and Zoxide
[[ -f ~/.fzf.zsh ]] && source ~/.fzf.zsh
zvm_after_init_commands+=('[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh')
eval "$(zoxide init --cmd cd zsh)"

# Oh My Posh prompt
eval "$(oh-my-posh init zsh --config ${XDG_DOTFILES_DIR}/ohmyposh/emodipt.json)"

# ------------------------------------------------------------------------------
# Local Configuration
# ------------------------------------------------------------------------------
# Source additional configurations
for config in keybindings completion antidote; do
    config_file="$HOME/dotfiles/zsh/config/${config}.zsh"
    [[ -f "$config_file" ]] && builtin source "$config_file"
done
