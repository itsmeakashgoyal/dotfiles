#!/usr/bin/env bash

#################################################
#      File: _linuxOS.sh                        #
#      Author: Akash Goyal                      #
#      Status: Development                      #
#################################################
# This script creates symlinks from the home directory to any desired dotfiles in $HOME/dotfiles
# This is used to setup both macOS and LinuxOS.
# And also installs MacOS and Linux packages.
# And also installs Homebrew Packages and Casks (Apps)
# And also sets up Sublime Text
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

# Enable strict mode for better error handling
set -euo pipefail

# Set CI environment variable if not already set
export CI="${CI:-}"

initGitSubmodules() {
    log_message "→ Initializing and updating git submodules..."
    git submodule update --init --recursive --remote
}

setupDotfiles() {
    if [ "$OS_TYPE" = "Darwin" ]; then
        log_message "------> Setting up MACOS"
        log_message "→ Running MacOS-specific setup script..."
        scripts=("_macOS" "_brew" "_sublime")
        for script in "${scripts[@]}"; do
            script_path="./scripts/setup/${script}.sh"
            if [ -f "${script_path}" ]; then
                echo "Running ${script_path} script..."
                if ! "${script_path}"; then
                    echo "Error: ${script} script failed. Continuing..."
                fi
            else
                echo "Warning: ${script_path} not found. Skipping..."
            fi
        done
    elif [ "$OS_TYPE" = "Linux" ]; then
        log_message "------> Setting up LINUX"
        # Run the setup script for the current OS
        log_message "→ Running LinuxOS-specific setup script..."
        scripts=("_linuxOS" "_brew")
        for script in "${scripts[@]}"; do
            script_path="./scripts/setup/${script}.sh"
            if [ -f "${script_path}" ]; then
                echo "Running ${script_path} script..."
                if ! "${script_path}"; then
                    echo "Error: ${script} script failed. Continuing..."
                fi
            else
                echo "Warning: ${script_path} not found. Skipping..."
            fi
        done
    fi
}

initiatingSymlink() {
    log_message "→ Initiating the symlinking process..."

    # Change to the dotfiles directory
    log_message "→ Changing to the ${DOTFILES_DIR} directory"
    cd "${DOTFILES_DIR}" || {
        log_message "Failed to change directory to ${DOTFILES_DIR}"
        exit 1
    }

    # List of folders to symlink in .config directory
    CONFIG_FOLDERS=("tmux" "nvim" "ohmyposh" "zsh")
    for folder in "${CONFIG_FOLDERS[@]}"; do
        log_message "→ Processing config folder: ${folder}"
        target_dir="${CONFIG_DIR}/${folder}"

        # Create .config directory if it doesn't exist
        mkdir -p "${CONFIG_DIR}"

        # Remove existing symlink or directory
        if [ -e "${target_dir}" ]; then
            if [ -L "${target_dir}" ]; then
                log_message "→ Removing existing symlink: ${target_dir}"
                rm "${target_dir}"
            else
                log_message "→ Removing existing directory: ${target_dir}"
                rm -rf "${target_dir}"
            fi
        fi

        log_message "→ Creating symlink to ${folder} in ~/.config directory."
        ln -svf "${DOTFILES_DIR}/${folder}" "${target_dir}"
    done

    # List of folders to process
    FOLDERS=("homeConfig" "git" "zsh")
    # List of files to symlink directly in home directory
    FILES=(".gitconfig" ".curlrc" ".gdbinit" ".wgetrc" ".zshenv" ".zshrc")
    # Create symlinks for each file within the specified folders
    for folder in "${FOLDERS[@]}"; do
        log_message "→ Processing folder: ${folder}"
        # Enable dotglob to match hidden files
        shopt -s dotglob # bash equivalent for handling dot files
        for file in "${DOTFILES_DIR}/${folder}"/*; do
            # Skip if file doesn't exist
            [[ -e "$file" ]] || continue

            # Skip if it's a '.' or '..' directory entry
            [[ $(basename "$file") == "." || $(basename "$file") == ".." ]] && continue
            filename=$(basename "${file}")

            # Check if the file matches any file in the list
            match_found=false
            for file in "${FILES[@]}"; do
                if [[ "$file" == "$filename" ]]; then
                    match_found=true
                    break
                fi
            done

            if [[ "$match_found" == true ]]; then
                log_message "→ Creating symlink to ${HOME} from ${DOTFILES_DIR}/${folder}/${file}"
                ln -svf "${DOTFILES_DIR}/${folder}/${file}" "${HOME}/${filename}"
            else
                log_message "→ Skipping ${filename}, not in the list of files to symlink."
            fi

        done
    done
}

setupNvim() {
    # Change to the .config/nvim directory and checkout the running branch
    log_message "→ Changing to the ${CONFIG_DIR}/nvim directory"
    cd "${CONFIG_DIR}/nvim" || {
        log_message "Failed to change directory to ${CONFIG_DIR}/nvim"
        exit 1
    }
    # Skip branch checkout in CI environment
    if [ -z "$CI" ]; then
        BRANCH_NAME="akgoyal/nvim"
        git checkout "${BRANCH_NAME}"
    fi
}

setupNix() {
    if [ "$OS_TYPE" = "Linux" ]; then
        log_message "→ Running nix installer..."
        if [ -f "${DOTFILES_DIR}/scripts/utils/_install_nix.sh" ]; then
            sh "${DOTFILES_DIR}/scripts/utils/_install_nix.sh"
        else
            log_message "→ Warning: _install_nix.sh setup script not found."
        fi
    fi
}

# Set the error trap
trap 'print_error "$LINENO" "$BASH_COMMAND" "$?"' ERR

# Main function
main() {
    log_message "Script started"
    print_message "$BLUE" "
You're running ${OS_TYPE}.
##############################################
#      We will begin applying updates,       #
#      and securing the system.              #
##############################################
#      You will be prompted for your         #
#      sudo password.                        #
##############################################
"

    if [ "$OS_TYPE" = "Darwin" ]; then
        print_message "$GREEN" "
##############################################
#      MacOS system detected.                #
#      Proceeding with setup...              #
##############################################
"
        log_message "MacOS system detected. Proceeding with setup."
    else
        print_message "$GREEN" "
##############################################
#      Ubuntu-based system detected.         #
#      Proceeding with setup...              #
##############################################
"
        log_message "Ubuntu-based system detected. Proceeding with setup."
    fi

    initGitSubmodules
    initiatingSymlink
    setupDotfiles
    setupNvim

    print_message "$GREEN" "
##############################################
#      Installation Completed                #
##############################################
"
    log_message "Installation Completed!"

    print_message "$GREEN" "
############################################################################
#      At last, do source your zsh configuration using 'exec zsh'          #
############################################################################
"
}

# Run the main function
main
