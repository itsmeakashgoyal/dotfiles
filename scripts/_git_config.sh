#!/usr/bin/env bash

# Enable stricter error handling
set -euo pipefail

# Function to prompt for input and set git config
set_git_config() {
    local prompt="$1"
    local config_key="$2"
    
    # Prompt user for input
    read -p "$prompt: " user_input
    
    # Set git config with provided input
    git config --global "$config_key" "$user_input"
    
    echo "Git $config_key set to: $user_input"
}

# Set git user.name
set_git_config "Please enter git user.name" "user.name"

# Set git user.email
set_git_config "Please enter git user.email" "user.email"

echo "Git configuration updated successfully."