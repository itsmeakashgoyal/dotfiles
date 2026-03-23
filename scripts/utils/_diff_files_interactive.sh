#!/usr/bin/env bash
#
#  ▓▓▓▓▓▓▓▓▓▓
# ░▓ author ▓ Akash Goyal
# ░▓ file   ▓ scripts/utils/_diff_files_interactive.sh
# ░▓▓▓▓▓▓▓▓▓▓
#
# Interactive file diff using tv for selection and entr for live watching.
# Uses delta for enhanced output if available, otherwise falls back to
# built-in colored diff.

set -euo pipefail

# ──────────────────────────────────────────────────────────────────────────────
# Constants
# ──────────────────────────────────────────────────────────────────────────────
readonly PROJECT_DIR="${DOTFILES_DIR:-${HOME}/dotfiles}"

# ──────────────────────────────────────────────────────────────────────────────
# Dependency Check
# ──────────────────────────────────────────────────────────────────────────────
check_dependencies() {
    local missing=()
    for cmd in tv diff entr; do
        command -v "$cmd" >/dev/null 2>&1 || missing+=("$cmd")
    done

    if [[ ${#missing[@]} -gt 0 ]]; then
        echo "Error: missing required tools: ${missing[*]}" >&2
        if [[ "$(uname -s)" == "Darwin" ]]; then
            echo "  brew install ${missing[*]}" >&2
        else
            echo "  sudo apt-get install ${missing[*]}  # or equivalent" >&2
        fi
        exit 1
    fi

    # delta (git-delta) is optional — prettier diffs
    command -v delta >/dev/null 2>&1 && USE_DELTA=true || USE_DELTA=false
}

# ──────────────────────────────────────────────────────────────────────────────
# File Selection
# ──────────────────────────────────────────────────────────────────────────────
select_file() {
    local prompt="$1"
    cd "$PROJECT_DIR" || exit 1
    find . \
        -type f \
        -not -path "*/\.*" \
        -not -path "*/node_modules/*" \
        2>/dev/null \
        | sed 's|^\./||' \
        | tv || echo ""
}

# ──────────────────────────────────────────────────────────────────────────────
# Diff
# ──────────────────────────────────────────────────────────────────────────────
perform_diff() {
    local file1="$1" file2="$2"
    local full1="${PROJECT_DIR}/${file1}"
    local full2="${PROJECT_DIR}/${file2}"

    if [[ ! -f "$full1" || ! -f "$full2" ]]; then
        echo "Error: one or both files do not exist:" >&2
        [[ ! -f "$full1" ]] && echo "  Missing: $full1" >&2
        [[ ! -f "$full2" ]] && echo "  Missing: $full2" >&2
        return 1
    fi

    clear
    echo "Comparing:"
    echo "  1: $full1"
    echo "  2: $full2"
    echo ""

    if [[ "${USE_DELTA:-false}" == "true" ]]; then
        diff --unified=3 "$full1" "$full2" | delta || true
    else
        diff --unified=3 --color=auto "$full1" "$full2" || true
    fi
}

# ──────────────────────────────────────────────────────────────────────────────
# Main
# ──────────────────────────────────────────────────────────────────────────────
main() {
    check_dependencies

    cd "$PROJECT_DIR" || exit 1

    local file1 file2
    file1=$(select_file "first")
    [[ -z "$file1" ]] && { echo "No file selected. Exiting."; exit 1; }

    file2=$(select_file "second")
    [[ -z "$file2" ]] && { echo "No file selected. Exiting."; exit 1; }

    perform_diff "$file1" "$file2"

    echo ""
    echo "Watching for changes. Press Ctrl+C to exit."

    export -f perform_diff
    export PROJECT_DIR USE_DELTA
    printf "%s\n%s\n" "${PROJECT_DIR}/${file1}" "${PROJECT_DIR}/${file2}" \
        | entr bash -c "perform_diff '$file1' '$file2'"
}

main
