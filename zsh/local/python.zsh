#!/usr/bin/env zsh
#                     █████
#                    ░░███
#   █████████  █████  ░███████
#  ░█░░░░███  ███░░   ░███░░███
#  ░   ███░  ░░█████  ░███ ░███
#    ███░   █ ░░░░███ ░███ ░███
#   █████████ ██████  ████ █████
#  ░░░░░░░░░ ░░░░░░  ░░░░ ░░░░░
#
#  ▓▓▓▓▓▓▓▓▓▓
# ░▓ author ▓ Akash Goyal
# ░▓ file   ▓ zsh/local/python.zsh
# ░▓▓▓▓▓▓▓▓▓▓
# ░░░░░░░░░░
#
#█▓▒░
# ------------------------------------------------------------------------------
# Python Configuration
# ------------------------------------------------------------------------------

# Basic Python aliases
alias python="python3" # Use Python 3 by default
alias pip="pip3"       # Use pip3 by default

# Python environment variables
export PYTHONIOENCODING='UTF-8'  # Ensure UTF-8 encoding
export PYTHONDONTWRITEBYTECODE=1 # Prevent Python from writing .pyc files
export PYTHONUNBUFFERED=1        # Prevent Python from buffering stdout/stderr

# ------------------------------------------------------------------------------
# pyenv Configuration
# ------------------------------------------------------------------------------

# pyenv configuration
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"

# Initialize pyenv if it's installed
if command -v pyenv 1>/dev/null 2>&1; then
    eval "$(pyenv init --path)"
    eval "$(pyenv init -)"
else
    echo "pyenv is not installed. Please install pyenv to manage Python versions."
fi

# ------------------------------------------------------------------------------
# Virtual Environment Management
# ------------------------------------------------------------------------------
# Create and activate a Python virtual environment
function mkvenv() {
    # Set the environment directory name, default to 'PYENV_ROOT' if no name provided
    local env_dir=${1:-$PYENV_ROOT}
    local requirements_path="$HOME/dotfiles/packages/pipx_packages.txt"

    # Check if environment already exists
    if [[ -d "$env_dir" ]]; then
        echo "Error: Environment '$env_dir' already exists"
        return 1
    fi

    # Create the virtual environment
    echo "Creating new virtual environment '$env_dir'..."
    if ! python3 -m venv "$env_dir"; then
        echo "Failed to create virtual environment '$env_dir'."
        return 1
    fi

    # Activate the virtual environment
    source "$env_dir/bin/activate" || {
        echo "Failed to activate virtual environment '$env_dir'. Activation script not found."
        return 1
    }

    # Update core packages
    pip install --upgrade pip wheel setuptools || {
        echo "Error: Failed to upgrade core packages"
        return 1
    }

    # Install packages from captured-requirements.txt if it exists
    if [[ -f "$requirements_path" ]]; then
        echo "Installing packages from $requirements_path..."
        pip install -r "$requirements_path" || {
            echo "Error: Failed to install packages from $requirements_path"
            return 1
        }
    else
        echo "Warning: $requirements_path not found. No packages installed."
    fi

    echo "Virtual environment created and activated successfully"
    echo "Location: $(pwd)/$env_dir"
    echo "Python version: $(python --version)"
    echo "Pip version: $(pip --version)"
}

# Remove a Python virtual environment
function rmvenv() {
    # Set the environment directory name, default to 'PYENV_ROOT' if no name provided
    local env_dir=${1:-$PYENV_ROOT}

    # Check if environment exists
    if [[ ! -d "$env_dir" ]]; then
        echo "Error: Environment '$env_dir' does not exist"
        return 1
    fi

    # Deactivate if this environment is active
    if [[ "$VIRTUAL_ENV" == "$(pwd)/$env_dir" ]]; then
        deactivate
    fi

    # Remove the environment
    rm -rf "$env_dir"
    echo "Removed virtual environment: $env_dir"
}

# Activate virtual environment
function venv() {
    local env_dir=${1:-$PYENV_ROOT} # Default to PYENV_ROOT if no name provided

    # Check if environment exists
    if [[ ! -d "$env_dir" ]]; then
        echo "Error: Environment '$env_dir' does not exist"
        return 1
    fi

    # Activate the environment
    source "$env_dir/bin/activate" || {
        echo "Error: Failed to activate virtual environment"
        return 1
    }

    echo "Activated virtual environment: $env_dir"
    echo "Python version: $(python --version)"
}
