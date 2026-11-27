#!/usr/bin/env zsh
#
#  ▓▓▓▓▓▓▓▓▓▓
# ░▓ author ▓ Akash Goyal
# ░▓ file   ▓ zsh/.config/zsh/conf.d/08-python.zsh
# ░▓▓▓▓▓▓▓▓▓▓
#
# ------------------------------------------------------------------------------
# Python Configuration
# ------------------------------------------------------------------------------

# Basic Python aliases
alias python="python3" # Use Python 3 by default
alias pip="pip3"       # Use pip3 by default

alias py3="python3"   # the standard 3.14 (mise); conda: `conda activate`

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
# No `mise activate`: its shims dir is first on PATH (01-exports.zsh), and a
# shim picks the version per directory (mise.toml / .python-version) on every
# call, so nothing has to run when the shell starts or you cd. Measured with
# zsh-bench: activation cost ~28ms before each new shell's first command; a
# shim adds ~15ms per python start instead. Use `mise exec -- cmd` / `mise
# env` for a mise.toml [env] section (only activation would load that).

# Default directory for mkvenv/venv/rmvenv below when no name is given.
# Previously reused $PYENV_ROOT (~/.pyenv, an absolute path) for this — but
# these functions build paths like "$(pwd)/$env_dir", which only makes sense
# for a relative name, so the no-argument case was already broken before
# pyenv's removal made it worse (an unset, empty path). ".venv" matches the
# convention most current Python tooling (uv, poetry, VS Code) defaults to.
VENV_DEFAULT_DIR=".venv"

# uv: prefer the Python on PATH (mise's 3.14, the standard) over interpreters
# uv downloaded itself, so `uv venv` without --python gets 3.14. Projects that
# pin a version (.python-version / requires-python) still get theirs.
export UV_PYTHON_PREFERENCE=system

# ------------------------------------------------------------------------------
# Virtual Environment Management (uv-backed)
# ------------------------------------------------------------------------------
# uv creates the venv and manages packages (`uv pip ...`) - mise (above) only
# decides which Python interpreter is on PATH when `--python` isn't given.
# See docs/CUSTOMIZE.md for the full mise+uv workflow (multiple envs, switching
# interpreter versions, uv's project mode for lockfile-based reproducibility).

# Create and activate a Python virtual environment
function mkvenv() {
    if ! command -v uv &>/dev/null; then
        echo "Error: uv is not installed (see docs/CUSTOMIZE.md)"
        return 1
    fi

    # Set the environment directory name, default to VENV_DEFAULT_DIR if no name provided
    local env_dir=${1:-$VENV_DEFAULT_DIR}
    # Optional second arg: a specific Python version/interpreter for uv to use
    # (e.g. `mkvenv .venv 3.12`) - otherwise uv uses whatever `python` mise
    # has on PATH.
    local py_version=$2

    # Check if environment already exists
    if [[ -d "$env_dir" ]]; then
        echo "Error: Environment '$env_dir' already exists"
        return 1
    fi

    # Create the virtual environment
    echo "Creating new virtual environment '$env_dir'..."
    if [[ -n "$py_version" ]]; then
        if ! uv venv --python "$py_version" "$env_dir"; then
            echo "Failed to create virtual environment '$env_dir'."
            return 1
        fi
    elif ! uv venv "$env_dir"; then
        echo "Failed to create virtual environment '$env_dir'."
        return 1
    fi

    # Activate the virtual environment
    source "$env_dir/bin/activate" || {
        echo "Failed to activate virtual environment '$env_dir'. Activation script not found."
        return 1
    }

    echo "Virtual environment created and activated successfully"
    echo "Location: $(pwd)/$env_dir"
    echo "Python version: $(python --version)"
    echo "Install packages with: uv pip install <package>"
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
