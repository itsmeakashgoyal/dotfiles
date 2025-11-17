# 🔍 Verification & Diagnostic Tools

This directory contains scripts to verify and diagnose your dotfiles installation. These tools help ensure everything is installed correctly and help troubleshoot issues.

## 📋 Available Scripts

### 1. Quick Health Check (`health_check.sh`)

**Purpose:** Fast overview of installation status

**Usage:**
```bash
bash ~/dotfiles/scripts/verification/health_check.sh
```

**What it checks:**
- ✓ Core components (Git, Homebrew, dotfiles directory)
- ✓ Shell configuration (Zsh, symlinks, Oh My Posh)
- ✓ Neovim setup
- ✓ Git configuration
- ✓ Essential CLI tools

**When to use:**
- After initial installation
- Quick status check
- Before making changes
- Daily health monitoring

---

### 2. Full Installation Verification (`verify_installation.sh`)

**Purpose:** Comprehensive verification of all components

**Usage:**
```bash
bash ~/dotfiles/scripts/verification/verify_installation.sh
```

**What it checks:**
- ✓ Directory structure
- ✓ All symlinks and their targets
- ✓ Core tools with version numbers
- ✓ Shell configuration and plugins
- ✓ Neovim setup and plugin manager
- ✓ Git configuration and tools (delta, lazygit)
- ✓ Tmux setup
- ✓ Modern CLI tools (bat, eza, ripgrep, fd, fzf, zoxide)
- ✓ Development tools (Python, Node, npm, etc.)

**Exit codes:**
- `0` - All checks passed
- `1` - Critical issues found

**Generates:** Report saved to `/tmp/dotfiles_verification_YYYYMMDD_HHMMSS.txt`

**When to use:**
- After installation to verify everything
- When troubleshooting issues
- Before and after major updates
- When reporting issues

---

### 3. System Information (`system_info.sh`)

**Purpose:** Display comprehensive system diagnostics

**Usage:**
```bash
# Show all information
bash ~/dotfiles/scripts/verification/system_info.sh

# Show specific sections
bash ~/dotfiles/scripts/verification/system_info.sh --system
bash ~/dotfiles/scripts/verification/system_info.sh --dev --tools
bash ~/dotfiles/scripts/verification/system_info.sh --dotfiles
```

**Available Options:**
- `--system` - OS, hardware, kernel, uptime
- `--shell` - Shell info, environment, terminal
- `--dev` - Git, Python, Node, Go, Ruby, Rust
- `--tools` - Neovim, Tmux, modern CLI tools
- `--dotfiles` - Dotfiles status, git info, symlinks
- `--network` - Network configuration, IP addresses
- `--disk` - Disk usage, home directory size
- `--process` - Load average, top processes
- `--env` - Key environment variables
- `--help` - Show help message

**When to use:**
- Gathering system information
- Troubleshooting environment issues
- Checking versions of installed tools
- Reporting bugs
- Documenting your setup

---

### 4. Package Verification (`check_packages.sh`)

**Purpose:** Verify installed packages against Brewfile

**Usage:**
```bash
# Check packages
bash ~/dotfiles/scripts/verification/check_packages.sh

# Export current packages to Brewfile
bash ~/dotfiles/scripts/verification/check_packages.sh --export ~/my-brewfile
```

**What it checks:**
- ✓ Homebrew installation and version
- ✓ Outdated packages
- ✓ Missing packages from Brewfile
- ✓ Extra packages not in Brewfile
- ✓ Taps, Formulae, and Casks

**Reports:**
- Installation coverage percentage
- Detailed status of each package
- Update recommendations

**When to use:**
- Verifying package installation
- Before/after updating packages
- Checking for missing dependencies
- Auditing installed packages
- Creating backup Brewfiles

---

## 🚀 Quick Start

### After Fresh Installation

Run in this order:

1. **Quick check:**
   ```bash
   bash ~/dotfiles/scripts/verification/health_check.sh
   ```

