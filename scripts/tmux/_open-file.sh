#!/usr/bin/env bash
#   █████
#  ░░███
#  ███████   █████████████   █████ ████ █████ █████
# ░░░███░   ░░███░░███░░███ ░░███ ░███ ░░███ ░░███
#   ░███     ░███ ░███ ░███  ░███ ░███  ░░░█████░
#   ░███ ███ ░███ ░███ ░███  ░███ ░███   ███░░░███
#   ░░█████  █████░███ █████ ░░████████ █████ █████
#    ░░░░░  ░░░░░ ░░░ ░░░░░   ░░░░░░░░ ░░░░░ ░░░░░
#
#  ▓▓▓▓▓▓▓▓▓▓
# ░▓ author ▓ Akash Goyal
# ░▓ file   ▓ scripts/tmux/_open-file.sh
# ░▓▓▓▓▓▓▓▓▓▓
# ░░░░░░░░░░
#
#█▓▒░

# The set -e option instructs bash to immediately exit if any command has a non-zero exit status
# The set -u referencing a previously undefined variable - with the exceptions of $* and $@ - is an error
# The set -o pipefaile if any command in a pipeline fails, that return code will be used as the return code of the whole pipeline
# https://bit.ly/37nFgin
set -eu pipefail

# Function to display help information
help_function() {
    cat <<EOF
Usage: _open_file.sh [query] [-h|--help]

This script opens files using television (tv) for selection and the configured editor (default: nvim) for viewing.
An optional query can be provided to filter the file selection.

Options:
  -h, --help    Show this help message and exit.

Arguments:
  [query]       Optional query to filter the file selection.

Features:
  - Filters files using tv with an optional query.
  - Opens selected file in the configured editor (default: nvim).
  - Handles interruptions and errors gracefully.

Note: This script requires tv (television) and a compatible editor (e.g., nvim).
EOF
}

# Check for help argument
if [[ "$1" == "-h" ]] || [[ "$1" == "--help" ]]; then
    help_function
    exit 0
fi

# Select file using television
file=$(tv --input "${1:-}" 2>/dev/null) || exit 0

# Check if a file was selected
if [ -z "$file" ]; then
    exit 0
fi

# Convert to absolute path and open in editor
file=$(realpath "$file")
${EDITOR:-nvim} "$file"
