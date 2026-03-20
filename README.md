# Modern Development Environment Dotfiles

[![CI](https://github.com/itsmeakashgoyal/dotfiles/actions/workflows/build_and_test.yml/badge.svg)](https://github.com/itsmeakashgoyal/dotfiles/actions/workflows/build_and_test.yml)
[![License](https://img.shields.io/badge/License-BSD_2--Clause-orange.svg)](https://opensource.org/licenses/BSD-2-Clause)
[![macOS](https://img.shields.io/badge/macOS-14%2B-blue?logo=apple)](https://www.apple.com/macos/)
[![Linux](https://img.shields.io/badge/Linux-Ubuntu%2FDebian-orange?logo=linux)](https://ubuntu.com/)
[![Shell](https://img.shields.io/badge/Shell-Zsh-informational?logo=gnu-bash)](https://www.zsh.org/)
[![Neovim](https://img.shields.io/badge/Neovim-0.10%2B-green?logo=neovim)](https://neovim.io/)
[![Last Commit](https://img.shields.io/github/last-commit/itsmeakashgoyal/dotfiles)](https://github.com/itsmeakashgoyal/dotfiles/commits/master)
[![Stars](https://img.shields.io/github/stars/itsmeakashgoyal/dotfiles?style=social)](https://github.com/itsmeakashgoyal/dotfiles/stargazers)

```text
     █████           █████       ██████   ███  ████
    ░░███           ░░███       ███░░███ ░░░  ░░███
  ███████   ██████  ███████    ░███ ░░░  ████  ░███   ██████   █████
 ███░░███  ███░░███░░░███░    ███████   ░░███  ░███  ███░░███ ███░░
░███ ░███ ░███ ░███  ░███    ░░░███░     ░███  ░███ ░███████ ░░█████
░███ ░███ ░███ ░███  ░███ ███  ░███      ░███  ░███ ░███░░░   ░░░░███
░░████████░░██████   ░░█████   █████     █████ █████░░██████  ██████
 ░░░░░░░░  ░░░░░░     ░░░░░   ░░░░░     ░░░░░ ░░░░░  ░░░░░░  ░░░░░░
```

A comprehensive, automated dotfiles setup for **macOS** and **Linux**, featuring Neovim, Zsh, Tmux, Git, and modern CLI tools -- all managed with [GNU Stow](https://www.gnu.org/software/stow/).

> **Warning:** These dotfiles are personalized and will overwrite existing configurations.
> Fork the repo and review the scripts before running on your machine.

---

## What's Included

- **Zsh** -- Modular config via `conf.d/`, Zinit plugin manager, Powerlevel10k prompt, fzf integration
- **Neovim** -- Lazy.nvim, LSP, Treesitter, Telescope, autocompletions
- **Git** -- 40+ aliases, delta diff viewer, XDG-compliant config
- **Tmux** -- TPM plugin manager, vim-aware pane switching, session persistence
- **Oh My Posh** -- Custom prompt theme
- **100+ CLI tools** -- via Homebrew Brewfile (eza, bat, ripgrep, fd, zoxide, and more)

---

## Quick Start

### One-liner Bootstrap (fresh machines)

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/itsmeakashgoyal/dotfiles/master/bootstrap.sh)"
```

### Standard Install

```bash
git clone https://github.com/itsmeakashgoyal/dotfiles.git ~/dotfiles
cd ~/dotfiles
make install
exec zsh
```

> For prerequisites, platform-specific notes, and what the installer does, see **[Installation Guide](docs/INSTALLATION.md)**.

---

## How It Works

Every top-level directory (`git/`, `zsh/`, `nvim/`, `tmux/`, `ohmyposh/`) is a **Stow package**. Each package mirrors the target path relative to `$HOME`:

```text
dotfiles/nvim/.config/nvim/init.lua
                │
    stow nvim   │   creates symlink
                ▼
~/.config/nvim  →  ~/dotfiles/nvim/.config/nvim
```

Running `stow <package>` from the repo root creates the correct symlinks automatically. Edits in the repo take effect immediately -- no re-linking needed.

---

## Repository Structure

```text
dotfiles/
├── git/                       → ~/.config/git/          Git config & aliases
├── zsh/                       → ~/.config/zsh/          Zsh shell configuration
├── nvim/                      → ~/.config/nvim/         Neovim editor setup
├── tmux/                      → ~/.config/tmux/         Tmux multiplexer
├── ohmyposh/                  → ~/.config/ohmyposh/     Prompt theme
├── packages/                  Brewfile & install script
├── scripts/                   Setup, verification, utilities
├── settings/                  App preferences (iTerm, Sublime, Rectangle)
├── install.sh                 Main installer
├── bootstrap.sh               One-liner bootstrap for fresh machines
└── Makefile                   Stow management & diagnostics
```

---

## Documentation

| Document | Description |
| --- | --- |
| **[Installation](docs/INSTALLATION.md)** | Prerequisites, platform notes, what the installer does |
| **[Usage](docs/USAGE.md)** | Makefile commands, updating, adding packages, diagnostics |
| **[Customization](docs/CUSTOMIZATION.md)** | Personalizing Git, Zsh, Neovim, Tmux configs |
| **[Troubleshooting](docs/TROUBLESHOOTING.md)** | Common issues, debug workflow, uninstalling |
| **[Architecture](docs/ARCHITECTURE.md)** | Deep dive: Stow internals, Zsh flow, scripts, CI, XDG |
| **[Manual Setup](docs/MANUAL_SETUP.md)** | GitHub settings, Ghostty, WezTerm, mise |
| **[Screenshots](docs/SCREENSHOTS.md)** | Recording terminal demos with VHS |
| **[Contributing](CONTRIBUTING.md)** | How to contribute, code style, PR process |
| **[Security](SECURITY.md)** | Secrets management and security practices |

---

## Resources

- [GNU Stow](https://www.gnu.org/software/stow/) -- Symlink farm manager
- [Homebrew](https://brew.sh/) -- Package manager for macOS and Linux
- [Neovim](https://neovim.io/) -- Hyperextensible text editor
- [Oh My Posh](https://ohmyposh.dev/) -- Prompt theme engine
- [VHS](https://github.com/charmbracelet/vhs) -- Terminal demo recorder
- [Awesome Dotfiles](https://github.com/webpro/awesome-dotfiles) -- Community dotfiles resources

---

## License

BSD 2-Clause License. See [LICENSE](LICENSE) for details.

---

**Akash Goyal** -- [@itsmeakashgoyal](https://github.com/itsmeakashgoyal)
