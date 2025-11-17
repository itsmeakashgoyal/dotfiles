#!/bin/bash
#
#  ▓▓▓▓▓▓▓▓▓▓
# ░▓ author ▓ Akash Goyal
# ░▓ file   ▓ scripts/utils/_helper.sh
# ░▓▓▓▓▓▓▓▓▓▓
# ░░░░░░░░░░
#
#█▓▒░

LOGGER_FILE="${HOME}/dotfiles/scripts/utils/_logger.sh"
if [[ -f "$LOGGER_FILE" ]]; then
    source "$LOGGER_FILE"
else
    echo "Error: Logger file not found at $LOGGER_FILE" >&2
    exit 1
fi

readonly REPO_NAME="${REPO_NAME:-}"
readonly OS_TYPE=$(uname)
readonly DOTFILES_DIR="${HOME}/dotfiles"
readonly CONFIG_DIR="${HOME}/.config"
readonly BACKUP_DIR="${HOME}/linuxtoolbox"
readonly LOG_FILE="/tmp/setup_log.txt"

export LOG_TO_FILE=true

log_message() {
    local message="$1"
    log_info "$message"
}

sudo_keep_alive() {
    while true; do
        sudo -n true
        sleep 60
    done
}

print_error() {
    local line_number="$1"
    local command="$2"
    local exit_code="$3"

    echo "ERROR: Script '${0}' failed on line ${line_number}" >&2
    echo "Command: ${command}" >&2
    echo "Exit Code: ${exit_code}" >&2

    # Print stack trace
    echo "Stack Trace:" >&2
    for i in "${!FUNCNAME[@]}"; do
        echo "  ${FUNCNAME[$i]}() called at line ${BASH_LINENO[$i - 1]} in ${BASH_SOURCE[$i]}" >&2
    done

    exit 1
}

# ------------------------------------------------------------------------------
# Utility Functions
# ------------------------------------------------------------------------------
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

check_command() {
    if [ $? -ne 0 ]; then
        error "Error: $1 failed"
        return 1
    fi
}

# ------------------------------------------------------------------------------
# Symlink Functions
# ------------------------------------------------------------------------------
symlink() {
    local source="$1"
    local destination="$2"
    local source_path="${DOTFILES_DIR}/${source}"
    local dest_path="${HOME}/${destination}"
    local backup_path="${BACKUP_DIR}/${destination}"

    # Validate source
    if [[ ! -e "$source_path" ]]; then
        error "Error: Source '$source_path' does not exist"
        return 1
    fi

    # Create backup directory
    mkdir -p "$(dirname "$backup_path")"

    # Handle existing destination
    if [[ -e "$dest_path" ]] || [[ -L "$dest_path" ]]; then
        if [[ -L "$dest_path" ]]; then
            warning "Removing existing symlink: $dest_path"
            unlink "$dest_path"
        elif [[ -e "$dest_path" ]]; then
            warning "Backing up: $dest_path → $backup_path"
            mv "$dest_path" "$backup_path"
        fi
    fi

    # Create parent directory
    mkdir -p "$(dirname "$dest_path")"

    # Create symlink
    ln -sf "$source_path" "$dest_path"
    success "Created symlink: $dest_path → $source_path"
    log_message "Created symlink: $dest_path → $source_path"
}

# Backup existing dotfiles
backup_existing_files() {
    local source="$1"
    local destination="$2"
    local dest_path="${HOME}/${destination}"
    local backup_path="${BACKUP_DIR}/${destination}"

    if [[ -e "$dest_path" || -L "$dest_path" ]]; then
        if [[ -L "$dest_path" ]]; then
            warning "Removing existing symlink: $dest_path"
            unlink "$dest_path"
        elif [[ -e "$dest_path" ]]; then
            warning "Backing up: $dest_path → $backup_path"
            mv "$dest_path" "$backup_path"
        fi
    fi
}

# ------------------------------------------------------------------------------
# Script Management
# ------------------------------------------------------------------------------
run_script() {
    local script_name="$1"
    local script_path="./scripts/setup/${script_name}.sh"

    if [[ -f "$script_path" ]]; then
        warning "Running ${script_name} setup..."
        if ! "$script_path"; then
            error "Error: ${script_name} setup failed"
            log_message "Error: ${script_name} setup failed"
            return 1
        fi
        log_message "${script_name} setup completed"
    else
        error "Warning: ${script_path} not found"
        log_message "Warning: ${script_path} not found"
        return 1
    fi
}

# Function to check for required commands
check_required_commands() {
    required_commands="curl git" # Space-separated list of required commands
    for cmd in $required_commands; do
        if ! command -v "$cmd" &>/dev/null; then
            echo "Error: $cmd is not installed." >&2
            exit 1
        fi
    done
}

# ------------------------------------------------------------------------------
# Initialization
# ------------------------------------------------------------------------------
# Create backup directory if it doesn't exist
if [ ! -d "$BACKUP_DIR" ]; then
    warning "Creating backup directory: $BACKUP_DIR"
    mkdir -p "$BACKUP_DIR"
    success "Backup directory created: $BACKUP_DIR"
fi
