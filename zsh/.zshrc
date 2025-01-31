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
zstyle ':omz:update' mode reminder # Update reminders
zstyle ':omz:update' frequency 13  # Check every 13 days

# Load profiling tool
zmodload zsh/zprof
# zmodload zsh/mapfile # Bring mapfile functionality similar to bash

# Disable unnecessary security checks
ZSH_DISABLE_COMPFIX=true
DISABLE_MAGIC_FUNCTIONS=true

# Core plugins
plugins=(
    fzf-tab                 # FZF tab completion
    zsh-syntax-highlighting # Syntax highlighting
    zsh-autosuggestions     # Command suggestions
)

source $ZSH/custom/plugins/fzf-tab/fzf-tab.plugin.zsh
source $ZSH/oh-my-zsh.sh

# ------------------------------------------------------------------------------
# Local Configuration
# ------------------------------------------------------------------------------
# Source additional configurations
for config in "$HOME/dotfiles/zsh/local/"*.zsh; do
    [[ -f "$config" ]] && source "$config"
done
