#!/usr/bin/env zsh
############################
# This script creates symlinks from the home directory to any desired dotfiles in $HOME/dotfiles
# And also installs MacOS Software
# And also installs Homebrew Packages and Casks (Apps)
# And also sets up Sublime Text
############################

# Enable strict mode for better error handling
set -euo pipefail

# Function to log messages
log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1"
}

# Define variables
DOTFILES_DIR="${HOME}/dotfiles-dev"
CONFIG_DIR="${HOME}/.config"

# This detection only works for mac and linux.
OS_TYPE=$(uname)
if [ "$OS_TYPE" = "Darwin" ]; then
    log "------> Setting up MACOS"
    log "→ Running MacOS-specific setup script..."
    scripts=("_macOS" "_brew" "_sublime")
    for script in "${scripts[@]}"; do
        script_path="./scripts/${script}.sh"
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
    log "------> Setting up LINUX"
    # Run the setup script for the current OS
    log "→ Running LinuxOS-specific setup script..."
    if [ -f "${DOTFILES_DIR}/scripts/_linuxOS.sh" ]; then
        sh "${DOTFILES_DIR}/scripts/_linuxOS.sh"
    else
        log "→ Warning: OS-specific setup script not found."
    fi
fi

log "→ Initiating the symlinking process..."

# Change to the dotfiles directory
log "→ Changing to the ${DOTFILES_DIR} directory"
cd "${DOTFILES_DIR}" || {
    log "Failed to change directory to ${DOTFILES_DIR}"
    exit 1
}

# List of folders to process
FOLDERS=("zshrc" "confrc" "git")
# List of files to symlink directly in home directory
FILES=(".zshrc" ".zprofile" ".gitconfig" ".gitignore" ".gitattributes" ".curlrc" ".gdbinit" ".wgetrc")
# List of folders to symlink in .config directory
CONFIG_FOLDERS=("tmux" "nvim" "nix")

# Create symlinks for each file within the specified folders
for folder in "${FOLDERS[@]}"; do
    log "→ Processing folder: ${folder}"
    # Enable dotglob to match hidden files
    setopt dotglob
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
            log "→ Creating symlink to ${HOME} from ${DOTFILES_DIR}/${folder}/${file}"
            ln -svf "${DOTFILES_DIR}/${folder}/${file}" "${HOME}/${filename}"
        else
            log "→ Skipping ${filename}, not in the list of files to symlink."
        fi

    done
done

# Create symlinks for config folders
for folder in "${CONFIG_FOLDERS[@]}"; do
    log "→ Processing config folder: ${folder}"
    target_dir="${CONFIG_DIR}/${folder}"

    # Create .config directory if it doesn't exist
    mkdir -p "${CONFIG_DIR}"

    # Remove existing symlink or directory
    if [ -e "${target_dir}" ]; then
        if [ -L "${target_dir}" ]; then
            log "→ Removing existing symlink: ${target_dir}"
            rm "${target_dir}"
        else
            log "→ Removing existing directory: ${target_dir}"
            rm -rf "${target_dir}"
        fi
    fi

    log "→ Creating symlink to ${folder} in ~/.config directory."
    ln -svf "${DOTFILES_DIR}/${folder}" "${target_dir}"
done

# Change to the .config/nvim directory and checkout the running branch
log "→ Changing to the ${CONFIG_DIR}/nvim directory"
cd "${CONFIG_DIR}/nvim" || {
    log "Failed to change directory to ${CONFIG_DIR}/nvim"
    exit 1
}
# Skip branch checkout in CI environment
if [ -z "$CI" ]; then
    BRANCH_NAME="akgoyal/nvim"
    git checkout "${BRANCH_NAME}"
fi

if [ "$OS_TYPE" = "Linux" ]; then
    log "→ Installing Nix packages"
    # Change to the .config/nix directory
    # Define CONFIG_DIR if not set
    CONFIG_DIR="${CONFIG_DIR:-$HOME/.config}"
    log "→ Changing to the ${CONFIG_DIR}/nvim directory"
    cd "${CONFIG_DIR}/nix" || {
        log "Failed to change directory to ${CONFIG_DIR}/nix"
        exit 1
    }

    # Restart nix-daemon to apply changes
    sudo systemctl restart nix-daemon.service

    # Install Home Manager if not installed
    if ! command -v home-manager &>/dev/null; then
        log "→ Setting up Home Manager"
        nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
        nix-channel --update
        nix-shell '<home-manager>' -A install
    fi

    # This command does not set up Home Manager as a standalone package though
    # This command runs Home Manager as a temporary process in a nix shell.
    # It will initialize a Home Manager configuration and switch to it if the configuration files already exist.
    # nix run home-manager -- init --switch .   # TODO: check if needed

    # Initialize and switch to the Home Manager configuration
    log "→ Switching Home Manager configuration"
    home-manager switch --flake .
fi

log "→ Source Zsh configuration"
exec zsh

log "→ Installation Complete!"
