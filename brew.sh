#!/usr/bin/env zsh

# Install Homebrew if it isn't already installed
if ! command -v brew &>/dev/null; then
    echo "Homebrew not installed. Installing Homebrew."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # Attempt to set up Homebrew PATH automatically for this session
    if [ -x "/opt/homebrew/bin/brew" ]; then
        # For Apple Silicon Macs
        echo "Configuring Homebrew in PATH for Apple Silicon Mac..."
        export PATH="/opt/homebrew/bin:$PATH"
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
brew update
brew upgrade
brew upgrade --cask
brew cleanup

# Define an array of packages to install using Homebrew.
packages=(
    "gcc"
    "llvm"
    "fzf"
    "python"
    "bash"
    "bash-completion2"
    "zsh"
    "git"
    "tree"
    "pylint"
    "black"
    "node"
    "openssh"
    "ssh-copy-id"
    "git"
)

# Loop over the array to install each application.
for package in "${packages[@]}"; do
    if brew list --formula | grep -q "^$package\$"; then
        echo "$package is already installed. Skipping..."
    else
        echo "Installing $package..."
        brew install "$package"
    fi
done

# Add the Homebrew zsh to allowed shells
echo "Changing default shell to Homebrew zsh"
echo "$(brew --prefix)/bin/zsh" | sudo tee -a /etc/shells >/dev/null
# Set the Homebrew zsh as default shell
chsh -s "$(brew --prefix)/bin/zsh"

# Git config name
echo "Please enter your FULL NAME for Git configuration:"
read git_user_name

# Git config email
echo "Please enter your EMAIL for Git configuration:"
read git_user_email

# Set my git credentials
$(brew --prefix)/bin/git config --global user.name "$git_user_name"
$(brew --prefix)/bin/git config --global user.email "$git_user_email"

# Create the tutorial virtual environment I use frequently
$(brew --prefix)/bin/python3 -m venv "${HOME}/tutorial"

# Install Prettier, which I use in both VS Code and Sublime Text
$(brew --prefix)/bin/npm install --global prettier

# Install `wget` with IRI support.
brew install wget --with-iri

# Define an array of applications to install using Homebrew Cask.
apps=(
    "warp"
    "iterm2"
    "google-chrome"
    "sublime-text"
    "visual-studio-code"
    "google-drive"
    "gimp"
    "vlc"
    "rectangle"
)

# Loop over the array to install each application.
for app in "${apps[@]}"; do
    if brew list --cask | grep -q "^$app\$"; then
        echo "$app is already installed. Skipping..."
    else
        echo "Installing $app..."
        brew install --cask "$app"
    fi
done

# Install Source Code Pro Font
# Tap the Homebrew font cask repository if not already tapped
brew tap | grep -q "^homebrew/cask-fonts$" || brew tap homebrew/cask-fonts

# Define the font name
fonts_name=(
    "font-source-code-pro"
    "font-fira-code-nerd-font"
    "font-jetbrains-mono-nerd-font"
)

# Loop over the array to install each fonts.
for font_name in "${fonts_name[@]}"; do
    # Check if the font is already installed
    if brew list --cask | grep -q "^$font_name\$"; then
        echo "$font_name is already installed. Skipping..."
    else
        echo "Installing $font_name..."
        brew install --cask "$font_name"
    fi
done

# Once font is installed, Import your Terminal Profile
echo "Import your terminal settings..."
echo "Terminal -> Settings -> Profiles -> Import..."
echo "Import from ${HOME}/dotfiles/settings/Pro.terminal"
echo "Press enter to continue..."
read

# Update and clean up again for safe measure
brew update
brew upgrade
brew upgrade --cask
brew cleanup

echo "Sign in to Google Chrome. Press enter to continue..."
read

echo "Open Rectangle and give it necessary permissions. Press enter to continue..."
read

echo "Import your Rectangle settings located in ~/dotfiles/settings/RectangleConfig.json. Press enter to continue..."
read
