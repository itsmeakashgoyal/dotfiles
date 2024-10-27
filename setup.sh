#!/usr/bin/env zsh
############################
# This script creates symlinks from the home directory to any desired dotfiles in $HOME/dotfiles
# And also installs MacOS Software
# And also installs Homebrew Packages and Casks (Apps)
# And also sets up Sublime Text
############################

# Enable strict mode for better error handling
set -o pipefail

# Function to log messages
log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1"
}

# Define variables
DOTFILES_DIR="${HOME}/dotfiles-dev"
CONFIG_DIR="${HOME}/.config"

# List of folders to process
FOLDERS=("zshrc" "git" "confrc")
# List of files to symlink directly in home directory
FILES=(".zshrc" ".zprofile" ".gitconfig" ".gitignore" ".gitattributes" ".curlrc" ".gdbinit" ".wgetrc")
# List of folders to symlink in .config directory
CONFIG_FOLDERS=("tmux" "nvim" "nix")

# Run setup scripts
scripts=("_macOS" "_brew" "_sublime")
for script in "${scripts[@]}"; do
    script_path="./scripts/${script}.sh"
    if [ -f "${script_path}" ]; then
        echo "Running ${script} script..."
        if ! "${script_path}"; then
            echo "Error: ${script} script failed. Continuing..."
        fi
    else
        echo "Warning: ${script_path} not found. Skipping..."
    fi
done

log "→ Initiating the symlinking process..."

# Change to the dotfiles directory
log "→ Changing to the ${DOTFILES_DIR} directory"
cd "${DOTFILES_DIR}" || {
    log "Failed to change directory to ${DOTFILES_DIR}"
    exit 1
}

# Create symlinks for each file within the specified folders
for folder in "${FOLDERS[@]}"; do
    log "→ Processing folder: ${folder}"
    for file in "${DOTFILES_DIR}/${folder}"/{.,}*; do
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
BRANCH_NAME="akgoyal/nvim"
git checkout "${BRANCH_NAME}"

log "→ Source Zsh configuration"
exec zsh

log "→ Installation Complete!"
