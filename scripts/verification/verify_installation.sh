#!/usr/bin/env bash
#                    ██  ████
#                   ░░  ░░███
#  █████ █████  ██████  ░███████ █████ ████
# ░░███ ░░███  ███░░███ ░███░░███░░███ ░███
#  ░███  ░███ ░███████  ░███ ░░░  ░███ ░███
#  ░░███ ███  ░███░░░   ░███      ░███ ░███
#   ░░█████   ░░██████  █████     ░░███████
#    ░░░░░     ░░░░░░  ░░░░░       ░░░░░███
#                                   ███ ░███
#                                  ░░██████
#                                   ░░░░░░
#
#  ▓▓▓▓▓▓▓▓▓▓
# ░▓ author ▓ Akash Goyal
# ░▓ file   ▓ scripts/verification/verify_installation.sh
# ░▓▓▓▓▓▓▓▓▓▓
# ░░░░░░░░░░
#
#█▓▒░
# Dotfiles Installation Verification Script
# Verifies that all components are installed and configured correctly

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
# Initialize Counters
# ------------------------------------------------------------------------------
PASS_COUNT=0
WARN_COUNT=0
FAIL_COUNT=0
TOTAL_COUNT=0

# ------------------------------------------------------------------------------
# Check Functions
# ------------------------------------------------------------------------------
check_item() {
    local name="$1"
    local status="$2"
    local message="$3"
    
    ((TOTAL_COUNT++))
    printf "  %-45s " "$name:"
    
    if [[ "$status" == "pass" ]]; then
        echo -e "${GREEN}✓ PASS${NC} ${message}"
        ((PASS_COUNT++))
    elif [[ "$status" == "warn" ]]; then
        echo -e "${YELLOW}⚠ WARN${NC} ${message}"
        ((WARN_COUNT++))
    else
        echo -e "${RED}✗ FAIL${NC} ${message}"
        ((FAIL_COUNT++))
    fi
}

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

get_version() {
    local cmd="$1"
    local version_flag="${2:---version}"
    
    if command_exists "$cmd"; then
        $cmd $version_flag 2>&1 | head -n 1 | grep -oE '[0-9]+\.[0-9]+(\.[0-9]+)?' | head -n 1 || echo "installed"
    else
        echo "not found"
    fi
}

# ------------------------------------------------------------------------------
# Core Tools Verification
# ------------------------------------------------------------------------------
verify_core_tools() {
    info "Verifying Core Tools..."
    echo ""
    
    # Git
    if command_exists git; then
        local version=$(get_version git)
        check_item "Git" "pass" "v${version}"
    else
        check_item "Git" "fail" "Not installed"
    fi
    
    # Curl
    if command_exists curl; then
        local version=$(get_version curl)
        check_item "Curl" "pass" "v${version}"
    else
        check_item "Curl" "fail" "Not installed"
    fi
    
    # Wget
    if command_exists wget; then
        local version=$(get_version wget)
        check_item "Wget" "pass" "v${version}"
    else
        check_item "Wget" "warn" "Not installed (optional)"
    fi
    
    # Make
    if command_exists make; then
        local version=$(get_version make)
        check_item "Make" "pass" "v${version}"
    else
        check_item "Make" "warn" "Not installed"
    fi
    
    echo ""
}

# ------------------------------------------------------------------------------
# Shell Verification
# ------------------------------------------------------------------------------
verify_shell() {
    info "Verifying Shell Configuration..."
    echo ""
    
    # Zsh
    if command_exists zsh; then
        local version=$(get_version zsh)
        check_item "Zsh" "pass" "v${version}"
    else
        check_item "Zsh" "fail" "Not installed"
    fi
    
    # Current shell
    if [[ "$SHELL" == *"zsh"* ]]; then
        check_item "Default Shell" "pass" "Zsh"
    else
        check_item "Default Shell" "warn" "$SHELL (expected zsh)"
    fi
    
    # .zshenv
    if [[ -L "$HOME/.zshenv" ]]; then
        check_item ".zshenv Symlink" "pass" "Linked"
    elif [[ -f "$HOME/.zshenv" ]]; then
        check_item ".zshenv" "warn" "Exists but not symlinked"
    else
        check_item ".zshenv" "fail" "Not found"
    fi
    
    # Oh My Posh
    if command_exists oh-my-posh; then
        local version=$(get_version oh-my-posh)
        check_item "Oh My Posh" "pass" "v${version}"
    else
        check_item "Oh My Posh" "warn" "Not installed"
    fi
    
    # Zsh plugins
    local zsh_plugins_dir="${HOME}/.config/zsh"
    if [[ -d "$zsh_plugins_dir" ]]; then
        check_item "Zsh Plugins Directory" "pass" "Exists"
    else
        check_item "Zsh Plugins Directory" "warn" "Not found at $zsh_plugins_dir"
    fi
    
    echo ""
}

