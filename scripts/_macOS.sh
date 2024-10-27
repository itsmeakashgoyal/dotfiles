#!/usr/bin/env zsh

set -eu pipefail

# Function to check if a command was successful
check_command() {
    if [ $? -ne 0 ]; then
        echo "Error: $1 failed" >&2
        exit 1
    fi
}

# Install Xcode Command Line Tools
xcode-select --install
check_command "Xcode Command Line Tools installation"

echo "Complete the installation of Xcode Command Line Tools before proceeding."
read -p "Press enter to continue..."

# macOS System Preferences
echo "Configuring macOS system preferences..."

# Set scroll as traditional instead of natural
defaults write NSGlobalDomain com.apple.swipescrolldirection -bool false
killall Finder
check_command "Setting scroll direction"

# Reveal IP address, hostname, OS version, etc. when clicking the clock
# in the login window
sudo defaults write /Library/Preferences/com.apple.loginwindow AdminHostInfo HostName
check_command "Setting login window info"

# Disable automatic capitalization as it's annoying when typing code
defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false
check_command "Disabling automatic capitalization"

###############################################################################
# Energy saving                                                               #
###############################################################################

# Energy saving settings
echo "Configuring energy saving settings..."

# Enable lid wakeup
sudo pmset -a lidwake 1

# Sleep the display after 15 minutes
sudo pmset -a displaysleep 15

# Disable machine sleep while charging
sudo pmset -c sleep 0

# Set machine sleep to 5 minutes on battery
sudo pmset -b sleep 5
check_command "Setting energy saving preferences"

###############################################################################
# Screen                                                                      #
###############################################################################

# Screen settings
echo "Configuring screen settings..."

# Require password immediately after sleep or screen saver begins
defaults write com.apple.screensaver askForPassword -int 1
defaults write com.apple.screensaver askForPasswordDelay -int 0

# Save screenshots to the Screenshot folder
defaults write com.apple.screencapture location -string "${HOME}/Screenshot"

# Save screenshots in PNG format (other options: BMP, GIF, JPG, PDF, TIFF)
defaults write com.apple.screencapture type -string "png"

# Disable shadow in screenshots
defaults write com.apple.screencapture disable-shadow -bool true
check_command "Setting screen preferences"

###############################################################################
# Finder                                                                      #
###############################################################################

echo "Configuring Finder settings..."

# Finder: allow quitting via ⌘ + Q; doing so will also hide desktop icons
defaults write com.apple.finder QuitMenuItem -bool true

# Finder: show hidden files by default
# defaults write com.apple.finder AppleShowAllFiles -bool true

# Finder: show all filename extensions
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

# Finder: show status bar
defaults write com.apple.finder ShowStatusBar -bool true

# Finder: show path bar
defaults write com.apple.finder ShowPathbar -bool true

# Display full POSIX path as Finder window title
defaults write com.apple.finder _FXShowPosixPathInTitle -bool true

# Keep folders on top when sorting by name
defaults write com.apple.finder _FXSortFoldersFirst -bool true

# When performing a search, search the current folder by default
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"

# Disable the warning when changing a file extension
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

# Enable spring loading for directories
defaults write NSGlobalDomain com.apple.springing.enabled -bool true

# Avoid creating .DS_Store files on network or USB volumes
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

# Use list view in all Finder windows by default
# Four-letter codes for the other view modes: `icnv`, `clmv`, `glyv`
defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"

# Show the ~/Library folder
chflags nohidden ~/Library && xattr -d com.apple.FinderInfo ~/Library

# Expand the following File Info panes:
# "General", "Open with", and "Sharing & Permissions"
defaults write com.apple.finder FXInfoPanesExpanded -dict \
    General -bool true \
    OpenWith -bool true \
    Privileges -bool true

check_command "Setting Finder preferences"

###############################################################################
# Dock, Dashboard, and hot corners                                            #
###############################################################################

echo "Configuring Dock settings..."

# Minimize windows into their application's icon
defaults write com.apple.dock minimize-to-application -bool true

# Show indicator lights for open applications in the Dock
defaults write com.apple.dock show-process-indicators -bool true

# Don't show recent applications in Dock
defaults write com.apple.dock show-recents -bool false

