#!/usr/bin/env bash

# Enable strict mode for better error handling
set -eu pipefail

# Set the filename of the script containing the functions
FILE="${HOME}/dotfiles/zsh/local/functions.zsh"

# Check if the file exists
if [[ ! -f "$FILE" ]]; then
    echo "Error: Function file not found at $FILE" >&2
    exit 1
fi

# Function to extract function name and comment
extract_function_info() {
    local line="$1"
    local next_line="$2"
    local comment=""
    local f_name=""

    # Extract comment (if present)
    if [[ $line =~ ^#[[:space:]]*(.*) ]]; then
        comment="${BASH_REMATCH[1]}"
    fi

    # Extract function name from the next line
    if [[ $next_line =~ ^function[[:space:]]+([a-zA-Z0-9_-]+) || $next_line =~ ^([a-zA-Z0-9_-]+)\(\) ]]; then
        f_name="${BASH_REMATCH[1]}"
    fi

    # Only return if both comment and function name are present
    if [[ -n "$comment" && -n "$f_name" ]]; then
        echo "$f_name|$comment"
    fi
}

# Parse the file for function names and comments
declare -a functions=()
while IFS= read -r line; do
    IFS= read -r next_line
    result=$(extract_function_info "$line" "$next_line")
    if [[ -n "$result" ]]; then
        functions+=("$result")
    fi
done <"$FILE"

# Sort the functions alphabetically by name
IFS=$'\n' sorted=($(sort <<<"${functions[*]}"))
unset IFS

# Print out the sorted functions
printf "%-20s %s\n" "Function" "Description"
printf "%-20s %s\n" "--------" "-----------"
for f in "${sorted[@]}"; do
    IFS='|' read -r f_name com <<<"$f"
    printf "%-20s %s\n" "$f_name" "$com"
done
