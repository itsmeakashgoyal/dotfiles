#!/usr/bin/env bash

#################################################
#      File: _setup_ssh.sh                      #
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

generate_ssh_key() {
    local email="$1"
    local key_type="${2:-ed25519}"
    local key_name="id_${key_type}"
    local key_path="$HOME/.ssh/${key_name}"

    # If key exists, prompt for a new name
    while [[ -f "${key_path}" ]]; do
        print_message "$YELLOW" "SSH key already exists at ${key_path}"
        read -p "Enter a new name for the key (without .pub extension): " new_name

        # Validate the new name
        if [[ -z "$new_name" ]]; then
            print_message "$RED" "Key name cannot be empty"
            continue
        fi

        key_path="$HOME/.ssh/${new_name}"
        if [[ -f "${key_path}" ]]; then
            print_message "$RED" "A key with name ${new_name} already exists"
            continue
        fi
        break
    done

    # Create .ssh directory if it doesn't exist
    mkdir -p "$HOME/.ssh"
    chmod 700 "$HOME/.ssh"

    # Generate new SSH key
    print_message "$BLUE" "Generating new SSH key..."
    ssh-keygen -t "$key_type" -C "$email" -f "$key_path" -N ""

    # Add key to ssh-agent
    eval "$(ssh-agent -s)"
    ssh-add "$key_path"

    # Set correct permissions
    chmod 600 "$key_path"
    chmod 644 "${key_path}.pub"

    # Display public key
    print_message "$GREEN" "SSH key generated successfully!"
    print_message "$YELLOW" "Your public SSH key:"
    cat "${key_path}.pub"

    # Copy to clipboard based on OS
    if [ "$OS_TYPE" = "Darwin" ]; then # macOS
        cat "${key_path}.pub" | pbcopy
        print_message "$GREEN" "Public key copied to clipboard!"
    elif command_exists xclip; then # Linux with xclip
        cat "${key_path}.pub" | xclip -selection clipboard
        print_message "$GREEN" "Public key copied to clipboard!"
    fi

    log_message "SSH key generated for $email at $key_path"
}

# Show help message
show_help() {
    echo "Usage: $0 -e EMAIL [-t KEY_TYPE]"
    echo ""
    echo "This script generates SSH keys with custom names and types."
    echo ""
    echo "Options:"
    echo "  -e EMAIL     Email address for the SSH key"
    echo "  -t KEY_TYPE  Key type (ed25519 or rsa) [default: ed25519]"
    echo "  -h          Show this help message"
    echo ""
    echo "Examples:"
    echo "  # Generate with default key type (ed25519)"
    echo "  $0 -e your.email@example.com"
    echo ""
    echo "  # Generate with specific key type"
    echo "  $0 -e your.email@example.com -t rsa"
    echo ""
    echo "Note: If a key already exists, you'll be prompted for a new name."
}

# Parse command line arguments
while getopts "e:t:h" opt; do
    case $opt in
    e) email="$OPTARG" ;;
    t) key_type="$OPTARG" ;;
    h)
        show_help
        exit 0
        ;;
    ?)
        show_help
        exit 1
        ;;
    esac
done

# Check if email is provided
if [[ -z "${email:-}" ]]; then
    print_message "$RED" "Error: Email address is required"
    show_help
    exit 1
fi

# Set the error trap (using the pattern from _gh_cli.sh)
trap 'print_error "$LINENO" "$BASH_COMMAND" "$?"' ERR

# Generate the SSH key
generate_ssh_key "$email" "${key_type:-rsa}"
