#!/usr/bin/env bash

#################################################
#      File: _cleanup.sh                         #
#      Author: Akash Goyal                      #
#      Status: Development                      #
#################################################

# ------------------------------
#          INITIALIZE
# ------------------------------
# Load Helper functions persistently
SCRIPT_DIR="${HOME}/dotfiles/scripts"
HELPER_FILE="${SCRIPT_DIR}/utils/_helper.sh"
# Check if helper file exists and source it
if [[ ! -f "$HELPER_FILE" ]]; then
    echo "Error: Helper file not found at $HELPER_FILE" >&2
    exit 1
fi

source "$HELPER_FILE"
set -euo pipefail

# Show help message
show_help() {
    echo "Usage: $0 [component1 component2 ...] or no arguments for interactive mode"
    echo ""
    echo "This script helps clean up various components installed by the dotfiles setup."
    echo ""
    echo "Components:"
    echo "  homebrew    - Uninstall Homebrew and all its packages"
    echo "  nvim        - Remove Neovim configuration"
    echo "  fzf         - Uninstall fzf"
    echo "  ohmyzsh     - Uninstall Oh My Zsh"
    echo "  all         - Clean everything"
    echo ""
    echo "Examples:"
    echo "  # Run in interactive mode"
    echo "  $0"
    echo ""
    echo "  # Clean specific components"
    echo "  $0 nvim fzf"
    echo ""
    echo "  # Clean everything"
    echo "  $0 all"
    echo ""
    echo "Note: The script will ask for confirmation before removing components."
}

# Cleanup functions for different components
cleanup_homebrew() {
    print_message "$YELLOW" "Cleaning up Homebrew..."
    if command_exists brew; then
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/uninstall.sh)"
        rm -rf "$(brew --cache)"
        rm -rf "$(brew --prefix)/Caskroom/"*
        log_message "Homebrew uninstalled successfully"
    else
        print_message "$YELLOW" "Homebrew is not installed"
    fi
}

cleanup_nvim() {
    print_message "$YELLOW" "Cleaning up Neovim..."
    rm -rf ~/.config/nvim
    rm -rf ~/.local/share/nvim
    rm -rf ~/.cache/nvim
    log_message "Neovim configuration cleaned"
}

cleanup_fzf() {
    print_message "$YELLOW" "Cleaning up fzf..."
    if [ -d ~/.config/.fzf ]; then
        ~/.config/.fzf/uninstall
        rm -rf ~/.config/.fzf
        log_message "fzf uninstalled successfully"
    else
        print_message "$YELLOW" "fzf is not installed in ~/.config/.fzf"
    fi
}

cleanup_ohmyzsh() {
    print_message "$YELLOW" "Cleaning up Oh My Zsh..."
    if [ -d ~/.oh-my-zsh ]; then
        uninstall_oh_my_zsh || {
            rm -rf ~/.oh-my-zsh
            print_message "$YELLOW" "Removed Oh My Zsh directory manually"
        }
        log_message "Oh My Zsh uninstalled successfully"
    else
        print_message "$YELLOW" "Oh My Zsh is not installed"
    fi
}

# Show available components
show_components() {
    echo "Available components to clean:"
    echo "1) homebrew    - Uninstall Homebrew and all its packages"
    echo "2) nvim        - Remove Neovim configuration"
    echo "3) fzf         - Uninstall fzf"
    echo "4) ohmyzsh     - Uninstall Oh My Zsh"
    echo "5) all         - Clean everything"
    echo "q) quit        - Exit cleanup"
}

# Main cleanup function
cleanup() {
    local component="$1"
    case "$component" in
    homebrew) cleanup_homebrew ;;
    nvim) cleanup_nvim ;;
    fzf) cleanup_fzf ;;
    ohmyzsh) cleanup_ohmyzsh ;;
    all)
        print_message "$YELLOW" "Cleaning up all components..."
        read -p "Are you sure you want to remove all components? [y/N] " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            # Order matters: remove dependencies first
            cleanup_fzf
            cleanup_nvim
            cleanup_ohmyzsh
            cleanup_homebrew
            print_message "$GREEN" "All components cleaned successfully!"
            log_message "All components cleaned successfully"
        else
            print_message "$YELLOW" "Cleanup cancelled"
            log_message "Full cleanup cancelled by user"
        fi
        ;;
    *) print_message "$RED" "Invalid component: $component" ;;
    esac
}

# Interactive menu
interactive_cleanup() {
    while true; do
        show_components
        read -p "Enter component number (or 'q' to quit): " choice
        case "$choice" in
        1) cleanup "homebrew" ;;
        2) cleanup "nvim" ;;
        3) cleanup "fzf" ;;
        4) cleanup "ohmyzsh" ;;
        5) cleanup "all" ;;
        q | Q) break ;;
        *) print_message "$RED" "Invalid choice" ;;
        esac
        echo
        read -p "Press enter to continue..."
        clear
    done
}

# Parse command line arguments
if [ $# -eq 0 ]; then
    interactive_cleanup
else
    case "$1" in
    -h | --help)
        show_help
        exit 0
        ;;
    *)
        for component in "$@"; do
            cleanup "$component"
        done
        ;;
    esac
fi

print_message "$GREEN" "Cleanup completed!"
log_message "Cleanup script finished execution"
