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

# Common paths for both OS types
COMMON_PATHS=(
    "/usr/bin"
    "/usr/sbin"
    "/bin"
    "/sbin"
)

# OS-specific Homebrew configuration
case "$OS_TYPE" in
"Darwin")
    # macOS Homebrew paths
    HOMEBREW_PREFIX="/opt/homebrew"
    HOMEBREW_CELLAR="/opt/homebrew/Cellar"
    HOMEBREW_REPOSITORY="/opt/homebrew"

    # macOS specific paths
    OS_PATHS=(
        "/opt/homebrew/bin"
        "/opt/homebrew/opt/llvm/bin"
    )
    ;;
"Linux")
    # Linux Homebrew paths
    HOMEBREW_PREFIX="/home/linuxbrew/.linuxbrew"
    HOMEBREW_CELLAR="/home/linuxbrew/.linuxbrew/Cellar"
    HOMEBREW_REPOSITORY="/home/linuxbrew/.linuxbrew/Homebrew"

    # Linux specific paths
    OS_PATHS=(
        "/usr/local/bin"
        "/usr/local/sbin"
        "/usr/local/compilers/clang15/bin"
        "/home/linuxbrew/.linuxbrew/bin"
        "/home/linuxbrew/.linuxbrew/sbin"
        "/usr/lib/jvm/java-11-openjdk-amd64"
    )
    ;;
esac

# Combine the common and OS-specific paths and ensure uniqueness in the final path
typeset -U path
path=(
    "${OS_PATHS[@]}"
    "${COMMON_PATHS[@]}"
    $path
)

# ------------------------------------------------------------------------------
# Export Environment Variables
# ------------------------------------------------------------------------------
export HOMEBREW_PREFIX HOMEBREW_CELLAR HOMEBREW_REPOSITORY
export PATH
export MAKEFLAGS="-j$(nproc)" # Use all CPU cores for compilation

# ------------------------------------------------------------------------------
# Oh My Posh prompt
# ------------------------------------------------------------------------------
export OHMYPOSH_THEMES_DIR="${HOMEBREW_PREFIX}/opt/oh-my-posh/themes"

# Lazy load Oh My Posh prompt only when needed
function lazy_omp() {
    eval "$(oh-my-posh init zsh --config ${XDG_DOTFILES_DIR}/ohmyposh/emodipt.json)"
}

precmd_functions+=(lazy_omp)
