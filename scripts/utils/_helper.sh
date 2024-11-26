#!/usr/bin/env bash

#################################################
#      File: _helper.sh                          #
#      Author: Akash Goyal                       #
#      Status: Development                       #
#################################################

# ------------------------------------------------------------------------------
# Constants
# ------------------------------------------------------------------------------
# Colors
readonly RED='\033[31m'
readonly YELLOW='\033[33m'
readonly GREEN='\033[32m'
readonly BLUE='\033[34m'
readonly NC='\033[0m' # No Color

# Paths
readonly OS_TYPE=$(uname)
readonly DOTFILES_DIR="${HOME}/dotfiles"
readonly CONFIG_DIR="${HOME}/.config"
readonly BACKUP_DIR="${HOME}/linuxtoolbox"
readonly LOG_FILE="/tmp/setup_log.txt"

# ------------------------------------------------------------------------------
# Logging Functions
# ------------------------------------------------------------------------------
print_message() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

log_message() {
    local timestamp="$(date '+%Y-%m-%d %H:%M:%S')"
    local message="[$timestamp] $1"
    echo "$message"
    echo "$message" >>"$LOG_FILE"
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
        print_message "$RED" "Error: $1 failed"
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
        print_message "$RED" "Error: Source '$source_path' does not exist"
        return 1
    fi

    # Create backup directory
    mkdir -p "$(dirname "$backup_path")"

    # Handle existing destination
    if [[ -e "$dest_path" ]] || [[ -L "$dest_path" ]]; then
        if [[ -L "$dest_path" ]]; then
            print_message "$YELLOW" "Removing existing symlink: $dest_path"
            unlink "$dest_path"
        elif [[ -e "$dest_path" ]]; then
            print_message "$YELLOW" "Backing up: $dest_path → $backup_path"
            mv "$dest_path" "$backup_path"
        fi
    fi

    # Create parent directory
    mkdir -p "$(dirname "$dest_path")"

    # Create symlink
    ln -sf "$source_path" "$dest_path"
    print_message "$GREEN" "Created symlink: $dest_path → $source_path"
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
            print_message "$YELLOW" "Removing existing symlink: $dest_path"
            unlink "$dest_path"
        elif [[ -e "$dest_path" ]]; then
            print_message "$YELLOW" "Backing up: $dest_path → $backup_path"
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
        print_message "$YELLOW" "Running ${script_name} setup..."
        if ! "$script_path"; then
            print_message "$RED" "Error: ${script_name} setup failed"
            log_message "Error: ${script_name} setup failed"
            return 1
        fi
        log_message "${script_name} setup completed"
    else
        print_message "$RED" "Warning: ${script_path} not found"
        log_message "Warning: ${script_path} not found"
        return 1
    fi
}

# ------------------------------------------------------------------------------
# Initialization
# ------------------------------------------------------------------------------
# Create backup directory if it doesn't exist
if [[ ! -d "$BACKUP_DIR" ]]; then
    print_message "$YELLOW" "Creating backup directory: $BACKUP_DIR"
    mkdir -p "$BACKUP_DIR"
    print_message "$GREEN" "Backup directory created: $BACKUP_DIR"
fi
