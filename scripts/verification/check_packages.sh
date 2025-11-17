#!/usr/bin/env bash
#
#  ▓▓▓▓▓▓▓▓▓▓
# ░▓ author ▓ Akash Goyal
# ░▓ file   ▓ scripts/verification/check_packages.sh
# ░▓▓▓▓▓▓▓▓▓▓
# ░░░░░░░░░░
#
#█▓▒░
# Package Verification Script
# Checks installed packages against Brewfile and shows status

# ------------------------------------------------------------------------------
# Load Helper Functions
# ------------------------------------------------------------------------------
SCRIPT_DIR="${HOME}/dotfiles/scripts"
LOGGER_FILE="${SCRIPT_DIR}/utils/_logger.sh"

if [[ ! -f "$LOGGER_FILE" ]]; then
    echo "Error: Logger file not found at $LOGGER_FILE" >&2
    exit 1
fi

source "$LOGGER_FILE"
set -uo pipefail

# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
BREWFILE="${HOME}/dotfiles/packages/Brewfile"
INSTALLED_COUNT=0
MISSING_COUNT=0
EXTRA_COUNT=0

# ------------------------------------------------------------------------------
# Helper Functions
# ------------------------------------------------------------------------------
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# ------------------------------------------------------------------------------
# Check Homebrew
# ------------------------------------------------------------------------------
check_homebrew() {
    log_banner "Checking Homebrew"
    
    if ! command_exists brew; then
        log_error "Homebrew is not installed!"
        echo ""
        echo "Install Homebrew with:"
        echo "  /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
        echo ""
        exit 1
    fi
    
    local brew_version=$(brew --version | head -n 1)
    log_ok "Homebrew found: $brew_version"
    
    echo ""
    log_substep "Checking for outdated packages..."
    local outdated=$(brew outdated 2>/dev/null)
    if [[ -z "$outdated" ]]; then
        log_ok "All packages are up to date!"
    else
        local count=$(echo "$outdated" | wc -l | tr -d ' ')
        log_warning "$count package(s) have updates available:"
        echo "$outdated" | sed 's/^/    • /'
        echo ""
        echo "  Run 'brew upgrade' to update all packages"
    fi
    echo ""
}

# ------------------------------------------------------------------------------
# Parse Brewfile
# ------------------------------------------------------------------------------
parse_brewfile() {
    if [[ ! -f "$BREWFILE" ]]; then
        log_error "Brewfile not found at: $BREWFILE"
        exit 1
    fi
    
    log_banner "Parsing Brewfile at: $BREWFILE"
}

# ------------------------------------------------------------------------------
# Check Formulae (CLI tools)
# ------------------------------------------------------------------------------
check_formulae() {
    log_section "HOMEBREW FORMULAE (CLI TOOLS)"
    
    local formulae=$(grep "^brew " "$BREWFILE" | sed 's/brew "\(.*\)".*/\1/' | sed "s/brew '\(.*\)'.*/\1/")
    
    if [[ -z "$formulae" ]]; then
        log_substep "No formulae specified in Brewfile"
        return
    fi
    
    local total=$(echo "$formulae" | wc -l | tr -d ' ')
    log_substep "Checking $total formulae..."
    echo ""
    
    while IFS= read -r formula; do
        [[ -z "$formula" ]] && continue
        
        printf "  %-40s " "$formula:"
        
        if brew list --formula "$formula" &>/dev/null; then
            local version=$(brew list --versions "$formula" 2>/dev/null | awk '{print $2}' || echo "")
            echo -e "${LOG_GREEN}✓ Installed${LOG_NC} ${version}"
            ((INSTALLED_COUNT++))
        else
            echo -e "${LOG_RED}✗ Missing${LOG_NC}"
            ((MISSING_COUNT++))
        fi
    done <<< "$formulae"
    
    echo ""
}

# ------------------------------------------------------------------------------
# Check Casks (GUI Applications)
# ------------------------------------------------------------------------------
check_casks() {
    log_section "HOMEBREW CASKS (GUI APPLICATIONS)"
    
    readonly OS_TYPE=$(uname)
    if [[ "$OS_TYPE" != "Darwin" ]]; then
        log_substep "Casks are only available on macOS - skipping"
        return
    fi
    
    local casks=$(grep "^cask " "$BREWFILE" | sed 's/cask "\(.*\)".*/\1/' | sed "s/cask '\(.*\)'.*/\1/")
    
    if [[ -z "$casks" ]]; then
        log_substep "No casks specified in Brewfile"
        return
    fi
    
    local total=$(echo "$casks" | wc -l | tr -d ' ')
    log_substep "Checking $total casks..."
    echo ""
    
    while IFS= read -r cask; do
        [[ -z "$cask" ]] && continue
        
        printf "  %-40s " "$cask:"
        
        if brew list --cask "$cask" &>/dev/null; then
            local version=$(brew list --versions --cask "$cask" 2>/dev/null | awk '{print $2}' || echo "")
            echo -e "${LOG_GREEN}✓ Installed${LOG_NC} ${version}"
            ((INSTALLED_COUNT++))
        else
            echo -e "${LOG_RED}✗ Missing${LOG_NC}"
            ((MISSING_COUNT++))
        fi
    done <<< "$casks"
    
    echo ""
}

