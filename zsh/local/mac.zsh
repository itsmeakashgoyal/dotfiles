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
# ░▓ file   ▓ zsh/local/mac.zsh
# ░▓▓▓▓▓▓▓▓▓▓
# ░░░░░░░░░░
#
#█▓▒░
# ------------------------------------------------------------------------------
# MacOS-specific Configuration
# ------------------------------------------------------------------------------

# Exit if not running on macOS
[[ "$(uname)" != "Darwin" ]] && return 0

# ------------------------------------------------------------------------------
# System Updates
# ------------------------------------------------------------------------------
# Update macOS and all package managers
alias update='sudo softwareupdate -i -a && \  # System updates
              brew update && \                 # Update Homebrew
              brew upgrade && \                # Upgrade formulae
              brew cleanup && \                # Clean up Homebrew
              npm update -g && \               # Update global npm packages
              gem update --system && \         # Update RubyGems
              gem update' # Update gems

# Individual update commands
alias update_system='sudo softwareupdate -i -a' # Only system updates
alias update_brew='brew update && brew upgrade && \
                  brew upgrade --cask && brew cleanup' # Only Homebrew updates

# ------------------------------------------------------------------------------
# Finder Configuration
# ------------------------------------------------------------------------------
# Toggle hidden files in Finder (Cmd + Shift + . also works in Finder)
alias show_hidden="defaults write com.apple.finder AppleShowAllFiles -bool true && killall Finder"
alias hide_hidden="defaults write com.apple.finder AppleShowAllFiles -bool false && killall Finder"

# Toggle desktop icons
alias hide_desktop="defaults write com.apple.finder CreateDesktop -bool false && killall Finder"
alias show_desktop="defaults write com.apple.finder CreateDesktop -bool true && killall Finder"

# ------------------------------------------------------------------------------
# System Commands
# ------------------------------------------------------------------------------
# Lock screen
alias afk="pmset displaysleepnow" # Put display to sleep
alias lock="/System/Library/CoreServices/Menu\ Extras/User.menu/Contents/Resources/CGSession -suspend"

# Network
alias localip="ipconfig getifaddr en0"                                                                    # Show local IP address
alias wifi="/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport -I" # WiFi info

# Cleanup
alias cleanup="find . -type f -name '*.DS_Store' -ls -delete" # Remove .DS_Store files

# caffeinate: Prevent the system from sleeping
alias ch='caffeinate -u -t 3600'

# ------------------------------------------------------------------------------
# Finder Integration
# ------------------------------------------------------------------------------
# Change to Finder's current directory
cdf() {
    local finder_path
    finder_path=$(osascript -e 'tell app "Finder" to POSIX path of (insertion location as alias)' 2>/dev/null)
    if [[ -n "$finder_path" ]]; then
        cd "$finder_path" || return 1
        echo "Changed to: $finder_path"
    else
        echo "Failed to get Finder path"
        return 1
    fi
}

# ------------------------------------------------------------------------------
# Homebrew Configuration
# ------------------------------------------------------------------------------
# Initialize Homebrew
if [[ -x "/opt/homebrew/bin/brew" ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"

    # Set up Homebrew completions (only once)
    if [[ -d "$(brew --prefix)/share/zsh/site-functions" ]]; then
        FPATH="$(brew --prefix)/share/zsh/site-functions:${FPATH}"
    fi
fi

# ------------------------------------------------------------------------------
# Application Shortcuts
# ------------------------------------------------------------------------------
# Only create aliases for installed applications
[[ -d "/Applications/Google Chrome.app" ]] &&
    alias chrome='/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome'

#█▓▒░ disk info
function disks() {
    # echo
    function _e() {
        title=$(echo "$1" | sed 's/./& /g')
        echo "
\033[0;31m╓─────\033[0;35m ${title}
\033[0;31m╙────────────────────────────────────── ─ ─"
    }
    # loops
    function _l() {
        X=$(printf '\033[0m')
        G=$(printf '\033[0;32m')
        R=$(printf '\033[0;35m')
        C=$(printf '\033[0;36m')
        W=$(printf '\033[0;37m')
        i=0
        while IFS= read -r line || [[ -n $line ]]; do
            if [[ $i == 0 ]]; then
                echo "${G}${line}${X}"
            else
                if [[ "$line" == *"%"* ]]; then
                    percent=$(echo "$line" | awk '{ print $5 }' | sed 's!%!!')
                    color=$W
                    ((percent >= 75)) && color=$C
                    ((percent >= 90)) && color=$R
                    line=$(echo "$line" | sed "s/${percent}%/${color}${percent}%${W}/")
                fi
                echo "${W}${line}${X}" | sed "s/\([─└├┌┐└┘├┤┬┴┼]\)/${R}\1${W}/g; s! \(/.*\)! ${C}\1${W}!g;"
            fi
            i=$((i + 1))
        done < <(printf '%s' "$1")
    }
    # outputs
    m=$(lsblk -a | grep -v loop)
    _e "mount.points"
    _l "$m"
    d=$(df -h)
    _e "disk.usage"
    _l "$d"
    s=$(swapon --show)
    _e "swaps"
    _l "$s"
}