# ------------------------------------------------------------------------------
# Neovim Verification
# ------------------------------------------------------------------------------
verify_neovim() {
    info "Verifying Neovim Setup..."
    echo ""
    
    # Neovim
    if command_exists nvim; then
        local version=$(get_version nvim)
        check_item "Neovim" "pass" "v${version}"
    else
        check_item "Neovim" "fail" "Not installed"
    fi
    
    # Neovim config
    if [[ -L "$HOME/.config/nvim" ]]; then
        check_item "Neovim Config Symlink" "pass" "Linked"
    elif [[ -d "$HOME/.config/nvim" ]]; then
        check_item "Neovim Config" "warn" "Exists but not symlinked"
    else
        check_item "Neovim Config" "fail" "Not found"
    fi
    
    # init.lua
    if [[ -f "$HOME/.config/nvim/init.lua" ]]; then
        check_item "init.lua" "pass" "Found"
    else
        check_item "init.lua" "fail" "Not found"
    fi
    
    # Lazy.nvim (plugin manager)
    local lazy_path="${HOME}/.local/share/nvim/lazy/lazy.nvim"
    if [[ -d "$lazy_path" ]]; then
        check_item "Lazy.nvim Plugin Manager" "pass" "Installed"
    else
        check_item "Lazy.nvim Plugin Manager" "warn" "Not found - run :Lazy sync in nvim"
    fi
    
    echo ""
}

# ------------------------------------------------------------------------------
# Git Configuration Verification
# ------------------------------------------------------------------------------
verify_git() {
    info "Verifying Git Configuration..."
    echo ""
    
    # Git config (at dotfiles location)
    if [[ -f "$HOME/dotfiles/git/config" ]]; then
        check_item "Git Config" "pass" "Found at ~/dotfiles/git/config"
    else
        check_item "Git Config" "warn" "Not found at ~/dotfiles/git/config"
    fi
    
    # Git user name
    if git config --global user.name >/dev/null 2>&1; then
        local username=$(git config --global user.name)
        check_item "Git User Name" "pass" "$username"
    else
        check_item "Git User Name" "warn" "Not set"
    fi
    
    # Git user email
    if git config --global user.email >/dev/null 2>&1; then
        local email=$(git config --global user.email)
        check_item "Git User Email" "pass" "$email"
    else
        check_item "Git User Email" "warn" "Not set"
    fi
    
    # Git delta (diff viewer)
    if command_exists delta; then
        local version=$(get_version delta)
        check_item "Git Delta" "pass" "v${version}"
    else
        check_item "Git Delta" "warn" "Not installed (optional)"
    fi
    
    # Lazygit
    if command_exists lazygit; then
        local version=$(get_version lazygit)
        check_item "Lazygit" "pass" "v${version}"
    else
        check_item "Lazygit" "warn" "Not installed (optional)"
    fi
    
    echo ""
}

# ------------------------------------------------------------------------------
# Tmux Verification
# ------------------------------------------------------------------------------
verify_tmux() {
    info "Verifying Tmux Setup..."
    echo ""
    
    # Tmux
    if command_exists tmux; then
        local version=$(get_version tmux -V)
        check_item "Tmux" "pass" "v${version}"
    else
        check_item "Tmux" "warn" "Not installed"
    fi
    
    # Tmux config
    if [[ -L "$HOME/.config/tmux" ]]; then
        check_item "Tmux Config Symlink" "pass" "Linked"
    elif [[ -d "$HOME/.config/tmux" ]]; then
        check_item "Tmux Config" "warn" "Exists but not symlinked"
    else
        check_item "Tmux Config" "warn" "Not found"
    fi
    
    # tmux.conf
    if [[ -f "$HOME/.config/tmux/tmux.conf" ]]; then
        check_item "tmux.conf" "pass" "Found"
    else
        check_item "tmux.conf" "warn" "Not found"
    fi
    
    echo ""
}

