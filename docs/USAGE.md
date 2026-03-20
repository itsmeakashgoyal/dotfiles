# Usage

[← Back to README](../README.md)

---

## Makefile Commands

```bash
make help                 # Show all available commands
```

### Stow Management

```bash
make run                  # Stow all packages
make stow pkg=nvim        # Stow a single package
make unstow pkg=nvim      # Unstow a single package
make update               # Restow all (picks up file changes)
make delete               # Unstow everything
make list                 # List available packages
```

### Diagnostics

```bash
make health               # Quick health check (symlinks, tools, configs)
make check                # Full verification of all components
make sysinfo              # System info (OS, hardware, dev tools)
make packages             # Compare installed packages vs. Brewfile
make diagnose             # Run all diagnostics at once
```

---

## Updating Your Dotfiles

```bash
cd ~/dotfiles
git pull
make update
exec zsh
```

---

## Adding Homebrew Packages

Edit `packages/Brewfile`, then:

```bash
brew bundle --file=~/dotfiles/packages/Brewfile
```

---

## Editing Configs

All edits happen in the repo. Stow symlinks mean changes take effect immediately -- no re-linking needed.

```bash
nvim ~/dotfiles/zsh/.config/zsh/conf.d/aliases.zsh   # Zsh aliases
nvim ~/dotfiles/git/.config/git/config                # Git config
nvim ~/dotfiles/nvim/.config/nvim/lua/akgoyal/plugins # Nvim plugins
nvim ~/dotfiles/tmux/.config/tmux/tmux.conf           # Tmux config
```

---

## Verification & Diagnostics

### Quick Health Check

```bash
make health
```

Checks core components (git, brew, zsh, nvim, tmux), symlinks, and essential CLI tools. Runs in seconds.

### Full Verification

```bash
make check
```

Comprehensive check of all 40+ components: directory structure, symlinks, tool versions, git config, plugin managers, and development tools. Outputs a score and saves a report to `/tmp/`.

### System Information

```bash
bash ~/dotfiles/scripts/verify/check.sh system_info.sh            # Everything
bash ~/dotfiles/scripts/verify/check.sh system_info.sh --system    # OS & hardware only
bash ~/dotfiles/scripts/verify/check.sh system_info.sh --dev       # Dev tools only
```

### Package Audit

```bash
make packages
```

Compares installed Homebrew packages against the Brewfile. Shows missing, extra, and outdated packages.
