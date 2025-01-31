#!/usr/bin/env zsh
#                     █████
#                    ░░███
#   █████████  █████  ░███████
#  ░█░░░░███  ███░░   ░███░░███
#  ░   ███░  ░░█████  ░███ ░███
#    ███░   █ ░░░░███ ░███ ░███
#   █████████ ██████  ████ █████
#  ░░░░░░░░░ ░░░░░░  ░░░░ ░░░░░
#
#  ▓▓▓▓▓▓▓▓▓▓
# ░▓ author ▓ Akash Goyal
# ░▓ file   ▓ zsh/local/system.zsh
# ░▓▓▓▓▓▓▓▓▓▓
# ░░░░░░░░░░
#
#█▓▒░
# ------------------------------------------------------------------------------
# System Configuration: Aliases and Functions
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Network Utilities
# ------------------------------------------------------------------------------
# Get public IP and location information
alias myip="curl ipinfo.io/ip"                       # Get public IP address
alias whereami='npx @rafaelrinaldi/whereami -f json' # Get location info in JSON format

# Detailed IP address information
ip_info() {
    echo "Local IP Addresses:"
    echo "----------------"
    ifconfig lo0 | grep 'inet ' | sed -e 's/:/ /' | awk '{print "Loopback   : " $2}'
    ifconfig en0 | grep 'inet ' | sed -e 's/:/ /' | awk '{print "WiFi (IPv4): " $2}'
    ifconfig en0 | grep 'inet6 ' | sed -e 's/ / /' | awk '{print "WiFi (IPv6): " $2}'
    ifconfig en1 | grep 'inet ' | sed -e 's/:/ /' | awk '{print "LAN (IPv4) : " $2}'

    echo "\nPublic IP:"
    echo "---------"
    curl -s ipinfo.io/ip
}

# Monitor internet connectivity
internet() {
    local disconnected=false

    while ! ping -c 1 8.8.8.8 &>/dev/null; do
        echo '❌ No internet connection.'
        disconnected=true
        sleep 1
    done

    [[ $disconnected == true ]] &&
        osascript -e 'display notification "Connection restored ✅" with title "Internet"'

    echo '✅ Connected to internet.'
}

# ------------------------------------------------------------------------------
# System Utilities
# ------------------------------------------------------------------------------
# Disk usage with sorting
alias du='du -sh * | sort -hr' # Human-readable disk usage
alias df='df -h'               # Human-readable disk free
alias top='htop'               # Better top command

# File size information
fs() {
    if du -b /dev/null >/dev/null 2>&1; then
        du -sbh "${@:-.}" # GNU-style
    else
        du -sh "${@:-.}" # BSD-style
    fi
}

# Compare original and gzipped file size
gz() {
    local orig_size gzip_size ratio
    orig_size=$(wc -c <"$1")
    gzip_size=$(gzip -c "$1" | wc -c)
    ratio=$(echo "scale=2; $gzip_size * 100 / $orig_size" | bc -l)

    printf "Original: %d bytes\n" "$orig_size"
    printf "Gzipped:  %d bytes (%.2f%%)\n" "$gzip_size" "$ratio"
}

# Interactive process killer
pkill() {
    ps aux |
        fzf --height 40% \
            --layout=reverse \
            --header-lines=1 \
            --prompt="Select process to kill: " \
            --preview 'echo {}' \
            --preview-window up:3:hidden:wrap \
            --bind 'F2:toggle-preview' |
        awk '{print $2}' |
        xargs -r kill -15 || sudo kill -15
}

# ------------------------------------------------------------------------------
# Utility Functions
# ------------------------------------------------------------------------------

# Font installation helper
install_font() {
    local font_path="$1"
    local font_dir="$HOME/.local/share/fonts"

    [[ -z "$font_path" ]] && {
        echo "Error: Please provide path to font file"
        return 1
    }
    [[ ! -f "$font_path" ]] && {
        echo "Error: Font file not found"
        return 1
    }

    mkdir -p "$font_dir"
    unzip -o "$font_path" "*.{ttf,otf}" -d "$font_dir" &&
        fc-cache -f "$font_dir"

    echo "Font installed successfully"
}

# Wrapper for easy extraction of compressed files
function extract() {
    if [ -f $1 ]; then
        case $1 in
        *.tar.xz) tar xvJf $1 ;;
        *.tar.bz2) tar xvjf $1 ;;
        *.tar.gz) tar xvzf $1 ;;
        *.bz2) bunzip2 $1 ;;
        *.rar) unrar e $1 ;;
        *.gz) gunzip $1 ;;
        *.tar) tar xvf $1 ;;
        *.tbz2) tar xvjf $1 ;;
        *.tgz) tar xvzf $1 ;;
        *.apk) unzip $1 ;;
        *.epub) unzip $1 ;;
        *.xpi) unzip $1 ;;
        *.zip) unzip $1 ;;
        *.war) unzip $1 ;;
        *.jar) unzip $1 ;;
        *.Z) uncompress $1 ;;
        *.7z) 7z x $1 ;;
        *) echo "don't know how to extract '$1'..." ;;
        esac
    else
        echo "'$1' is not a valid file!"
    fi
}

# Create a .tar.gz archive, using `zopfli`, `pigz` or `gzip` for compression
function targz() {
    local tmpFile="${@%/}.tar"
    tar -cvf "${tmpFile}" --exclude=".DS_Store" "${@}" || return 1

    size=$(
        stat -f"%z" "${tmpFile}" 2>/dev/null # macOS `stat`
        stat -c"%s" "${tmpFile}" 2>/dev/null # GNU `stat`
    )

    local cmd=""
    if ((size < 52428800)) && hash zopfli 2>/dev/null; then
        # the .tar file is smaller than 50 MB and Zopfli is available; use it
        cmd="zopfli"
    else
        if hash pigz 2>/dev/null; then
            cmd="pigz"
        else
            cmd="gzip"
        fi
    fi

    echo "Compressing .tar ($((size / 1000)) kB) using \`${cmd}\`…"
    "${cmd}" -v "${tmpFile}" || return 1
    [ -f "${tmpFile}" ] && rm "${tmpFile}"

    zippedSize=$(
        stat -f"%z" "${tmpFile}.gz" 2>/dev/null # macOS `stat`
        stat -c"%s" "${tmpFile}.gz" 2>/dev/null # GNU `stat`
    )

    echo "${tmpFile}.gz ($((zippedSize / 1000)) kB) created successfully."
}

# `tre` is a shorthand for `tree` with hidden files and color enabled, ignoring
# the `.git` directory, listing directories first. The output gets piped into
# `less` with options to preserve color and line numbers, unless the output is
# small enough for one screen.
function tre() {
    tree -aC -I '.git|node_modules|bower_components' --dirsfirst "$@" | less -FRNX
}

function sshp() {
    local machine="$1"
    local user="ir"          # Replace with your username or make this dynamic
    local password="welcome" # Replace with your password or set dynamically

    # Debug logs
    # echo "Debug: Machine -> $machine"
    # echo "Debug: User -> $user"
    # echo "Debug: Checking if sshpass is installed..."

    # Check if sshpass is installed
    if ! command -v sshpass >/dev/null 2>&1; then
        echo "Error: sshpass is not installed. Install it using 'brew install sshpass'."
        return 1
    fi

    # Check if machine name is provided
    if [ -z "$machine" ]; then
        echo "Error: No machine name provided."
        echo "Usage: sshp <machinename>"
        return 1
    fi

    # Run sshpass with SSH
    echo "Debug: Connecting to $machine..."
    sshpass -p "$password" ssh "$user@$machine" -o StrictHostKeyChecking=no
}
