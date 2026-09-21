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
make install dry=1    # Preview the whole install without changing anything
make run              # Stow all packages (create symlinks)
make stow pkg=<name>  # Stow a single package
make unstow pkg=<name># Remove a package's symlinks
make update           # Re-stow all packages (picks up new files)
make delete           # Unstow everything

make menu             # Interactive picker for every dutils command
make manifest         # Regenerate package lists from packages.toml
make manifest-check   # Fail if a generated list drifted (CI gate)

make health           # Quick health check (symlinks, tools, configs)
make check            # Full verification of 40+ components with score
make diagnose         # Run all diagnostics
make packages         # Compare installed tools vs packages.toml

make list             # List available stow packages
make clean            # Remove backup files
```

Verification/diagnostics/benchmark `make` targets (`health`, `check`, `diagnose`,
`sysinfo`, `packages`, `bench`, `bench-detail`) are thin aliases to the `dutils`
CLI (`dutils health`, `dutils check`, …). `dutils` is the cross-platform path and
the single implementation — it also works on Windows, which has no `make`. `make`
remains the entry point for the install/stow/nix *lifecycle*; `dutils` is the
day-to-day maintenance/introspection hub (`menu`, `manifest`, `update`, `cleanup`, verification,
`bench`, `profile`, `ssh-setup`, `secrets`, `theme`, `zcompile`, `vulns`, `diff`, …). See `scripts/dutils/dutils`.
`dutils menu` is the interactive entry point: a television-backed picker over the whole command
registry, with a numbered fallback when `tv` isn't installed.

**Lint (CI runs this too):**
```bash
find . -type f -name "*.sh" ! -name "profile_zsh.sh" -exec shellcheck -x {} +  # Lint shell scripts (dutils is Python, excluded)
dutils manifest check               # Generated package lists match packages.toml
```
> `shfmt` is **not** run over this repo — the shell is hand-aligned (see Key Conventions).

## Architecture

### The package manifest (`packages.toml`)
**Single source of truth** for every tool installed on every platform, and for the Stow package
list. The per-manager lists are *generated* from it and delimited by `# BEGIN GENERATED: <id>` /
`# END GENERATED: <id>` markers — only the text between markers is rewritten:

| Region | Target file |
| --- | --- |
| `brew` | `brew/Brewfile` |
| `nix` | `nix/home.nix` (`home.packages`) |
| `scoop` / `symlinks` | `scripts/setup/windows.ps1` (`$SCOOP_PACKAGES` / `$SYMLINK_MAP`) |
| `apt` / `apt-optional` | `scripts/setup/linux.sh` |
| `stow` | `Makefile` (`STOW_PACKAGES`) |

**Never hand-edit inside the markers.** Edit `packages.toml`, then run `dutils manifest generate`.
`dutils manifest check` is a CI gate that fails on drift. `scripts/lib/manifest.py` is the loader
(with a small TOML-subset fallback parser, because `tomllib` needs Python 3.11 and macOS ships 3.9);
`scripts/dutils/manifest.py` is the renderer/CLI. `scripts/verify/check.py` reads the same manifest,
so health checks can't drift from what's declared.

Note: `nix/home.nix` must stay `nixfmt --check` clean (CI gate), so the nix renderer emits
single-space trailing comments rather than aligned columns.

### Stow Packages
`STOW_PACKAGES` in the `Makefile` is **generated** from `packages.toml`'s `[[stow]]` entries. To add a package: create the directory, add a `[[stow]]` entry (with `platforms` and, for Windows, an optional `windows_target`), then run `dutils manifest generate` — that updates both the Makefile list and the Windows `$SYMLINK_MAP`. Or use `dutils new`, which scaffolds the directory for you.
- `git/` → `~/.config/git/` — Git config, aliases (40+), delta diff viewer, GPG signing
- `zsh/` → `~/.zshenv` + `~/.config/zsh/` — Shell config with Zinit plugin manager
- `nvim/` → `~/.config/nvim/` — Neovim with Lazy.nvim + Harpoon
- `tmux/` → `~/.config/tmux/` — Tmux config
- `television/` → `~/.config/television/` — Fuzzy finder with channels
- `bin/` → `~/.local/bin/` — Custom scripts (yank, zoxide-edit) + a `dutils` symlink into `scripts/dutils/`, so stowing `bin` puts the `dutils` CLI on `PATH` automatically
- `atuin/` → `~/.config/atuin/` — Shell history search
- `fastfetch/` → `~/.config/fastfetch/` — System info display
- `starship/` → `~/.config/starship/` — Cross-shell prompt; **the default** (`starship.toml`). Set `DOTFILES_PROMPT=p10k` to switch back to Powerlevel10k (`zsh/.config/zsh/.p10k.zsh` + zinit), which stays fully wired. The `DOTFILES_PROMPT` knob is at the top of `.zshrc` (section 1); it must be set before `.zshrc` runs (not in `99-private.zsh`, which loads too late)
- `ghostty/` → `~/.config/ghostty/` — Ghostty terminal config (macOS; trying alongside iTerm2, see `settings/iterm/`)
- `yazi/` → `~/.config/yazi/` — Yazi terminal file manager (minimal config, built-in theme)
- `readline/` → `~/.inputrc` — GNU Readline config for bash/python/psql and other libreadline sub-shells (zsh has its own line editor and ignores it)

