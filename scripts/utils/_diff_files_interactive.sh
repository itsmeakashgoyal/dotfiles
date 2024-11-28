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
# ░▓ file   ▓ scripts/utils/_diff_files_interactive.sh
# ░▓▓▓▓▓▓▓▓▓▓
# ░░░░░░░░░░
#
#█▓▒░

# ------------------------------------------------------------------------------
# Initialization
# ------------------------------------------------------------------------------
set -eu pipefail

# ------------------------------------------------------------------------------
# Constants
# ------------------------------------------------------------------------------
readonly PROJECT_DIR="${HOME}/dotfiles"  # Adjust this to your project root

# ------------------------------------------------------------------------------
# Dependency Check
# ------------------------------------------------------------------------------
check_dependencies() {
    local missing_deps=()
    
    for cmd in fzf diff diff-so-fancy entr; do
        if ! command -v "$cmd" >/dev/null 2>&1; then
            missing_deps+=("$cmd")
        fi
    done

    if [[ ${#missing_deps[@]} -gt 0 ]]; then
        echo "Error: Missing required dependencies: ${missing_deps[*]}"
        echo -e "\nInstallation instructions:"
        
        if [[ "$(uname)" == "Darwin" ]]; then
            echo "Using Homebrew:"
            echo "  brew install ${missing_deps[*]}"
        elif [[ "$(uname)" == "Linux" ]]; then
            if command -v apt-get >/dev/null 2>&1; then
                echo "Using apt:"
                echo "  sudo apt-get install ${missing_deps[*]}"
            elif command -v dnf >/dev/null 2>&1; then
                echo "Using dnf:"
                echo "  sudo dnf install ${missing_deps[*]}"
            elif command -v pacman >/dev/null 2>&1; then
                echo "Using pacman:"
                echo "  sudo pacman -S ${missing_deps[*]}"
            fi
        fi
        
        exit 1
    fi
}

# ------------------------------------------------------------------------------
# Functions
# ------------------------------------------------------------------------------
select_file() {
    local prompt="$1"
    
    # Change to project directory
    cd "$PROJECT_DIR" || exit 1
    
    # Find files, excluding common directories to ignore
    find . \
        -type f \
        -not -path "*/\.*" \
        -not -path "*/node_modules/*" \
        -not -path "*/vendor/*" \
        2>/dev/null | \
        sed 's|^./||' | \
        fzf --height 40% \
            --reverse \
            --prompt="Select $prompt file: " || echo ""
}

perform_diff() {
    local file1="$1"
    local file2="$2"

    # Construct full paths
    local full_path1="${PROJECT_DIR}/${file1}"
    local full_path2="${PROJECT_DIR}/${file2}"

    # Debug output
    echo "Checking paths:"
    echo "File 1: $full_path1"
    echo "File 2: $full_path2"

    # Verify files exist
    if [[ ! -f "$full_path1" || ! -f "$full_path2" ]]; then
        echo "Error: One or both files do not exist:"
        [[ ! -f "$full_path1" ]] && echo "Missing: $full_path1"
        [[ ! -f "$full_path2" ]] && echo "Missing: $full_path2"
        return 1
    fi

    # Perform diff with fancy output
    echo -e "\nComparing files:"
    echo "1: $full_path1"
    echo "2: $full_path2"
    echo -e "\nDifferences:\n"
    diff --unified=0 "$full_path1" "$full_path2" | diff-so-fancy
}

# ------------------------------------------------------------------------------
# Main Function
# ------------------------------------------------------------------------------
main() {
    # Check dependencies first
    check_dependencies

    # Ensure we're in the project directory
    cd "$PROJECT_DIR" || exit 1

    # Select files
    local file1
    local file2
    
    # Select first file
    file1=$(select_file "first")
    if [[ -z "$file1" ]]; then
        echo "No file selected. Exiting."
        exit 1
    fi

    # Select second file
    file2=$(select_file "second")
    if [[ -z "$file2" ]]; then
        echo "No file selected. Exiting."
        exit 1
    fi

    # Debug output
    echo "Selected files:"
    echo "File 1: $file1"
    echo "File 2: $file2"

    # Watch files for changes and perform diff
    echo -e "\nWatching files for changes. Press Ctrl+C to exit.\n"
    (
        echo "$full_path1"
        echo "$full_path2"
    ) | entr -s "$(declare -f perform_diff); perform_diff '$file1' '$file2'"
}

# Run main function
main