#!/usr/bin/env zsh

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
    local requirements_path="captured-requirements.txt"

    # Check if environment already exists
    if [[ -d "$env_dir" ]]; then
        echo "Error: Environment '$env_name' already exists"
        return 1
    fi

    # Create the virtual environment
    echo "Creating new virtual environment '$env_dir'..."
    if ! python3 -m venv $env_dir; then
        echo "Failed to create virtual environment '$env_dir'."
        return 1
    fi

    # Activate the virtual environment
    if [ -f "$env_dir/bin/activate" ]; then
        source $env_dir/bin/activate
    else
        echo "Failed to activate virtual environment '$env_dir'. Activation script not found."
        return 1
    fi

    # Update core packages
    pip install --upgrade pip wheel setuptools || {
        echo "Error: Failed to upgrade core packages"
        return 1
    }

    echo "Virtual environment created and activated successfully"
    echo "Location: $(pwd)/$env_name"
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
venv() {
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

# ------------------------------------------------------------------------------
# Python Development Helpers
# ------------------------------------------------------------------------------
# Run Python tests with coverage
pytest-cov() {
    pytest --cov=. --cov-report=term-missing "$@"
}

# Create a new Python project structure
pyproject() {
    local project_name=$1

    if [[ -z "$project_name" ]]; then
        echo "Error: Please provide a project name"
        return 1
    fi

    mkdir -p "$project_name"/{src,tests,docs}
    touch "$project_name"/{README.md,requirements.txt}
    touch "$project_name"/src/__init__.py
    touch "$project_name"/tests/__init__.py

    echo "Created Python project structure: $project_name"
    tree "$project_name"
}