# ------------------------------------------------------------------------------
# Check Taps
# ------------------------------------------------------------------------------
check_taps() {
    log_section "HOMEBREW TAPS"
    
    local taps=$(grep "^tap " "$BREWFILE" | sed 's/tap "\(.*\)".*/\1/' | sed "s/tap '\(.*\)'.*/\1/")
    
    if [[ -z "$taps" ]]; then
        log_substep "No taps specified in Brewfile"
        return
    fi
    
    local total=$(echo "$taps" | wc -l | tr -d ' ')
    log_substep "Checking $total taps..."
    echo ""
    
    while IFS= read -r tap; do
        [[ -z "$tap" ]] && continue
        
        printf "  %-40s " "$tap:"
        
        if brew tap | grep -q "^$tap$"; then
            echo -e "${LOG_GREEN}✓ Tapped${LOG_NC}"
            ((INSTALLED_COUNT++))
        else
            echo -e "${LOG_RED}✗ Not tapped${LOG_NC}"
            ((MISSING_COUNT++))
        fi
    done <<< "$taps"
    
    echo ""
}

# ------------------------------------------------------------------------------
# Show Summary
# ------------------------------------------------------------------------------
show_summary() {
    log_section "SUMMARY"
    
    local total=$((INSTALLED_COUNT + MISSING_COUNT))
    local install_pct=0
    
    if [[ $total -gt 0 ]]; then
        install_pct=$((INSTALLED_COUNT * 100 / total))
    fi
    
    echo -e "  ${LOG_GREEN}✓ Installed:${LOG_NC}     $INSTALLED_COUNT / $total"
    echo -e "  ${LOG_RED}✗ Missing:${LOG_NC}       $MISSING_COUNT / $total"
    echo ""
    echo "  Installation Coverage: ${install_pct}%"
    echo ""
    
    if [[ $MISSING_COUNT -gt 0 ]]; then
        log_warning "Some packages are missing!"
        echo ""
        echo "  To install missing packages, run:"
        echo "    cd ~/dotfiles"
        echo "    brew bundle --file=packages/Brewfile"
        echo ""
    else
        log_success "All packages from Brewfile are installed!"
    fi
    
    echo ""
}

# ------------------------------------------------------------------------------
# Check for Extra Packages
# ------------------------------------------------------------------------------
check_extra_packages() {
    log_section "ADDITIONAL INSTALLED PACKAGES"
    
    log_substep "Checking for packages not in Brewfile..."
    echo ""
    
    local all_installed=$(brew list --formula 2>/dev/null)
    local brewfile_formulae=$(grep "^brew " "$BREWFILE" | sed 's/brew "\(.*\)".*/\1/' | sed "s/brew '\(.*\)'.*/\1/")
    
    local extras=""
    while IFS= read -r installed; do
        if ! echo "$brewfile_formulae" | grep -q "^$installed$"; then
            extras="$extras$installed"$'\n'
            ((EXTRA_COUNT++))
        fi
    done <<< "$all_installed"
    
    if [[ $EXTRA_COUNT -gt 0 ]]; then
        log_substep "$EXTRA_COUNT package(s) installed but not in Brewfile:"
        echo ""
        echo "$extras" | head -n 20 | sed 's/^/    • /'
        if [[ $EXTRA_COUNT -gt 20 ]]; then
            echo "    ... and $((EXTRA_COUNT - 20)) more"
        fi
        echo ""
        log_substep "These were likely installed manually or as dependencies"
    else
        log_ok "No extra packages found"
    fi
    
    echo ""
}

# ------------------------------------------------------------------------------
# Show Recommendations
# ------------------------------------------------------------------------------
show_recommendations() {
    log_banner "Recommendations"
    
    if [[ $MISSING_COUNT -gt 0 ]]; then
        echo "  1. Install missing packages: brew bundle --file=~/dotfiles/packages/Brewfile"
    fi
    
    echo "  2. Keep packages updated: brew update && brew upgrade"
    echo "  3. Clean up old versions: brew cleanup"
    echo "  4. Check for issues: brew doctor"
    
    if [[ $EXTRA_COUNT -gt 20 ]]; then
        echo "  5. Review extra packages and consider adding important ones to Brewfile"
    fi
    
    echo ""
    echo "  For system diagnostics, run:"
    echo "    bash ~/dotfiles/scripts/verification/system_info.sh"
    echo ""
}

# ------------------------------------------------------------------------------
# Export Brewfile
# ------------------------------------------------------------------------------
export_brewfile() {
    local output_file="${1:-$HOME/Brewfile.backup}"
    
    log_info "Exporting current Homebrew packages to: $output_file"
    
    brew bundle dump --file="$output_file" --force
    
    log_success "Brewfile exported successfully!"
    echo ""
    echo "  To use this Brewfile:"
    echo "    brew bundle --file=$output_file"
    echo ""
}

# ------------------------------------------------------------------------------
# Main Function
# ------------------------------------------------------------------------------
main() {
    # Parse arguments
    case "${1:-}" in
        --export)
            export_brewfile "${2:-$HOME/Brewfile.backup}"
            exit 0
            ;;
        --help|-h)
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Check installed packages against Brewfile."
            echo ""
            echo "Options:"
            echo "  --export [FILE]  Export current packages to Brewfile"
            echo "  --help,-h        Show this help message"
            echo ""
            exit 0
            ;;
        "")
            ;;
        *)
            log_error "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
    
    log_box "Package Verification Tool"
    
    check_homebrew
    parse_brewfile
    check_taps
    check_formulae
    check_casks
    show_summary
    check_extra_packages
    show_recommendations
    
    # Exit with appropriate code
    if [[ $MISSING_COUNT -gt 0 ]]; then
        exit 1
    else
        exit 0
    fi
}

main "$@"

