# ------------------------------------------------------------------------------
# Zsh Completion Configuration
# ------------------------------------------------------------------------------

# Set up cache directory
cache_directory="${XDG_CACHE_HOME:-$HOME/.cache}/zsh"
[[ ! -d "$cache_directory" ]] && mkdir -p "$cache_directory"

# ------------------------------------------------------------------------------
# Basic Completion Settings
# ------------------------------------------------------------------------------
# Enable caching
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "$cache_directory/completion-cache"

# Prevent tab completion on paste
zstyle ':completion:*' insert-tab pending

# Set completion display limits
zstyle ':completion:*' list-max-items 20
zstyle ':completion:*' menu no          # Disable menu for fzf-tab
zstyle ':completion:*' verbose yes      # Verbose output
zstyle ':completion:*' group-name ''    # Group by categories

# ------------------------------------------------------------------------------
# Completion Formatting
# ------------------------------------------------------------------------------
# Set descriptions and messages
zstyle ':completion:*:descriptions' format '[%d]'
zstyle ':completion:*:messages' format '%d'
zstyle ':completion:*:warnings' format 'No matches for: %d'

# Colors and styling
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*:directory-stack' list-colors '=(#b) #([0-9]#)*( *)==95=38;5;12'

# ------------------------------------------------------------------------------
# Matching Configuration
# ------------------------------------------------------------------------------
# Completion matching rules
zstyle ':completion:*' completer _complete _ignored _approximate
zstyle ':completion:*' matcher-list \
    'm:{a-z}={A-Z}' \
    'm:{[:lower:]}={[:upper:]} r:|[._-]=* r:|=*' \
    'm:{[:lower:]}={[:upper:]}' \
    'm:{[:lower:]}={[:upper:]}'

# Error tolerance
zstyle ':completion:*' max-errors 2

# ------------------------------------------------------------------------------
# Git-specific Settings
# ------------------------------------------------------------------------------
# Disable sorting for git checkout
zstyle ':completion:*:git-checkout:*' sort false

# ------------------------------------------------------------------------------
# FZF-tab Configuration
# ------------------------------------------------------------------------------
# Directory preview
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'eza -1 --color=always $realpath'

# Navigation and display
zstyle ':fzf-tab:*' switch-group '<' '>'
zstyle ':fzf-tab:*' fzf-command ftb-tmux-popup

# ------------------------------------------------------------------------------
# Initialize Completion System
# ------------------------------------------------------------------------------
autoload -Uz compinit

# Only regenerate completion dump if needed (older than 24 hours)
if [[ -n ${ZDOTDIR}/.zcompdump(#qN.mh+24) ]]; then
    compinit -d "$cache_directory/.zcompdump"
else
    compinit -C -d "$cache_directory/.zcompdump"
fi