#!/usr/bin/env bash
#               █████
#              ░░███
#  ████████   ░███ █████  ███████
# ░░███░░███ ███████░░███ ███░░███
#  ░███ ░███░░░███░  ░███░███ ░███
#  ░███ ░███  ░███   ░███░███ ░███
#  ░███████   ░░████ █████░░███████
#  ░███░░░     ░░░░ ░░░░░  ░░██░░░
#  ░███                    ███ ░███
#  █████                  ░░██████
# ░░░░░                    ░░░░░░
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
HELPER_FILE="${SCRIPT_DIR}/utils/_helper.sh"

if [[ ! -f "$HELPER_FILE" ]]; then
    echo "Error: Helper file not found at $HELPER_FILE" >&2
    exit 1
fi

source "$HELPER_FILE"
# Note: Not using 'set -e' here because we want to continue checking even when packages are missing
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
    info "Checking Homebrew..."
    echo ""
    
    if ! command_exists brew; then
        error "Homebrew is not installed!"
        echo ""
        echo "Install Homebrew with:"
        echo "  /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
        echo ""
        exit 1
    fi
    
    local brew_version=$(brew --version | head -n 1)
    substep_success "Homebrew found: $brew_version"
    
    # Check for updates
    echo ""
    substep_info "Checking for outdated packages..."
    local outdated=$(brew outdated 2>/dev/null)
    if [[ -z "$outdated" ]]; then
        substep_success "All packages are up to date!"
    else
        local count=$(echo "$outdated" | wc -l | tr -d ' ')
        warning "$count package(s) have updates available:"
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
        error "Brewfile not found at: $BREWFILE"
        exit 1
    fi
    
    info "Parsing Brewfile at: $BREWFILE"
    echo ""
}

# ------------------------------------------------------------------------------
# Check Formulae (CLI tools)
# ------------------------------------------------------------------------------
check_formulae() {
    section_header "HOMEBREW FORMULAE (CLI TOOLS)"
    
    # Extract formulae from Brewfile
    local formulae=$(grep "^brew " "$BREWFILE" | sed 's/brew "\(.*\)".*/\1/' | sed "s/brew '\(.*\)'.*/\1/")
    
    if [[ -z "$formulae" ]]; then
        substep_info "No formulae specified in Brewfile"
        return
    fi
    
    local total=$(echo "$formulae" | wc -l | tr -d ' ')
    substep_info "Checking $total formulae..."
    echo ""
    
    while IFS= read -r formula; do
        [[ -z "$formula" ]] && continue
        
        printf "  %-40s " "$formula:"
        
        if brew list --formula "$formula" &>/dev/null; then
            local version=$(brew list --versions "$formula" 2>/dev/null | awk '{print $2}' || echo "")
            echo -e "${GREEN}✓ Installed${NC} ${version}"
            ((INSTALLED_COUNT++))
        else
            echo -e "${RED}✗ Missing${NC}"
            ((MISSING_COUNT++))
        fi
    done <<< "$formulae"
    
    echo ""
}

# ------------------------------------------------------------------------------
# Check Casks (GUI Applications)
# ------------------------------------------------------------------------------
check_casks() {
    section_header "HOMEBREW CASKS (GUI APPLICATIONS)"
    
    # Only check casks on macOS
    if [[ "$OS_TYPE" != "Darwin" ]]; then
        substep_info "Casks are only available on macOS - skipping"
        return
    fi
    
    # Extract casks from Brewfile
    local casks=$(grep "^cask " "$BREWFILE" | sed 's/cask "\(.*\)".*/\1/' | sed "s/cask '\(.*\)'.*/\1/")
    
    if [[ -z "$casks" ]]; then
        substep_info "No casks specified in Brewfile"
        return
    fi
    
    local total=$(echo "$casks" | wc -l | tr -d ' ')
    substep_info "Checking $total casks..."
    echo ""
    
    while IFS= read -r cask; do
        [[ -z "$cask" ]] && continue
        
        printf "  %-40s " "$cask:"
        
        if brew list --cask "$cask" &>/dev/null; then
            local version=$(brew list --versions --cask "$cask" 2>/dev/null | awk '{print $2}' || echo "")
            echo -e "${GREEN}✓ Installed${NC} ${version}"
            ((INSTALLED_COUNT++))
        else
            echo -e "${RED}✗ Missing${NC}"
            ((MISSING_COUNT++))
        fi
    done <<< "$casks"
    
    echo ""
}

