# 🔍 Verification & Diagnostic Tools

## Overview

This directory contains scripts to verify and diagnose your dotfiles installation. These tools are **automatically integrated** into the installation process and can be run manually anytime.

---

## 🎯 Automatic Integration

### During Installation

Verification is **automatically run** at the end of:

1. **Main installation** (`install.sh`) - Runs health check
2. **Package installation** (`packages/install.sh`) - Verifies packages

No manual intervention needed! 🎉

### Manual Verification

You can run verification anytime using:

```bash
make health          # Quick health check
make check           # Full verification
make packages        # Package verification
make diagnose        # Complete diagnostic suite
```

---

## 📋 Available Scripts

### 1. Health Check (`health_check.sh`)

**Quick 22-point check** of critical components.

```bash
make health
```

**Checks:**
- Core components (Git, Homebrew, dotfiles)
- Shell configuration (Zsh, Oh My Posh)
- Neovim setup
- Git configuration
- Essential CLI tools

**Use when:**
- After installation
- Daily health monitoring
- Before making changes

---

### 2. Full Verification (`verify_installation.sh`)

**Comprehensive 40+ point check** with detailed reporting.

```bash
make check
```

**Checks:**
- Everything in health check
- Tool versions
- Symlink targets
- Directory structure
- Development tools

**Generates:** Report in `/tmp/`

---

### 3. System Information (`system_info.sh`)

**Display system diagnostics** and environment details.

```bash
make sysinfo
```

**Shows:**
- OS and hardware info
- Installed software versions
- Dotfiles status
- Network configuration
- Disk usage

---

### 4. Package Verification (`check_packages.sh`)

**Verify packages** against Brewfile.

```bash
make packages
```

**Checks:**
- Installed vs missing packages
- Outdated packages
- Extra packages
- Installation coverage

---

## 🚀 Quick Start

### After Fresh Installation

Installation automatically verifies! But you can re-check:

```bash
make health
```

### Regular Maintenance

```bash
# Weekly
make health

# Monthly
make diagnose
```

### Before Reporting Issues

```bash
make diagnose > ~/diagnostic-report.txt
```

---

## 📊 Understanding Results

### Status Indicators

| Symbol | Meaning |
|--------|---------|
| ✓ | Pass - Working correctly |
| ⚠ | Warning - Optional issue |
| ✗ | Fail - Critical problem |

### Health Scores

| Score | Status |
|-------|--------|
| 90-100% | Excellent |
| 75-89% | Good |
| 60-74% | Fair |
| <60% | Needs attention |

---

## 🔄 CI/CD Integration

Verification is included in GitHub Actions workflow (`.github/workflows/verify.yml`):

```yaml
- name: Run health check
  run: bash scripts/verification/health_check.sh

- name: Run full verification
  run: bash scripts/verification/verify_installation.sh
```

Runs on every push to test installation on:
- macOS
- Linux (Ubuntu)

---

## 💡 Tips

1. **Run health check regularly** - Catch issues early
2. **Use in scripts** - Exit codes enable automation
3. **Save reports** - Useful for troubleshooting
4. **Check before updates** - Verify current state first

---

## 🔗 Related

- [Main README](../../README.md) - Full documentation
- [Logger Documentation](../utils/_logger.sh) - Logging system
- [Helper Functions](../utils/_helper.sh) - Utility functions

---

**All scripts are read-only and safe to run anytime!**
