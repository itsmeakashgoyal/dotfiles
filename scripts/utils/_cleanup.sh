#!/usr/bin/env bash
#              █████     ███  ████
#             ░░███     ░░░  ░░███
#  █████ ████ ███████   ████  ░███   █████
# ░░███ ░███ ░░░███░   ░░███  ░███  ███░░
#  ░███ ░███   ░███     ░███  ░███ ░░█████
#  ░███ ░███   ░███ ███ ░███  ░███  ░░░░███
#  ░░████████  ░░█████  █████ █████ ██████
#   ░░░░░░░░    ░░░░░  ░░░░░ ░░░░░ ░░░░░░
#
#  ▓▓▓▓▓▓▓▓▓▓
# ░▓ author ▓ Akash Goyal
# ░▓ file   ▓ scripts/utils/_cleanup.sh
# ░▓▓▓▓▓▓▓▓▓▓
# ░░░░░░░░░░
#
#█▓▒░

# ------------------------------------------------------------------------------
# Initialization
# ------------------------------------------------------------------------------
SCRIPT_DIR="${HOME}/dotfiles/scripts"
HELPER_FILE="${SCRIPT_DIR}/utils/_helper.sh"

# Source helper functions
if [[ ! -f "$HELPER_FILE" ]]; then
    echo "Error: Helper file not found at $HELPER_FILE" >&2
    exit 1
fi
source "$HELPER_FILE"

set -euo pipefail

# ------------------------------------------------------------------------------
# Help Functions
# ------------------------------------------------------------------------------
show_help() {
    cat <<EOF
Usage: $0 [options] [components]

Options:
    -h, --help     Show this help message
    -y, --yes      Auto-confirm all actions
    -v, --verbose  Show detailed output

Components:
    dotfiles   - Remove dotfile symlinks and configurations
    homebrew   - Uninstall Homebrew and all packages
    nvim       - Remove Neovim configuration
    tmux       - Remove tmux configuration
    all        - Clean everything

Examples:
    $0                     # Interactive mode
    $0 nvim homebrew      # Clean specific components
    $0 -y all             # Clean everything without confirmation
EOF
}

# ------------------------------------------------------------------------------
# Cleanup Functions
# ------------------------------------------------------------------------------
cleanup_dotfiles() {
    info "Removing dotfile symlinks..."

    local symlinks=(
        "${HOME}/.zshenv"
        "${HOME}/.config/nvim"
        "${HOME}/.config/tmux"
    )

    for link in "${symlinks[@]}"; do
        if [[ -L "$link" ]]; then
            rm -f "$link"
            success "Removed symlink: $link"
        fi
    done
}

cleanup_homebrew() {
    info "Cleaning up Homebrew..."

    if command_exists brew; then
        info "This will uninstall Homebrew and all of the packages installed with brew."
        while true; do
            read -p "Uninstall Homebrew and all packages installed with brew ? (y/n) " yn
            case $yn in
            [Yy]*)
                break
                ;;
            [Nn]*)
                printf "\nExiting.\n"
                exit 0
                ;;
            *)
                echo "Please answer yes or no."
                ;;
            esac
        done

        brew remove --force $(brew list --formula)

        platform=$(uname -s)
        if [ "${platform}" == "Darwin" ]; then
            brew remove --cask --force $(brew list)
        else
            brew remove --force $(brew list)
        fi

        NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/uninstall.sh)"

        # Remove Homebrew cache and directories
        rm -rf "$(brew --cache)"
        rm -rf "$(brew --prefix)/Caskroom/"
        [ -d /home/linuxbrew/.linuxbrew ] && sudo rm -rf /home/linuxbrew/.linuxbrew

        success "Homebrew uninstalled successfully"
    fi
}

cleanup_nvim() {
    info "Cleaning up Neovim..."
    DESTDIR="${HOME}"/.config/nvim
    rm -rf "${DESTDIR}"
    rm -rf "${HOME}"/.local/share/nvim
    rm -rf "${HOME}"/.local/state/nvim
    rm -rf "${HOME}"/.cache/nvim
    success "Neovim configuration cleaned"
}
 
cleanup_tmux() {
    info "Cleaning up tmux..."
    rm -rf "${HOME}/.config/tmux"
    rm -rf "${HOME}/.tmux"
    success "Tmux configuration cleaned"
}

# ------------------------------------------------------------------------------
# Main Function
# ------------------------------------------------------------------------------
main() {
    local auto_confirm=false
    local components=()

    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
        -h | --help)
            show_help
            exit 0
            ;;
        -y | --yes)
            auto_confirm=true
            shift
            ;;
        all)
            components=(dotfiles homebrew nvim tmux zsh)
            shift
            ;;
        *)
            components+=("$1")
            shift
            ;;
        esac
    done

    # Interactive mode if no components specified
    if [[ ${#components[@]} -eq 0 ]]; then
        info "Select components to clean:"
        select comp in "dotfiles" "homebrew" "nvim" "tmux" "zsh" "all" "quit"; do
            case $comp in
            "all")
                components=(dotfiles homebrew nvim tmux zsh)
                break
                ;;
            "quit")
                exit 0
                ;;
            *)
                if [[ -n "$comp" ]]; then
                    components=("$comp")
                    break
                fi
                ;;
            esac
        done
    fi

    # Confirm cleanup
    if ! $auto_confirm; then
        info "The following components will be cleaned:"
        printf '%s\n' "${components[@]}"
        read -p "Continue? [y/N] " -n 1 -r
        echo
        [[ ! $REPLY =~ ^[Yy]$ ]] && exit 1
    fi

    # Execute cleanup
    for component in "${components[@]}"; do
        case "$component" in
        dotfiles) cleanup_dotfiles ;;
        homebrew) cleanup_homebrew ;;
        nvim) cleanup_nvim ;;
        tmux) cleanup_tmux ;;
        *) error "Unknown component: $component" ;;
        esac
    done

    success "Cleanup completed!"
    log_message "Cleanup completed successfully"
}

# Set error trap
trap 'print_error "$LINENO" "$BASH_COMMAND" "$?"' ERR

# Run main
main "$@"