# ------------------------------------------------------------------------------
# Check Taps
# ------------------------------------------------------------------------------
check_taps() {
    section_header "HOMEBREW TAPS"
    
    # Extract taps from Brewfile
    local taps=$(grep "^tap " "$BREWFILE" | sed 's/tap "\(.*\)".*/\1/' | sed "s/tap '\(.*\)'.*/\1/")
    
    if [[ -z "$taps" ]]; then
        substep_info "No taps specified in Brewfile"
        return
    fi
    
    local total=$(echo "$taps" | wc -l | tr -d ' ')
    substep_info "Checking $total taps..."
    echo ""
    
    while IFS= read -r tap; do
        [[ -z "$tap" ]] && continue
        
        printf "  %-40s " "$tap:"
        
        if brew tap | grep -q "^$tap$"; then
            echo -e "${GREEN}✓ Tapped${NC}"
            ((INSTALLED_COUNT++))
        else
            echo -e "${RED}✗ Not tapped${NC}"
            ((MISSING_COUNT++))
        fi
    done <<< "$taps"
    
    echo ""
}

# ------------------------------------------------------------------------------
# Show Summary
# ------------------------------------------------------------------------------
show_summary() {
    section_header "SUMMARY"
    
    local total=$((INSTALLED_COUNT + MISSING_COUNT))
    local install_pct=0
    
    if [[ $total -gt 0 ]]; then
        install_pct=$((INSTALLED_COUNT * 100 / total))
    fi
    
    echo -e "  ${GREEN}✓ Installed:${NC}     $INSTALLED_COUNT / $total"
    echo -e "  ${RED}✗ Missing:${NC}       $MISSING_COUNT / $total"
    echo ""
    echo "  Installation Coverage: ${install_pct}%"
    echo ""
    
    if [[ $MISSING_COUNT -gt 0 ]]; then
        warning "Some packages are missing!"
        echo ""
        echo "  To install missing packages, run:"
        echo "    cd ~/dotfiles"
        echo "    brew bundle --file=packages/Brewfile"
        echo ""
    else
        success "All packages from Brewfile are installed!"
    fi
    
    echo ""
}

# ------------------------------------------------------------------------------
# Check for Extra Packages
# ------------------------------------------------------------------------------
check_extra_packages() {
    section_header "ADDITIONAL INSTALLED PACKAGES"
    
    substep_info "Checking for packages not in Brewfile..."
    echo ""
    
    # Get all installed formulae
    local all_installed=$(brew list --formula 2>/dev/null)
    local brewfile_formulae=$(grep "^brew " "$BREWFILE" | sed 's/brew "\(.*\)".*/\1/' | sed "s/brew '\(.*\)'.*/\1/")
    
    # Find extras
    local extras=""
    while IFS= read -r installed; do
        if ! echo "$brewfile_formulae" | grep -q "^$installed$"; then
            extras="$extras$installed"$'\n'
            ((EXTRA_COUNT++))
        fi
    done <<< "$all_installed"
    
    if [[ $EXTRA_COUNT -gt 0 ]]; then
        substep_info "$EXTRA_COUNT package(s) installed but not in Brewfile:"
        echo ""
        echo "$extras" | head -n 20 | sed 's/^/    • /'
        if [[ $EXTRA_COUNT -gt 20 ]]; then
            echo "    ... and $((EXTRA_COUNT - 20)) more"
        fi
        echo ""
        substep_info "These were likely installed manually or as dependencies"
    else
        substep_success "No extra packages found"
    fi
    
    echo ""
}

# ------------------------------------------------------------------------------
# Show Recommendations
# ------------------------------------------------------------------------------
show_recommendations() {
    info "Recommendations"
    echo ""
    
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
    
    info "Exporting current Homebrew packages to: $output_file"
    
    brew bundle dump --file="$output_file" --force
    
    success "Brewfile exported successfully!"
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
            # No arguments - proceed with checks
            ;;
        *)
            error "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
    
    echo ""
    echo "╔═══════════════════════════════════════════════════╗"
    echo "║                                                   ║"
    echo "║         Package Verification Tool                ║"
    echo "║                                                   ║"
    echo "╚═══════════════════════════════════════════════════╝"
    echo ""
    
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

# ------------------------------------------------------------------------------
# Utility Functions
# ------------------------------------------------------------------------------
section_header() {
    local title="$1"
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  $title"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
}

# Run main
main "$@"

