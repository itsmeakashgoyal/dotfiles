#!/usr/bin/env bash
#  ██                     ████  █████     ██
# ░██                    ░██░  ░░███     ░██
# ░██      ██████   ███████░   ███████  ░██
# ░██████ ███░░███ ░░░███░    ░░░███░   ░██████
# ░██░░░██░███████   ░███       ░███    ░██░░░██
# ░██  ░██░███░░░    ░███ ███   ░███ ███░██  ░██
# ░██  ░██░░██████   ░░█████    ░░█████ ░██  ░██
# ░░   ░░  ░░░░░░     ░░░░░      ░░░░░  ░░   ░░
#
#  ▓▓▓▓▓▓▓▓▓▓
# ░▓ author ▓ Akash Goyal
# ░▓ file   ▓ scripts/verification/health_check.sh
# ░▓▓▓▓▓▓▓▓▓▓
# ░░░░░░░░░░
#
#█▓▒░
# Quick Health Check Script
# Provides a fast overview of dotfiles installation status

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
# Note: Not using 'set -e' here because we want to continue checking even when items fail
set -uo pipefail

# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
ISSUES=0
WARNINGS=0

# ------------------------------------------------------------------------------
# Check Functions
# ------------------------------------------------------------------------------
check_status() {
    local name="$1"
    local condition="$2"
    local critical="${3:-false}"
    
    printf "  %-35s " "$name:"
    
    if eval "$condition"; then
        echo -e "${GREEN}✓ OK${NC}"
        return 0
    else
        if [[ "$critical" == "true" ]]; then
            echo -e "${RED}✗ MISSING${NC}"
            ((ISSUES++))
        else
            echo -e "${YELLOW}⚠ WARNING${NC}"
            ((WARNINGS++))
        fi
        return 0  # Return 0 to not trigger 'set -e' in other contexts
    fi
}

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# ------------------------------------------------------------------------------
# Quick Checks
# ------------------------------------------------------------------------------
run_health_checks() {
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  CORE COMPONENTS"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    check_status "Dotfiles Directory" "[[ -d '$HOME/dotfiles' ]]" true
    check_status "Helper Scripts" "[[ -f '$HOME/dotfiles/scripts/utils/_helper.sh' ]]" true
    check_status "Git" "command_exists git" true
    check_status "Homebrew" "command_exists brew" true
    
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  SHELL CONFIGURATION"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    check_status "Zsh" "command_exists zsh" true
    check_status "Zsh as Default Shell" "[[ '$SHELL' == *'zsh'* ]]" false
    check_status ".zshenv Symlink" "[[ -L '$HOME/.zshenv' ]]" true
    check_status "Oh My Posh" "command_exists oh-my-posh" false
    
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  NEOVIM SETUP"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    check_status "Neovim" "command_exists nvim" false
    check_status "Neovim Config Symlink" "[[ -L '$HOME/.config/nvim' ]]" false
    check_status "init.lua" "[[ -f '$HOME/.config/nvim/init.lua' ]]" false
    
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  GIT CONFIGURATION"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    check_status "Git Config" "[[ -f '$HOME/.config/git/config' ]] || [[ -f '$HOME/.gitconfig' ]] || [[ -f '$HOME/dotfiles/git/config' ]]" false
    check_status "Git User Name" "git config --global user.name >/dev/null 2>&1" false
    check_status "Git User Email" "git config --global user.email >/dev/null 2>&1" false
    
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  ESSENTIAL TOOLS"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    check_status "Tmux" "command_exists tmux" false
    check_status "fzf (Fuzzy Finder)" "command_exists fzf" false
    check_status "ripgrep" "command_exists rg" false
    check_status "bat" "command_exists bat" false
    check_status "eza" "command_exists eza" false
    check_status "zoxide" "command_exists zoxide" false
    
    echo ""
}

# ------------------------------------------------------------------------------
# Show Summary
# ------------------------------------------------------------------------------
show_summary() {
    local total_checks=$((ISSUES + WARNINGS + (22 - ISSUES - WARNINGS)))
    local health_pct=$(( (total_checks - ISSUES - WARNINGS) * 100 / total_checks ))
    
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  HEALTH CHECK SUMMARY"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    
    if [[ $ISSUES -eq 0 ]] && [[ $WARNINGS -eq 0 ]]; then
        echo -e "  ${GREEN}✓ System Health: EXCELLENT${NC}"
        echo "  All critical components are installed and configured."
    elif [[ $ISSUES -eq 0 ]]; then
        echo -e "  ${YELLOW}⚠ System Health: GOOD${NC}"
        echo "  Critical components OK, but $WARNINGS optional component(s) missing."
    else
        echo -e "  ${RED}✗ System Health: NEEDS ATTENTION${NC}"
        echo "  $ISSUES critical issue(s) and $WARNINGS warning(s) detected."
    fi
    
    echo ""
    echo "  Health Score: ${health_pct}%"
    echo ""
    
    if [[ $ISSUES -gt 0 ]]; then
        echo "  ${RED}⚠️  ACTION REQUIRED:${NC}"
        echo "  • Run: cd ~/dotfiles && make install"
        echo "  • Or: bash ~/dotfiles/install.sh"
        echo ""
    fi
    
    if [[ $WARNINGS -gt 0 ]]; then
        echo "  ${YELLOW}💡 OPTIONAL IMPROVEMENTS:${NC}"
        echo "  • Install missing tools with Homebrew"
        echo "  • Configure Git user settings"
        echo "  • Set Zsh as default shell: chsh -s \$(which zsh)"
        echo ""
    fi
    
    echo "  For detailed analysis, run:"
    echo "    bash ~/dotfiles/scripts/verification/verify_installation.sh"
    echo ""
    echo "  For system information, run:"
    echo "    bash ~/dotfiles/scripts/verification/system_info.sh"
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
}

# ------------------------------------------------------------------------------
# Main Function
# ------------------------------------------------------------------------------
main() {
    echo ""
    echo "╔═══════════════════════════════════════════════════╗"
    echo "║                                                   ║"
    echo "║         Dotfiles Quick Health Check              ║"
    echo "║                                                   ║"
    echo "╚═══════════════════════════════════════════════════╝"
    
    run_health_checks
    show_summary
    
    # Exit with appropriate code
    if [[ $ISSUES -gt 0 ]]; then
        exit 1
    else
        exit 0
    fi
}

# Run main
main

