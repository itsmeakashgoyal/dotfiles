# ------------------------------------------------------------------------------
# System Configuration: Aliases and Functions
# ------------------------------------------------------------------------------

# Network and IP-related aliases
alias myip="curl ipinfo.io/ip"                       # Get public IP address
alias whereami='npx @rafaelrinaldi/whereami -f json' # Get location info in JSON format

# System utilities
alias diskusage='du -sh * | sort -h --reverse' # Show disk usage, sorted

# Determine size of a file or total size of a directory
function fs() {
    if du -b /dev/null >/dev/null 2>&1; then
        local arg=-sbh
    else
        local arg=-sh
    fi
    if [[ -n "$@" ]]; then
        du $arg -- "$@"
    else
        du $arg .[^.]* ./*
    fi
}

# Detailed IP address information
function myip() {
    ifconfig lo0 | grep 'inet ' | sed -e 's/:/ /' | awk '{print "lo0       : " $2}'
    ifconfig en0 | grep 'inet ' | sed -e 's/:/ /' | awk '{print "en0 (IPv4): " $2 " " $3 " " $4 " " $5 " " $6}'
    ifconfig en0 | grep 'inet6 ' | sed -e 's/ / /' | awk '{print "en0 (IPv6): " $2 " " $3 " " $4 " " $5 " " $6}'
    ifconfig en1 | grep 'inet ' | sed -e 's/:/ /' | awk '{print "en1 (IPv4): " $2 " " $3 " " $4 " " $5 " " $6}'
    ifconfig en1 | grep 'inet6 ' | sed -e 's/ / /' | awk '{print "en1 (IPv6): " $2 " " $3 " " $4 " " $5 " " $6}'
}

# Compare original and gzipped file size
function gz() {
    local origsize=$(wc -c <"$1")
    local gzipsize=$(gzip -c "$1" | wc -c)
    local ratio=$(echo "$gzipsize * 100 / $origsize" | bc -l)
    printf "orig: %d bytes\n" "$origsize"
    printf "gzip: %d bytes (%2.2f%%)\n" "$gzipsize" "$ratio"
}

# Show all the names (CNs and SANs) listed in the SSL certificate
# for a given domain
function getcertnames() {
    if [ -z "${1}" ]; then
        echo "ERROR: No domain specified."
        return 1
    fi

    local domain="${1}"
    echo "Testing ${domain}…"
    echo "" # newline

    local tmp=$(echo -e "GET / HTTP/1.0\nEOT" |
        openssl s_client -connect "${domain}:443" -servername "${domain}" 2>&1)

    if [[ "${tmp}" = *"-----BEGIN CERTIFICATE-----"* ]]; then
        local certText=$(echo "${tmp}" |
            openssl x509 -text -certopt "no_aux, no_header, no_issuer, no_pubkey, \
			no_serial, no_sigdump, no_signame, no_validity, no_version")
        echo "Common Name:"
        echo "" # newline
        echo "${certText}" | grep "Subject:" | sed -e "s/^.*CN=//" | sed -e "s/\/emailAddress=.*//"
        echo "" # newline
        echo "Subject Alternative Name(s):"
        echo "" # newline
        echo "${certText}" | grep -A 1 "Subject Alternative Name:" |
            sed -e "2s/DNS://g" -e "s/ //g" | tr "," "\n" | tail -n +2
        return 0
    else
        echo "ERROR: Certificate not found."
        return 1
    fi
}

function pkill() {
    ps aux |
        fzf --height 40% \
            --layout=reverse \
            --header-lines=1 \
            --prompt="Select process to kill: " \
            --preview 'echo {}' \
            --preview-window up:3:hidden:wrap \
            --bind 'F2:toggle-preview' |
        awk '{print $2}' |
        xargs -r bash -c '
        if ! kill "$1" 2>/dev/null; then
            echo "Regular kill failed. Attempting with sudo..."
            sudo kill "$1" || echo "Failed to kill process $1" >&2
        fi
    ' --
}

# Ping until internet is connected/re-connected
internet() {
    disconnected=false

    while ! ping 8.8.8.8 -c 1 &>/dev/null; do
        echo '❌ No internet connection.'
        disconnected=true
        sleep 1
    done

    # Show notification only if it was ever disconnected, so you
    # can leave the command running in the background.
    if $disconnected; then
        osascript -e 'display notification "Connection restored ✅" with title "Internet"'
    fi

    echo '✅ Connected to internet.'
}

# Creates a real-time countdown with alert sound, useful for bash scripts and terminal.
function timer() {
    total=$1
    for ((i = total; i > 0; i--)); do
        sleep 1
        printf "Time remaining %s secs \r" "$i"
    done
    echo -e "\a"
}

# Display calendar with day highlighted
function cal() {
    if [ -t 1 ]; then
        alias cal="ncal -b"
    else
        alias cal="/usr/bin/cal"
    fi
}

# Simplifies font installation, making font customization easier and improving visual experience in the shell
function install_font() {
    if [[ -z $1 ]]; then
        echo provide path to zipped font file
        return 1
    fi

    font_zip=$(realpath "$1")

    unzip "$font_zip" "*.ttf" "*.otf" -d ~/.local/share/fonts/
    fc-cache -vf
}

# Check system info using onefetch and output in terminal
function checkfetch() {
    local res=$(onefetch) &>/dev/null
    if [[ "$res" =~ "Error" ]]; then
        echo ""
    else
        echo $(onefetch)
    fi
}
