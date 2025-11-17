#!/usr/bin/env bash
#
#  ▓▓▓▓▓▓▓▓▓▓
# ░▓ author ▓ Akash Goyal
# ░▓ file   ▓ scripts/utils/_logger.sh
# ░▓▓▓▓▓▓▓▓▓▓
# ░░░░░░░░░░
#
#█▓▒░
# Centralized Logging Utility
# Provides consistent logging across all dotfiles scripts

# ------------------------------------------------------------------------------
# Color Definitions
# ------------------------------------------------------------------------------
readonly LOG_RED='\033[31m'
readonly LOG_YELLOW='\033[33m'
readonly LOG_GREEN='\033[32m'
readonly LOG_BLUE='\033[34m'
readonly LOG_MAGENTA='\033[35m'
readonly LOG_CYAN='\033[36m'
readonly LOG_WHITE='\033[37m'
readonly LOG_BOLD='\033[1m'
readonly LOG_NC='\033[0m' # No Color

# ------------------------------------------------------------------------------
# Log Level Configuration
# ------------------------------------------------------------------------------
# Available log levels: TRACE, DEBUG, INFO, SUCCESS, WARNING, ERROR, FATAL
# Set LOG_LEVEL environment variable to control verbosity
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

# Default log level
LOG_LEVEL="${LOG_LEVEL:-INFO}"
LOG_MIN_LEVEL=$(_get_log_level_num "$LOG_LEVEL")

# Log file location (optional)
LOG_FILE="${LOG_FILE:-/tmp/dotfiles.log}"
LOG_TO_FILE="${LOG_TO_FILE:-false}"

# Timestamp format
LOG_TIMESTAMP_FORMAT="${LOG_TIMESTAMP_FORMAT:-%Y-%m-%d %H:%M:%S}"

# ------------------------------------------------------------------------------
# Internal Logging Function
# ------------------------------------------------------------------------------
_log() {
    local level="$1"
    local color="$2"
    local message="$3"
    local level_num
    level_num=$(_get_log_level_num "$level")
    
    # Check if message should be logged based on level
    if [[ $level_num -lt $LOG_MIN_LEVEL ]]; then
        return 0
    fi
    
    # Format timestamp
    local timestamp
    timestamp=$(date +"$LOG_TIMESTAMP_FORMAT")
    
    # Format message
    local formatted_message
    if [[ -t 1 ]]; then
        # Terminal output with colors
        formatted_message="${color}[${level}]${LOG_NC} ${message}"
    else
        # No colors for pipes/redirects
        formatted_message="[${level}] ${message}"
    fi
    
    # Output to stdout/stderr
    if [[ "$level" == "ERROR" ]] || [[ "$level" == "FATAL" ]]; then
        echo -e "$formatted_message" >&2
    else
        echo -e "$formatted_message"
    fi
    
    # Optionally log to file
    if [[ "$LOG_TO_FILE" == "true" ]]; then
        echo "[$timestamp] [$level] $message" >> "$LOG_FILE"
    fi
    
    # Exit on FATAL
    if [[ "$level" == "FATAL" ]]; then
        exit 1
    fi
}

# ------------------------------------------------------------------------------
# Public Logging Functions
# ------------------------------------------------------------------------------

# Trace: Very detailed debugging information
log_trace() {
    _log "TRACE" "$LOG_CYAN" "$*"
}

# Debug: Debugging information
log_debug() {
    _log "DEBUG" "$LOG_MAGENTA" "$*"
}

# Info: General informational messages
log_info() {
    _log "INFO" "$LOG_BLUE" "$*"
}

# Success: Success messages
log_success() {
    _log "SUCCESS" "$LOG_GREEN" "$*"
}

# Warning: Warning messages that don't stop execution
log_warning() {
    _log "WARNING" "$LOG_YELLOW" "$*"
}

# Error: Error messages that don't stop execution
log_error() {
    _log "ERROR" "$LOG_RED" "$*"
}

