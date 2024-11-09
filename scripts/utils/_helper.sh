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

# Get OS name
readonly OS_NAME=$(grep ^NAME /etc/*os-release | cut -d '"' -f 2)

# This detection only works for mac and linux.
OS_TYPE=$(uname)

# Get current user
user=$(whoami)

# Define variables
DOTFILES_DIR="${HOME}/dotfiles"
CONFIG_DIR="${HOME}/.config"

# Function to print colored messages
print_message() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

# Function to log messages
log_message() {
    local message=$1
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $message" >>setup.log
}

# Error handling function
handle_error() {
    print_message "$RED" "An error occurred on line $1"
    log_message "ERROR: Script failed on line $1"
    exit 1
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

# Function to log messages
log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1"
}
