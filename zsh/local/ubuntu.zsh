#!/usr/bin/env zsh

# ------------------------------------------------------------------------------
# Ubuntu-specific Configuration
# ------------------------------------------------------------------------------

# Exit if not running on Linux
[[ "$(uname)" != "Linux" ]] && return 0

# ------------------------------------------------------------------------------
# System Update Aliases
# ------------------------------------------------------------------------------
# Update and upgrade system packages
alias apt_update='sudo apt-get update && \
                 sudo apt-get -y upgrade && \
                 echo "✅ System updated successfully"'

# Clean up system packages
alias apt_clean='sudo apt-get clean && \
                sudo apt-get autoclean && \
                sudo apt-get autoremove && \
                echo "✅ System cleaned successfully"'

# Combined update and cleanup
alias apt_maintain='apt_update && apt_clean'

# ------------------------------------------------------------------------------
# System Utilities
# ------------------------------------------------------------------------------
# Copy file with progress bar
cpp() {
    local source="$1"
    local dest="$2"

    # Validate input
    if [[ -z "$source" || -z "$dest" ]]; then
        echo "Usage: cpp source_file destination_file"
        return 1
    fi

    # Check if source file exists
    if [[ ! -f "$source" ]]; then
        echo "Error: Source file '$source' not found"
        return 1
    }

    # Get file size
    local total_size=$(stat -c '%s' "${source}")

    echo "Copying ${source} to ${dest}"
    echo "Total size: $(numfmt --to=iec-i --suffix=B ${total_size})"

    strace -q -ewrite cp -- "${source}" "${dest}" 2>&1 | \
        awk -v total_size="$total_size" '
        {
            count += $NF
            if (count % 10 == 0) {
                percent = count / total_size * 100
                printf "%3d%% [", percent
                for (i=0;i<=percent;i++)
                    printf "="
                printf ">"
                for (i=percent;i<100;i++)
                    printf " "
                printf "]\r"
            }
        }
        END { print "\n✅ Copy completed successfully" }'
}

# ------------------------------------------------------------------------------
# Package Management
# ------------------------------------------------------------------------------
# Search for package
alias apt_search='apt-cache search'

# Show package info
alias apt_info='apt-cache show'

# List installed packages
alias apt_list='dpkg --list'

# ------------------------------------------------------------------------------
# System Information
# ------------------------------------------------------------------------------
# Show system information
system_info() {
    echo "System Information:"
    echo "------------------"
    echo "OS: $(lsb_release -ds)"
    echo "Kernel: $(uname -r)"
    echo "Memory: $(free -h | awk '/^Mem:/ {print $3 "/" $2}')"
    echo "Disk Usage: $(df -h / | awk 'NR==2 {print $5 " (" $3 "/" $2 ")"}')"
    echo "CPU Load: $(uptime | awk -F'load average:' '{print $2}')"
}
