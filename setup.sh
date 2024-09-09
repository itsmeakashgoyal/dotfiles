#!/usr/bin/env zsh
############################
# This script creates symlinks from the home directory to any desired dotfiles in $HOME/dotfiles
# And also installs MacOS Software
# And also installs Homebrew Packages and Casks (Apps)
# And also sets up Sublime Text
############################

# dotfiles directory
dotfiledir="${HOME}/dotfiles-dev"

# Run the MacOS Script
./scripts/macOS.sh

# Run the Homebrew Script
./scripts/brew.sh

# Run the Sublime Script
./scripts/sublime.sh

echo "Initiate the symlinking process..."
# list of files/folders to symlink in ${homedir}
folders=("zshrc" "tmux" "nvim")
files=(".zshrc" ".zprofile")
config_folders=("tmux" "nvim")

# change to the dotfiles directory
echo "Changing to the ${dotfiledir} directory"
cd "${dotfiledir}" || exit

# Create symlinks for each file within the specified folders (will overwrite old dotfiles)
for folder in "${folders[@]}"; do
    echo "Processing folder: ${folder}"
    for file in "${dotfiledir}/${folder}"/*; do
        filename=$(basename "${file}")

        # Check if the file matches any file in the list
        if [[ " ${files[@]} " =~ " ${filename} " ]]; then
            echo "Creating symlink to ${filename} in home directory."
            # Create symbolic link in the home directory
            ln -sf "${file}" "${HOME}/.${filename}"
        else
            echo "Skipping ${filename}, not in the list."
        fi
    done
done

for folder in "${config_folders[@]}"; do
    echo "Processing folder: ${folder}"
    echo "Creating symlink to ${folder} in ~/.config directory."
    # Create symbolic link in the home directory
    ln -sf "${folder}" "${HOME}/.config/${folder}"
done

echo "Installation Complete!"