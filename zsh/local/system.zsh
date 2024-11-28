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

# System maintenance
alias ubrew='brew update && brew upgrade && brew cleanup' # Update Homebrew

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
# SSL Certificate Utilities
# ------------------------------------------------------------------------------
getcertnames() {
    local domain="$1"

    [[ -z "$domain" ]] && {
        echo "Error: No domain specified."
        return 1
    }

    echo "Fetching SSL certificate for ${domain}..."

    local cert_text
    cert_text=$(openssl s_client -connect "${domain}:443" -servername "${domain}" 2>/dev/null <<<"GET / HTTP/1.0\nEOT" |
        openssl x509 -text -certopt "no_aux,no_header,no_issuer,no_pubkey,no_serial,no_sigdump,no_signame,no_validity,no_version")

    [[ -z "$cert_text" ]] && {
        echo "Error: No certificate found."
        return 1
    }

    echo "\nCommon Name:"
    echo "$cert_text" | grep "Subject:" | sed -e "s/^.*CN=//" -e "s/\/emailAddress=.*//"

    echo "\nSubject Alternative Names:"
    echo "$cert_text" | grep -A 1 "Subject Alternative Name:" |
        sed -e "2s/DNS://g" -e "s/ //g" | tr "," "\n" | tail -n +2
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
