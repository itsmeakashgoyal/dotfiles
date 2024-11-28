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
# ░▓ file   ▓ zsh/config/keybindings.zsh
# ░▓▓▓▓▓▓▓▓▓▓
# ░░░░░░░░░░
#
#█▓▒░
# ------------------------------------------------------------------------------
# Zsh Keybindings Configuration
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Auto-suggestions
# ------------------------------------------------------------------------------
bindkey '^w' autosuggest-execute # Execute suggestion
bindkey '^e' autosuggest-accept  # Accept suggestion
bindkey '^u' autosuggest-toggle  # Toggle suggestions

# ------------------------------------------------------------------------------
# Navigation
# ------------------------------------------------------------------------------
bindkey '^L' vi-forward-word     # Move forward one word
bindkey '^k' up-line-or-search   # Search history up
bindkey '^j' down-line-or-search # Search history down

# ------------------------------------------------------------------------------
# History Search
# ------------------------------------------------------------------------------
bindkey "^[[A" history-beginning-search-backward # Up arrow
bindkey "^[[B" history-beginning-search-forward  # Down arrow

# ------------------------------------------------------------------------------
# Key Reference
# ------------------------------------------------------------------------------
# ^w = Ctrl + w
# ^e = Ctrl + e
# ^u = Ctrl + u
# ^L = Ctrl + l
# ^k = Ctrl + k
# ^j = Ctrl + j
# ^[[A = Up Arrow
# ^[[B = Down Arrow
