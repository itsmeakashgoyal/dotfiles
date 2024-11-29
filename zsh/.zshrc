#                     █████
#                    ░░███
#   █████████  █████  ░███████   ████████   ██████
#  ░█░░░░███  ███░░   ░███░░███ ░░███░░███ ███░░███
#  ░   ███░  ░░█████  ░███ ░███  ░███ ░░░ ░███ ░░░
#    ███░   █ ░░░░███ ░███ ░███  ░███     ░███  ███
#   █████████ ██████  ████ █████ █████    ░░██████
#  ░░░░░░░░░ ░░░░░░  ░░░░ ░░░░░ ░░░░░      ░░░░░░
#
#  ▓▓▓▓▓▓▓▓▓▓
# ░▓ author ▓ Akash Goyal
# ░▓ file   ▓ zsh/.zshrc
# ░▓▓▓▓▓▓▓▓▓▓
# ░░░░░░░░░░
#
#█▓▒░

# ------------------------------------------------------------------------------
# Oh My Zsh Configuration
# ------------------------------------------------------------------------------
# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"
zstyle ':omz:update' mode reminder # Update reminders
zstyle ':omz:update' frequency 13  # Check every 13 days

# Core plugins
plugins=(
    git                      # Git integration
    sudo                     # Sudo support
    history-substring-search # Better history search
    colored-man-pages        # Colored man pages
    zsh-vi-mode              # Vi mode
    ruby                     # Ruby support
    fzf-tab                  # FZF tab completion
    zsh-syntax-highlighting  # Syntax highlighting
    zsh-autosuggestions      # Command suggestions
    # zsh-autocomplete
)

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
# Local Configuration
# ------------------------------------------------------------------------------
# Source additional configurations
for config in "$HOME/dotfiles/zsh/local/"*.zsh; do
    [[ -f "$config" ]] && source "$config"
done
