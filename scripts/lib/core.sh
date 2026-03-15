#!/usr/bin/env bash
#
#  ▓▓▓▓▓▓▓▓▓▓
# ░▓ author ▓ Akash Goyal
# ░▓ file   ▓ scripts/lib/core.sh
# ░▓▓▓▓▓▓▓▓▓▓
#
# Shared library: logging, colors, OS detection, and utility functions.
# Every script sources this file — it is the single source of truth.
# Guard prevents double-sourcing.

[[ -n "${CORE_LOADED:-}" ]] && return 0

# ==============================================================================
# Colors
# ==============================================================================
readonly LOG_RED='\033[31m'
readonly LOG_YELLOW='\033[33m'
readonly LOG_GREEN='\033[32m'
readonly LOG_BLUE='\033[34m'
readonly LOG_MAGENTA='\033[35m'
readonly LOG_CYAN='\033[36m'
readonly LOG_WHITE='\033[37m'
readonly LOG_BOLD='\033[1m'
readonly LOG_NC='\033[0m'

# ==============================================================================
# Log Levels  (TRACE=0  DEBUG=1  INFO=2  SUCCESS=3  WARNING=4  ERROR=5  FATAL=6)
# ==============================================================================
_log::level_num() {
    case "$1" in
        TRACE)   echo 0 ;; DEBUG)   echo 1 ;; INFO)    echo 2 ;;
        SUCCESS) echo 3 ;; WARNING) echo 4 ;; ERROR)   echo 5 ;;
        FATAL)   echo 6 ;; *)       echo 2 ;;
    esac
}

LOG_LEVEL="${LOG_LEVEL:-INFO}"
LOG_MIN_LEVEL=$(_log::level_num "$LOG_LEVEL")
LOG_FILE="${LOG_FILE:-/tmp/dotfiles.log}"
LOG_TO_FILE="${LOG_TO_FILE:-true}"
LOG_TIMESTAMP_FORMAT="${LOG_TIMESTAMP_FORMAT:-%Y-%m-%d %H:%M:%S}"

# ==============================================================================
# Core Log Function
# ==============================================================================
_log() {
    local level="$1" color="$2" message="$3"
    local level_num
    level_num=$(_log::level_num "$level")
    [[ $level_num -lt $LOG_MIN_LEVEL ]] && return 0

    local formatted
    if [[ -n "${CI:-}" ]]; then
        [[ "$level" == "INFO" || "$level" == "SUCCESS" ]] \
            && formatted="$message" \
            || formatted="[$level] $message"
    elif [[ -t 1 ]]; then
        formatted="${color}[${level}]${LOG_NC} ${message}"
    else
        formatted="[$level] $message"
    fi

    if [[ "$level" == "ERROR" || "$level" == "FATAL" ]]; then
        echo -e "$formatted" >&2
    else
        echo -e "$formatted"
    fi

    if [[ "$LOG_TO_FILE" == "true" ]]; then
        local ts
        ts=$(date +"$LOG_TIMESTAMP_FORMAT")
        echo "[$ts] [$level] $message" >> "$LOG_FILE"
    fi

    if [[ "$level" == "FATAL" ]]; then exit 1; fi
}

# ==============================================================================
# Public Log Functions  (namespace: log::*)
# ==============================================================================
log::trace()   { _log "TRACE"   "$LOG_CYAN"               "$*"; }
log::debug()   { _log "DEBUG"   "$LOG_MAGENTA"            "$*"; }
log::info()    { _log "INFO"    "$LOG_BLUE"               "$*"; }
log::success() { _log "SUCCESS" "$LOG_GREEN"              "$*"; }
log::warning() { _log "WARNING" "$LOG_YELLOW"             "$*"; }
log::error()   { _log "ERROR"   "$LOG_RED"                "$*"; }
log::fatal()   { _log "FATAL"   "${LOG_RED}${LOG_BOLD}"   "$*"; }

