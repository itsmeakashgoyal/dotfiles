#!/usr/bin/env bash
#
#  ▓▓▓▓▓▓▓▓▓▓
# ░▓ author ▓ Akash Goyal
# ░▓ file   ▓ scripts/utils/_helper.sh
# ░▓▓▓▓▓▓▓▓▓▓
# ░░░░░░░░░░
#
#█▓▒░
# Unified helper library: logging, OS detection, and utility functions.
# Source this file from any script that needs logging or helper functions.

# ==============================================================================
# Color Definitions
# ==============================================================================
readonly LOG_RED='\033[31m'
readonly LOG_YELLOW='\033[33m'
readonly LOG_GREEN='\033[32m'
readonly LOG_BLUE='\033[34m'
readonly LOG_MAGENTA='\033[35m'
readonly LOG_CYAN='\033[36m'
readonly LOG_WHITE='\033[37m'
readonly LOG_BOLD='\033[1m'
readonly LOG_NC='\033[0m' # No Color

# ==============================================================================
# Log Level Configuration
# ==============================================================================
# Available: TRACE, DEBUG, INFO, SUCCESS, WARNING, ERROR, FATAL
_get_log_level_num() {
    case "$1" in
        TRACE)   echo 0 ;;
        DEBUG)   echo 1 ;;
        INFO)    echo 2 ;;
        SUCCESS) echo 3 ;;
        WARNING) echo 4 ;;
        ERROR)   echo 5 ;;
        FATAL)   echo 6 ;;
        *)       echo 2 ;;
    esac
}

LOG_LEVEL="${LOG_LEVEL:-INFO}"
LOG_MIN_LEVEL=$(_get_log_level_num "$LOG_LEVEL")

LOG_FILE="${LOG_FILE:-/tmp/dotfiles.log}"
LOG_TO_FILE="${LOG_TO_FILE:-false}"
LOG_TIMESTAMP_FORMAT="${LOG_TIMESTAMP_FORMAT:-%Y-%m-%d %H:%M:%S}"

# ==============================================================================
# Internal Logging
# ==============================================================================
_log() {
    local level="$1"
    local color="$2"
    local message="$3"
    local level_num
    level_num=$(_get_log_level_num "$level")

    if [[ $level_num -lt $LOG_MIN_LEVEL ]]; then
        return 0
    fi

    local timestamp
    timestamp=$(date +"$LOG_TIMESTAMP_FORMAT")

    local formatted_message
    if [[ -n "${CI:-}" ]]; then
        if [[ "$level" == "INFO" ]] || [[ "$level" == "SUCCESS" ]]; then
            formatted_message="${message}"
        else
            formatted_message="[${level}] ${message}"
        fi
    elif [[ -t 1 ]]; then
        formatted_message="${color}[${level}]${LOG_NC} ${message}"
    else
        formatted_message="[${level}] ${message}"
    fi

    if [[ "$level" == "ERROR" ]] || [[ "$level" == "FATAL" ]]; then
        echo -e "$formatted_message" >&2
    else
        echo -e "$formatted_message"
    fi

    if [[ "$LOG_TO_FILE" == "true" ]]; then
        echo "[$timestamp] [$level] $message" >> "$LOG_FILE"
    fi

    if [[ "$level" == "FATAL" ]]; then
        exit 1
    fi
}

# ==============================================================================
# Public Logging Functions
# ==============================================================================
log_trace()   { _log "TRACE"   "$LOG_CYAN"                "$*"; }
log_debug()   { _log "DEBUG"   "$LOG_MAGENTA"             "$*"; }
log_info()    { _log "INFO"    "$LOG_BLUE"                "$*"; }
log_success() { _log "SUCCESS" "$LOG_GREEN"               "$*"; }
log_warning() { _log "WARNING" "$LOG_YELLOW"              "$*"; }
log_error()   { _log "ERROR"   "$LOG_RED"                 "$*"; }
log_fatal()   { _log "FATAL"   "${LOG_RED}${LOG_BOLD}"    "$*"; }

# Formatted output
log_section() {
    local title="$1"
    local width="${2:-70}"
    local separator
    separator=$(printf '%*s' "$width" | tr ' ' '━')
    echo ""
    echo -e "${LOG_BLUE}$separator${LOG_NC}"
    echo -e "${LOG_BLUE}  $title${LOG_NC}"
    echo -e "${LOG_BLUE}$separator${LOG_NC}"
}

log_box() {
    local message="$1"
    local color="${2:-$LOG_BLUE}"
    echo ""
    echo -e "${color}╔═══════════════════════════════════════════════════╗${LOG_NC}"
    echo -e "${color}║                                                   ║${LOG_NC}"
    echo -e "${color}║  $message${LOG_NC}"
    echo -e "${color}║                                                   ║${LOG_NC}"
    echo -e "${color}╚═══════════════════════════════════════════════════╝${LOG_NC}"
    echo ""
}

log_banner() {
    local title="$1"
    local color="${2:-$LOG_GREEN}"
    echo ""
    echo -e "${color}====================================================${LOG_NC}"
    echo -e "${color} $title${LOG_NC}"
    echo -e "${color}====================================================${LOG_NC}"
}

