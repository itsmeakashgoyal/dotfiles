#!/usr/bin/env bash
#   ██                ██
#  ░░                ░░
#   ████  ███████   ██████  ██████
#  ░░███ ░░███░░███ ███░░███ ███░░███
#   ░███  ░███ ░███░███ ░░ ░███ ░███
#   ░███  ░███ ░███░███    ░███ ░███
#   █████ ████ █████░░██████░░██████
#  ░░░░░ ░░░░ ░░░░░  ░░░░░░  ░░░░░░
#
#  ▓▓▓▓▓▓▓▓▓▓
# ░▓ author ▓ Akash Goyal
# ░▓ file   ▓ scripts/verification/system_info.sh
# ░▓▓▓▓▓▓▓▓▓▓
# ░░░░░░░░░░
#
#█▓▒░
# System Information and Diagnostic Script
# Displays comprehensive system information for troubleshooting

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
set -euo pipefail

# ------------------------------------------------------------------------------
# Helper Functions
# ------------------------------------------------------------------------------
section_header() {
    local title="$1"
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  $title"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
}

info_line() {
    local label="$1"
    local value="$2"
    printf "  %-30s : %s\n" "$label" "$value"
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
        echo "not installed"
    fi
}

# ------------------------------------------------------------------------------
# System Information
# ------------------------------------------------------------------------------
show_system_info() {
    section_header "SYSTEM INFORMATION"
    
    info_line "Hostname" "$(hostname)"
    info_line "User" "$USER"
    info_line "Operating System" "$OS_TYPE"
    
    if [[ "$OS_TYPE" == "Darwin" ]]; then
        info_line "macOS Version" "$(sw_vers -productVersion)"
        info_line "Build" "$(sw_vers -buildVersion)"
        info_line "Architecture" "$(uname -m)"
        info_line "Kernel" "$(uname -r)"
        
        # Hardware info
        local model=$(sysctl -n hw.model 2>/dev/null || echo "Unknown")
        local cpu=$(sysctl -n machdep.cpu.brand_string 2>/dev/null || echo "Unknown")
        local cores=$(sysctl -n hw.ncpu 2>/dev/null || echo "Unknown")
        local mem=$(sysctl -n hw.memsize 2>/dev/null | awk '{print $1/1024/1024/1024 " GB"}' || echo "Unknown")
        
        info_line "Model" "$model"
        info_line "CPU" "$cpu"
        info_line "CPU Cores" "$cores"
        info_line "Memory" "$mem"
        
    elif [[ "$OS_TYPE" == "Linux" ]]; then
        if [[ -f /etc/os-release ]]; then
            source /etc/os-release
            info_line "Distribution" "$NAME"
            info_line "Version" "$VERSION"
        fi
        info_line "Kernel" "$(uname -r)"
        info_line "Architecture" "$(uname -m)"
        
        # Hardware info
        if [[ -f /proc/cpuinfo ]]; then
            local cpu=$(grep "model name" /proc/cpuinfo | head -n 1 | cut -d: -f2 | xargs)
            local cores=$(grep -c "processor" /proc/cpuinfo)
            info_line "CPU" "$cpu"
            info_line "CPU Cores" "$cores"
        fi
        
        if [[ -f /proc/meminfo ]]; then
            local mem=$(grep "MemTotal" /proc/meminfo | awk '{print $2/1024/1024 " GB"}')
            info_line "Memory" "$mem"
        fi
    fi
    
    # Uptime
    if command_exists uptime; then
        local uptime_info=$(uptime | sed 's/.*up //' | sed 's/,.*//')
        info_line "Uptime" "$uptime_info"
    fi
    
    # Current date/time
    info_line "Current Time" "$(date '+%Y-%m-%d %H:%M:%S %Z')"
}

