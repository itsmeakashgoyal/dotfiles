#!/usr/bin/env bash
#                    █████
#                   ░░███
#   █████   ██████  ███████   █████ ████ ████████
#  ███░░   ███░░███░░░███░   ░░███ ░███ ░░███░░███
# ░░█████ ░███████   ░███     ░███ ░███  ░███ ░███
#  ░░░░███░███░░░    ░███ ███ ░███ ░███  ░███ ░███
#  ██████ ░░██████   ░░█████  ░░████████ ░███████
# ░░░░░░   ░░░░░░     ░░░░░    ░░░░░░░░  ░███░░░
#                                        ░███
#                                        █████
#                                       ░░░░░
#
#  ▓▓▓▓▓▓▓▓▓▓
# ░▓ author ▓ Akash Goyal
# ░▓ file   ▓ scripts/setup/_macOS.sh
# ░▓▓▓▓▓▓▓▓▓▓
# ░░░░░░░░░░

# ------------------------------------------------------------------------------
# macOS System Configuration Script
# Configures macOS system preferences, Finder, Dock, and application settings
#
# CAUTION: This script will modify your macOS system configuration.
# Review carefully before running and remove anything you don't want.
# Some changes require a logout/restart to take effect.
# ------------------------------------------------------------------------------

# Skip in CI environment (before loading anything)
if [[ -n "${CI:-}" ]]; then
    echo "Skipping macOS configuration in CI environment"
    exit 0
fi

# Load helper functions
SCRIPT_DIR="${HOME}/dotfiles/scripts"
HELPER_FILE="${SCRIPT_DIR}/utils/_helper.sh"

if [[ ! -f "$HELPER_FILE" ]]; then
    echo "Error: Helper file not found at $HELPER_FILE" >&2
    exit 1
fi

source "$HELPER_FILE"
set -euo pipefail

# Request sudo access upfront
sudo -v

# ------------------------------------------------------------------------------
# Xcode Command Line Tools
# ------------------------------------------------------------------------------
setup_xcode() {
    if ! xcode-select -p &>/dev/null; then
        info "Installing Xcode Command Line Tools..."
        xcode-select --install
        check_command "Xcode Command Line Tools installation"
        success "Please complete the Xcode installation before continuing."
        read -r "?Press Enter to continue..."
    else
        info "Xcode Command Line Tools already installed"
    fi
}

# ------------------------------------------------------------------------------
# System Preferences
# ------------------------------------------------------------------------------
configure_system_preferences() {
    info "Configuring system preferences..."

    # Input & Scrolling
    info "→ Configuring input settings..."
    defaults write NSGlobalDomain com.apple.swipescrolldirection -bool false
    defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false
    check_command "Setting input preferences"

    # Login Window
    info "→ Configuring login window..."
    sudo defaults write /Library/Preferences/com.apple.loginwindow AdminHostInfo HostName
    check_command "Setting login window info"

    # Energy & Power Management
    info "→ Configuring energy settings..."
    sudo pmset -a lidwake 1           # Enable lid wakeup
    sudo pmset -a displaysleep 15     # Display sleep after 15 min
    sudo pmset -c sleep 0             # Never sleep while charging
    sudo pmset -b sleep 5             # Sleep after 5 min on battery
    check_command "Setting energy preferences"

    success "System preferences configured"
}

# ------------------------------------------------------------------------------
# Screen & Security Settings
# ------------------------------------------------------------------------------
configure_screen_settings() {
    info "Configuring screen and security settings..."

    # Screen Saver & Lock
    info "→ Setting screen lock preferences..."
    defaults write com.apple.screensaver askForPassword -int 1
    defaults write com.apple.screensaver askForPasswordDelay -int 0

    # Screenshots
    info "→ Configuring screenshot settings..."
    mkdir -p "${HOME}/Screenshot"
    defaults write com.apple.screencapture location -string "${HOME}/Screenshot"
    defaults write com.apple.screencapture type -string "png"
    defaults write com.apple.screencapture disable-shadow -bool true
    
    check_command "Setting screen preferences"
    success "Screen settings configured"
}

# ------------------------------------------------------------------------------
# Finder Configuration
# ------------------------------------------------------------------------------
configure_finder() {
    info "Configuring Finder..."

    # General Finder Settings
    info "→ Setting general Finder preferences..."
    defaults write com.apple.finder QuitMenuItem -bool true
    defaults write NSGlobalDomain AppleShowAllExtensions -bool true
    defaults write com.apple.finder ShowStatusBar -bool true
    defaults write com.apple.finder ShowPathbar -bool true
    defaults write com.apple.finder _FXShowPosixPathInTitle -bool true
    defaults write com.apple.finder _FXSortFoldersFirst -bool true

    # Search & Warnings
    info "→ Configuring search and warnings..."
    defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"
    defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

    # Spring Loading
    info "→ Enabling spring loading..."
    defaults write NSGlobalDomain com.apple.springing.enabled -bool true

    # Network & USB Volumes
    info "→ Preventing .DS_Store on network/USB..."
    defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
    defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

    # View Settings
    info "→ Setting default view mode..."
    defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"

    # Show ~/Library folder
    info "→ Unhiding Library folder..."
    chflags nohidden ~/Library && xattr -d com.apple.FinderInfo ~/Library 2>/dev/null || true

    # File Info Panes
    info "→ Expanding File Info panes..."
    defaults write com.apple.finder FXInfoPanesExpanded -dict \
        General -bool true \
        OpenWith -bool true \
        Privileges -bool true

    check_command "Setting Finder preferences"
    success "Finder configured"
}

