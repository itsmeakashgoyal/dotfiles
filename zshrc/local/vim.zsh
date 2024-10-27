# ------------------------------------------------------------------------------
# Vim Configuration: Aliases and Functions
# ------------------------------------------------------------------------------

# Set default editor to Neovim
export EDITOR='nvim'

# Function to open Vim with zoxide integration
v() {
    if [ -n "$1" ]; then
        # If an argument is provided, use zoxide to navigate to the directory
        z "$1"
    fi

    # Open Neovim in the current directory
    $EDITOR
}

# ------------------------------------------------------------------------------
# Additional Vim-related configurations (if needed)
# ------------------------------------------------------------------------------

# Add any other Vim-specific configurations, functions, or aliases here
# For example:
# - Custom Vim key bindings
# - Vim plugin configurations
# - Additional Vim-related utility functions

# Example: Function to open Vim with a fuzzy-found file
# vf() {
#     local file=$(fzf)
#     [ -n "$file" ] && $EDITOR "$file"
# }

# Example: Alias for opening Vim in read-only mode
# alias vr='vim -R'

# Example: Function to open Vim with the last edited file
# vl() {
#     local last_file=$(ls -t | head -n1)
#     [ -n "$last_file" ] && $EDITOR "$last_file"
# }