2. **If issues found, run full verification:**
   ```bash
   bash ~/dotfiles/scripts/verification/verify_installation.sh
   ```

3. **Check packages:**
   ```bash
   bash ~/dotfiles/scripts/verification/check_packages.sh
   ```

---

## 🎯 Use Cases

### Troubleshooting Installation Issues

```bash
# 1. Run health check
bash ~/dotfiles/scripts/verification/health_check.sh

# 2. If issues found, get detailed info
bash ~/dotfiles/scripts/verification/verify_installation.sh

# 3. Check system info for environment issues
bash ~/dotfiles/scripts/verification/system_info.sh --system --shell

# 4. Verify packages
bash ~/dotfiles/scripts/verification/check_packages.sh
```

### Reporting Bugs

Gather information for bug reports:

```bash
# System info
bash ~/dotfiles/scripts/verification/system_info.sh > ~/system_info.txt

# Installation status
bash ~/dotfiles/scripts/verification/verify_installation.sh > ~/install_status.txt

# Package status
bash ~/dotfiles/scripts/verification/check_packages.sh > ~/package_status.txt
```

### Before Making Changes

```bash
# Verify current state
bash ~/dotfiles/scripts/verification/health_check.sh

# Backup current packages
bash ~/dotfiles/scripts/verification/check_packages.sh --export ~/brewfile_backup
```

### After Updating

```bash
# Verify everything still works
bash ~/dotfiles/scripts/verification/verify_installation.sh

# Check for new/missing packages
bash ~/dotfiles/scripts/verification/check_packages.sh
```

---

## 📊 Understanding Results

### Health Check Results

- **✓ OK** (Green) - Component working correctly
- **⚠ WARNING** (Yellow) - Optional component missing or misconfigured
- **✗ MISSING** (Red) - Critical component missing

**Health Scores:**
- **90-100%** - Excellent (all critical components OK)
- **75-89%** - Good (minor issues)
- **60-74%** - Fair (some attention needed)
- **<60%** - Poor (immediate attention required)

### Installation Verification Results

- **PASS** (Green) - Component installed and configured
- **WARN** (Yellow) - Optional or minor issue
- **FAIL** (Red) - Critical component missing

### Package Check Results

- **Coverage Percentage** - % of Brewfile packages installed
- **Outdated Count** - Packages with updates available
- **Extra Packages** - Installed but not in Brewfile (usually dependencies)

---

## 🛠️ Script Details

### Requirements

All scripts require:
- Bash or Zsh
- Helper script at `~/dotfiles/scripts/utils/_helper.sh`
- Dotfiles directory at `~/dotfiles`

### Generated Files

Scripts may generate temporary files in `/tmp/`:
- `dotfiles_verification_*.txt` - Verification reports
- `setup_log.txt` - Installation logs

### Exit Codes

Standard exit codes for automation:
- `0` - Success, no issues
- `1` - Failures or critical issues detected

Use in CI/CD:
```bash
if bash ~/dotfiles/scripts/verification/verify_installation.sh; then
    echo "Installation verified successfully"
else
    echo "Installation verification failed"
    exit 1
fi
```

---

## 🔄 Maintenance

### Updating Scripts

These scripts are part of your dotfiles. To update:

```bash
cd ~/dotfiles
git pull
```

### Adding Custom Checks

To add custom checks, modify the scripts or create new ones in this directory following the existing patterns.

### Contributing

If you find bugs or want to add features:
1. Test your changes
2. Ensure scripts remain non-destructive (read-only)
3. Follow existing coding style
4. Update this README
5. Submit a pull request

---

## 📚 Related Documentation

- [Main README](../../README.md) - Full dotfiles documentation
- [Helper Functions](../utils/_helper.sh) - Shared utility functions
- [Installation Guide](../../README.md#-detailed-installation) - Installation instructions

---

Made with ❤️ for troubleshooting and peace of mind!

