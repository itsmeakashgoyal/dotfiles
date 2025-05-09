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

function add_to_path() {
  # NOTE: zsh only

  # usage:
  # add_to_path prepend /path/to/prepend
  # add_to_path append /path/to/append

  if [ -d "$2" ]; then
    # If the given path exist, proceed...
    if [[ ":$PATH:" == *":$2:"* ]]; then
      remove_from_path "$2"
    fi

    if [ "$1" = "prepend" ]; then
      PATH="$2:$PATH"
      export PATH
    elif [ "$1" = "append" ]; then
      PATH="$PATH:$2"
      export PATH
    else
      echo "Unknown option. Use 'prepend' or 'append'."
    fi
  fi
}

function remove_from_path() {
  # NOTE: zsh only

  # usage:
  # remove_from_path /path/to/remove

  local path_to_remove="$1"
  if [[ -n "$path_to_remove" && ":$PATH:" == *":$path_to_remove:"* ]]; then
    while [[ ":$PATH:" == *":$path_to_remove:"* ]]; do
      # Remove
      PATH="${PATH/#$path_to_remove:/}"   # If it's at the beginning
      PATH="${PATH/%:$path_to_remove/}"   # If it's at the end
      PATH="${PATH//:$path_to_remove:/:}" # If it's in the middle
    done
    PATH="${PATH#:}" # Remove leading colon
    PATH="${PATH%:}" # Remove trailing colon
    export PATH
  fi
}

# ------------------------------------------------------------------------------
# Homebrew Configuration
# ------------------------------------------------------------------------------
# Core Homebrew settings
if command -v brew &>/dev/null; then
  export HOMEBREW_NO_ANALYTICS=1 # Disable analytics collection
  export HOMEBREW_AUTOREMOVE=1   # Automatically remove unused dependencies
fi

# ------------------------------------------------------------------------------
# Terminal and Editor Settings
# ------------------------------------------------------------------------------
if command -v nvim >/dev/null 2>&1; then
  export EDITOR="nvim"
  export VISUAL="nvim"
  alias vi="nvim"
else
  export EDITOR="vim"
  export VISUAL="vim"
fi

# Bat: https://github.com/sharkdp/bat
# export BAT_THEME="Squirrelsong Dark"

# Ripgrep config file location
# export RIPGREP_CONFIG_PATH="$XDG_DOTFILES_DIR/dots/.ripgreprc"

# Config file for wget
# export WGET_CONFIG_PATH="${XDG_DOTFILES_DIR}/dots/.wgetrc"

# ------------------------------------------------------------------------------
# Zsh Completion Configuration
# ------------------------------------------------------------------------------
# Set up completion system
loc=${ZDOTDIR:-"${HOME}/dotfiles/zsh"}
fpath=($loc/completion $fpath)

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
    "/usr/local/lib/pkgconfig"
    "/usr/local/lib"
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
