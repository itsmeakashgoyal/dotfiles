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
# ░▓ file   ▓ scripts/setup/packages.sh
# ░▓▓▓▓▓▓▓▓▓▓
# ░░░░░░░░░░
#
#█▓▒░

#################################################
#      File: packages.sh                        #
#      Author: Akash Goyal                      #
#      Status: Development                      #
#################################################

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

install_oh_my_zsh() {
    info "Installing Oh My Zsh..."

    # Remove existing installation
    rm -rf ~/.oh-my-zsh

    # Install Oh My Zsh
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

    # Install plugins
    info "Installing Oh My Zsh plugins..."
    git clone https://github.com/romkatv/powerlevel10k.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
    git clone https://github.com/zsh-users/zsh-autosuggestions "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions"
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting"
    git clone https://github.com/Aloxaf/fzf-tab "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/fzf-tab"
    git clone https://github.com/jeffreytse/zsh-vi-mode "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-vi-mode"
    git clone https://github.com/marlonrichert/zsh-autocomplete.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autocomplete"

    # Check if zsh is installed and set it as the default shell if desired
    info "Set Zsh as default shell..."
    if command -v zsh &>/dev/null; then
        if ! grep -q "$(command -v zsh)" /etc/shells; then
            substep_info "Adding zsh to available shells..."
            sudo sh -c "echo $(command -v zsh) >> /etc/shells"
        fi
        sudo chsh -s "$(command -v zsh)" "$USER"
    fi
}

install_fzf() {
    if command_exists fzf; then
        info "Fzf already installed"
        return 0
    fi

    info "Installing fzf.."
    git clone --depth 1 https://github.com/junegunn/fzf.git ~/.config/.fzf
    ~/.config/.fzf/install
}

setup_nvim() {
    # Change to the .config/nvim directory and checkout the running branch
    log_message "→ Changing to the ${CONFIG_DIR}/nvim directory"
    cd "${CONFIG_DIR}/nvim" || {
        log_message "Failed to change directory to ${CONFIG_DIR}/nvim"
        exit 1
    }
    BRANCH_NAME="akgoyal/nvim"
    git checkout "${BRANCH_NAME}"
}

setup_nix() {
    if [ "$OS_TYPE" = "Linux" ]; then
        log_message "→ Running nix installer..."
        if [ -f "${DOTFILES_DIR}/scripts/utils/_install_nix.sh" ]; then
            sh "${DOTFILES_DIR}/scripts/utils/_install_nix.sh"
        else
            log_message "→ Warning: _install_nix.sh setup script not found."
        fi
    fi
}
