#!/usr/bin/env bash
#                    █████
#                   ░░███
#   █████   ██████  ███████   █████ ████ ████████
#  ███░░   ███░░███░░░███░   ░░███ ░███ ░░███░░███
# ░░█████ ░███████   ░███     ░███ ░███  ░███ ░███
#  ░░░░███░███░░░    ░███ ███ ░███ ░███  ░███ ░███
#  ██████ ░░██████   ░░█████  ░░████████ ░███████
# ░░░░░░   ░░░░░░     ░░░░░    ░░░░░░░░  ░███░░░
#                                        ░███
#                                        █████
#                                       ░░░░░
#
#  ▓▓▓▓▓▓▓▓▓▓
# ░▓ author ▓ Akash Goyal
# ░▓ file   ▓ scripts/setup/_linuxOS.sh
# ░▓▓▓▓▓▓▓▓▓▓
# ░░░░░░░░░░
#
#█▓▒░

# ------------------------------
#          INITIALIZE
# ------------------------------
# Load Helper functions persistently
SCRIPT_DIR="${HOME}/dotfiles/scripts"
HELPER_FILE="${SCRIPT_DIR}/utils/_helper.sh"
# Check if helper file exists and source it
if [[ ! -f "$HELPER_FILE" ]]; then
    echo "Error: Helper file not found at $HELPER_FILE" >&2
    exit 1
fi

# Source the helper file
source "$HELPER_FILE"

# Enable strict mode
set -euo pipefail
IFS=$'nt'

# Get OS name
readonly OS_NAME=$(grep ^NAME /etc/*os-release | cut -d '"' -f 2)

# ------------------------------------------------------------------------------
# System Detection
# ------------------------------------------------------------------------------
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

# Clean up
cleanup() {
    info "
##############################################
#              Cleanup Section               #
##############################################
"
    log_message "Starting cleanup process"
    sudo apt-get -y autoclean
    sudo apt-get -y clean
    info "Cleaned!"
    log_message "Cleanup completed"
    sleep 2
}

# Update and install packages
update_and_install() {
    info "
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

    # Core packages
    local packages=(
        build-essential
        libc++-15-dev
        clang-format-15
        libkrb5-dev
        procps
        file
        vim-gtk
        python3-setuptools
        tmux
        locate
        libgraph-easy-perl
        fd-find
        fontconfig
        python3-venv
        python3-pip
        luarocks
        shellcheck
        strace
        lsb-release
        entr
        stow
        figlet
        lolcat
    )

    sudo apt-get -y install "${packages[@]}"
    success "Package installation complete"
    log_message "Completed system update and package installation"
    sleep 2
}

# ------------------------------------------------------------------------------
# Tool Installation Functions
# ------------------------------------------------------------------------------
installEzaAndExa() {
    if command_exists exa; then
        info "exa already installed"
    else
        info "Installing exa.."
        EXA_VERSION=$(curl -s "https://api.github.com/repos/ogham/exa/releases/latest" | grep -Po '"tag_name": "v\K[0-9.]+')
        curl -Lo exa.zip "https://github.com/ogham/exa/releases/latest/download/exa-linux-x86_64-v${EXA_VERSION}.zip"
        sudo unzip -q exa.zip bin/exa -d /usr/local
        rm exa.zip
    fi

    if command_exists eza; then
        info "eza already installed"
    else
        info "Installing eza.."
        sudo apt install -y gpg
        sudo mkdir -p /etc/apt/keyrings
        wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
        echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | sudo tee /etc/apt/sources.list.d/gierens.list
        sudo chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list
        sudo apt update
        sudo apt install -y eza
    fi
}

installLatestGo() {
    if command_exists go; then
        info "go already installed"
    else
        info "Installing go.."
        GO_VERSION="1.23.0" # Update this version as needed
        curl -LO "https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz"
        sudo rm -rf /usr/local/go
        sudo tar -C /usr/local -xzf "go${GO_VERSION}.linux-amd64.tar.gz"
        rm "go${GO_VERSION}.linux-amd64.tar.gz"
    fi
}

installCargoPackageManager() {
    if command_exists cargo; then
        info "cargo already installed"
    else
        info "Installing cargo package manager."
        sudo apt install -y cargo
        # cargo install just onefetch
    fi
}

installNvim() {
    if command_exists nvim; then
        info "nvim already installed"
    else
        info "Installing nvim.."
        sh ~/dotfiles/scripts/utils/_install_nvim.sh
    fi
}

installZoxide() {
    if command_exists zoxide; then
        info "Zoxide already installed"
        return
    fi

    if ! curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh; then
        error "Something went wrong during zoxide install!"
        return 1
    fi
}

# ------------------------------------------------------------------------------
# Main Function
# ------------------------------------------------------------------------------
main() {
    log_message "Script started"
    info "
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
        success "
##############################################
#      Ubuntu-based system detected.         #
#      Proceeding with setup...              #
##############################################
"
        log_message "Ubuntu-based system detected. Proceeding with setup."
    else
        error "
##############################################
#      This script is intended for           #
#      Ubuntu-based systems only.            #
#      Exiting Now!                          #
##############################################
"
        log_message "Non-Ubuntu system detected. Script execution aborted."
        exit 1
    fi

    # Install components
    update_and_install
    # installEzaAndExa
    # installLatestGo
    installCargoPackageManager
    # installNvim
    # installZoxide

    success "
###################################################
#      Installation Completed for _linuxOS.sh     #
###################################################
"
    log_message "Installation Completed for Ubuntu-based system detected. Proceeding with other steps"
}

# Set error trap
trap 'print_error "$LINENO" "$BASH_COMMAND" "$?"' ERR

# Run main
main
