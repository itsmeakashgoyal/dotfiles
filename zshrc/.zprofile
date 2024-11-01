# Detect OS type
OS_TYPE=$(uname)

if [ "$OS_TYPE" = "Darwin" ]; then
    # macOS specific settings
    if [ -x "/opt/homebrew/bin/brew" ]; then
        # For Apple Silicon Macs
        export PATH="/opt/homebrew/bin:$PATH"
        eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [ -x "/usr/local/bin/brew" ]; then
        # For Intel Macs
        eval "$(/usr/local/bin/brew shellenv)"
    fi

elif [ "$OS_TYPE" = "Linux" ]; then
    # Linux specific settings
    # Load .zshrc if available
    if [ -f ~/.zshrc ]; then
        source ~/.zshrc
    fi

    # Add any Linux-specific PATH or environment variables here
    if [ -d "$HOME/.local/bin" ]; then
        export PATH="$HOME/.local/bin:$PATH"
    fi
fi
