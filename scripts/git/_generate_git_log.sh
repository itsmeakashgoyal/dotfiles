#!/usr/bin/env bash
#            ███   █████
#           ░░░   ░░███
#   ███████ ████  ███████
#  ███░░███░░███ ░░░███░
# ░███ ░███ ░███   ░███
# ░███ ░███ ░███   ░███ ███
# ░░███████ █████  ░░█████
#  ░░░░░███░░░░░    ░░░░░
#  ███ ░███
# ░░██████
#  ░░░░░░
#
#  ▓▓▓▓▓▓▓▓▓▓
# ░▓ author ▓ Akash Goyal
# ░▓ file   ▓ scripts/git/_generate_git_log.sh
# ░▓▓▓▓▓▓▓▓▓▓
# ░░░░░░░░░░
#
#█▓▒░
# ------------------------------
#          INITIALIZE
# ------------------------------
# Load Helper functions persistently
TRAP_FILE="${HOME}/dotfiles/scripts/utils/_trap.sh"
# Check if trap file exists and source it
if [[ ! -f "$TRAP_FILE" ]]; then
    echo "Error: trap file not found at $TRAP_FILE" >&2
    exit 1
fi

# Source the trap file
source "$TRAP_FILE"

# Set the default number of commits to 10 if not provided
num_commits="${1:-10}"

# Get the remote URL for the current Git repository
remote_url=$(git remote get-url origin)

# Get the git log
git_log_output=$(git log --oneline --decorate=short -n "$num_commits" 2>&1)
exit_status=$?

# Check if git log command was successful
if [ $exit_status -ne 0 ]; then
    echo "ERROR: ${git_log_output}"
    exit 1
fi

# Process the git log output
# - Replace the first word (commit hash) with hash@
# - Format each line as a markdown link with commit message
processed_git_log=$(echo "${git_log_output}" | awk -v remote_url="${remote_url}" '
    {
        gsub(/^[a-f0-9]+/, "&@")
        hash = substr($1, 1, 7)
        full_hash = substr($1, 1, 40)
        message = substr($0, index($0,$2))
        printf "- [%s](%s/%s) - %s\n", hash, remote_url, full_hash, message
    }
')

# Print the processed git log
echo "${processed_git_log}"