# ------------------------------------------------------------------------------
# Dock Configuration
# ------------------------------------------------------------------------------
configure_dock() {
    info "Configuring Dock..."

    # Dock Behavior
    defaults write com.apple.dock minimize-to-application -bool true
    defaults write com.apple.dock show-process-indicators -bool true
    defaults write com.apple.dock show-recents -bool false

    check_command "Setting Dock preferences"
    success "Dock configured"
}

# ------------------------------------------------------------------------------
# Safari Configuration
# ------------------------------------------------------------------------------
configure_safari() {
    info "Configuring Safari..."

    # Privacy & Security
    info "→ Setting privacy preferences..."
    defaults write com.apple.Safari UniversalSearchEnabled -bool false
    defaults write com.apple.Safari SuppressSearchSuggestions -bool true
    defaults write com.apple.Safari SendDoNotTrackHTTPHeader -bool true
    defaults write com.apple.Safari WarnAboutFraudulentWebsites -bool true

    # Behavior
    info "→ Setting Safari behavior..."
    defaults write com.apple.Safari WebKitTabToLinksPreferenceKey -bool true
    defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2TabsToLinks -bool true
    defaults write com.apple.Safari ShowFullURLInSmartSearchField -bool true
    defaults write com.apple.Safari AutoOpenSafeDownloads -bool false

    # Extensions
    info "→ Enabling automatic extension updates..."
    defaults write com.apple.Safari InstallExtensionUpdatesAutomatically -bool true

    check_command "Setting Safari preferences"
    success "Safari configured"
}

# ------------------------------------------------------------------------------
# Activity Monitor Configuration
# ------------------------------------------------------------------------------
configure_activity_monitor() {
    info "Configuring Activity Monitor..."

    defaults write com.apple.ActivityMonitor OpenMainWindow -bool true
    defaults write com.apple.ActivityMonitor IconType -int 5
    defaults write com.apple.ActivityMonitor ShowCategory -int 0
    defaults write com.apple.ActivityMonitor SortColumn -string "CPUUsage"
    defaults write com.apple.ActivityMonitor SortDirection -int 0

    check_command "Setting Activity Monitor preferences"
    success "Activity Monitor configured"
}

# ------------------------------------------------------------------------------
# App Store Configuration
# ------------------------------------------------------------------------------
configure_app_store() {
    info "Configuring Mac App Store..."

    # Automatic Updates
    defaults write com.apple.SoftwareUpdate AutomaticCheckEnabled -bool true
    defaults write com.apple.SoftwareUpdate ScheduleFrequency -int 1
    defaults write com.apple.SoftwareUpdate AutomaticDownload -int 1
    defaults write com.apple.SoftwareUpdate CriticalUpdateInstall -int 1
    defaults write com.apple.commerce AutoUpdate -bool true

    check_command "Setting Mac App Store preferences"
    success "App Store configured"
}

# ------------------------------------------------------------------------------
# Restart Applications
# ------------------------------------------------------------------------------
restart_applications() {
    info "Restarting affected applications..."

    local apps=(
        "Activity Monitor"
        "Dock"
        "Finder"
        "Mail"
        "Photos"
        "Safari"
        "SystemUIServer"
        "Terminal"
    )

    for app in "${apps[@]}"; do
        killall "${app}" &>/dev/null || true
    done

    success "Applications restarted"
}

# ------------------------------------------------------------------------------
# Main Function
# ------------------------------------------------------------------------------
main() {
    log_message "macOS configuration script started"
    
    info "
##############################################
#      macOS System Configuration            #
##############################################
#  This will customize your macOS settings.  #
#  Some changes require logout/restart.      #
##############################################
"

    # Close System Preferences to prevent overriding our changes
    osascript -e 'tell application "System Preferences" to quit' 2>/dev/null || true

    # Run configuration steps
    setup_xcode
    configure_system_preferences
    configure_screen_settings
    configure_finder
    configure_dock
    configure_safari
    configure_activity_monitor
    configure_app_store
    restart_applications

    success "
###################################################
#     macOS Configuration Completed!              #
#     Some changes require logout/restart.        #
###################################################
"
    log_message "macOS configuration completed successfully"
}

# Set error trap
trap 'print_error "$LINENO" "$BASH_COMMAND" "$?"' ERR

# Run main
main