# ------------------------------------------------------------------------------
# Shell Information
# ------------------------------------------------------------------------------
show_shell_info() {
    section_header "SHELL INFORMATION"
    
    info_line "Current Shell" "$SHELL"
    info_line "Shell Version" "$($SHELL --version | head -n 1)"
    
    if [[ -n "${ZSH_VERSION:-}" ]]; then
        info_line "Zsh Version" "$ZSH_VERSION"
    fi
    
    if [[ -n "${BASH_VERSION:-}" ]]; then
        info_line "Bash Version" "$BASH_VERSION"
    fi
    
    # Environment
    info_line "Terminal" "${TERM:-not set}"
    info_line "Terminal Program" "${TERM_PROGRAM:-not set}"
    info_line "Editor" "${EDITOR:-not set}"
    info_line "Visual Editor" "${VISUAL:-not set}"
    
    # Path count
    local path_count=$(echo "$PATH" | tr ':' '\n' | wc -l | tr -d ' ')
    info_line "PATH Entries" "$path_count"
}

# ------------------------------------------------------------------------------
# Development Tools
# ------------------------------------------------------------------------------
show_dev_tools() {
    section_header "DEVELOPMENT TOOLS"
    
    # Package managers
    if command_exists brew; then
        info_line "Homebrew" "$(get_version brew)"
        local brew_packages=$(brew list --formula 2>/dev/null | wc -l | tr -d ' ')
        local brew_casks=$(brew list --cask 2>/dev/null | wc -l | tr -d ' ')
        info_line "  └─ Packages" "$brew_packages formulae, $brew_casks casks"
    else
        info_line "Homebrew" "not installed"
    fi
    
    # Version control
    if command_exists git; then
        info_line "Git" "$(get_version git)"
        local git_user=$(git config --global user.name 2>/dev/null || echo "not set")
        local git_email=$(git config --global user.email 2>/dev/null || echo "not set")
        info_line "  └─ User" "$git_user <$git_email>"
    else
        info_line "Git" "not installed"
    fi
    
    # Programming languages
    if command_exists python3; then
        info_line "Python3" "$(get_version python3)"
    else
        info_line "Python3" "not installed"
    fi
    
    if command_exists python; then
        info_line "Python" "$(get_version python)"
    fi
    
    if command_exists node; then
        info_line "Node.js" "$(get_version node)"
    else
        info_line "Node.js" "not installed"
    fi
    
    if command_exists npm; then
        info_line "npm" "$(get_version npm)"
    fi
    
    if command_exists ruby; then
        info_line "Ruby" "$(get_version ruby)"
    fi
    
    if command_exists go; then
        info_line "Go" "$(get_version go)"
    fi
    
    if command_exists rust; then
        info_line "Rust" "$(rustc --version 2>/dev/null | awk '{print $2}' || echo 'not installed')"
    fi
}

# ------------------------------------------------------------------------------
# Editors and Tools
# ------------------------------------------------------------------------------
show_editors_tools() {
    section_header "EDITORS & CLI TOOLS"
    
    # Editors
    if command_exists nvim; then
        info_line "Neovim" "$(get_version nvim)"
    else
        info_line "Neovim" "not installed"
    fi
    
    if command_exists vim; then
        info_line "Vim" "$(vim --version | head -n 1 | grep -oE '[0-9]+\.[0-9]+' | head -n 1)"
    fi
    
    if command_exists code; then
        info_line "VS Code" "$(get_version code)"
    fi
    
    # Terminal multiplexer
    if command_exists tmux; then
        info_line "Tmux" "$(get_version tmux -V)"
    else
        info_line "Tmux" "not installed"
    fi
    
    # Modern CLI tools
    if command_exists bat; then
        info_line "bat" "$(get_version bat)"
    fi
    
    if command_exists eza; then
        info_line "eza" "$(get_version eza)"
    fi
    
    if command_exists rg; then
        info_line "ripgrep" "$(get_version rg)"
    fi
    
    if command_exists fd; then
        info_line "fd" "$(get_version fd)"
    fi
    
    if command_exists fzf; then
        info_line "fzf" "$(get_version fzf)"
    fi
    
    if command_exists zoxide; then
        info_line "zoxide" "$(get_version zoxide)"
    fi
    
    if command_exists delta; then
        info_line "git-delta" "$(get_version delta)"
    fi
    
    if command_exists lazygit; then
        info_line "lazygit" "$(get_version lazygit)"
    fi
    
    if command_exists jq; then
        info_line "jq" "$(get_version jq)"
    fi
    
    if command_exists gh; then
        info_line "GitHub CLI" "$(get_version gh)"
    fi
}

