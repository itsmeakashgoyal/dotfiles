# Dotfiles Utility Scripts

A unified collection of utility scripts for managing dotfiles, SSH keys, system information, and more.

## 🚀 Quick Start

### Installation

The utility tool is already accessible through the `dutils` command. If not available:

```bash
# Make sure ~/.local/bin is in your PATH
export PATH="$HOME/.local/bin:$PATH"

# Create symlink (already done if you ran install.sh)
ln -sf ~/dotfiles/scripts/utils/dutils ~/.local/bin/dutils
```

### Basic Usage

```bash
# Show all available commands
dutils help

# Show version
dutils version

# Use a specific command
dutils <command> [options]
```

---

## 📚 Available Commands

### 1. **cleanup** - Clean Up Configurations

Remove dotfiles, Homebrew, Neovim, or tmux configurations safely.

```bash
# Interactive mode
dutils cleanup

# Clean specific components
dutils cleanup nvim              # Clean Neovim only
dutils cleanup homebrew          # Uninstall Homebrew
dutils cleanup dotfiles tmux     # Clean multiple components

# Auto-confirm all actions
dutils cleanup -y all            # Clean everything without prompts
```

**Components:**
- `dotfiles` - Remove symlinks
- `homebrew` - Uninstall Homebrew and all packages
- `nvim` - Clean Neovim configuration and data
- `tmux` - Remove tmux configuration
- `all` - Clean everything

**Options:**
- `-y, --yes` - Auto-confirm all actions
- `-h, --help` - Show help

---

### 2. **ssh-keygen** - Generate SSH Keys

Generate SSH keys with custom names and types.

```bash
# Generate with default type (ed25519)
dutils ssh-keygen -e your.email@example.com

# Generate with specific type
dutils ssh-keygen -e your.email@example.com -t rsa
dutils ssh-keygen -e your.email@example.com -t ed25519

# Show help
dutils ssh-keygen --help
```

**Features:**
- Automatically copies public key to clipboard
- Adds key to ssh-agent
- Prompts for new name if key already exists
- Sets correct permissions (600 for private, 644 for public)

**Options:**
- `-e EMAIL` - Email address for the SSH key (required)
- `-t TYPE` - Key type: `ed25519` (default) or `rsa`
- `-h` - Show help

**Supported Key Types:**
- `ed25519` - Modern, secure, recommended (default)
- `rsa` - Traditional, widely compatible

---

### 3. **detect-os** - Detect Operating System

Detect current operating system and architecture with detailed information.

```bash
dutils detect-os
```

**Output Example:**
```
Operating System Detection
==========================
OS Type:     macOS (Apple Silicon)
Kernel:      Darwin
Version:     23.0.0
Arch:        arm64
```

**Detected Platforms:**
- macOS (Apple Silicon) - M1/M2/M3 Macs
- macOS (Intel) - Intel-based Macs
- Linux (x86_64) - Standard Linux
- Linux (ARM) - ARM/Raspberry Pi Linux

---

### 4. **diff** - Interactive File Diff

Compare two files with interactive selection and live watching.

```bash
# Start interactive diff
dutils diff
```

**Features:**
- 🔍 **Interactive file selection** with fzf
- 🎨 **Syntax-highlighted diffs** (if diff-so-fancy is installed)
- 👀 **Live watching** - automatically updates when files change
- 🧹 **Clean interface** with clear screen between updates

**Dependencies:**
- **Required:** `fzf`, `diff`, `entr`
- **Optional:** `diff-so-fancy` (for prettier output)

**Installation:**
```bash
# macOS
brew install fzf entr diff-so-fancy

# Linux (Debian/Ubuntu)
sudo apt-get install fzf entr
```

**Usage:**
1. Run `dutils diff`
2. Select first file from fzf menu
3. Select second file from fzf menu
4. View diff (updates automatically when files change)
5. Press `Ctrl+C` to exit

---

### 5. **install-nvim** - Install Neovim (Linux Only)

Install the latest version of Neovim on Linux systems.

```bash
dutils install-nvim
```

**What it does:**
1. Backs up existing Neovim configuration to `~/linuxtoolbox/backup/nvim`
2. Removes old Neovim installation
3. Downloads latest Neovim from GitHub
4. Installs to `/opt/nvim`

**Note:** This command is Linux-only. On macOS, use:
```bash
brew install neovim
```

---

### 6. **list-functions** - List Custom Zsh Functions

Display all custom functions defined in your zsh configuration.

```bash
dutils list-functions
```