`powershell/` mirrors this same layout for `Documents/PowerShell/Microsoft.PowerShell_profile.ps1`, but is deliberately **not** in `STOW_PACKAGES` — Windows uses `scripts/setup/windows.ps1`'s own symlink function instead (see Windows section below). The profile is a thin loader that resolves its own symlink and dot-sources `profile.d/*.ps1` (mirroring zsh's `conf.d/`); `profile.d/` lives only in the repo (found via the symlink's target), so it needs no separate symlink.

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
- `16-iterm.zsh` — iTerm2 shell integration (macOS; sources `~/.iterm2_shell_integration.zsh`, regenerated per machine)
- `17-bookmarks.zsh` — Named directory bookmarks via `hash -d` (`cd ~df`, `~cfg`); machine-specific ones go in `99-private.zsh`
- `99-private.zsh` — Machine-local overrides, gitignored

### Scripts Layout
- `scripts/lib/core.sh` — Shared library for logging, command checking; sourced by all bash entry-point scripts. Has side effects on source (creates `~/linuxtoolbox`, `/tmp/dotfiles.log`).
- `scripts/lib/os-detect.sh` — OS detection only (`os::is_mac`/`os::is_linux`/`os::arch`/`os::detail`), split out from `core.sh` specifically because it has none of core.sh's side effects — safe to source from zsh's interactive startup too. `scripts/lib/osdetect.py` mirrors the same API for Python scripts.
- `scripts/verify/check.sh` → `check.py` — Health/verification checks (`--quick`, `--full`, `--packages`, `--system`). Manifest-driven and cross-platform: it resolves the repo via `$DOTFILES_DIR`/its own location (never a hardcoded `~/dotfiles`), and checks the platform's real package manager (brew on macOS, nix on Linux, scoop on Windows) rather than assuming Homebrew.
- `scripts/lib/manifest.py` — `packages.toml` loader shared by the generator and the verifier
- `scripts/setup/` — OS-specific setup: `linux.sh` (apt deps), `nix.sh` (Nix/Home Manager, Linux CLI tools), `sublime.sh` (Sublime Text: symlinks `settings/sublime/` into the per-OS User dir + installs Package Control; **macOS + Linux**, Windows handled by `windows.ps1`), `iterm.sh`, `macos-defaults.sh` (curated `defaults write` driven by a `DEFAULTS` data table; snapshots the previous values to `$XDG_STATE_HOME/dotfiles/macos-defaults.snapshot` on first apply so `make macos-defaults undo=1` can revert, and supports `dry=1`; run via `make macos-defaults`, not in the default install flow) (`iterm.sh`/`macos-defaults.sh` are macOS-only), `uninstall.sh`, `windows.ps1` (Windows). There is no `macos.sh`.
- `scripts/setup/macos.sh` + `brew/Brewfile` — Homebrew bundle installation (macOS only — Linux uses Nix instead, see `nix.sh`/`nix/home.nix`)

### Installation Flow
`install.sh` self-locates `DOTFILES_DIR` → sources `core.sh` → set default shell → OS branch (macOS: `scripts/setup/macos.sh`; Linux: `scripts/setup/linux.sh` + `scripts/setup/nix.sh`) → `sublime.sh` (macOS + Linux) + macOS-only `iterm.sh` → `make run` (stow all) → health verification

### Windows
Separate path, no Stow: `install.ps1` → `scripts/setup/windows.ps1` (Scoop packages, hand-rolled symlinks via `$SYMLINK_MAP`, PowerShell modules, `Test-Installation` health check that exits non-zero under `$env:CI`). Not yet required in CI (`test-windows` job is soft-gated/`continue-on-error`).

### CI/CD
`.github/workflows/build_and_test.yml`:
1. Lint: shellcheck (`--severity=error`) + file permissions + **manifest drift check** (`dutils manifest check`) + YAML validation + `py_compile` + PSScriptAnalyzer (Error/ParseError gate on `git ls-files '*.ps1'`) + markdownlint (*informational*, `continue-on-error` — pre-existing backlog). **shfmt is deliberately not a CI gate**: the shell here is hand-aligned for readability (aligned `case` arms, column-aligned one-liner function bodies in `core.sh`/`os-detect.sh`), and shfmt reflows all of it — see the style note below.
2. `test-macos` / `test-ubuntu` (required): full install → package verification → zsh config test (sources `.zshrc`, asserts real exit codes) → Neovim headless config test → uninstall → verify-uninstall. `test-ubuntu` also lints Nix (`nixfmt --check` on `nix/*.nix` + `nix flake check --impure`) right after installing Nix, reusing that install.
3. `test-windows` (soft-gated, informational only for now): `windows.ps1` install → PowerShell profile symlink check

## Key Conventions

- All shell scripts must: start with `#!/bin/bash`, use `set -euo pipefail`, source `scripts/lib/core.sh`, and pass `shellcheck -x`
- Use `log_message`, `info`, `success`, `warning`, `error` from `core.sh` for output — never raw `echo` for status messages
- XDG Base Directory spec: configs live in `~/.config/`, not `$HOME` directly (except `.zshenv`)
- `private.zsh` is gitignored and used for machine-local secrets/overrides — don't commit secrets to tracked files
- Shell style is **hand-aligned on purpose** — aligned `case` arms, column-aligned one-liner function bodies, and
  compact `local x; x=$(...)` / `{ cmd; cmd; }` idioms. `shfmt` reflows every one of these, so do **not** bulk-run
  `shfmt -w` over the repo; match the surrounding style by hand instead
- Pre-commit hooks (`.pre-commit-config.yaml`) run shellcheck and detect-secrets automatically
- Documentation lives in `docs/` — see `docs/ARCHITECTURE.md` for deep technical details
