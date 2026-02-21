# ------------------------------------------------------------------------------
# Custom Functions
# ------------------------------------------------------------------------------

# Navigate up multiple directories
# Usage: up 3 (goes up 3 directories)
up() {
    local d=""
    limit=$1
    for ((i = 1; i <= limit; i++)); do
        d=$d/..
    done
    d=$(echo $d | sed 's/^\///')
    if [ -z "$d" ]; then
        d=..
    fi
    cd $d
}

# ------------------------------------------------------------------------------
# Docker Container Inspection and Interaction
# ------------------------------------------------------------------------------
# Get container IP
dcip() {
    local container_name="$1"
    if [[ -z "$container_name" ]]; then
        echo "Usage: dip CONTAINER_NAME"
        return 1
    fi
    docker inspect --format '{{ .NetworkSettings.IPAddress }}' "$container_name"
}

# Execute bash in container
dbash() {
    local container_name="$1"
    if [[ -z "$container_name" ]]; then
        echo "Usage: dbash CONTAINER_NAME"
        return 1
    fi
    docker exec -it "$container_name" bash || docker exec -it "$container_name" sh
}

# Show docker disk usage
dsize() {
    docker system df -v
}

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

    # macOS notification (only if running on macOS)
    if [[ $disconnected == true ]] && [[ "$(uname -s)" == "Darwin" ]]; then
        osascript -e 'display notification "Connection restored ✅" with title "Internet"' 2>/dev/null
    fi

    echo '✅ Connected to internet.'
}

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

# SSH with password helper (use SSH keys instead for better security!)
# WARNING: Storing passwords in shell config is insecure
# This function expects credentials in ~/.ssh/sshpass_config
function sshp() {
    local machine="$1"
    local config_file="${HOME}/.ssh/sshpass_config"

    # Check if sshpass is installed
    if ! command -v sshpass >/dev/null 2>&1; then
        echo "Error: sshpass is not installed."
        echo "Install: brew install hudochenkov/sshpass/sshpass  # macOS"
        echo "        sudo apt-get install sshpass               # Linux"
        return 1
    fi

    # Check if machine name is provided
    if [[ -z "$machine" ]]; then
        echo "Error: No machine name provided."
        echo "Usage: sshp <machinename>"
        echo ""
        echo "Configure credentials in: $config_file"
        echo "Format: USER=username"
        echo "        PASS=password"
        return 1
    fi

    # Check for config file
    if [[ ! -f "$config_file" ]]; then
        echo "Error: Configuration file not found: $config_file"
        echo "Create it with your credentials (ensure it's chmod 600!)"
        return 1
    fi

    # Source credentials from config
    source "$config_file"

    if [[ -z "$USER" ]] || [[ -z "$PASS" ]]; then
        echo "Error: USER or PASS not set in $config_file"
        return 1
    fi

    # Connect using sshpass
    sshpass -p "$PASS" ssh "$USER@$machine" -o StrictHostKeyChecking=no
}

# ------------------------------------------------------------------------------
# Session Management Functions
# ------------------------------------------------------------------------------
# Attach to existing session or create new one
ta() {
    if [[ -n "$1" ]]; then
        tmux attach -t "$1"
        return
    fi

    # Interactive session selection
    tmux ls 2>/dev/null &&
        read "tmux_session?Session name/number (default: misc): " &&
        tmux attach -t "${tmux_session:-misc}" ||
        tmux new -s "${tmux_session:-misc}"
}

# ------------------------------------------------------------------------------
# tmux functions
# ------------------------------------------------------------------------------
# Interactive session selection with preview
tls() {
    local session=$(tmux list-sessions -F "#{session_name}" |
        fzf --preview 'tmux list-windows -t {}' \
            --preview-window=right:50% \
            --prompt="Select session: ")

    [[ -n "$session" ]] && tmux switch-client -t "$session"
}

# Kill selected session interactively
tks() {
    local session=$(tmux list-sessions -F "#{session_name}" |
        fzf --preview 'tmux list-windows -t {}' \
            --preview-window=right:50% \
            --prompt="Select session to kill: ")

    [[ -n "$session" ]] && tmux kill-session -t "$session"
}

# Per-platform settings
case "$(uname -s)" in
    Darwin)
        # macOS disk info (uses df instead of lsblk)
        function disks() {
            echo "\n\033[0;35m╓───── Disk Usage\033[0;31m ──────────────────────────────────────\033[0m"
            df -h | awk 'NR==1 || /^\/dev\/disk/'
            echo "\n\033[0;35m╓───── Mount Points\033[0;31m ────────────────────────────────────\033[0m"
            mount | grep ^/dev/ | column -t
        }
        ;;
    Linux)
        # Linux disk info with lsblk
        function disks() {
            if command -v lsblk >/dev/null 2>&1; then
                echo "\n\033[0;35m╓───── Block Devices\033[0;31m ───────────────────────────────────\033[0m"
                lsblk -o NAME,SIZE,TYPE,MOUNTPOINT,FSTYPE
            fi
            echo "\n\033[0;35m╓───── Disk Usage\033[0;31m ────────────────────────────────────────\033[0m"
            df -h -x tmpfs -x devtmpfs
            if command -v swapon >/dev/null 2>&1; then
                echo "\n\033[0;35m╓───── Swap\033[0;31m ─────────────────────────────────────────────\033[0m"
                swapon --show
            fi
        }

        # Show system information
        function system_info() {
            echo "System Information:"
            echo "──────────────────"
            [[ -f /etc/os-release ]] && source /etc/os-release && echo "OS: $PRETTY_NAME"
            echo "Kernel: $(uname -r)"
            command -v free >/dev/null && echo "Memory: $(free -h | awk '/^Mem:/ {print $3 "/" $2}')"
            echo "Disk Usage: $(df -h / | awk 'NR==2 {print $5 " (" $3 "/" $2 ")"}')"
            echo "CPU Load:$(uptime | awk -F'load average:' '{print $2}')"
        }
        ;;
esac
