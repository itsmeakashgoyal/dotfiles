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
# ░▓ file   ▓ zsh/local/history.zsh
# ░▓▓▓▓▓▓▓▓▓▓
# ░░░░░░░░░░
#
#█▓▒░

# ------------------------------------------------------------------------------
# History Configuration
# ------------------------------------------------------------------------------
# History file location and size
export HISTFILE="${HOME}/.zsh_history"
export HISTSIZE=130000 # Internal history list size
export SAVEHIST=100000 # History file size
export HISTDUP=erase   # Erase duplicates in history
export LESSHISTFILE=-
# HIST_STAMPS=yyyy/mm/dd

# History Options
setopt append_history # Append to history file
setopt extended_history
setopt hist_expire_dups_first
setopt share_history        # Share history between sessions
setopt hist_reduce_blanks   # Remove unnecessary blanks
setopt hist_ignore_space    # Ignore space-prefixed commands
setopt hist_ignore_all_dups # Remove older duplicate entries
setopt hist_save_no_dups    # Don't save duplicates
setopt hist_ignore_dups     # Don't record duplicates
setopt hist_find_no_dups    # Skip duplicates when searching
setopt hist_verify          # Show command before executing from history
setopt inc_append_history   # Add commands immediately
setopt bang_hist            # Enable history expansion
