#!/usr/bin/env bash

#################################################
#      File: _helper.sh                        #
#      Author: Akash Goyal                      #
#      Status: Development                      #
#################################################

# Define colors for text output
readonly RED='\033[31m'
readonly YELLOW='\033[33m'
readonly GREEN='\033[32m'
readonly BLUE='\033[34m'
readonly NC='\033[0m' # No Color

# This detection only works for mac and linux.
OS_TYPE=$(uname)

# Get current user
user=$(whoami)

# Define variables
DOTFILES_DIR="${HOME}/dotfiles"
CONFIG_DIR="${HOME}/.config"

# Check if the home directory and linuxtoolbox folder exist, create them if they don't
LINUXTOOLBOXDIR="$HOME/linuxtoolbox"

# Define log file
LOG_FILE="/tmp/setup_log.txt"

# Function to print colored messages
print_message() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

# Function to log messages
log_message() {
    local message="$1"
    local timestamp="$(date '+%Y-%m-%d %H:%M:%S')"
    local log_line="[$timestamp] $message"

    echo "$log_line"
    echo "$log_line" >>"$LOG_FILE"
}

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to check if a command was successful
check_command() {
    if [ $? -ne 0 ]; then
        echo "${RED}Error: $1 failed${RC}" >&2
        exit 1
    fi
}

# Define a function to print the error message and exit with a non-zero status
print_error() {
    local line_number="$1"
    local command="$2"
    local exit_code="$3"

    echo "ERROR: An error occurred in the script \"$0\" on line $line_number" >&2
    echo "Command: $command" >&2
    echo "Exit Code: $exit_code" >&2

    # Print stack trace
    echo "Stack Trace:" >&2
    for i in "${!FUNCNAME[@]}"; do
        echo "  ${FUNCNAME[$i]}() called at line ${BASH_LINENO[$i - 1]} in ${BASH_SOURCE[$i]}" >&2
    done

    exit 1
}

linkUnderHome() {
    cp "${HOME}/${2}" "$LINUXTOOLBOXDIR" 2>/dev/null
    # Force create/replace the symlink.
    ln -svf "${DOTFILES_DIR}/${1}" "${HOME}/${2}"
}

linkUnderConfig() {
    cp "${HOME}/${2}" "$LINUXTOOLBOXDIR" 2>/dev/null
    # Force create/replace the symlink.
    ln -svf "${DOTFILES_DIR}/${1}" "${CONFIG_DIR}/${2}"
}

# Function to create symlinks with backup
symlink() {
    local source="$1"
    local destination="$2"
    local source_path="${DOTFILES_DIR}/${source}"
    local dest_path="${HOME}/${destination}"
    local backup_path="${LINUXTOOLBOXDIR}/${destination}"

    # Check if source exists
    if [[ ! -e "$source_path" ]]; then
        print_message "$RED" "Error: Source '$source_path' does not exist"
        return 1
    fi

    # Create backup directory if it doesn't exist
    mkdir -p "$(dirname "$backup_path")"

    # If destination exists or is a symlink
    if [[ -e "$dest_path" ]] || [[ -L "$dest_path" ]]; then
        # If it's a symlink, unlink it first
        if [[ -L "$dest_path" ]]; then
            print_message "$YELLOW" "Unlinking existing symlink '$dest_path'"
            unlink "$dest_path"
        fi
        
        # If it's a regular file/directory, back it up
        if [[ -e "$dest_path" ]]; then
            print_message "$YELLOW" "Backing up existing '$dest_path' to '$backup_path'"
            mv "$dest_path" "$backup_path"
        fi
    fi

    # Create parent directory if it doesn't exist
    mkdir -p "$(dirname "$dest_path")"

    # Create the symlink
    ln -svf "$source_path" "$dest_path"
    print_message "$GREEN" "Created symlink: '$dest_path' -> '$source_path'"
    log_message "Created symlink: '$dest_path' -> '$source_path'"
}

if [ ! -d "$LINUXTOOLBOXDIR" ]; then
    print_message "$YELLOW" "→ Creating linuxtoolbox directory: $LINUXTOOLBOXDIR"
    mkdir -p "$LINUXTOOLBOXDIR"
    print_message "$GREEN" "→ linuxtoolbox directory created: $LINUXTOOLBOXDIR"
fi
