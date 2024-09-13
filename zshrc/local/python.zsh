# ------------------------------------------------------------------------------
# Python Configuration
# ------------------------------------------------------------------------------

# Aliases for Python and pip
alias python="python3"
alias pip="pip3"

# Ensure Python uses UTF-8 encoding for stdin, stdout, and stderr
export PYTHONIOENCODING='UTF-8'

# pyenv configuration
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"

# Initialize pyenv if it's installed
if command -v pyenv 1>/dev/null 2>&1; then
    eval "$(pyenv init --path)"
    eval "$(pyenv init -)"
fi

# Function to create and activate a Python virtual environment
function mkvenv() {
    # Set the environment directory name, default to 'venv' if no name provided
    local env_dir=${1:-venv}
    local requirements_path="captured-requirements.txt"

    # Create the virtual environment
    echo "Creating new virtual environment '$env_dir'..."
    python3 -m venv $env_dir
    
    # Activate the virtual environment
    source $env_dir/bin/activate
    
    # Upgrade pip and install wheel
    echo "Upgrading pip and installing wheel..."
    pip3 install --upgrade pip
    pip3 install wheel

    # Install packages from requirements file if it exists
    if [ -f "$requirements_path" ]; then
        echo "Installing packages from '$requirements_path'..."
        pip3 install -r "$requirements_path"
    fi
    
    echo "Virtual environment '$env_dir' created and activated!"
}

# Function to deactivate and capture requirements of a virtual environment
function rmvenv() {
    local requirements_path="captured-requirements.txt"

    # Check if a virtual environment is active
    if [[ "$VIRTUAL_ENV" != "" ]]; then
        # Capture installed packages if requirements.txt doesn't exist
        if [[ ! -f "requirements.txt" ]]; then
            pip3 freeze > "$requirements_path"
            echo "Installed packages captured in $requirements_path"
        fi

        # Deactivate the environment
        deactivate
        echo "Virtual environment deactivated"
    else
        echo "No virtual environment is active."
    fi
}