**Output Example:**
```
Function            Description
--------            -----------
dcip                Get container IP
dbash               Execute bash in container
dsize               Show docker disk usage
up                  Navigate up multiple directories
```

**Features:**
- Parses `~/dotfiles/zsh/local/function.zsh`
- Extracts function names and comments
- Displays in a formatted table
- Sorted alphabetically

---

### 7. **debug** - Run Scripts with Debug Tracing

Run a bash script with detailed debug output (bash -x mode).

```bash
# Debug a script
dutils debug script.sh

# Debug with arguments
dutils debug script.sh arg1 arg2
```

**Features:**
- Shows bash version, hostname, and username
- Traces each command execution
- Shows line numbers and function names
- Useful for troubleshooting scripts

**Output includes:**
- Timestamp for each line
- Function call stack
- Variable expansions
- Exit codes

---

## 🔧 Script Organization

### Core Files

```
scripts/utils/
├── dutils                       # Main CLI entry point
├── _helper.sh                   # Shared helper functions
├── _cleanup.sh                  # Cleanup functionality
├── _detect_os.sh               # OS detection
├── _diff_files_interactive.sh  # Interactive diff
├── _install_nvim.sh            # Neovim installer
├── _print-functions.sh         # Function lister
├── _run_with_xtrace.sh         # Debug runner
├── _setup_ssh.sh               # SSH key generator
└── README.md                   # This file
```

### Helper Functions (_helper.sh)

The helper file provides shared functionality:

**Logging Functions:**
- `log_message()` - Log with timestamp
- `error()` - Display error messages (red)
- `info()` - Display info messages (blue)
- `warning()` - Display warnings (yellow)
- `success()` - Display success messages (green)

**Utility Functions:**
- `command_exists()` - Check if command exists
- `symlink()` - Create symlinks with backup
- `print_error()` - Print detailed error with stack trace

**Constants:**
- `$DOTFILES_DIR` - Path to dotfiles
- `$CONFIG_DIR` - Path to config directory
- `$BACKUP_DIR` - Path for backups
- `$OS_TYPE` - Operating system type

---

## 🎯 Design Principles

### 1. **Safety First**
- All destructive operations require confirmation
- Automatic backups before overwriting
- Clear error messages
- Rollback capabilities

### 2. **Cross-Platform**
- Works on both macOS and Linux
- Automatic OS detection
- Platform-specific fallbacks
- Graceful degradation

### 3. **User-Friendly**
- Interactive modes when possible
- Clear help messages
- Informative output
- Consistent interface

### 4. **Maintainable**
- Modular design
- Shared helper functions
- Consistent error handling
- Well-documented code

---

## 🐛 Troubleshooting

### Command not found: dutils

**Solution:**
```bash
# Make sure symlink exists
ln -sf ~/dotfiles/scripts/utils/dutils ~/.local/bin/dutils

# Make sure ~/.local/bin is in PATH
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
```

### Permission denied

**Solution:**
```bash
# Make script executable
chmod +x ~/dotfiles/scripts/utils/dutils
chmod +x ~/dotfiles/scripts/utils/_*.sh
```

### Helper file not found

**Solution:**
```bash
# Verify helper file exists
ls -la ~/dotfiles/scripts/utils/_helper.sh

# If missing, check your dotfiles are properly cloned
cd ~/dotfiles
git status
```

### diff command: diff-so-fancy not found

This is **not an error**. The diff command works without it, but looks better with it.

**Optional installation:**
```bash
# macOS
brew install diff-so-fancy

# Linux
npm install -g diff-so-fancy
# or
brew install diff-so-fancy  # if using Linuxbrew
```

---

## 📝 Examples

### Example 1: Fresh System Setup

```bash
# Generate SSH key
dutils ssh-keygen -e your.email@example.com

# Check OS info
dutils detect-os

# Install Neovim (Linux only)
dutils install-nvim

# List available functions
dutils list-functions
```

### Example 2: Clean Up Old Installation

```bash
# Interactive cleanup
dutils cleanup

# Or clean specific components
dutils cleanup nvim tmux

# Nuclear option (clean everything)
dutils cleanup -y all
```

### Example 3: Compare Configuration Files

```bash
# Compare any two files in your dotfiles
dutils diff
# Select .zshrc (old)
# Select .zshrc.backup
# Watch for changes
```

### Example 4: Debug a Script

```bash
# Debug your custom script
dutils debug ~/my-script.sh

# Debug with arguments
dutils debug ~/deploy.sh production --verbose
```

