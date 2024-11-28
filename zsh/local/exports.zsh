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

# ------------------------------------------------------------------------------
# Homebrew Configuration
# ------------------------------------------------------------------------------
# Core Homebrew settings
export HOMEBREW_NO_AUTO_UPDATE=1     # Prevent automatic updates
export HOMEBREW_NO_ANALYTICS=1       # Disable analytics collection
export HOMEBREW_NO_INSTALL_CLEANUP=1 # Skip cleanup during installation
export HOMEBREW_NO_ENV_HINTS=1       # Disable environment hints
export HOMEBREW_AUTOREMOVE=1         # Automatically remove unused dependencies
export HOMEBREW_BAT=1                # Use bat for brew cat command
export HOMEBREW_CURL_RETRIES=3       # Number of download retry attempts

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
# Language and Locale Settings
# ------------------------------------------------------------------------------
export LC_COLLATE=en_US.UTF-8
export LC_CTYPE=en_US.UTF-8
export LC_MESSAGES=en_US.UTF-8
export LC_MONETARY=en_US.UTF-8
export LC_NUMERIC=en_US.UTF-8
export LC_TIME=en_US.UTF-8
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
export LANGUAGE=en_US.UTF-8
export LESSCHARSET=utf-8

# ------------------------------------------------------------------------------
# Terminal and Editor Settings
# ------------------------------------------------------------------------------
# Set default editor
export EDITOR="nvim"
export VISUAL="nvim"

# Configure less
export LESS="-R --quit-if-one-screen"
export LESSHISTFILE="-" # Prevent creation of ~/.lesshst file

# Colorful man pages
export LESS_TERMCAP_mb=$'\e[1;31m'   # begin bold
export LESS_TERMCAP_md=$'\e[1;31m'   # begin double-bright mode
export LESS_TERMCAP_me=$'\e[0m'      # end all mode
export LESS_TERMCAP_se=$'\e[0m'      # end standout-mode
export LESS_TERMCAP_so=$'\e[01;33m'  # begin standout-mode
export LESS_TERMCAP_ue=$'\e[0m'      # end underline
export LESS_TERMCAP_us=$'\e[1;4;32m' # begin underline

# ------------------------------------------------------------------------------
# Performance Optimization
# ------------------------------------------------------------------------------
# Compilation flags
export MAKEFLAGS="-j$(nproc)" # Use all CPU cores for compilation
