# Changelog

All notable changes to this dotfiles setup are documented here.
Format follows [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

---

## [Unreleased]

---

## [1.0.0] — 2024-01-01

### Added
- GNU Stow-based symlink management for all packages (`git`, `zsh`, `nvim`, `tmux`, `ohmyposh`)
- Full macOS and Linux (Ubuntu/Debian) support via a single `install.sh`
- One-liner bootstrap script (`bootstrap.sh`) for fresh machine setup
- Homebrew `Brewfile` with 100+ curated packages
- Modular Zsh configuration via `conf.d/` directory (sourced alphabetically)
- Zinit plugin manager with lazy-loaded plugins
- Powerlevel10k prompt with instant prompt enabled
- Neovim configuration with Lazy.nvim plugin manager and LSP support
- Tmux configuration with TPM, vim-aware pane switching, and session persistence
- Git configuration with 40+ aliases and `delta` diff viewer
- `fzf` integration for fuzzy history, file, and process search
- Comprehensive Makefile with colorized help, stow management, and diagnostics
- Health check and full verification scripts (`make health`, `make check`)
- GitHub Actions CI/CD pipeline testing on macOS and Ubuntu
- `dutils` CLI utility for OS detection and helper functions
- XDG Base Directory compliance throughout
- `private.zsh` pattern for machine-local secrets (gitignored)
- macOS system preferences script (Finder, Dock, keyboard, trackpad)
- Linux setup script (apt packages, fonts, locale)
- SSH key generation helper (`scripts/utils/_setup_ssh.sh`)
- Pre-commit hooks via `.pre-commit-config.yaml`
- Issue and PR templates for GitHub
