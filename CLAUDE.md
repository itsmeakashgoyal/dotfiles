# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Repo Is

A dotfiles repository using **GNU Stow** to manage symlinks. Each top-level directory (e.g., `git/`, `zsh/`, `nvim/`) is a Stow "package" that mirrors the target filesystem structure relative to `$HOME`. Running `stow <pkg>` creates symlinks in `$HOME` pointing into this repo.

```
dotfiles/nvim/.config/nvim/init.lua  →  stow nvim  →  ~/.config/nvim/init.lua (symlink)
```

## Common Commands

```bash
make install          # Full bootstrap: Homebrew, packages, shell setup, stow all
make run              # Stow all packages (create symlinks)
make stow pkg=<name>  # Stow a single package
make unstow pkg=<name># Remove a package's symlinks
make update           # Re-stow all packages (picks up new files)
make delete           # Unstow everything

make health           # Quick health check (symlinks, tools, configs)
make check            # Full verification of 40+ components with score
make diagnose         # Run all diagnostics
make packages         # Compare installed tools vs Brewfile

make list             # List available stow packages
make clean            # Remove backup files
```

**Lint (CI runs this too):**
```bash
shellcheck scripts/**/*.sh          # Lint shell scripts
shfmt -d scripts/                   # Check shell formatting
```

## Architecture

### Stow Packages
- `git/` → `~/.config/git/` — Git config, aliases (40+), delta diff viewer
- `zsh/` → `~/.zshenv` + `~/.config/zsh/` — Shell config with Zinit plugin manager
- `nvim/` → `~/.config/nvim/` — Neovim with Lazy.nvim
- `tmux/` → `~/.config/tmux/` — Tmux config
- `ohmyposh/` → `~/.config/ohmyposh/` — Prompt theme

### Zsh Configuration Layout
`zsh/.config/zsh/conf.d/` contains modular config files sourced alphabetically:
- `aliases.zsh`, `exports.zsh`, `functions.zsh`, `fzf.zsh`, `git.zsh`, `docker.zsh`, `options.zsh`, `python.zsh`, `startup.zsh`
- `private.zsh` — Machine-local overrides, gitignored

### Scripts Layout
- `scripts/utils/_helper.sh` — Shared library for logging, OS detection, command checking; sourced by all install scripts
- `scripts/utils/_logger.sh` — Multi-level logging (TRACE → FATAL)
- `scripts/verification/` — `health_check.sh`, `verify_installation.sh`, `system_info.sh`, `check_packages.sh`
- `scripts/setup/` — OS-specific setup: `_macOS.sh`, `_linuxOS.sh`, `_sublime.sh`, `_iterm.sh`
- `packages/install.sh` + `packages/Brewfile` — Homebrew bundle installation

### Installation Flow
`install.sh` → Homebrew (`packages/install.sh`) → set default shell → OS-specific setup (`scripts/setup/`) → `make run` (stow all) → health verification

### CI/CD
`.github/workflows/build_and_test.yml` tests on macOS and Ubuntu:
1. Lint: shellcheck + file permissions + YAML validation
2. Platform tests: full install → package verification → zsh config test

## Key Conventions

- All shell scripts source `scripts/utils/_helper.sh` for consistent logging and OS detection
- XDG Base Directory spec: configs live in `~/.config/`, not `$HOME` directly (except `.zshenv`)
- `private.zsh` is gitignored and used for machine-local secrets/overrides — don't commit secrets to tracked files
- The `.cursor/rules/security-global/` directory contains security linting rules that apply to code edits
