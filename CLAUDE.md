# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Repo Is

A dotfiles repository using **GNU Stow** to manage symlinks on macOS and Linux. Each top-level directory (e.g., `git/`, `zsh/`, `nvim/`) is a Stow "package" that mirrors the target filesystem structure relative to `$HOME`. Running `stow <pkg>` creates symlinks in `$HOME` pointing into this repo.

```text
dotfiles/nvim/.config/nvim/init.lua  →  stow nvim  →  ~/.config/nvim/init.lua (symlink)
```

**Windows is also supported**, but via a separate, non-Stow path: `install.ps1` + `scripts/setup/windows.ps1` create symlinks with a hand-rolled PowerShell function instead (Stow doesn't run natively on Windows). See the `powershell/` package and the Windows subsection below. The recommended daily-driver path for the actual dev shell is still WSL2, where all the Stow packages work unmodified.

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
find . -type f \( -name "*.sh" -o -name "dutils" \) -exec shellcheck -x {} +  # Lint shell scripts
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
- `starship/` → `~/.config/starship/` — Cross-shell prompt (default; replaced Powerlevel10k)

`powershell/` mirrors this same layout for `Documents/PowerShell/Microsoft.PowerShell_profile.ps1`, but is deliberately **not** in `STOW_PACKAGES` — Windows uses `scripts/setup/windows.ps1`'s own symlink function instead (see Windows section below).

### Zsh Configuration Layout
`zsh/.config/zsh/conf.d/` contains numbered modular config files sourced in order:
- `00-logo.zsh` — ASCII art startup greeting (guards: interactive, non-tmux)
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
- `13-vi-mode.zsh` — Vi keybindings
- `14-abbreviations.zsh` — Shell abbreviations
- `15-nix.zsh` — Nix/Home Manager PATH setup (Linux)
- `99-private.zsh` — Machine-local overrides, gitignored

### Scripts Layout
- `scripts/lib/core.sh` — Shared library for logging, command checking; sourced by all bash entry-point scripts. Has side effects on source (creates `~/linuxtoolbox`, `/tmp/dotfiles.log`).
- `scripts/lib/os-detect.sh` — OS detection only (`os::is_mac`/`os::is_linux`/`os::arch`/`os::detail`), split out from `core.sh` specifically because it has none of core.sh's side effects — safe to source from zsh's interactive startup too. `scripts/lib/osdetect.py` mirrors the same API for Python scripts.
- `scripts/verify/check.sh` → `check.py` — Health/verification checks (`--quick`, `--full`, `--packages`, `--system`)
- `scripts/setup/` — OS-specific setup: `linux.sh` (apt deps), `nix.sh` (Nix/Home Manager, Linux CLI tools), `sublime.sh`, `iterm.sh` (macOS), `uninstall.sh`, `windows.ps1` (Windows). There is no `macos.sh`.
- `packages/install.sh` + `packages/Brewfile` — Homebrew bundle installation (macOS only — Linux uses Nix instead, see `nix.sh`/`nix/home.nix`)

### Installation Flow
`install.sh` self-locates `DOTFILES_DIR` → sources `core.sh` → set default shell → OS branch (macOS: `packages/install.sh`; Linux: `scripts/setup/linux.sh` + `scripts/setup/nix.sh`) → macOS-only `sublime.sh`/`iterm.sh` → `make run` (stow all) → health verification

### Windows
Separate path, no Stow: `install.ps1` → `scripts/setup/windows.ps1` (Scoop packages, hand-rolled symlinks via `$SYMLINK_MAP`, PowerShell modules, `Test-Installation` health check that exits non-zero under `$env:CI`). Not yet required in CI (`test-windows` job is soft-gated/`continue-on-error`).

### CI/CD
`.github/workflows/build_and_test.yml`:
1. Lint: shellcheck + file permissions + YAML validation + `py_compile`
2. `test-macos` / `test-ubuntu` (required): full install → package verification → zsh config test (sources `.zshrc`, asserts real exit codes) → Neovim headless config test → uninstall → verify-uninstall
3. `test-windows` (soft-gated, informational only for now): `windows.ps1` install → PowerShell profile symlink check

## Key Conventions

- All shell scripts must: start with `#!/bin/bash`, use `set -euo pipefail`, source `scripts/lib/core.sh`, and pass `shellcheck -x`
- Use `log_message`, `info`, `success`, `warning`, `error` from `core.sh` for output — never raw `echo` for status messages
- XDG Base Directory spec: configs live in `~/.config/`, not `$HOME` directly (except `.zshenv`)
- `private.zsh` is gitignored and used for machine-local secrets/overrides — don't commit secrets to tracked files
- Pre-commit hooks (`.pre-commit-config.yaml`) run shellcheck, shfmt, and detect-secrets automatically
- Documentation lives in `docs/` — see `docs/ARCHITECTURE.md` for deep technical details