# ------------------------------------------------------------------------------
# Modern CLI Tools Verification
# ------------------------------------------------------------------------------
verify_modern_tools() {
    info "Verifying Modern CLI Tools..."
    echo ""
    
    # bat (cat replacement)
    if command_exists bat; then
        local version=$(get_version bat)
        check_item "bat (cat replacement)" "pass" "v${version}"
    else
        check_item "bat" "warn" "Not installed"
    fi
    
    # eza (ls replacement)
    if command_exists eza; then
        local version=$(get_version eza)
        check_item "eza (ls replacement)" "pass" "v${version}"
    else
        check_item "eza" "warn" "Not installed"
    fi
    
    # ripgrep (grep replacement)
    if command_exists rg; then
        local version=$(get_version rg)
        check_item "ripgrep (grep replacement)" "pass" "v${version}"
    else
        check_item "ripgrep" "warn" "Not installed"
    fi
    
    # fd (find replacement)
    if command_exists fd; then
        local version=$(get_version fd)
        check_item "fd (find replacement)" "pass" "v${version}"
    else
        check_item "fd" "warn" "Not installed"
    fi
    
    # fzf (fuzzy finder)
    if command_exists fzf; then
        local version=$(get_version fzf)
        check_item "fzf (fuzzy finder)" "pass" "v${version}"
    else
        check_item "fzf" "warn" "Not installed"
    fi
    
    # zoxide (cd replacement)
    if command_exists zoxide; then
        local version=$(get_version zoxide)
        check_item "zoxide (cd replacement)" "pass" "v${version}"
    else
        check_item "zoxide" "warn" "Not installed"
    fi
    
    # jq (JSON processor)
    if command_exists jq; then
        local version=$(get_version jq)
        check_item "jq (JSON processor)" "pass" "v${version}"
    else
        check_item "jq" "warn" "Not installed"
    fi
    
    echo ""
}

# ------------------------------------------------------------------------------
# Development Tools Verification
# ------------------------------------------------------------------------------
verify_dev_tools() {
    info "Verifying Development Tools..."
    echo ""
    
    # Homebrew
    if command_exists brew; then
        local version=$(get_version brew)
        check_item "Homebrew" "pass" "v${version}"
    else
        check_item "Homebrew" "fail" "Not installed"
    fi
    
    # Python
    if command_exists python3; then
        local version=$(get_version python3)
        check_item "Python3" "pass" "v${version}"
    else
        check_item "Python3" "warn" "Not installed"
    fi
    
    # Node.js
    if command_exists node; then
        local version=$(get_version node)
        check_item "Node.js" "pass" "v${version}"
    else
        check_item "Node.js" "warn" "Not installed"
    fi
    
    # npm
    if command_exists npm; then
        local version=$(get_version npm)
        check_item "npm" "pass" "v${version}"
    else
        check_item "npm" "warn" "Not installed"
    fi
    
    # gh (GitHub CLI)
    if command_exists gh; then
        local version=$(get_version gh)
        check_item "GitHub CLI" "pass" "v${version}"
    else
        check_item "GitHub CLI" "warn" "Not installed"
    fi
    
    echo ""
}

# ------------------------------------------------------------------------------
# Symlinks Verification
# ------------------------------------------------------------------------------
verify_symlinks() {
    info "Verifying Dotfiles Symlinks..."
    echo ""
    
    declare -A symlinks=(
        ["$HOME/.zshenv"]="${HOME}/dotfiles/zsh/.zshenv"
        ["$HOME/.config/nvim"]="${HOME}/dotfiles/nvim"
        ["$HOME/.config/tmux"]="${HOME}/dotfiles/tmux"
    )
    
    for link_path in "${!symlinks[@]}"; do
        local target="${symlinks[$link_path]}"
        local link_name=$(basename "$link_path")
        
        if [[ -L "$link_path" ]]; then
            local actual_target=$(readlink "$link_path")
            if [[ "$actual_target" == "$target" ]]; then
                check_item "$link_name" "pass" "Correctly linked"
            else
                check_item "$link_name" "warn" "Points to $actual_target"
            fi
        elif [[ -e "$link_path" ]]; then
            check_item "$link_name" "warn" "Exists but not a symlink"
        else
            check_item "$link_name" "fail" "Not found"
        fi
    done
    
    echo ""
}