# Formatted output helpers
log::section() {
    local title="$1" width="${2:-70}"
    local sep; sep=$(printf '%*s' "$width" | tr ' ' '━')
    echo -e "\n${LOG_BLUE}${sep}\n  ${title}\n${sep}${LOG_NC}"
}
log::banner() {
    local title="$1" color="${2:-$LOG_GREEN}"
    echo -e "\n${color}====================================================\n ${title}\n====================================================${LOG_NC}"
}
log::box() {
    local msg="$1" color="${2:-$LOG_BLUE}"
    echo -e "\n${color}╔═══════════════════════════════════════════════════╗\n║                                                   ║\n║  ${msg}\n║                                                   ║\n╚═══════════════════════════════════════════════════╝${LOG_NC}\n"
}
log::ok()      { echo -e "  ${LOG_GREEN}✓${LOG_NC} $1"; }
log::fail()    { echo -e "  ${LOG_RED}✗${LOG_NC} $1"; }
log::warn()    { echo -e "  ${LOG_YELLOW}⚠${LOG_NC} $1"; }
log::bullet()  { echo -e "  ${LOG_BLUE}•${LOG_NC} $1"; }
log::substep() { echo -e "  ${LOG_YELLOW}→${LOG_NC} $1"; }
log::kvp()     { printf "  %-30s : %s\n" "$1" "$2"; }
log::sep()     { local w="${1:-70}" c="${2:-─}"; printf '%*s\n' "$w" | tr ' ' "$c"; }
log::newline() { echo ""; }

log::spinner() {
    local pid=$1 msg="${2:-Processing}" spin='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏' i=0
    while kill -0 "$pid" 2>/dev/null; do
        i=$(( (i+1) % 10 ))
        printf "\r  ${LOG_BLUE}${spin:$i:1}${LOG_NC} %s..." "$msg"
        sleep 0.1
    done
    printf "\r  ${LOG_GREEN}✓${LOG_NC} %s... Done\n" "$msg"
}

log::progress() {
    local cur=$1 tot=$2 w=50
    local pct=$((cur * 100 / tot)) filled=$((cur * w / tot)) empty=$((w - cur * w / tot))
    printf "\r  ["; printf "%${filled}s" | tr ' ' '█'; printf "%${empty}s" | tr ' ' '░'
    printf "] %3d%%" "$pct"
    [[ $cur -eq $tot ]] && echo ""
}

is_verbose() { [[ "${LOG_LEVEL}" == "DEBUG" || "${LOG_LEVEL}" == "TRACE" ]]; }

# Compatibility aliases — existing scripts can keep calling info(), success(), etc.
info()            { log::info    "$@"; }
success()         { log::success "$@"; }
warning()         { log::warning "$@"; }
error()           { log::error   "$@"; }
substep_info()    { log::substep "$@"; }
substep_success() { log::ok      "$@"; }
substep_error()   { log::fail    "$@"; }
section_header()  { log::section "$@"; }
log_message()     { log::info    "$@"; }

# Legacy log_* names used by existing scripts
log_trace()   { log::trace   "$@"; }
log_debug()   { log::debug   "$@"; }
log_info()    { log::info    "$@"; }
log_success() { log::success "$@"; }
log_warning() { log::warning "$@"; }
log_error()   { log::error   "$@"; }
log_fatal()   { log::fatal   "$@"; }
log_section() { log::section "$@"; }
log_banner()  { log::banner  "$@"; }
log_box()     { log::box     "$@"; }
log_substep() { log::substep "$@"; }
log_kvp()     { log::kvp     "$@"; }
log_ok()      { log::ok      "$@"; }
log_fail()    { log::fail    "$@"; }
log_warn()    { log::warn    "$@"; }
log_bullet()  { log::bullet  "$@"; }
log_spinner() { log::spinner "$@"; }
log_progress(){ log::progress "$@"; }
log_separator(){ log::sep    "$@"; }
log_newline() { log::newline; }

# ==============================================================================
# OS Detection  (namespace: os::*)
# ==============================================================================
readonly OS_TYPE=$(uname)