---

## 🔄 Updates & Maintenance

### Updating Scripts

Scripts are part of your dotfiles repository:

```bash
cd ~/dotfiles
git pull origin main
```

### Adding New Commands

1. Create new script in `scripts/utils/`
2. Add command handler to `dutils` main script
3. Update this README
4. Test on both macOS and Linux (if applicable)

### Code Style

- Use `#!/usr/bin/env bash` shebang
- Enable strict mode: `set -euo pipefail`
- Source `_helper.sh` for common functions
- Add header banner with author and file info
- Include `--help` option for all commands
- Use `readonly` for constants
- Quote all variable expansions

---

## 🤝 Contributing

### Guidelines

1. **Test on multiple platforms** - macOS and Linux
2. **Add help documentation** - Include `--help` flag
3. **Use helper functions** - Don't duplicate code
4. **Handle errors gracefully** - Check dependencies
5. **Update README** - Document new features

### Testing Checklist

- [ ] Script has execute permissions
- [ ] Works on macOS
- [ ] Works on Linux
- [ ] Help message is clear
- [ ] Error handling works
- [ ] Added to `dutils` main script
- [ ] Updated README

---

## 📚 Related Documentation

- **Zsh Configuration:** See `/dotfiles/zsh/README.md`
- **Main Dotfiles:** See `/dotfiles/README.md`
- **Neovim Setup:** See `/dotfiles/nvim/README.md`
- **Tmux Setup:** See `/dotfiles/tmux/README.md`

---

## 📊 Comparison: Before vs After

### Before (Without dutils)

```bash
# Had to remember full paths
~/dotfiles/scripts/utils/_setup_ssh.sh -e email@example.com

# Difficult to discover what's available
ls ~/dotfiles/scripts/utils/

# No unified interface
# Each script had different arguments style
# No centralized help
```

### After (With dutils)

```bash
# Simple, memorable command
dutils ssh-keygen -e email@example.com

# Easy to discover
dutils help

# Unified interface
# Consistent arguments across all commands
# Centralized help and documentation
```

---

## 🎓 Advanced Usage

### Combining Commands

```bash
# Setup new machine
dutils detect-os && \
dutils ssh-keygen -e user@email.com && \
dutils list-functions

# Clean and reinstall Neovim (Linux)
dutils cleanup nvim && dutils install-nvim
```

### Using in Scripts

```bash
#!/usr/bin/env bash

# Source the helper library
source ~/dotfiles/scripts/utils/_helper.sh

# Use helper functions
info "Starting setup..."
command_exists git || error "Git is required"
success "Setup complete!"
```

### Debugging Your Own Scripts

```bash
# Add to your script for debugging
set -x  # Enable debug mode
# ... your code ...
set +x  # Disable debug mode

# Or use dutils
dutils debug my-script.sh
```

---

## 🔐 Security Notes

### SSH Key Generation

- **Never share private keys** (files without `.pub` extension)
- **Use ed25519** for modern systems (smaller, faster, more secure)
- **Use strong passphrases** (optional but recommended)
- **Backup your keys** securely

### Cleanup Command

- **Review before confirming** - cleanup operations are irreversible
- **Backups are created** in `~/linuxtoolbox/backup/`
- **Use `-y` flag carefully** - it skips confirmations

---

## 💡 Tips & Tricks

### Tab Completion

Add to your `.zshrc` for tab completion:

```zsh
# dutils completion
compdef '_arguments "1: :(cleanup ssh-keygen detect-os diff install-nvim list-functions debug help version)"' dutils
```

### Aliases

Add useful aliases to your `.zshrc`:

```zsh
alias dcl='dutils cleanup'
alias dssh='dutils ssh-keygen'
alias dos='dutils detect-os'
alias ddiff='dutils diff'
alias dlf='dutils list-functions'
```

### Quick Reference Card

Print and keep handy:

```
dutils cleanup        # Clean configurations
dutils ssh-keygen     # Generate SSH keys
dutils detect-os      # Show OS info
dutils diff           # Compare files
dutils install-nvim   # Install Neovim (Linux)
dutils list-functions # List zsh functions
dutils debug          # Debug scripts
```

---
If you encounter issues:

1. Check this README first
2. Run with `bash -x` for debugging: `bash -x $(which dutils) <command>`
3. Check the helper file is properly sourced
4. Verify file permissions: `chmod +x ~/dotfiles/scripts/utils/_*.sh`
5. Review the log file: `/tmp/setup_log.txt`
