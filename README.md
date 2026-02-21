# Modern Development Environment Dotfiles

[![Test Setup dotfiles](https://github.com/itsmeakashgoyal/dotfiles/actions/workflows/build_and_test.yml/badge.svg)](https://github.com/itsmeakashgoyal/dotfiles/actions/workflows/build_and_test.yml)
[![License](https://img.shields.io/badge/License-BSD_2--Clause-orange.svg)](https://opensource.org/licenses/BSD-2-Clause)

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
> Backup your current configs first -- some changes are hard to reverse without a fresh install.

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

Running `stow <package>` from the repo root creates the correct symlinks automatically. No manual `ln -sf` needed.

---

## Prerequisites

### macOS

| Requirement | How to get it |
| --- | --- |
| macOS 10.15+ | -- |
| Xcode Command Line Tools | `xcode-select --install` |
| `git` | Included with Xcode CLT |
| Admin (sudo) access | Required for Homebrew and changing default shell |

### Linux (Ubuntu / Debian)

| Requirement | How to get it |
| --- | --- |
| Ubuntu 20.04+ or Debian 11+ | -- |
| `git` | `sudo apt update && sudo apt install -y git curl build-essential` |
| `curl` | Included above |
| `build-essential` | Needed for Homebrew/Linuxbrew |
| Sudo access | Required for package installation and changing default shell |

---

## Installation

### Fresh Machine (One-liner Bootstrap)

If you don't have `git` yet or want a fully hands-off start, use the bootstrap script:

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/itsmeakashgoyal/dotfiles/master/bootstrap.sh)"
```

This downloads the repo (via `git`, `curl`, or `wget` -- whichever is available), then runs the installer.

### Standard Install

#### 1. Clone the repository

```bash
git clone https://github.com/itsmeakashgoyal/dotfiles.git ~/dotfiles
cd ~/dotfiles
```

#### 2. Run the installer

```bash
make install
```

Or equivalently:

```bash
./install.sh
```

#### 3. Activate the new shell

```bash
exec zsh
```

That's it. Open a new terminal and everything is ready.

### What the Installer Does

The installer runs through these stages in order:

| Stage | What happens |
| --- | --- |
| **Homebrew** | Installs Homebrew (or Linuxbrew on Linux), updates it, then installs every formula and cask listed in `packages/Brewfile`. |
| **Default shell** | Adds `zsh` to `/etc/shells` if missing, then sets it as your login shell via `chsh`. |
| **OS-specific setup** | Runs `scripts/setup/_macOS.sh` (Finder, Dock, trackpad, keyboard preferences) or `scripts/setup/_linuxOS.sh` (essential apt packages, fonts, locale). |
| **Stow** | Removes any old manual symlinks, then runs `stow --restow` for each package: `git`, `zsh`, `nvim`, `tmux`, `ohmyposh`. |
| **Verification** | Runs `scripts/verification/health_check.sh` to confirm everything is linked and working. |

### macOS-Specific Notes

- Homebrew installs to `/opt/homebrew` on Apple Silicon and `/usr/local` on Intel Macs. The installer handles both.
- The macOS setup script (`scripts/setup/_macOS.sh`) configures system preferences (Finder, Dock, keyboard repeat, trackpad). Review it and remove any settings you don't want before running.
- GUI apps (casks) in the Brewfile are macOS-only and are skipped on Linux automatically.

### Linux-Specific Notes

- The installer uses [Linuxbrew](https://docs.brew.sh/Homebrew-on-Linux) for package management, keeping the Brewfile portable across both platforms.
- After installation, if `brew` is not found in a new shell, run:

  ```bash
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
  ```

- The Linux setup script (`scripts/setup/_linuxOS.sh`) installs base development packages via `apt` (compilers, libraries, fonts).

### (Optional) SSH Key Setup

To generate and configure SSH keys for GitHub:

```bash
./scripts/utils/_setup_ssh.sh
```

This generates an Ed25519 key, starts `ssh-agent`, and copies the public key to your clipboard.

---

## Repository Structure

```text
dotfiles/
├── install.sh                 # Main installer: brew -> stow -> os-setup
├── bootstrap.sh               # One-liner bootstrap for fresh machines
├── Makefile                   # Stow management & diagnostics
│
├── git/                       # -> ~/.config/git/
│   └── .config/git/
│       ├── config             # Aliases, delta, user settings
│       └── attributes         # File-type handling rules
│
├── zsh/                       # -> ~/.zshenv + ~/.config/zsh/
│   ├── .zshenv                # Sets ZDOTDIR, XDG vars (sourced on every invocation)
│   └── .config/zsh/
│       ├── .zshrc             # Interactive shell config (plugins, prompt)
│       ├── .zprofile          # Login shell config (PATH additions)
│       ├── .p10k.zsh          # Powerlevel10k prompt theme
│       ├── completion/        # Custom completions
│       └── conf.d/            # Modular configs (sourced alphabetically)
│           ├── aliases.zsh    # Command aliases
│           ├── exports.zsh    # Environment exports
│           ├── functions.zsh  # Custom shell functions
│           ├── fzf.zsh        # Fuzzy finder config
│           ├── git.zsh        # Git aliases & helpers
│           ├── docker.zsh     # Docker shortcuts
│           ├── options.zsh    # Shell options, history, completion
│           ├── python.zsh     # Python/pyenv environment
│           ├── startup.zsh    # Shell startup tasks
│           └── private.zsh    # Machine-local overrides (gitignored)
│
├── nvim/                      # -> ~/.config/nvim/
│   └── .config/nvim/
│       ├── init.lua           # Entry point
│       ├── lua/akgoyal/
│       │   ├── core/          # Settings, keymaps, autocommands
│       │   └── plugins/       # Plugin specs (lazy.nvim)
│       └── after/ftplugin/    # Filetype-specific overrides
│
├── tmux/                      # -> ~/.config/tmux/
│   └── .config/tmux/
│       └── tmux.conf          # Tmux settings & key bindings
│
├── ohmyposh/                  # -> ~/.config/ohmyposh/
│   └── .config/ohmyposh/
│       └── emodipt.json       # Custom prompt theme
│
├── packages/
│   ├── Brewfile               # All Homebrew formulae and casks
│   └── install.sh             # Homebrew install + bundle
│
├── scripts/
│   ├── setup/                 # _macOS.sh, _linuxOS.sh, _sublime.sh
│   ├── verification/          # health_check.sh, verify_installation.sh, etc.
│   ├── utils/                 # _helper.sh (logging, OS detection, utilities)
│   └── tmux/                  # Tmux helper scripts
│
├── settings/                  # App settings (deployed by make apps)
│   ├── iterm/                 # iTerm2 preferences (plist)
│   ├── sublime/               # Sublime Text user settings
│   └── RectangleConfig.json
│
└── .github/workflows/
    └── build_and_test.yml     # CI: tests setup on macOS + Ubuntu
```

---

## Post-Install: Day-to-Day Usage

### Makefile Commands

```bash
make help                 # Show all available commands
```

#### Stow Management

```bash
make run                  # Stow all packages
make stow pkg=nvim        # Stow a single package
make unstow pkg=nvim      # Unstow a single package
make update               # Restow all (picks up file changes)
make delete               # Unstow everything
make list                 # List available packages
```

#### Diagnostics

```bash
make health               # Quick health check (symlinks, tools, configs)
make check                # Full verification of all components
make sysinfo              # System info (OS, hardware, dev tools)
make packages             # Compare installed packages vs. Brewfile
make diagnose             # Run all diagnostics at once
```

### Updating Your Dotfiles

```bash
cd ~/dotfiles
git pull
make update
exec zsh
```

### Adding Homebrew Packages

Edit `packages/Brewfile`, then:

```bash
brew bundle --file=~/dotfiles/packages/Brewfile
```

### Editing Configs

All edits happen in the repo. Stow symlinks mean changes take effect immediately -- no re-linking needed.

```bash
nvim ~/dotfiles/zsh/.config/zsh/conf.d/aliases.zsh   # Zsh aliases
nvim ~/dotfiles/git/.config/git/config                # Git config
nvim ~/dotfiles/nvim/.config/nvim/lua/akgoyal/plugins # Nvim plugins
nvim ~/dotfiles/tmux/.config/tmux/tmux.conf           # Tmux config
```

---

## Customization

### Git

Edit `git/.config/git/config` and update the `[user]` section:

```ini
[user]
    name = Your Name
    email = your.email@example.com
```

Git discovers this config automatically via the XDG path (`~/.config/git/config`). No environment variable needed.

### Zsh

Modular configs live in `zsh/.config/zsh/conf.d/`. Every `*.zsh` file in that directory is sourced automatically:

| File | Purpose |
| --- | --- |
| `aliases.zsh` | Command aliases (`l`, `ll`, `gs`, `gc`, etc.) |
| `exports.zsh` | `PATH` and environment variables |
| `functions.zsh` | Custom shell functions |
| `fzf.zsh` | Fuzzy finder key bindings and options |
| `git.zsh` | Git-specific aliases and functions |
| `options.zsh` | Zsh options, history, completion settings |
| `private.zsh` | Machine-local overrides (gitignored) |

To add your own config, create a new `.zsh` file in `conf.d/` or use `private.zsh` for secrets and machine-specific values.

### Neovim

| Task | File |
| --- | --- |
| Add a plugin | Create a file in `nvim/.config/nvim/lua/akgoyal/plugins/` |
| Change keymaps | `nvim/.config/nvim/lua/akgoyal/core/keymaps.lua` |
| Change colorscheme | `nvim/.config/nvim/lua/akgoyal/plugins/colorscheme.lua` |
| Filetype settings | `nvim/.config/nvim/after/ftplugin/<filetype>.lua` |

### Tmux

Edit `tmux/.config/tmux/tmux.conf` directly. Changes apply on the next tmux session or after `tmux source ~/.config/tmux/tmux.conf`.

---

## Verification & Diagnostics

The installer runs a health check automatically at the end. You can re-run diagnostics any time:

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
bash ~/dotfiles/scripts/verification/system_info.sh            # Everything
bash ~/dotfiles/scripts/verification/system_info.sh --system    # OS & hardware only
bash ~/dotfiles/scripts/verification/system_info.sh --dev       # Dev tools only
```

### Package Audit

```bash
make packages
```

Compares installed Homebrew packages against the Brewfile. Shows missing, extra, and outdated packages.

---

## Troubleshooting

### `brew` command not found (Linux)

Linuxbrew needs its shell environment loaded. This should happen automatically via `.zshenv`, but if not:

```bash
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
```

### Stow conflicts with existing files

If `stow` reports a conflict, it means a real file (not a symlink) already exists at the target path. Back it up and retry:

```bash
mv ~/.config/nvim ~/.config/nvim.backup
make run
```

### Git config not found after install

Git reads its global config from `~/.config/git/config` (XDG path). If `~/.gitconfig` exists, Git prefers it and ignores the XDG path. Remove the old file:

```bash
rm ~/.gitconfig
git config user.name   # should now print your name
```

### Neovim plugins not loading

```bash
nvim --headless "+Lazy! sync" +qa
```

Or open Neovim and run `:Lazy sync`.

### Zsh completions broken

```bash
rm -f ~/.config/zsh/.zcompdump*
exec zsh
```

### Permission errors

```bash
sudo chown -R $(whoami) ~/dotfiles
```

### Full debug workflow

```bash
make health                  # 1. Quick check
make check                   # 2. Full verification
make sysinfo                 # 3. System info
cat /tmp/setup_log.txt       # 4. Install logs (if available)
```

---

## Uninstalling

To remove all symlinks created by Stow:

```bash
make delete
```

This only removes the symlinks -- your dotfiles repo and all config files remain untouched.

---

## Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/my-change`
3. Commit your changes: `git commit -m 'Add my change'`
4. Push and open a Pull Request

Issues and suggestions welcome at [github.com/itsmeakashgoyal/dotfiles/issues](https://github.com/itsmeakashgoyal/dotfiles/issues).

---

## Resources

- [GNU Stow](https://www.gnu.org/software/stow/) -- Symlink farm manager
- [Homebrew](https://brew.sh/) -- Package manager for macOS and Linux
- [Neovim](https://neovim.io/) -- Hyperextensible text editor
- [Oh My Posh](https://ohmyposh.dev/) -- Prompt theme engine
- [Awesome Dotfiles](https://github.com/webpro/awesome-dotfiles) -- Community dotfiles resources

---

## License

BSD 2-Clause License. See [LICENSE](LICENSE) for details.

---

**Akash Goyal** -- [@itsmeakashgoyal](https://github.com/itsmeakashgoyal)
