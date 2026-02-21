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
# ░▓ file   ▓ zsh/.config/zsh/conf.d/python.zsh
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
# Initialize pyenv if it's installed (lazy loading for better performance)
if [[ -d "$HOME/.pyenv" ]]; then
    export PYENV_ROOT="$HOME/.pyenv"
    export PATH="$PYENV_ROOT/bin:$PATH"
    
    if command -v pyenv >/dev/null 2>&1; then
        eval "$(pyenv init --path)"
        eval "$(pyenv init -)"
    fi
fi

# ------------------------------------------------------------------------------
# Virtual Environment Management
# ------------------------------------------------------------------------------
# Create and activate a Python virtual environment
function mkvenv() {
    # Set the environment directory name, default to 'PYENV_ROOT' if no name provided
    local env_dir=${1:-$PYENV_ROOT}

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
