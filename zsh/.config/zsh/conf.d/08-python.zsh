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

alias py3="/opt/anaconda3/bin/python3"

# Python environment variables
export PYTHONIOENCODING='UTF-8'  # Ensure UTF-8 encoding
export PYTHONDONTWRITEBYTECODE=1 # Prevent Python from writing .pyc files
export PYTHONUNBUFFERED=1        # Prevent Python from buffering stdout/stderr

# ------------------------------------------------------------------------------
# mise: Python (and other runtime) version management
# ------------------------------------------------------------------------------
# Replaces pyenv: mise has real native Windows/PowerShell support
# (`mise activate pwsh`) where pyenv has none at all (it hard-forks to a
# separately-maintained pyenv-win).
#
# Measured with `make bench` before committing this: running `eval "$(mise
# activate zsh)"` unconditionally at startup added ~20-30ms to shell startup
# on this machine (111ms -> 130-141ms), not the "fast enough to not matter"
# cost it's sometimes advertised as. Deferred to a one-shot precmd hook
# instead — the same idea as pyenv's old lazy-init stub above, adapted for
# the fact that mise's value is an always-on hook, not a single lazily
# invoked command. This only helps first_command_lag, not first_prompt_lag
# (confirmed real interactive sessions fire precmd before reading the next
# command; `zsh -i -c exit`, what `make bench` uses, does not — so this
# doesn't show up in `make bench` even though it's a real improvement).
if command -v mise &>/dev/null; then
    autoload -Uz add-zsh-hook
    _mise_lazy_activate() {
        add-zsh-hook -d precmd _mise_lazy_activate
        unfunction _mise_lazy_activate
        eval "$(mise activate zsh)"
    }
    add-zsh-hook precmd _mise_lazy_activate
fi

# Default directory for mkvenv/venv/rmvenv below when no name is given.
# Previously reused $PYENV_ROOT (~/.pyenv, an absolute path) for this — but
# these functions build paths like "$(pwd)/$env_dir", which only makes sense
# for a relative name, so the no-argument case was already broken before
# pyenv's removal made it worse (an unset, empty path). ".venv" matches the
# convention most current Python tooling (uv, poetry, VS Code) defaults to.
VENV_DEFAULT_DIR=".venv"

# ------------------------------------------------------------------------------
# Virtual Environment Management
# ------------------------------------------------------------------------------
# Create and activate a Python virtual environment
function mkvenv() {
    # Set the environment directory name, default to VENV_DEFAULT_DIR if no name provided
    local env_dir=${1:-$VENV_DEFAULT_DIR}

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
    # Set the environment directory name, default to VENV_DEFAULT_DIR if no name provided
    local env_dir=${1:-$VENV_DEFAULT_DIR}

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
    local env_dir=${1:-$VENV_DEFAULT_DIR} # Default to VENV_DEFAULT_DIR if no name provided

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
