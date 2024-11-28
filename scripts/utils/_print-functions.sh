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
# ░▓ file   ▓ scripts/utils/_print-functions.sh
# ░▓▓▓▓▓▓▓▓▓▓
# ░░░░░░░░░░
#
#█▓▒░

# ------------------------------------------------------------------------------
# Initialization
# ------------------------------------------------------------------------------
set -eu pipefail

# Constants
readonly FUNCTIONS_FILE="${HOME}/dotfiles/zsh/local/functions.zsh"
readonly TABLE_FORMAT="%-20s %s\n"
readonly HEADER_LINE="%-20s %s\n"

# Check if functions file exists
if [[ ! -f "$FUNCTIONS_FILE" ]]; then
    echo "Error: Function file not found at $FUNCTIONS_FILE" >&2
    exit 1
fi

# ------------------------------------------------------------------------------
# Function Parser
# ------------------------------------------------------------------------------
extract_function_info() {
    local line="$1"
    local next_line="$2"
    local comment=""
    local func_name=""

    # Debug output (uncomment to debug)
    # echo "Processing line: $line"
    # echo "Next line: $next_line"

    # Extract comment if line starts with #
    if [[ $line =~ ^[[:space:]]*#[[:space:]]*(.*) ]]; then
        comment="${BASH_REMATCH[1]}"
    fi

    # Extract function name (more flexible pattern matching)
    if [[ $next_line =~ ^[[:space:]]*(function[[:space:]]+)?([a-zA-Z0-9_-]+)[[:space:]]*\(\) ]]; then
        func_name="${BASH_REMATCH[2]}"
    fi

    # Output only if both comment and function name exist
    if [[ -n "$comment" && -n "$func_name" ]]; then
        echo "$func_name|$comment"
    fi
}

# ------------------------------------------------------------------------------
# Main Function
# ------------------------------------------------------------------------------
main() {
    # Parse file and store functions
    local -a functions=()
    local line=""
    local next_line=""

    # Read file line by line
    while IFS= read -r line || [[ -n "$line" ]]; do
        # Read next line
        IFS= read -r next_line || true

        # Skip empty lines
        [[ -z "$line" ]] && continue

        # Extract function info
        local result=$(extract_function_info "$line" "$next_line")
        if [[ -n "$result" ]]; then
            functions+=("$result")
        fi
    done <"$FUNCTIONS_FILE"

    # Check if any functions were found
    if [[ ${#functions[@]} -eq 0 ]]; then
        echo "No functions found in $FUNCTIONS_FILE"
        exit 0
    fi

    # Sort functions alphabetically
    IFS=$'\n' sorted=($(sort <<<"${functions[*]}"))
    unset IFS

    # Print header
    printf "$HEADER_LINE" "Function" "Description"
    printf "$HEADER_LINE" "--------" "-----------"

    # Print sorted functions
    for func in "${sorted[@]}"; do
        IFS='|' read -r name description <<<"$func"
        printf "$TABLE_FORMAT" "$name" "$description"
    done
}

# Run main function
main
