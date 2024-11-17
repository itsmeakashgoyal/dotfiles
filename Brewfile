# ------------------------------------------------------------------------------
# Taps
# ------------------------------------------------------------------------------
tap "homebrew/bundle"
tap "jandedobbeleer/oh-my-posh"

if OS.mac?
    tap "homebrew/command-not-found"
end

# ------------------------------------------------------------------------------
# Common Packages
# ------------------------------------------------------------------------------
# Development Tools
brew "antidote"          # Plugin manager for zsh
brew "automake"          # Build automation tool
brew "cmake"            # Build system
brew "gcc"              # GNU compiler collection
brew "git-delta"        # Better git diffs
brew "go"               # Go programming language
brew "node"             # Node.js
brew "python"           # Python programming language
brew "ruby"             # Ruby programming language
brew "rust"             # Rust programming language

# Shell Tools
brew "awk"              # Text processing tool
brew "bat"              # Better cat
brew "diff-so-fancy"    # Better git diff
brew "eza"              # Better ls
brew "fd"               # Better find
brew "htop"             # Process viewer
brew "jq"               # JSON processor
brew "ripgrep"          # Better grep
brew "shellcheck"       # Shell script analysis
brew "shfmt"            # Shell formatter
brew "tldr"             # Simplified man pages
brew "tree"             # Directory listings
brew "wget"             # File downloader
brew "zoxide"           # Better cd

# Python Tools
brew "black"            # Python formatter
brew "pyenv"            # Python version manager
brew "pylint"           # Python linter

# Lua Tools
brew "lua-language-server"
brew "luajit"
brew "luarocks"
brew "luv"
brew "stylua"           # Lua formatter

# System Monitoring
brew "bpytop"           # Resource monitor
brew "btop"             # Resource monitor

# GitHub Tools
brew "gh"               # GitHub CLI

# Oh My Posh
brew "jandedobbeleer/oh-my-posh/oh-my-posh"

# ------------------------------------------------------------------------------
# macOS Specific
# ------------------------------------------------------------------------------
if OS.mac?
    # Core Tools
    brew "coreutils"        # GNU core utilities
    brew "curl"             # Better URL transfers
    brew "openssh"          # OpenSSH client
    brew "ssh-copy-id"      # SSH key installer
    brew "stow"             # Symlink farm manager
    brew "trash"            # Safe rm alternative
    brew "zsh"              # Zsh shell
    brew "zstd"             # Data compression

    # Development
    brew "brew-cask-completion"
    brew "brew-gem"
    brew "clang-format"     # C/C++ formatter
    brew "editorconfig"     # Editor config
    brew "llvm"             # LLVM toolchain

    # Casks (macOS only)
    cask "font-3270-nerd-font"
    cask "font-fira-code-nerd-font"
    cask "font-jetbrains-mono-nerd-font"
    cask "font-meslo-lg-nerd-font"
    cask "font-source-code-pro"
    cask "font-ubuntu-mono-nerd-font"
    cask "google-chrome"
    cask "google-drive"
    cask "iterm2"
    cask "rar"
    cask "rectangle"
    cask "sublime-text"

    # VS Code Extensions
    vscode "freecodecamp.freecodecamp-dark-vscode-theme"
    vscode "github.github-vscode-theme"
    vscode "ms-vscode-remote.remote-containers"
    vscode "ms-vscode-remote.remote-ssh"
    vscode "ms-vscode.cmake-tools"
    vscode "ms-vscode.cpptools"
    vscode "ms-vscode.cpptools-extension-pack"
    vscode "ms-vscode.cpptools-themes"
    vscode "ms-vscode.makefile-tools"
end

# ------------------------------------------------------------------------------
# Linux Specific
# ------------------------------------------------------------------------------
if OS.linux?
    brew "gettext"          # GNU internationalization
    brew "xclip"            # X11 clipboard tool
end
