#!/usr/bin/env bash

#################################################
#      File: _linuxOS.sh                        #
#      Author: Akash Goyal                      #
#      Status: Development                      #
#################################################

# Enable strict mode
set -euo pipefail
IFS=$'nt'

# Define colors for text output
readonly RED='\033[31m'
readonly YELLOW='\033[33m'
readonly GREEN='\033[32m'
readonly BLUE='\033[34m'
readonly NC='\033[0m' # No Color

# Get OS name
readonly OS_NAME=$(grep ^NAME /etc/*os-release | cut -d '"' -f 2)

# Get current user
user=$(whoami)

# Define log file
LOG="/tmp/setup_log.txt"

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

# Check if we are on ubuntu
check_ubuntu() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        if [[ "$ID" == "ubuntu" || "$ID_LIKE" == *"ubuntu"* ]]; then
            return 0 # It's Ubuntu or Ubuntu-based
        fi
    elif [ -f /etc/lsb-release ]; then
        . /etc/lsb-release
        if [[ "$DISTRIB_ID" == "Ubuntu" ]]; then
            return 0 # It's Ubuntu
        fi
    fi
    return 1 # It's not Ubuntu or Ubuntu-based
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

# Clean up
cleanup() {
    print_message "$YELLOW" "
##############################################
#              Cleanup Section               #
##############################################
"
    log_message "Starting cleanup process"
    sudo apt-get -y autoclean
    sudo apt-get -y clean
    print_message "$GREEN" "Cleaned!"
    log_message "Cleanup completed"
    sleep 2
}

# Update and install packages
update_and_install() {
    print_message "$YELLOW" "
##############################################
#      Update, Install, & Secure Section     #
##############################################
"
    log_message "Starting system update and package installation"

    if [ -z "$CI" ]; then
        # Update and upgrade system
        sudo apt-get update
        sudo apt-get -y upgrade
    fi

    local packages=(
        build-essential libc++-15-dev clang-format-15 libkrb5-dev procps file vim-gtk python3-setuptools
        tmux locate libgraph-easy-perl fd-find fontconfig python3-venv python3-pip luarocks shellcheck
    )

    sudo apt-get -y install "${packages[@]}"

    print_message "$GREEN" "Completed Updates & Installs."
    log_message "Completed system update and package installation"
    sleep 2
}

installEzaAndExa() {
    if command_exists exa; then
        print_message "$YELLOW" "exa already installed"
    else
        print_message "$YELLOW" "Installing exa.."
        EXA_VERSION=$(curl -s "https://api.github.com/repos/ogham/exa/releases/latest" | grep -Po '"tag_name": "v\K[0-9.]+')
        curl -Lo exa.zip "https://github.com/ogham/exa/releases/latest/download/exa-linux-x86_64-v${EXA_VERSION}.zip"
        sudo unzip -q exa.zip bin/exa -d /usr/local
        rm exa.zip
    fi

    if command_exists eza; then
        print_message "$YELLOW" "eza already installed"
    else
        print_message "$YELLOW" "Installing eza.."
        sudo apt install -y gpg
        sudo mkdir -p /etc/apt/keyrings
        wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
        echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | sudo tee /etc/apt/sources.list.d/gierens.list
        sudo chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list
        sudo apt update
        sudo apt install -y eza
    fi
}

installAntidote() {
    if command_exists antidote; then
        print_message "$YELLOW" "antidote already installed"
    else
        print_message "$YELLOW" "Installing antidote.."
        git clone --depth=1 https://github.com/mattmc3/antidote.git "${ZDOTDIR:-$HOME}/.antidote"
    fi
}

installLatestGo() {
    if command_exists go; then
        print_message "$YELLOW" "go already installed"
    else
        print_message "$YELLOW" "Installing go.."
        GO_VERSION="1.23.0" # Update this version as needed
        curl -LO "https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz"
        sudo rm -rf /usr/local/go && sudo tar -C /usr/local -xzf "go${GO_VERSION}.linux-amd64.tar.gz"
        rm "go${GO_VERSION}.linux-amd64.tar.gz"
    fi
}

installCargoPackageManager() {
    if command_exists cargo; then
        print_message "$YELLOW" "cargo already installed"
    else
        print_message "$YELLOW" "Installing cargo package manager."
        sudo apt install -y cargo
        # cargo install just onefetch
    fi
}

installNvim() {
    if command_exists nvim; then
        print_message "$YELLOW" "nvim already installed"
    else
        print_message "$YELLOW" "Installing nvim.."
        sh ~/dotfiles/scripts/_install_nvim.sh
    fi
}

installZoxide() {
    if command_exists zoxide; then
        print_message "$YELLOW" "Zoxide already installed"
        return
    fi

    if ! curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh; then
        print_message "$RED" "Something went wrong during zoxide install!"
        exit 1
    fi
}

# Main function
main() {
    log_message "Script started"
    print_message "$BLUE" "
You're running ${OS_NAME}.
##############################################
#      We will begin applying updates,       #
#      and securing the system.              #
##############################################
#      You will be prompted for your         #
#      sudo password.                        #
##############################################
"

    if check_ubuntu; then
        print_message "$GREEN" "
##############################################
#      Ubuntu-based system detected.         #
#      Proceeding with setup...              #
##############################################
"
        log_message "Ubuntu-based system detected. Proceeding with setup."
    else
        print_message "$RED" "
##############################################
#      This script is intended for           #
#      Ubuntu-based systems only.            #
#      Exiting Now!                          #
##############################################
"
        log_message "Non-Ubuntu system detected. Script execution aborted."
        exit 1
    fi

    update_and_install
    # installEzaAndExa
    # installAntidote
    # installLatestGo
    installCargoPackageManager
    # installNvim
    # installZoxide

    echo "${GREEN}Installation Completed...${RC}"
    print_message "$GREEN" "
##############################################
#      Installation Completed                #
##############################################
"
    log_message "Installation Completed for Ubuntu-based system detected. Proceeding with other steps"
}

# Run the main function
main