# ------------------------------------------------------------------------------
# Directory Structure Verification
# ------------------------------------------------------------------------------
verify_directories() {
    info "Verifying Directory Structure..."
    echo ""
    
    declare -a required_dirs=(
        "$HOME/dotfiles"
        "$HOME/dotfiles/zsh"
        "$HOME/dotfiles/nvim"
        "$HOME/dotfiles/tmux"
        "$HOME/dotfiles/scripts"
        "$HOME/.config"
    )
    
    for dir in "${required_dirs[@]}"; do
        local dir_name=$(basename "$dir")
        if [[ -d "$dir" ]]; then
            check_item "$dir_name/" "pass" "Exists"
        else
            check_item "$dir_name/" "fail" "Not found at $dir"
        fi
    done
    
    echo ""
}

# ------------------------------------------------------------------------------
# Generate Summary
# ------------------------------------------------------------------------------
generate_summary() {
    local pass_pct=$((PASS_COUNT * 100 / TOTAL_COUNT))
    local score_color="${RED}"
    local score_status="POOR"
    
    if [[ $pass_pct -ge 90 ]]; then
        score_color="${GREEN}"
        score_status="EXCELLENT"
    elif [[ $pass_pct -ge 75 ]]; then
        score_color="${GREEN}"
        score_status="GOOD"
    elif [[ $pass_pct -ge 60 ]]; then
        score_color="${YELLOW}"
        score_status="FAIR"
    fi
    
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  INSTALLATION VERIFICATION SUMMARY"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo -e "  ${GREEN}✓ Passed:${NC}       $PASS_COUNT / $TOTAL_COUNT"
    echo -e "  ${YELLOW}⚠ Warnings:${NC}     $WARN_COUNT / $TOTAL_COUNT"
    echo -e "  ${RED}✗ Failed:${NC}       $FAIL_COUNT / $TOTAL_COUNT"
    echo ""
    echo -e "  Installation Score: ${score_color}${pass_pct}% - ${score_status}${NC}"
    echo ""
    
    if [[ $FAIL_COUNT -gt 0 ]]; then
        echo -e "  ${RED}⚠️  $FAIL_COUNT critical issues found!${NC}"
        echo "  Consider running: cd ~/dotfiles && make install"
    elif [[ $WARN_COUNT -gt 0 ]]; then
        echo -e "  ${YELLOW}⚠️  $WARN_COUNT warnings - optional improvements available${NC}"
    else
        echo -e "  ${GREEN}✓ All checks passed! Your dotfiles are properly installed.${NC}"
    fi
    
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
}

# ------------------------------------------------------------------------------
# Show Next Steps
# ------------------------------------------------------------------------------
show_next_steps() {
    if [[ $FAIL_COUNT -gt 0 ]] || [[ $WARN_COUNT -gt 5 ]]; then
        info "Recommended Next Steps"
        echo ""
        echo "  1. Review failed checks above"
        echo "  2. Reinstall if needed: cd ~/dotfiles && make install"
        echo "  3. Run this verification again after fixes"
        echo "  4. For detailed system info: bash ~/dotfiles/scripts/verification/system_info.sh"
        echo ""
    fi
}

# ------------------------------------------------------------------------------
# Main Function
# ------------------------------------------------------------------------------
main() {
    log_message "Installation verification started"
    
    echo ""
    echo "╔═══════════════════════════════════════════════════╗"
    echo "║                                                   ║"
    echo "║    Dotfiles Installation Verification Tool       ║"
    echo "║                                                   ║"
    echo "╚═══════════════════════════════════════════════════╝"
    echo ""
    echo "  Verifying your dotfiles installation..."
    echo "  This will check all components and configurations."
    echo ""
    
    # Run all verification checks
    verify_directories
    verify_core_tools
    verify_shell
    verify_neovim
    verify_git
    verify_tmux
    verify_modern_tools
    verify_dev_tools
    verify_symlinks
    
    # Generate summary
    generate_summary
    
    # Show next steps if needed
    show_next_steps
    
    # Save report
    local report_file="/tmp/dotfiles_verification_$(date +%Y%m%d_%H%M%S).txt"
    {
        echo "Dotfiles Installation Verification Report"
        echo "Generated: $(date)"
        echo "User: $USER"
        echo "Hostname: $(hostname)"
        echo "OS: $OS_TYPE"
        echo ""
        echo "Summary: $PASS_COUNT passed, $WARN_COUNT warnings, $FAIL_COUNT failed"
        echo "Total Checks: $TOTAL_COUNT"
    } > "$report_file"
    
    substep_info "Report saved to: $report_file"
    
    log_message "Installation verification completed"
    
    # Exit with appropriate code
    if [[ $FAIL_COUNT -gt 0 ]]; then
        exit 1
    else
        exit 0
    fi
}

# Run main
main

