#!/usr/bin/env zsh
#                     █████
#                    ░░███
#   █████████  █████  ░███████
#  ░█░░░░███  ███░░   ░███░░███
#  ░   ███░  ░░█████  ░███ ░███
#    ███░   █ ░░░░███ ░███ ░███
#   █████████ ██████  ████ █████
#  ░░░░░░░░░ ░░░░░░  ░░░░ ░░░░░
#
#  ▓▓▓▓▓▓▓▓▓▓
# ░▓ author ▓ Akash Goyal
# ░▓ file   ▓ zsh/local/exports.zsh
# ░▓▓▓▓▓▓▓▓▓▓
# ░░░░░░░░░░
#
#█▓▒░
# ------------------------------------------------------------------------------
# Environment Detection and Base Configuration
# ------------------------------------------------------------------------------
OS_TYPE=$(uname)
ARCH_TYPE=$(uname -m)

# OS-specific Homebrew configuration
case "$OS_TYPE" in
"Darwin")
    # macOS Homebrew paths
    export HOMEBREW_PREFIX="/opt/homebrew"
    export HOMEBREW_CELLAR="/opt/homebrew/Cellar"
    export HOMEBREW_REPOSITORY="/opt/homebrew"

    # macOS specific paths
    typeset -U path # Ensure PATH elements are unique
    path=(
        "/opt/homebrew/bin"
        "/opt/homebrew/opt/llvm/bin"
        "/usr/local/opt/ruby/bin"
        $path
    )
    ;;
"Linux")
    # Linux Homebrew paths
    export HOMEBREW_PREFIX="/home/linuxbrew/.linuxbrew"
    export HOMEBREW_CELLAR="/home/linuxbrew/.linuxbrew/Cellar"
    export HOMEBREW_REPOSITORY="/home/linuxbrew/.linuxbrew/Homebrew"

    # Linux specific paths
    typeset -U path # Ensure PATH elements are unique
    path=(
        "/usr/local/go/bin"
        "/usr/local/bin/clang-15"
        "/usr/local/compilers/clang15/bin"
        "$HOME/.local/share/gem/ruby/3.0.0/bin"
        "/snap/bin"
        "$HOME/.cargo/bin"
        "/home/linuxbrew/.linuxbrew/bin"
        "/home/linuxbrew/.linuxbrew/sbin"
        $path
    )

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
# Common Path Configuration
# ------------------------------------------------------------------------------
# Add common paths (for both OS types)
typeset -U path # Ensure PATH elements are unique
path=(
    "$HOME/bin"
    "$HOME/.local/bin"
    "/usr/local/bin"
    "/usr/local/sbin"
    "/usr/bin"
    "/usr/sbin"
    "/bin"
    "/sbin"
    "$HOME/.fzf/bin"
    "/usr/local/lib/node_modules"
    "$HOME/.config/tmux/plugins/t-smart-tmux-session-manager/bin"
    $path
)
export PATH # Export the final PATH

# ------------------------------------------------------------------------------
# Performance Optimization
# ------------------------------------------------------------------------------
# Compilation flags
export MAKEFLAGS="-j$(nproc)" # Use all CPU cores for compilation

# Oh My Posh prompt
export OHMYPOSH_THEMES_DIR="${HOMEBREW_PREFIX}/opt/oh-my-posh/themes"
eval "$(oh-my-posh init zsh --config ${XDG_DOTFILES_DIR}/ohmyposh/emodipt.json)"
