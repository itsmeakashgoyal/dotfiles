#!/usr/bin/env zsh

# Enable strict mode for better error handling
set -euo pipefail

# Define variables
DOTFILES_DIR="${HOME}/dotfiles-dev"

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

# Turn off analytics
brew analytics off

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
if [ -z "$CI" ]; then
    chsh -s "$BREW_ZSH"
    check_command "Changing default shell"
else
    export SHELL="$BREW_ZSH"
fi

# Setup Git config
echo "Setting up Git config..."
# Skip branch checkout in CI environment
if [ -z "$CI" ]; then
    sh ${DOTFILES_DIR}/scripts/_git_config.sh
    check_command "Git config setup"
fi

# Install Prettier
echo "Installing Prettier..."
npm install --global prettier
check_command "Prettier installation"

# Final update and cleanup
echo "Performing final update and cleanup..."
brew update
brew upgrade
brew upgrade --cask
brew cleanup

echo "Homebrew setup complete!"

echo "→ Install Oh My Zsh"
rm -rf ~/.oh-my-zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

echo "→ Install Oh My Zsh plugins"
git clone https://github.com/romkatv/powerlevel10k.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
git clone https://github.com/zsh-users/zsh-autosuggestions "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions"
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting"
git clone https://github.com/Aloxaf/fzf-tab "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/fzf-tab"
git clone https://github.com/jeffreytse/zsh-vi-mode "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-vi-mode"
git clone https://github.com/marlonrichert/zsh-autocomplete.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autocomplete"

echo "Install fzf"
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.config/.fzf
~/.config/.fzf/install --all