# ------------------------------------------------------------------------------
# Dotfiles Information
# ------------------------------------------------------------------------------
show_dotfiles_info() {
    section_header "DOTFILES CONFIGURATION"
    
    # Dotfiles directory
    if [[ -d "$HOME/dotfiles" ]]; then
        info_line "Dotfiles Location" "$HOME/dotfiles"
        
        # Git info
        if [[ -d "$HOME/dotfiles/.git" ]]; then
            cd "$HOME/dotfiles"
            local branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")
            local commit=$(git rev-parse --short HEAD 2>/dev/null || echo "unknown")
            local remote=$(git config --get remote.origin.url 2>/dev/null || echo "not set")
            
            info_line "  └─ Git Branch" "$branch"
            info_line "  └─ Last Commit" "$commit"
            info_line "  └─ Remote" "$remote"
            
            # Check for uncommitted changes
            if ! git diff-index --quiet HEAD 2>/dev/null; then
                info_line "  └─ Status" "${YELLOW}uncommitted changes${NC}"
            else
                info_line "  └─ Status" "${GREEN}clean${NC}"
            fi
            cd - >/dev/null
        fi
    else
        info_line "Dotfiles Location" "${RED}not found${NC}"
    fi
    
    # Symlinks status
    if [[ -L "$HOME/.zshenv" ]]; then
        info_line "Zsh Config" "symlinked"
    elif [[ -f "$HOME/.zshenv" ]]; then
        info_line "Zsh Config" "exists (not symlinked)"
    else
        info_line "Zsh Config" "not found"
    fi
    
    if [[ -L "$HOME/.config/nvim" ]]; then
        info_line "Neovim Config" "symlinked"
    elif [[ -d "$HOME/.config/nvim" ]]; then
        info_line "Neovim Config" "exists (not symlinked)"
    else
        info_line "Neovim Config" "not found"
    fi
    
    if [[ -L "$HOME/.config/tmux" ]]; then
        info_line "Tmux Config" "symlinked"
    elif [[ -d "$HOME/.config/tmux" ]]; then
        info_line "Tmux Config" "exists (not symlinked)"
    else
        info_line "Tmux Config" "not found"
    fi
}

# ------------------------------------------------------------------------------
# Network Information
# ------------------------------------------------------------------------------
show_network_info() {
    section_header "NETWORK INFORMATION"
    
    # Hostname and IP
    info_line "Hostname" "$(hostname)"
    
    if [[ "$OS_TYPE" == "Darwin" ]]; then
        # macOS
        local ip=$(ipconfig getifaddr en0 2>/dev/null || ipconfig getifaddr en1 2>/dev/null || echo "not connected")
        info_line "Local IP" "$ip"
        
        # Network interface
        if networksetup -listallhardwareports 2>/dev/null | grep -q "Wi-Fi"; then
            local wifi_status=$(networksetup -getairportpower en0 2>/dev/null | awk '{print $NF}')
            info_line "WiFi Status" "$wifi_status"
        fi
        
    elif [[ "$OS_TYPE" == "Linux" ]]; then
        # Linux
        local ip=$(hostname -I 2>/dev/null | awk '{print $1}' || echo "not connected")
        info_line "Local IP" "$ip"
    fi
    
    # Public IP (optional - commented out to avoid external calls)
    # if command_exists curl; then
    #     local public_ip=$(curl -s ifconfig.me 2>/dev/null || echo "unable to retrieve")
    #     info_line "Public IP" "$public_ip"
    # fi
    
    # DNS
    if [[ -f /etc/resolv.conf ]]; then
        local dns=$(grep "^nameserver" /etc/resolv.conf | head -n 1 | awk '{print $2}')
        info_line "DNS Server" "$dns"
    fi
}

