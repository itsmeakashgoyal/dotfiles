#!/bin/bash

#################################################
#      File: install.sh                         #
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
if [ ! -f "$HELPER_FILE" ]; then
    echo "Error: Helper file not found at $HELPER_FILE" >&2
    exit 1
fi

# Source the helper file
. "$HELPER_FILE"

# Enable strict mode for better error handling
set -eu pipefail

readonly PACKAGES_DIR="${DOTFILES_DIR}/packages"

# Define variables for each package manager and include the corresponding package lists
brewfile="${PACKAGES_DIR}/Brewfile"
node_packages="${PACKAGES_DIR}/node_packages.txt"
python_packages="${PACKAGES_DIR}/pipx_packages.txt"
ruby_packages="${PACKAGES_DIR}/ruby_packages.txt"
rust_packages="${PACKAGES_DIR}/rust_packages.txt"

# ------------------------------------------------------------------------------
# Homebrew Functions
# ------------------------------------------------------------------------------
update_brew() {
    if ! command_exists brew; then
        return 1
    fi

    info "Updating Homebrew..."
    brew update
    brew upgrade
    [ "$OS_TYPE" = "Darwin" ] && brew upgrade --cask
    brew cleanup
}

install_homebrew() {
    # Install Homebrew if it isn't already installed
    if command_exists brew; then
        success "Homebrew is already installed"
    else
        info "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        check_command "Homebrew installation"

        # Configure Homebrew PATH
        case "$OS_TYPE" in
            "Darwin")
                if [ -x "/opt/homebrew/bin/brew" ]; then
                    info "Configuring Homebrew in PATH for Apple Silicon Mac..."
                    eval "$(/opt/homebrew/bin/brew shellenv)"  # Apple Silicon
                elif [ -x "/usr/local/bin/brew" ]; then
                    info "Configuring Homebrew in PATH for Intel Mac..."
                    eval "$(/usr/local/bin/brew shellenv)"     # Intel Mac
                fi
                ;;
            "Linux")
                info "Configuring Homebrew in PATH for Linux..."
                eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
                ;;
        esac
    fi

    # Verify installation
    if ! command -v brew &>/dev/null; then
        error "Failed to configure Homebrew in PATH"
        return 1
    fi

    # Turn off analytics
    brew analytics off

    # Update Homebrew and Upgrade any already-installed formulae
    info "Updating Homebrew and upgrading formulae..."
    update_brew
}

install_packages() {
    info "Installing Homebrew packages..."

    if [ ! -f "$brewfile" ]; then
        error "Error: Brewfile not found at $brewfile"
        return 1
    fi

    brew bundle --file="$brewfile"
    success "Finished installing Homebrew packages."
}

# Install Node with FNM and set latest LTS as default, then install npm packages
install_node_packages() {
  # Install FNM
  if ! command -v fnm &>/dev/null; then
    substep_info "Installing FNM..."
    curl -fsSL https://fnm.vercel.app/install | bash
    eval "$(fnm env --use-on-cd)" # needed to install npm packages - already set for Fish
    substep_success "FNM installed."
  fi

  # Install latest LTS version of Node with FNM and set as default
  if ! fnm use --lts &>/dev/null; then
    info "Installing latest LTS version of Node..."
    fnm install --lts
    fnm alias lts-latest default
    fnm use default
    substep_success "Node LTS installed and set as default for FNM."
  fi

  # Install NPM packages
  info "Installing NPM packages..."
  npm install -g $(cat $node_packages)
  corepack enable
  success "All NPM global packages installed."
}

# Define a function for installing packages with Python
install_python_packages() {
  if ! command -v $(which python) &>/dev/null; then
    substep_info "Python not found. Installing..."
    brew install python
    if ! command -v $(which python) &>/dev/null; then
      error "Failed to install Python. Exiting."
      exit 1
    fi
    substep_success "Python installed."
  fi
  info "Installing Python packages..."
  pip install $(cat "$python_packages")
  success "Finished installing Python packages."
}

# Install Ruby with rbenv, set 3.1.3 as default, then install gems
install_ruby_packages() {
  # Install rbenv
  if ! command -v rbenv &>/dev/null; then
    substep_info "Installing rbenv..."
    brew install rbenv ruby-build
    eval "$(rbenv init - zsh)" # needed to install gems - already set for Fish
    substep_success "rbenv installed."
  fi

  # Install Ruby 3.1.3 with rbenv and set as default
  if ! rbenv versions | grep -q 3.1.3; then
    substep_info "Installing Ruby 3.1.3..."
    rbenv install 3.1.3
    rbenv global 3.1.3
    rbenv rehash
    substep_success "Ruby 3.1.3 installed and set as default for rbenv."
  fi

  # Install gems
  info "Installing Ruby gems..."
  gem install $(cat ruby_packages.txt)
  success "Ruby gems installed."
}

# Define a function for installing packages with Rust
install_rust_packages() {
  if ! command -v $(which rustc) &>/dev/null; then
    substep_info "Rust not found. Installing..."
    brew install rust rustup-init
    rustup-init
    if ! command -v $(which rustc) &>/dev/null; then
      error "Failed to install Rust. Exiting."
      exit 1
    fi
    substep_success "Rust installed."
  fi
  info "Installing Rust packages..."
  rustup update
  cargo install $(cat "$rust_packages")
  success "Finished installing Rust packages."
}

# ------------------------------------------------------------------------------
# Main Function
# ------------------------------------------------------------------------------
main() {
    info "Initiating packages installation.."

    # Call each installation function
    install_homebrew
    install_packages
    update_brew
    install_node_packages
    install_python_packages
    # install_ruby_packages
    install_rust_packages

    success "Packages installation completed successfully"
    log_message "Packages installation completed successfully"
}

# Set error trap
trap 'print_error "$LINENO" "$BASH_COMMAND" "$?"' ERR

# Run main
main
