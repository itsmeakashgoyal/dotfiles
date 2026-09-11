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

`make update` re-stows symlinks (picks up new/renamed files) — it does **not**
upgrade any installed packages. See below for that.

```bash
cd ~/dotfiles
git pull
make update
exec zsh
```

---

## Updating Installed Packages

`dutils update` upgrades the tools this dotfiles setup actually installed:
Homebrew formulae + casks (macOS), Nix flake inputs + Home Manager (Linux),
mise-managed runtime versions, zinit-managed zsh plugins, and Neovim plugins.
It deliberately does **not** touch macOS system software updates — that stays
a manual, separate decision (System Settings, or `softwareupdate` yourself),
since an OS update is a different risk tier and can require a restart.

```bash
dutils update            # everything applicable to this OS
dutils update brew mise  # just specific components
dutils update --help     # full list of components
```

---

## Adding Homebrew Packages

Edit `brew/Brewfile`, then:

```bash
brew bundle --file=~/dotfiles/brew/Brewfile
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

These are all available two ways: as `dutils <cmd>` (works on macOS, Linux, **and
Windows** — the cross-platform path) or as `make <cmd>` (a thin alias to the same
thing, kept for muscle memory; macOS/Linux only, since Windows has no make).

| What | dutils (any OS) | make (macOS/Linux) |
| --- | --- | --- |
| Quick health check | `dutils health` | `make health` |
| Full verification (scored) | `dutils check` | `make check` |
| System information | `dutils sysinfo` | `make sysinfo` |
| Package audit vs Brewfile | `dutils packages` | `make packages` |
| Everything (health + system + packages) | `dutils diagnose` | `make diagnose` |
| Benchmark zsh startup | `dutils bench` | `make bench` |
| Profile zsh startup (per-function) | `dutils profile` | `make bench-detail` |

- **Health check** — core components (git, brew, zsh, nvim, tmux), symlinks, and
  essential CLI tools. Runs in seconds.
- **Full verification** — all 40+ components: directory structure, symlinks, tool
  versions, git config, plugin managers, dev tools. Outputs a score and saves a
  report to `/tmp/`.
- **Package audit** — installed Homebrew packages vs the Brewfile (missing, extra,
  outdated).
