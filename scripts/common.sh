#!/usr/bin/env bash

# Enable strict mode for better error handling
set -eu pipefail
IFS=$'\n\t'

# Get current user
user=$(whoami)

# Define constants
DOTFILES_DIR="${HOME}/dotfiles"
CONFIG_DIR="${HOME}/.config"
LOG_FILE="/tmp/setup_log.txt"

# Define log file
LOG="/tmp/setup_log.txt"

# Function to log and display process steps
process() {
    echo "$(date) PROCESSING:  $@" >>"$LOG"
    printf "$(tput setaf 6) [STEP ${STEP:-0}] %s...$(tput sgr0)\n" "$@"
    STEP=$((STEP + 1))
}

command_exists() {
    command -v "$1" >/dev/null 2>&1
}