# Fatal: Fatal errors that stop execution
log_fatal() {
    _log "FATAL" "${LOG_RED}${LOG_BOLD}" "$*"
}

# ------------------------------------------------------------------------------
# Formatted Output Functions
# ------------------------------------------------------------------------------

# Print a section header
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

# Print a box message
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

# Print a banner
log_banner() {
    local title="$1"
    local color="${2:-$LOG_GREEN}"
    
    echo ""
    echo -e "${color}====================================================${LOG_NC}"
    echo -e "${color} $title${LOG_NC}"
    echo -e "${color}====================================================${LOG_NC}"
}

# Print a substep (indented message)
log_substep() {
    local message="$1"
    echo -e "  ${LOG_YELLOW}→${LOG_NC} $message"
}

# Print an info line (key-value pair)
log_kvp() {
    local key="$1"
    local value="$2"
    printf "  %-30s : %s\n" "$key" "$value"
}

# ------------------------------------------------------------------------------
# Status Indicators
# ------------------------------------------------------------------------------

# Print status with checkmark
log_ok() {
    local message="$1"
    echo -e "  ${LOG_GREEN}✓${LOG_NC} $message"
}

# Print status with X
log_fail() {
    local message="$1"
    echo -e "  ${LOG_RED}✗${LOG_NC} $message"
}

# Print status with warning symbol
log_warn() {
    local message="$1"
    echo -e "  ${LOG_YELLOW}⚠${LOG_NC} $message"
}

# Print bullet point
log_bullet() {
    local message="$1"
    echo -e "  ${LOG_BLUE}•${LOG_NC} $message"
}

# ------------------------------------------------------------------------------
# Progress Indicators
# ------------------------------------------------------------------------------

# Show a spinner (for long-running operations)
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

# Show progress bar
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
    
    if [[ $current -eq $total ]]; then
        echo ""
    fi
}

# ------------------------------------------------------------------------------
# Utility Functions
# ------------------------------------------------------------------------------

# Check if verbose mode is enabled
is_verbose() {
    [[ "${LOG_LEVEL}" == "DEBUG" ]] || [[ "${LOG_LEVEL}" == "TRACE" ]]
}

# Print separator line
log_separator() {
    local width="${1:-70}"
    local char="${2:-─}"
    printf '%*s\n' "$width" | tr ' ' "$char"
}

# Print empty line
log_newline() {
    echo ""
}

# Print a command being executed (for debugging)
log_command() {
    local cmd="$*"
    log_debug "Executing: $cmd"
    eval "$cmd"
}

# Log file information
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

# ------------------------------------------------------------------------------
# Compatibility Layer (for existing scripts)
# ------------------------------------------------------------------------------

# Provide backward compatibility with existing function names
info() { log_info "$@"; }
success() { log_success "$@"; }
warning() { log_warning "$@"; }
error() { log_error "$@"; }
substep_info() { log_substep "$@"; }
substep_success() { log_ok "$@"; }
substep_error() { log_fail "$@"; }
section_header() { log_section "$@"; }

# ------------------------------------------------------------------------------
# Initialization
# ------------------------------------------------------------------------------

# Create log file if logging to file is enabled
if [[ "$LOG_TO_FILE" == "true" ]]; then
    mkdir -p "$(dirname "$LOG_FILE")"
    touch "$LOG_FILE" 2>/dev/null || LOG_TO_FILE="false"
fi

# Export functions for use in subshells
export -f log_trace log_debug log_info log_success log_warning log_error log_fatal
export -f log_section log_box log_banner log_substep log_kvp
export -f log_ok log_fail log_warn log_bullet
export -f log_spinner log_progress
export -f log_separator log_newline log_command log_file_info
export -f is_verbose

# Export color variables
export LOG_RED LOG_YELLOW LOG_GREEN LOG_BLUE LOG_MAGENTA LOG_CYAN LOG_WHITE LOG_BOLD LOG_NC

# Indicate logger is loaded
readonly LOGGER_LOADED=true
export LOGGER_LOADED

