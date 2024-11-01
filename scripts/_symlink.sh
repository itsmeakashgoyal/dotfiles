#!/usr/bin/env sh

# Enable strict mode
set -eu pipefail
IFS=$'\n\t'

# Define variables
DOTFILES_DIR="${HOME}/dotfiles"
CONFIG_DIR="${HOME}/.config"

# Function to log and display process steps
process() {
    echo "$(date) PROCESSING:  $@" >>"$LOG"
    printf "$(tput setaf 6) [STEP ${STEP:-0}] %s...$(tput sgr0)\n" "$@"
    STEP=$((STEP + 1))
}

process "→ Initiating the symlinking process..."

# Change to the dotfiles directory
process "→ Changing to the ${DOTFILES_DIR} directory"
cd "${DOTFILES_DIR}" || {
    process "Failed to change directory to ${DOTFILES_DIR}"
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
    process "→ Processing folder: ${folder}"
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
            process "→ Creating symlink to ${HOME} from ${DOTFILES_DIR}/${folder}/${file}"
            ln -svf "${DOTFILES_DIR}/${folder}/${file}" "${HOME}/${filename}"
        else
            process "→ Skipping ${filename}, not in the list of files to symlink."
        fi

    done
done

# Create symlinks for config folders
for folder in "${CONFIG_FOLDERS[@]}"; do
    process "→ Processing config folder: ${folder}"
    target_dir="${CONFIG_DIR}/${folder}"

    # Create .config directory if it doesn't exist
    mkdir -p "${CONFIG_DIR}"

    # Remove existing symlink or directory
    if [ -e "${target_dir}" ]; then
        if [ -L "${target_dir}" ]; then
            process "→ Removing existing symlink: ${target_dir}"
            rm "${target_dir}"
        else
            process "→ Removing existing directory: ${target_dir}"
            rm -rf "${target_dir}"
        fi
    fi

    process "→ Creating symlink to ${folder} in ~/.config directory."
    ln -svf "${DOTFILES_DIR}/${folder}" "${target_dir}"
done