# dutils Quick Reference

## 📋 Command Cheat Sheet

```bash
dutils help              # Show help
dutils version           # Show version

# Common Operations
dutils cleanup [component]      # Clean configurations
dutils ssh-keygen -e EMAIL      # Generate SSH keys
dutils detect-os                # Show OS info
dutils list-functions           # List zsh functions

# Advanced
dutils diff                     # Interactive file diff
dutils install-nvim             # Install Neovim (Linux)
dutils debug SCRIPT             # Debug bash scripts
```

---

## 🚀 Most Used Commands

### 1. Generate SSH Key
```bash
dutils ssh-keygen -e your.email@example.com
```

### 2. Clean Neovim Config
```bash
dutils cleanup nvim
```

### 3. Detect OS
```bash
dutils detect-os
```

### 4. List Functions
```bash
dutils list-functions
```

---

## 💡 Useful Aliases

Add to your `.zshrc`:

```zsh
alias dcl='dutils cleanup'
alias dssh='dutils ssh-keygen'
alias dos='dutils detect-os'
alias ddiff='dutils diff'
alias dlf='dutils list-functions'
```

---

## 🔧 Cleanup Options

```bash
dutils cleanup dotfiles   # Remove symlinks
dutils cleanup homebrew   # Uninstall Homebrew
dutils cleanup nvim       # Clean Neovim
dutils cleanup tmux       # Clean tmux
dutils cleanup all        # Clean everything
dutils cleanup -y all     # No confirmations
```

---

## 📁 File Locations

```
~/dotfiles/scripts/utils/dutils           # Main CLI
~/dotfiles/scripts/utils/_helper.sh       # Helper functions
~/dotfiles/scripts/utils/README.md        # Full documentation
~/.local/bin/dutils                       # Symlink (if created)
```

---

## 🐛 Troubleshooting

### Command not found
```bash
# Check if executable
ls -la ~/dotfiles/scripts/utils/dutils

# Make executable
chmod +x ~/dotfiles/scripts/utils/dutils

# Create symlink
ln -sf ~/dotfiles/scripts/utils/dutils ~/.local/bin/dutils
```

### Permission denied
```bash
chmod +x ~/dotfiles/scripts/utils/_*.sh
```