os::is_mac()   { [[ "$OS_TYPE" == "Darwin" ]]; }
os::is_linux() { [[ "$OS_TYPE" == "Linux"  ]]; }
os::arch()     { uname -m; }
os::detail() {
    local arch; arch=$(uname -m)
    case "${OS_TYPE},${arch}" in
        Linux,arm*|Linux,aarch64) echo "Linux (ARM)" ;;
        Linux,x86_64|Linux,amd64) echo "Linux (x86_64)" ;;
        Darwin,arm64)             echo "macOS (Apple Silicon)" ;;
        Darwin,x86_64)            echo "macOS (Intel)" ;;
        *)                        echo "Unknown: ${OS_TYPE} on ${arch}" ;;
    esac
}

# ==============================================================================
# Utility Functions  (namespace: pkg::* / util::*)
# ==============================================================================

# Check if a command is available
command_exists() { command -v "$1" >/dev/null 2>&1; }
pkg::exists()    { command_exists "$@"; }

# Check command and error if missing
check_command() {
    if ! command_exists "$1"; then
        log::error "$1 not found"
        return 1
    fi
}

# Get the version string of a command
pkg::version() {
    local cmd="$1" flag="${2:---version}"
    if command_exists "$cmd"; then
        $cmd $flag 2>&1 | head -n 1 | grep -oE '[0-9]+\.[0-9]+(\.[0-9]+)?' | head -n 1 || echo "installed"
    else
        echo "not found"
    fi
}
# Legacy alias used by existing scripts
get_version() { pkg::version "$@"; }

# Ensure required commands exist, exit if any are missing
check_required_commands() {
    local required_commands="curl git"
    for cmd in $required_commands; do
        if ! command_exists "$cmd"; then
            log::fatal "Required command not found: $cmd"
        fi
    done
}

# Keep sudo alive in background (call before long installs)
sudo_keep_alive() {
    while true; do sudo -n true; sleep 60; done
}

# Run an error handler with context on ERR
print_error() {
    local line="$1" cmd="$2" code="$3"
    echo "ERROR: '${0}' failed on line ${line}" >&2
    echo "Command: ${cmd}" >&2
    echo "Exit Code: ${code}" >&2
    echo "Stack:" >&2
    for i in "${!FUNCNAME[@]}"; do
        echo "  ${FUNCNAME[$i]}() at line ${BASH_LINENO[$i-1]} in ${BASH_SOURCE[$i]}" >&2
    done
    exit 1
}

# Run a setup script by short name (looks in scripts/setup/)
run_script() {
    local name="$1"
    local path="${DOTFILES_DIR}/scripts/setup/${name}.sh"
    if [[ ! -f "$path" ]]; then
        log::error "Setup script not found: $path"
        return 1
    fi
    log::warning "Running ${name} setup..."
    if ! bash "$path"; then
        log::error "${name} setup failed"
        return 1
    fi
    log::info "${name} setup completed"
}

# ==============================================================================
# Environment Constants
# ==============================================================================
readonly DOTFILES_DIR="${HOME}/dotfiles"
readonly CONFIG_DIR="${HOME}/.config"
readonly BACKUP_DIR="${HOME}/linuxtoolbox"
export DOTFILES_DIR CONFIG_DIR BACKUP_DIR

# ==============================================================================
# Initialization Side-effects
# ==============================================================================

# Ensure backup dir exists
if [[ ! -d "$BACKUP_DIR" ]]; then
    mkdir -p "$BACKUP_DIR"
fi

# Ensure log file is writable
if [[ "$LOG_TO_FILE" == "true" ]]; then
    mkdir -p "$(dirname "$LOG_FILE")"
    touch "$LOG_FILE" 2>/dev/null || LOG_TO_FILE="false"
fi

# Export functions so sub-shells can use them
export -f log::trace log::debug log::info log::success log::warning log::error log::fatal
export -f log::section log::banner log::box log::substep log::kvp
export -f log::ok log::fail log::warn log::bullet log::spinner log::progress
export -f command_exists pkg::exists pkg::version get_version check_command
export -f info success warning error substep_info substep_success substep_error
export -f log_trace log_debug log_info log_success log_warning log_error log_fatal
export LOG_RED LOG_YELLOW LOG_GREEN LOG_BLUE LOG_MAGENTA LOG_CYAN LOG_WHITE LOG_BOLD LOG_NC

readonly CORE_LOADED=true
export CORE_LOADED
