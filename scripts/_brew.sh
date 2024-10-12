#!/usr/bin/env zsh

# Enable strict mode for better error handling
set -euo pipefail

# Function to check if a command was successful
check_command() {
    if [ $? -ne 0 ]; then
        echo "Error: $1 failed" >&2
        exit 1
    fi
}

# Install Homebrew if it isn't already installed
if ! command -v brew &>/dev/null; then
    echo "Homebrew not installed. Installing Homebrew."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    check_command "Homebrew installation"

    # Attempt to set up Homebrew PATH automatically for this session
    if [ -x "/opt/homebrew/bin/brew" ]; then
        # For Apple Silicon Macs
        echo "Configuring Homebrew in PATH for Apple Silicon Mac..."
        eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [ -x "/usr/local/bin/brew" ]; then
        # For Intel Macs
        echo "Configuring Homebrew in PATH for Intel Mac..."
        eval "$(/usr/local/bin/brew shellenv)"
    fi
else
    echo "Homebrew is already installed."
fi

# Verify brew is now accessible
if ! command -v brew &>/dev/null; then
    echo "Failed to configure Homebrew in PATH. Please add Homebrew to your PATH manually."
    exit 1
fi

# Update Homebrew and Upgrade any already-installed formulae
echo "Updating Homebrew and upgrading formulae..."
brew update
brew upgrade
brew upgrade --cask
brew cleanup

# Install packages from Brewfile
echo "Installing packages from Brewfile..."
brew bundle install
check_command "Brewfile installation"

# Add the Homebrew zsh to allowed shells
echo "Adding Homebrew zsh to allowed shells..."
BREW_ZSH="$(brew --prefix)/bin/zsh"
if ! grep -q "$BREW_ZSH" /etc/shells; then
    echo "$BREW_ZSH" | sudo tee -a /etc/shells >/dev/null
    check_command "Adding Homebrew zsh to /etc/shells"
fi

# Set the Homebrew zsh as default shell
echo "Changing default shell to Homebrew zsh..."
chsh -s "$BREW_ZSH"
check_command "Changing default shell"

# Setup Git config
echo "Setting up Git config..."
sh ~/dotfiles-dev/scripts/_git_config.sh
check_command "Git config setup"

# Install Prettier
echo "Installing Prettier..."
npm install --global prettier
check_command "Prettier installation"

# Install wget with IRI support
echo "Installing wget with IRI support..."
brew install wget --with-iri
check_command "wget installation"

# Tap the Homebrew font cask repository if not already tapped
if ! brew tap | grep -q "^homebrew/cask-fonts$"; then
    echo "Tapping homebrew/cask-fonts..."
    brew tap homebrew/cask-fonts
    check_command "Tapping homebrew/cask-fonts"
fi

# Final update and cleanup
echo "Performing final update and cleanup..."
brew update
brew upgrade
brew upgrade --cask
brew cleanup

echo "Homebrew setup complete!"