# ------------------------------------------------------------------------------
# Disk Usage
# ------------------------------------------------------------------------------
show_disk_usage() {
    section_header "DISK USAGE"
    
    if [[ "$OS_TYPE" == "Darwin" ]]; then
        df -h / | tail -n 1 | awk '{printf "  %-30s : %s / %s (%s used)\n", "Root Volume", $3, $2, $5}'
        df -h /System/Volumes/Data 2>/dev/null | tail -n 1 | awk '{printf "  %-30s : %s / %s (%s used)\n", "Data Volume", $3, $2, $5}' || true
    else
        df -h / | tail -n 1 | awk '{printf "  %-30s : %s / %s (%s used)\n", "Root Filesystem", $3, $2, $5}'
    fi
    
    # Home directory size
    if command_exists du; then
        local home_size=$(du -sh "$HOME" 2>/dev/null | awk '{print $1}' || echo "unknown")
        info_line "Home Directory Size" "$home_size"
    fi
    
    # Dotfiles size
    if [[ -d "$HOME/dotfiles" ]]; then
        local dotfiles_size=$(du -sh "$HOME/dotfiles" 2>/dev/null | awk '{print $1}' || echo "unknown")
        info_line "Dotfiles Size" "$dotfiles_size"
    fi
}

# ------------------------------------------------------------------------------
# Environment Variables
# ------------------------------------------------------------------------------
show_env_vars() {
    section_header "KEY ENVIRONMENT VARIABLES"
    
    info_line "HOME" "${HOME:-not set}"
    info_line "USER" "${USER:-not set}"
    info_line "SHELL" "${SHELL:-not set}"
    info_line "EDITOR" "${EDITOR:-not set}"
    info_line "LANG" "${LANG:-not set}"
    info_line "DOTFILES" "${DOTFILES:-not set}"
    info_line "XDG_CONFIG_HOME" "${XDG_CONFIG_HOME:-not set}"
    
    if [[ "$OS_TYPE" == "Darwin" ]]; then
        info_line "HOMEBREW_PREFIX" "${HOMEBREW_PREFIX:-not set}"
    fi
}

# ------------------------------------------------------------------------------
# Main Function
# ------------------------------------------------------------------------------
main() {
    local show_all=true
    local sections=()
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --system) sections+=("system"); show_all=false ;;
            --shell) sections+=("shell"); show_all=false ;;
            --dev) sections+=("dev"); show_all=false ;;
            --tools) sections+=("tools"); show_all=false ;;
            --dotfiles) sections+=("dotfiles"); show_all=false ;;
            --network) sections+=("network"); show_all=false ;;
            --disk) sections+=("disk"); show_all=false ;;
            --process) sections+=("process"); show_all=false ;;
            --env) sections+=("env"); show_all=false ;;
            --help|-h)
                echo "Usage: $0 [OPTIONS]"
                echo ""
                echo "Display system information and diagnostics."
                echo ""
                echo "Options:"
                echo "  --system    Show system information"
                echo "  --shell     Show shell information"
                echo "  --dev       Show development tools"
                echo "  --tools     Show editors and CLI tools"
                echo "  --dotfiles  Show dotfiles configuration"
                echo "  --network   Show network information"
                echo "  --disk      Show disk usage"
                echo "  --process   Show process information"
                echo "  --env       Show environment variables"
                echo "  --help,-h   Show this help message"
                echo ""
                echo "If no options are provided, all information is shown."
                exit 0
                ;;
            *)
                error "Unknown option: $1"
                echo "Use --help for usage information"
                exit 1
                ;;
        esac
        shift
    done
    
    echo ""
    echo "╔═══════════════════════════════════════════════════╗"
    echo "║                                                   ║"
    echo "║        System Information & Diagnostics           ║"
    echo "║                                                   ║"
    echo "╚═══════════════════════════════════════════════════╝"
    
    if $show_all; then
        show_system_info
        show_shell_info
        show_dev_tools
        show_editors_tools
        show_dotfiles_info
        show_network_info
        show_disk_usage
        show_env_vars
    else
        for section in "${sections[@]}"; do
            case $section in
                system) show_system_info ;;
                shell) show_shell_info ;;
                dev) show_dev_tools ;;
                tools) show_editors_tools ;;
                dotfiles) show_dotfiles_info ;;
                network) show_network_info ;;
                disk) show_disk_usage ;;
                env) show_env_vars ;;
            esac
        done
    fi
    
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    substep_info "For installation verification, run:"
    echo "  bash ~/dotfiles/scripts/verification/verify_installation.sh"
    echo ""
}

# Run main
main "$@"

