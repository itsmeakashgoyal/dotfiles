# ------------------------------------------------------------------------------
# Aliases and functions for Python
# ------------------------------------------------------------------------------

alias python="python3"
alias pip="pip3"

# Make Python use UTF-8 encoding for output to stdin, stdout, and stderr.
export PYTHONIOENCODING='UTF-8';

export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
if command -v pyenv 1>/dev/null 2>&1; then
    eval "$(pyenv init --path)"
    eval "$(pyenv init -)"
fi


# Function to create and activate a Python virtual environment
function mkvenv() {    # Set the environment directory name, default to 'venv' if no name provided
    local env_dir=${1:-venv}
    local requirements_path="captured-requirements.txt"
    # Check if the environment already exists
    # Create the virtual environment
    echo "Creating new virtual environment '$env_dir'..."
    python3 -m venv $env_dir
    
    # Activate the virtual environment
    source $env_dir/bin/activate
    
    # Optional: Install any default packages
    pip3 install --upgrade pip
    pip3 install wheel

    if [ -f "$requirements_path" ]; then
        echo "Installing packages from '$requirements_path'..."
        pip3 install -r "$requirements_path"
    fi
    
    echo "Virtual environment '$env_dir' created and activated!"
}

function rmvenv() {
    # Check if the environment is active
    local requirements_path="captured-requirements.txt"
    if [[ "$VIRTUAL_ENV" != "" ]]; then
        if [[ ! -f "requirements.txt" ]]; then
            pip3 freeze > "$requirements_path"
        fi
        # Deactivate the environment
        deactivate
        
        echo "Virtual environment deactivated and all installed packages captured"
    else
        echo "No virtual environment is active."
    fi
}