log_substep() { echo -e "  ${LOG_YELLOW}→${LOG_NC} $1"; }
log_kvp()     { printf "  %-30s : %s\n" "$1" "$2"; }
log_ok()      { echo -e "  ${LOG_GREEN}✓${LOG_NC} $1"; }
log_fail()    { echo -e "  ${LOG_RED}✗${LOG_NC} $1"; }
log_warn()    { echo -e "  ${LOG_YELLOW}⚠${LOG_NC} $1"; }
log_bullet()  { echo -e "  ${LOG_BLUE}•${LOG_NC} $1"; }

log_separator() {
    local width="${1:-70}"
    local char="${2:-─}"
    printf '%*s\n' "$width" | tr ' ' "$char"
}

log_newline() { echo ""; }

log_spinner() {
    local pid=$1
    local message="${2:-Processing}"
    local spin='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
    local i=0
    while kill -0 "$pid" 2>/dev/null; do
        i=$(( (i+1) %10 ))
        printf "\r  ${LOG_BLUE}${spin:$i:1}${LOG_NC} %s..." "$message"
        sleep 0.1
    done
    printf "\r  ${LOG_GREEN}✓${LOG_NC} %s... Done\n" "$message"
}

log_progress() {
    local current=$1
    local total=$2
    local width=50
    local percentage=$((current * 100 / total))
    local filled=$((current * width / total))
    local empty=$((width - filled))
    printf "\r  ["
    printf "%${filled}s" | tr ' ' '█'
    printf "%${empty}s" | tr ' ' '░'
    printf "] %3d%%" "$percentage"
    if [[ $current -eq $total ]]; then echo ""; fi
}

log_command() {
    log_debug "Executing: $*"
    eval "$@"
}

log_file_info() {
    local file="$1"
    if [[ -f "$file" ]]; then
        local size
        size=$(du -h "$file" | awk '{print $1}')
        log_info "File: $file (Size: $size)"
    else
        log_warning "File not found: $file"
    fi
}

is_verbose() {
    [[ "${LOG_LEVEL}" == "DEBUG" ]] || [[ "${LOG_LEVEL}" == "TRACE" ]]
}

# Compatibility aliases used by existing scripts
info()            { log_info "$@"; }
success()         { log_success "$@"; }
warning()         { log_warning "$@"; }
error()           { log_error "$@"; }
substep_info()    { log_substep "$@"; }
substep_success() { log_ok "$@"; }
substep_error()   { log_fail "$@"; }
section_header()  { log_section "$@"; }
log_message()     { log_info "$@"; }

# Initialize log file
if [[ "$LOG_TO_FILE" == "true" ]]; then
    mkdir -p "$(dirname "$LOG_FILE")"
    touch "$LOG_FILE" 2>/dev/null || LOG_TO_FILE="false"
fi

# Export logging functions for subshells
export -f log_trace log_debug log_info log_success log_warning log_error log_fatal
export -f log_section log_box log_banner log_substep log_kvp
export -f log_ok log_fail log_warn log_bullet
export -f log_spinner log_progress
export -f log_separator log_newline log_command log_file_info
export -f is_verbose log_message
export LOG_RED LOG_YELLOW LOG_GREEN LOG_BLUE LOG_MAGENTA LOG_CYAN LOG_WHITE LOG_BOLD LOG_NC

readonly LOGGER_LOADED=true
export LOGGER_LOADED

# ==============================================================================
# Environment
# ==============================================================================
readonly REPO_NAME="${REPO_NAME:-}"
readonly OS_TYPE=$(uname)
readonly DOTFILES_DIR="${HOME}/dotfiles"
readonly CONFIG_DIR="${HOME}/.config"
readonly BACKUP_DIR="${HOME}/linuxtoolbox"

export LOG_TO_FILE=true

# ==============================================================================
# Utility Functions
# ==============================================================================
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

    echo "Stack Trace:" >&2
    for i in "${!FUNCNAME[@]}"; do
        echo "  ${FUNCNAME[$i]}() called at line ${BASH_LINENO[$i - 1]} in ${BASH_SOURCE[$i]}" >&2
    done

    exit 1
}

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

check_command() {
    if ! command -v "$1" >/dev/null 2>&1; then
        error "Error: $1 not found"
        return 1
    fi
}

# ==============================================================================
# Script Management
# ==============================================================================
run_script() {
    local script_name="$1"
    local script_path="./scripts/setup/${script_name}.sh"

    if [[ -f "$script_path" ]]; then
        warning "Running ${script_name} setup..."
        if ! "$script_path"; then
            error "${script_name} setup failed"
            log_message "${script_name} setup failed"
            return 1
        fi
        log_message "${script_name} setup completed"
    else
        error "${script_path} not found"
        return 1
    fi
}

check_required_commands() {
    required_commands="curl git stow"
    for cmd in $required_commands; do
        if ! command -v "$cmd" &>/dev/null; then
            echo "Error: $cmd is not installed." >&2
            exit 1
        fi
    done
}

# ==============================================================================
# Initialization
# ==============================================================================
if [ ! -d "$BACKUP_DIR" ]; then
    warning "Creating backup directory: $BACKUP_DIR"
    mkdir -p "$BACKUP_DIR"
    success "Backup directory created: $BACKUP_DIR"
fi
