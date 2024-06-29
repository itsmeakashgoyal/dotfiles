#!/usr/bin/env zsh
############################
# This script creates symlinks from the home directory to any desired dotfiles in $HOME/dotfiles
# And also installs MacOS Software
# And also installs Homebrew Packages and Casks (Apps)
# And also sets up Sublime Text
############################

# dotfiles directory
dotfiledir="${HOME}/dotfiles-dev"

# list of files/folders to symlink in ${homedir}
folders=(zshrc)
files=()

# change to the dotfiles directory
echo "Changing to the ${dotfiledir} directory"
cd "${dotfiledir}" || exit

# Create symlinks for each file within the specified folders (will overwrite old dotfiles)
for folder in "${folders[@]}"; do
    echo "Processing folder: ${folder}"
    for file in "${dotfiledir}/${folder}"/*; do
        filename=$(basename "${file}")
        echo "Creating symlink to ${filename} in home directory."
        ln -sf "${file}" "${HOME}/.${filename}"
    done
done

# Run the MacOS Script
./scripts/macOS.sh

# Run the Homebrew Script
./scripts/brew.sh

# Run VS Code Script
./scripts/vscode.sh

# Run the Sublime Script
./scripts/sublime.sh

# Install diff-so-fancy-install.sh
./scripts/diff-so-fancy-install.sh

echo "Installation Complete!"