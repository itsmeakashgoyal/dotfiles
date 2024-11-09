# ------------------------------------------------------------------------------
# UbuntuOS-specific aliases and functions
# ------------------------------------------------------------------------------

# Detect OS type
OS_TYPE=$(uname)
if [ "$OS_TYPE" != "Linux" ]; then
    return 0 # Exit the file without terminating the session
fi

alias apt_update="sudo apt-get update && sudo apt-get -y upgrade"
alias apt_clean="sudo apt-get clean && sudo apt-get autoclean && sudo apt-get autoremove"