check_command "Setting Dock preferences"

###############################################################################
# Safari & WebKit                                                             #
###############################################################################

echo "Configuring Safari settings..."

# Privacy: don't send search queries to Apple
defaults write com.apple.Safari UniversalSearchEnabled -bool false
defaults write com.apple.Safari SuppressSearchSuggestions -bool true

# Press Tab to highlight each item on a web page
defaults write com.apple.Safari WebKitTabToLinksPreferenceKey -bool true
defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2TabsToLinks -bool true

# Show the full URL in the address bar (note: this still hides the scheme)
defaults write com.apple.Safari ShowFullURLInSmartSearchField -bool true

# Prevent Safari from opening 'safe' files automatically after downloading
defaults write com.apple.Safari AutoOpenSafeDownloads -bool false

# Warn about fraudulent websites
defaults write com.apple.Safari WarnAboutFraudulentWebsites -bool true

# Enable "Do Not Track"
defaults write com.apple.Safari SendDoNotTrackHTTPHeader -bool true

# Update extensions automatically
defaults write com.apple.Safari InstallExtensionUpdatesAutomatically -bool true

check_command "Setting Safari preferences"

###############################################################################
# Mail                                                                        #
###############################################################################

echo "Configuring Mail settings..."

# Copy email addresses as `foo@example.com` instead of `Foo Bar <foo@example.com>` in Mail.app
defaults write com.apple.mail AddressesIncludeNameOnPasteboard -bool false

# Display emails in threaded mode, sorted by date (oldest at the top)
defaults write com.apple.mail DraftsViewerAttributes -dict-add "DisplayInThreadedMode" -string "yes"
defaults write com.apple.mail DraftsViewerAttributes -dict-add "SortedDescending" -string "yes"
defaults write com.apple.mail DraftsViewerAttributes -dict-add "SortOrder" -string "received-date"

# Disable inline attachments (just show the icons)
defaults write com.apple.mail DisableInlineAttachmentViewing -bool true

check_command "Setting Mail preferences"

###############################################################################
# Activity Monitor                                                            #
###############################################################################

echo "Configuring Activity Monitor settings..."

# Show the main window when launching Activity Monitor
defaults write com.apple.ActivityMonitor OpenMainWindow -bool true

# Visualize CPU usage in the Activity Monitor Dock icon
defaults write com.apple.ActivityMonitor IconType -int 5

# Show all processes in Activity Monitor
defaults write com.apple.ActivityMonitor ShowCategory -int 0

# Sort Activity Monitor results by CPU usage
defaults write com.apple.ActivityMonitor SortColumn -string "CPUUsage"
defaults write com.apple.ActivityMonitor SortDirection -int 0

check_command "Setting Activity Monitor preferences"

###############################################################################
# Mac App Store                                                               #
###############################################################################

echo "Configuring Mac App Store settings..."

# Enable the automatic update check
defaults write com.apple.SoftwareUpdate AutomaticCheckEnabled -bool true

# Check for software updates daily, not just once per week
defaults write com.apple.SoftwareUpdate ScheduleFrequency -int 1

# Download newly available updates in background
defaults write com.apple.SoftwareUpdate AutomaticDownload -int 1

# Install System data files & security updates
defaults write com.apple.SoftwareUpdate CriticalUpdateInstall -int 1

# Turn on app auto-update
defaults write com.apple.commerce AutoUpdate -bool true

check_command "Setting Mac App Store preferences"

###############################################################################
# Photos                                                                      #
###############################################################################

echo "Configuring Photos settings..."

# Prevent Photos from opening automatically when devices are plugged in
defaults -currentHost write com.apple.ImageCapture disableHotPlug -bool true

check_command "Setting Photos preferences"

###############################################################################
# Kill affected applications                                                  #
###############################################################################

echo "Restarting affected applications..."
affected_apps=(
    "Activity Monitor" "Address Book" "Calendar" "Contacts" "cfprefsd"
    "Dock" "Finder" "Mail" "Messages" "Photos" "Safari" "SystemUIServer"
    "Terminal" "iCal"
)

for app in "${affected_apps[@]}"; do
    killall "${app}" &>/dev/null || true
done

echo "Done. Note that some of these changes require a logout/restart to take effect."
