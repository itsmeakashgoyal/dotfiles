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
# Shell Options
# ------------------------------------------------------------------------------
setopt glob_dots     # Include dotfiles in globbing
setopt extended_glob # Extended globbing capabilities
setopt NO_HUP        # Don't kill background jobs on exit
setopt noflowcontrol # Disable flow control (ctrl-s/ctrl-q)
setopt autocd              # change directory just by typing its name
setopt interactivecomments # allow comments in interactive mode
setopt magicequalsubst     # enable filename expansion for arguments of the form ‘anything=expression’
setopt nonomatch           # hide error message if there is no match for the pattern
setopt notify              # report the status of background jobs immediately
setopt numericglobsort     # sort filenames numerically when it makes sense
setopt promptsubst         # enable command substitution in prompt

# Eza colors: https://github.com/eza-community/eza/blob/main/man/eza_colors.5.md
# ------------------------------------------------------------------------------
# Eza Configuration
# ------------------------------------------------------------------------------
# Icons and colors for different file types
export EZA_COLORS="
di=34:                    # Directories (blue)
fi=0:                     # Files (default)
ex=32:                    # Executables (green)
ln=36:                    # Symlinks (cyan)
or=31:                    # Broken symlinks (red)
bd=33:                    # Block devices (yellow)
cd=33:                    # Character devices (yellow)
so=35:                    # Sockets (magenta)
pi=35:                    # Pipes (magenta)

# Permissions
ur=38;5;250:             # User read
uw=38;5;250:             # User write
ux=38;5;250:             # User execute
ue=38;5;250:             # User special
gr=38;5;245:             # Group read
gw=38;5;245:             # Group write
gx=38;5;245:             # Group execute
ge=38;5;245:             # Group special
tr=38;5;240:             # Others read
tw=38;5;240:             # Others write
tx=38;5;240:             # Others execute
te=38;5;240:             # Others special

# Size colors
sn=32:                   # Size numbers (green)
sb=32:                   # Size unit (green)
nb=32:                   # Allocated size numbers
nk=32:                   # Allocated size unit

# Git status colors
ga=32:                   # New
gm=33:                   # Modified
gd=31:                   # Deleted
gv=36:                   # Renamed

# File types and extensions
*.zip=38;5;214:         # Archives
*.tar=38;5;214:
*.gz=38;5;214:
*.rar=38;5;214:
*.7z=38;5;214:

*.pdf=38;5;203:         # Documents
*.md=38;5;123:
*.txt=38;5;123:
*.doc=38;5;123:
*.docx=38;5;123:

*.mp3=38;5;135:         # Media
*.wav=38;5;135:
*.mp4=38;5;135:
*.mov=38;5;135:

*.jpg=38;5;205:         # Images
*.jpeg=38;5;205:
*.png=38;5;205:
*.gif=38;5;205:
*.svg=38;5;205:

*.vim=38;5;156:         # Code
*.zsh=38;5;156:
*.sh=38;5;156:
*.py=38;5;156:
*.js=38;5;156:
*.rb=38;5;156:
*.rs=38;5;156:
*.go=38;5;156:

# Special files
.git=38;5;197:          # Git directory
.gitignore=38;5;197:    # Git ignore file
Dockerfile=38;5;222:    # Docker files
docker-compose.yml=38;5;222:
"

# ------------------------------------------------------------------------------
# Homebrew Configuration
# ------------------------------------------------------------------------------
# Core Homebrew settings
if command -v brew &> /dev/null; then
    export HOMEBREW_NO_ANALYTICS=1       # Disable analytics collection
    export HOMEBREW_AUTOREMOVE=1         # Automatically remove unused dependencies
fi

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

# Colorful man pages
export LESS_TERMCAP_mb=$'\e[1;31m'   # begin bold
export LESS_TERMCAP_md=$'\e[1;31m'   # begin double-bright mode
export LESS_TERMCAP_me=$'\e[0m'      # end all mode
export LESS_TERMCAP_se=$'\e[0m'      # end standout-mode
export LESS_TERMCAP_so=$'\e[01;33m'  # begin standout-mode
export LESS_TERMCAP_ue=$'\e[0m'      # end underline
export LESS_TERMCAP_us=$'\e[1;4;32m' # begin underline

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
# Basic Completion Settings
# ------------------------------------------------------------------------------
# Enable caching
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "$XDG_CACHE_HOME/zsh/zcompcache"
# zstyle :compinstall filename "$ZDOTDIR/.zshrc"

# Hide unnecessary files
zstyle ':completion:*' ignored-patterns '.|..|.DS_Store|**/.|**/..|**/.DS_Store|**/.git'

# Set descriptions and messages
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu select
zstyle ':completion:*:descriptions' format '[%d]'
zstyle ':completion:*:messages' format '%d'
zstyle ':completion:*:warnings' format 'No matches for: %d'
zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s

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

