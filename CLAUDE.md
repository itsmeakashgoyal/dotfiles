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
shellcheck -x scripts/**/*.sh       # Lint shell scripts (-x follows sourced files)
shfmt -d scripts/                   # Check shell formatting
```

## Architecture

### Stow Packages
Defined in `Makefile` via `STOW_PACKAGES` variable. To add a new package, create the directory and add it to that list.
- `git/` → `~/.config/git/` — Git config, aliases (40+), delta diff viewer, GPG signing
- `zsh/` → `~/.zshenv` + `~/.config/zsh/` — Shell config with Zinit plugin manager
- `nvim/` → `~/.config/nvim/` — Neovim with Lazy.nvim + Harpoon
- `tmux/` → `~/.config/tmux/` — Tmux config
- `television/` → `~/.config/television/` — Fuzzy finder with channels
- `bin/` → `~/.local/bin/` — Custom scripts (yank, zoxide-edit)
- `atuin/` → `~/.config/atuin/` — Shell history search
- `fastfetch/` → `~/.config/fastfetch/` — System info display


### Zsh Configuration Layout
`zsh/.config/zsh/conf.d/` contains numbered modular config files sourced in order:
- `00-logo.zsh` — ASCII art startup greeting (guards: non-tmux, non-p10k)
- `01-exports.zsh` — PATH, environment variables (sourced early in .zshrc)
- `02-options.zsh` — Shell options, history, completion settings
- `03-startup.zsh` — Completion system init (sourced early in .zshrc)
- `04-aliases.zsh` — Command aliases (eza, bat, tmux, docker, system)
- `05-functions.zsh` — Utility functions (navigation, docker, network, archives)
- `06-git.zsh` — Git aliases and interactive functions (uses television)
- `07-docker.zsh` — Docker container/image management
- `08-python.zsh` — Python, pyenv, venv management
- `09-television.zsh` — Television fuzzy finder setup (Ctrl+T, Tab)
- `10-atuin.zsh` — Atuin shell history (Ctrl+R)
- `11-colored-man-pages.zsh` — Colored man page output
- `12-prompt-styles.zsh` — Pure ZSH prompt alternatives (minimal/classic/dual/ascii/arrows/ninja)
- `99-private.zsh` — Machine-local overrides, gitignored

### Scripts Layout
- `scripts/lib/core.sh` — Shared library for logging, OS detection, command checking; sourced by all install scripts
- `scripts/verify/check.sh` → `check.py` — Health/verification checks (`--quick`, `--full`, `--packages`, `--system`)
- `scripts/setup/` — OS-specific setup: `macos.sh`, `linux.sh`, `sublime.sh`, `iterm.sh`
- `packages/install.sh` + `packages/Brewfile` — Homebrew bundle installation

### Installation Flow
`install.sh` → Homebrew (`packages/install.sh`) → set default shell → OS-specific setup (`scripts/setup/`) → `make run` (stow all) → health verification

### CI/CD
`.github/workflows/build_and_test.yml` tests on macOS and Ubuntu:
1. Lint: shellcheck + file permissions + YAML validation
2. Platform tests: full install → package verification → zsh config test

## Key Conventions

- All shell scripts must: start with `#!/bin/bash`, use `set -euo pipefail`, source `scripts/lib/core.sh`, and pass `shellcheck -x`
- Use `log_message`, `info`, `success`, `warning`, `error` from `core.sh` for output — never raw `echo` for status messages
- XDG Base Directory spec: configs live in `~/.config/`, not `$HOME` directly (except `.zshenv`)
- `private.zsh` is gitignored and used for machine-local secrets/overrides — don't commit secrets to tracked files
- Pre-commit hooks (`.pre-commit-config.yaml`) run shellcheck, shfmt, and detect-secrets automatically
- The `.cursor/rules/security-global/` directory contains security linting rules that apply to code edits
- Documentation lives in `docs/` — see `docs/ARCHITECTURE.md` for deep technical details
