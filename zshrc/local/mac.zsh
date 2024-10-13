# ------------------------------------------------------------------------------
# MacOS-specific aliases and functions
# ------------------------------------------------------------------------------

# System Updates
# Update macOS software
alias update_system='sudo softwareupdate -i -a'

# Update/upgrade Homebrew and installed packages
alias update_brew='brew update; brew upgrade; brew upgrade --cask; brew cleanup'

# Comprehensive update: macOS, Homebrew, npm, and Ruby gems
alias update='sudo softwareupdate -i -a; brew update; brew upgrade; brew cleanup; npm install npm -g; npm update -g; sudo gem update --system; sudo gem update; sudo gem cleanup'

# Finder and Desktop
# Toggle hidden files visibility in Finder
# Note: As of macOS Sierra (10.12) and later, you can use Cmd + Shift + . in Finder
alias show="defaults write com.apple.finder AppleShowAllFiles -bool true && killall Finder"
alias hide="defaults write com.apple.finder AppleShowAllFiles -bool false && killall Finder"

# Toggle desktop icons visibility
alias hidedesktop="defaults write com.apple.finder CreateDesktop -bool false && killall Finder"
alias showdesktop="defaults write com.apple.finder CreateDesktop -bool true && killall Finder"

# Applications
# Open Google Chrome from terminal
alias chrome='/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome'

# Lock the screen (when going AFK - Away From Keyboard)
alias afk="/System/Library/CoreServices/Menu\ Extras/User.menu/Contents/Resources/CGSession -suspend"

# Network
# Display local IP address
alias localip="ipconfig getifaddr en0"

# File Management
# Recursively delete .DS_Store files
alias cleanup="find . -type f -name '*.DS_Store' -ls -delete"

# Finder Hidden Files Toggle
# Functions to show/hide all files in Finder
hiddenOn() { defaults write com.apple.Finder AppleShowAllFiles YES; }
hiddenOff() { defaults write com.apple.Finder AppleShowAllFiles NO; }

# Change to Finder's current directory
cdf() { # short for `cdfinder`
    cd "$(osascript -e 'tell app "Finder" to POSIX path of (insertion location as alias)')";
}

# ------------------------------------------------------------------------------
# Homebrew Configuration
# ------------------------------------------------------------------------------

# Initialize Homebrew environment
eval "$(/opt/homebrew/bin/brew shellenv)"

## Brew completions
if type brew &>/dev/null
then
  FPATH="$(brew --prefix)/share/zsh/site-functions:${FPATH}"
  autoload -Uz compinit
  compinit -d "$cache_directory/compinit-dumpfile"
fi

# Set up Homebrew completions
if type brew &>/dev/null
then
  FPATH="$(brew --prefix)/share/zsh/site-functions:${FPATH}"
  autoload -Uz compinit
  compinit
fi

# ------------------------------------------------------------------------------
# Additional MacOS-specific configurations
# ------------------------------------------------------------------------------

# Add any other MacOS-specific configurations, functions, or aliases here
# For example:
# - Custom PATH modifications
# - macOS-specific environment variables
# - Additional application-specific aliases or functions

# Example: Set JAVA_HOME for macOS
# export JAVA_HOME=$(/usr/libexec/java_home)

# Example: Add a custom directory to PATH
# export PATH=$HOME/custom/bin:$PATH