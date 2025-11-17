# 🚀 Modern Development Environment Dotfiles

[![Test Setup dotfiles](https://github.com/itsmeakashgoyal/dotfiles/actions/workflows/build_and_test.yml/badge.svg)](https://github.com/itsmeakashgoyal/dotfiles/actions/workflows/build_and_test.yml)
[![Quality](https://img.shields.io/badge/Quality-A%2B-brightgreen.svg)](https://img.shields.io/badge/Quality-A%2B-brightgreen.svg)
[![License](https://img.shields.io/badge/License-BSD_2--Clause-orange.svg)](https://opensource.org/licenses/BSD-2-Clause)

```
     █████           █████       ██████   ███  ████
    ░░███           ░░███       ███░░███ ░░░  ░░███
  ███████   ██████  ███████    ░███ ░░░  ████  ░███   ██████   █████
 ███░░███  ███░░███░░░███░    ███████   ░░███  ░███  ███░░███ ███░░
░███ ░███ ░███ ░███  ░███    ░░░███░     ░███  ░███ ░███████ ░░█████
░███ ░███ ░███ ░███  ░███ ███  ░███      ░███  ░███ ░███░░░   ░░░░███
░░████████░░██████   ░░█████   █████     █████ █████░░██████  ██████
 ░░░░░░░░  ░░░░░░     ░░░░░   ░░░░░     ░░░░░ ░░░░░  ░░░░░░  ░░░░░░
```

A comprehensive, automated dotfiles setup for **macOS** and **Linux**, featuring modern CLI tools, Neovim configuration, Zsh with powerful aliases, and a complete development environment.

## ✨ Features

- 🎯 **One-Command Setup** - Fully automated installation and configuration
- 🔧 **Modern CLI Tools** - Rust-powered alternatives (`bat`, `eza`, `ripgrep`, `zoxide`)
- 📝 **Neovim IDE** - Complete LSP setup with 40+ plugins
- 🐚 **Zsh Configuration** - Oh My Posh prompt with extensive aliases and functions
- 🎨 **Git Enhanced** - Delta diff viewer, lazygit, and custom aliases
- 🖥️ **Tmux Setup** - Productive terminal multiplexer configuration
- 🔄 **Stow Support** - Easy package management with GNU Stow
- ✅ **CI/CD Testing** - GitHub Actions validates setup on macOS and Linux
- 🔐 **SSH Key Management** - Automated SSH key generation and setup

## ⚠️ Important Warning

These dotfiles are **highly personalized** and will modify your system configuration. Key considerations:

- ⚠️ Scripts will **modify/overwrite** existing configurations
- 🔄 Backup mechanism backs up files **once** - reruns may overwrite backups
- 🛠️ Some changes may be **difficult to reverse** without fresh OS install
- 📝 **Review scripts before running** to understand what will change

**Recommendation**: Fork this repository and customize it to your needs rather than using it as-is.

**By using these scripts, you acknowledge and accept the risk of potential data loss or system alteration.**

---

## 🚀 Quick Start

### Prerequisites

- **macOS** (10.15+) or **Linux** (Ubuntu/Debian-based)
- `git` installed
- `curl` or `wget` installed
- Internet connection
- Sudo/admin privileges

### One-Line Installation

```bash
git clone https://github.com/itsmeakashgoyal/dotfiles.git ~/dotfiles && cd ~/dotfiles && make install
```

This will:
1. ✅ Install Homebrew (if not present)
2. ✅ Install all packages from Brewfile
3. ✅ Configure Zsh with Oh My Posh
4. ✅ Set up Neovim with plugins
5. ✅ Configure Tmux
6. ✅ Set up Git with Delta
7. ✅ Create symlinks for all configs
8. ✅ Apply OS-specific configurations
9. ✅ Run post-installation verification

---

## 📖 Detailed Installation

### Step 1: Clone the Repository

```bash
git clone https://github.com/itsmeakashgoyal/dotfiles.git ~/dotfiles
cd ~/dotfiles
```

### Step 2: (Optional) Generate SSH Key

If you need to set up SSH keys for GitHub:

```bash
./scripts/utils/_setup_ssh.sh -h
```

This will guide you through:
- Generating a new SSH key
- Adding it to ssh-agent
- Copying it to clipboard for GitHub

### Step 3: Install Everything

**Option A: Using Makefile (Recommended)**

```bash
make install
```

**Option B: Direct Script Execution**

```bash
./install.sh
```

### Step 4: Apply Changes

After installation completes:

```bash
exec zsh
```

Or restart your terminal.

---

## 📂 Repository Structure

```
dotfiles/
├── 📄 install.sh              # Main installation script
├── 📄 bootstrap.sh            # Legacy bootstrap script
├── 📄 Makefile               # Stow-based package management
│
├── 📁 git/                   # Git configuration
│   ├── config                # Git config with aliases & delta setup
│   └── gitattributes         # Git attributes for file handling
│
├── 📁 zsh/                   # Zsh configuration
│   ├── .zshenv               # Zsh environment variables
│   └── local/                # Modular Zsh configs
│       ├── aliases.zsh       # Command aliases
│       ├── exports.zsh       # Environment exports
│       ├── function.zsh      # Custom functions
│       ├── fzf.zsh          # Fuzzy finder config
│       ├── git.zsh          # Git aliases & functions
│       ├── docker.zsh       # Docker shortcuts
│       ├── python.zsh       # Python environment
│       └── startup.zsh      # Shell initialization
│
├── 📁 nvim/                  # Neovim configuration (submodule)
│   ├── init.lua             # Main config entry
│   ├── lua/akgoyal/         # Personal configurations
│   │   ├── core/            # Core settings & keymaps
│   │   └── plugins/         # Plugin configurations
│   └── after/ftplugin/      # Filetype-specific settings
│
├── 📁 tmux/                  # Tmux configuration
│   └── tmux.conf            # Tmux settings
│
├── 📁 packages/              # Package management
│   ├── Brewfile             # Homebrew packages list
│   └── install.sh           # Package installation script
│
├── 📁 scripts/               # Utility scripts
│   ├── setup/               # OS-specific setup scripts
│   │   ├── _macOS.sh       # macOS configurations
│   │   ├── _linuxOS.sh     # Linux configurations
│   │   └── _sublime.sh     # Sublime Text setup
│   ├── verification/        # Verification & diagnostic scripts
│   │   ├── health_check.sh          # Quick health check
│   │   ├── verify_installation.sh   # Full verification
│   │   ├── system_info.sh           # System diagnostics
│   │   └── check_packages.sh        # Package verification
│   ├── utils/               # Helper utilities
│   │   ├── dutils          # Dotfiles utility CLI
│   │   ├── _helper.sh      # Common functions
│   │   ├── _setup_ssh.sh   # SSH key management
│   │   └── ...             # Other utilities
│   └── tmux/                # Tmux scripts
│
├── 📁 settings/              # Editor & app settings
│   ├── iterm/               # iTerm2 configuration (macOS)
│   ├── Preferences.sublime-settings
│   └── RectangleConfig.json
│
├── 📁 ohmyposh/              # Oh My Posh theme
│   └── emodipt.json         # Custom prompt theme
│
├── 📁 update-motd.d/         # Linux login message
│   ├── 0-logo
│   ├── 1-welcome
│   └── 2-info
│
└── 📁 .github/
    └── workflows/
        └── build_and_test.yml  # CI/CD pipeline
```

---

## ⚙️ Configuration Details

### Zsh Configuration

**Location**: `~/dotfiles/zsh/`

The Zsh setup includes:

- **Oh My Posh** for beautiful prompt with git status
- **Auto-suggestions** via zsh-autosuggestions
- **Syntax highlighting** via zsh-syntax-highlighting
- **Command aliases** for productivity (see below)
- **Fuzzy finding** with fzf integration
- **Smart directory jumping** with zoxide

**Key Aliases**:

```bash
# Navigation
l, ll, la, lt          # eza variants (ls replacement)
..., ...., .....       # Quick directory traversal
z                      # zoxide (smart cd)

# Git shortcuts (see git/config for full list)
gs, gst                # git status
gc                     # git commit
gp, gpush              # git push
gl, glog               # git log

# System
c                      # clear
h                      # history
path                   # print $PATH nicely
reload                 # reload zsh config
```

### Neovim Configuration

**Location**: `~/dotfiles/nvim/`

A complete IDE setup with:

- **LSP Support**: Language servers for Python, Lua, TypeScript, Go, and more
- **Autocompletion**: nvim-cmp with snippets
- **File Navigation**: Telescope, Oil.nvim, Harpoon
- **Git Integration**: Gitsigns, Fugitive
- **UI Enhancements**: Lualine, Noice, Snacks
- **Code Quality**: Linting (via nvim-lint), Formatting (via conform.nvim)
- **AI Integration**: GitHub Copilot support

**Plugin Manager**: Lazy.nvim

**Key Bindings**: Leader key is `<Space>`

### Git Configuration

**Location**: `~/dotfiles/git/`

Features:

- **Delta Diff Viewer**: Beautiful syntax-highlighted diffs
- **Custom Aliases**: Shortcuts for common git operations
- **GitHub Integration**: `gh` CLI for GitHub operations
- **Lazy Git**: Terminal UI for git operations

### Tmux Configuration

**Location**: `~/dotfiles/tmux/`

Features:

- Custom key bindings
- Mouse support
- Pane navigation shortcuts
- Status bar customization

---

## 🎮 Usage & Commands

### Makefile Commands

The Makefile provides convenient commands for managing your dotfiles:

#### Installation & Management
```bash
make help              # Show all available commands
make install          # Run full installation
make run              # Stow all packages
make stow pkg=NAME    # Stow individual package
make unstow pkg=NAME  # Unstow individual package
make update           # Update all stowed packages
make list             # List available packages
make verify           # Verify package directories
make clean            # Remove backup files
```

#### Verification & Diagnostics
```bash
make health           # Quick health check
make check            # Full installation verification
make sysinfo          # Display system information
make packages         # Check packages against Brewfile
make diagnose         # Run all diagnostic tools
```

### Utility Script (dutils)

After installation, use the `dutils` command:

```bash
dutils help           # Show help
dutils version        # Show version
dutils detect-os      # Detect operating system
dutils list-functions # List available functions
```

### Common Workflows

**Update dotfiles**:
```bash
cd ~/dotfiles
git pull
make update
exec zsh
```

**Add new package**:
```bash
cd ~/dotfiles
# Edit Brewfile to add packages
brew bundle --file=packages/Brewfile
```

**Edit configurations**:
```bash
cd ~/dotfiles
nvim zsh/local/aliases.zsh  # Edit zsh aliases
nvim git/config              # Edit git config
nvim nvim/init.lua          # Edit nvim config
```

---

## 🎨 Customization

### Personalizing Git Config

Edit `git/config` and update:

```ini
[user]
    name = Your Name
    email = your.email@example.com
```

### Customizing Zsh

1. **Add aliases**: Edit `zsh/local/aliases.zsh`
2. **Add functions**: Edit `zsh/local/function.zsh`
3. **Add exports**: Edit `zsh/local/exports.zsh`
4. **Private configs**: Use `zsh/local/private.zsh` (gitignored)

### Customizing Neovim

- **Add plugins**: Create new file in `nvim/lua/akgoyal/plugins/`
- **Modify keymaps**: Edit `nvim/lua/akgoyal/core/keymaps.lua`
- **Change theme**: Edit `nvim/lua/akgoyal/plugins/colorscheme.lua`

### Modifying Package List

Edit `packages/Brewfile` to add/remove packages:

```ruby
brew "package-name"           # Add CLI tool
cask "app-name"              # Add GUI app (macOS)
```

Then run:
```bash
brew bundle --file=packages/Brewfile
```

---

## 🔍 Verification & Diagnostic Tools

**✨ Automatic Verification:** The installation process now automatically runs verification checks at the end to ensure everything is set up correctly!

You can also run these verification scripts manually anytime:

### Quick Health Check

Get a fast overview of your installation status:

```bash
make health
# or
bash ~/dotfiles/scripts/verification/health_check.sh
```

This performs quick checks on:
- Core components (Git, Homebrew, dotfiles directory)
- Shell configuration (Zsh, Oh My Posh, symlinks)
- Neovim setup
- Git configuration
- Essential CLI tools

### Full Installation Verification

Run comprehensive verification of all components:

```bash
make check
# or
bash ~/dotfiles/scripts/verification/verify_installation.sh
```

This checks:
- Directory structure
- All symlinks
- Core tools and their versions
- Shell configuration
- Neovim setup and plugins
- Git configuration
- Tmux setup
- Modern CLI tools (bat, eza, ripgrep, fzf, etc.)
- Development tools

**Exit Codes:**
- `0` - All checks passed
- `1` - Critical issues found

### System Information

Display comprehensive system diagnostics:

```bash
# Show all information
bash ~/dotfiles/scripts/verification/system_info.sh

# Show specific sections only
bash ~/dotfiles/scripts/verification/system_info.sh --system
bash ~/dotfiles/scripts/verification/system_info.sh --dev --tools
```

**Available Sections:**
- `--system` - System information (OS, hardware, uptime)
- `--shell` - Shell configuration and environment
- `--dev` - Development tools (Git, Python, Node, etc.)
- `--tools` - Editors and CLI tools
- `--dotfiles` - Dotfiles configuration status
- `--network` - Network information
- `--disk` - Disk usage
- `--process` - Process information
- `--env` - Environment variables

### Package Verification

Check installed packages against your Brewfile:

```bash
# Verify packages
make packages
# or
bash ~/dotfiles/scripts/verification/check_packages.sh

# Export current packages to new Brewfile
bash ~/dotfiles/scripts/verification/check_packages.sh --export ~/my-brewfile
```

This shows:
- Installed vs missing packages
- Outdated packages
- Extra packages not in Brewfile
- Installation coverage percentage

---

## 🔧 Troubleshooting

### Homebrew Not Found (Linux)

After installation, if `brew` command not found:

```bash
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
```

Or restart your terminal.

### Neovim Plugins Not Loading

```bash
nvim
:Lazy sync
```

### Zsh Completions Not Working

```bash
rm -rf ~/.zcompdump*
exec zsh
```

### Permission Issues

If you encounter permission errors:

```bash
sudo chown -R $(whoami) ~/dotfiles
```

### Symlink Conflicts

If symlinks fail, backup and remove existing configs:

```bash
mv ~/.zshrc ~/.zshrc.backup
mv ~/.config/nvim ~/.config/nvim.backup
```

Then re-run installation.

### Git Delta Not Working

Ensure delta is in PATH:

```bash
which delta
# If not found
brew install git-delta
```

### Debugging Installation Issues

1. **Run health check first:**
   ```bash
   bash ~/dotfiles/scripts/verification/health_check.sh
   ```

2. **Run full verification:**
   ```bash
   bash ~/dotfiles/scripts/verification/verify_installation.sh
   ```

3. **Check system info:**
   ```bash
   bash ~/dotfiles/scripts/verification/system_info.sh
   ```

4. **Verify packages:**
   ```bash
   bash ~/dotfiles/scripts/verification/check_packages.sh
   ```

5. **Review logs:**
   ```bash
   cat /tmp/setup_log.txt
   ```

---

## 🤝 Contributing

Contributions are welcome! Here's how you can help:

1. **Fork the repository**
2. **Create a feature branch**: `git checkout -b feature/amazing-feature`
3. **Commit your changes**: `git commit -m 'Add amazing feature'`
4. **Push to the branch**: `git push origin feature/amazing-feature`
5. **Open a Pull Request**

### Areas for Contribution

- 🐛 Bug fixes
- 📝 Documentation improvements
- ✨ New features or utilities
- 🧪 Testing improvements
- 🎨 Theme/UI enhancements

### Reporting Issues

If you encounter issues:

1. Check [existing issues](https://github.com/itsmeakashgoyal/dotfiles/issues)
2. Create a new issue with:
   - Clear description
   - Steps to reproduce
   - Expected vs actual behavior
   - OS and version info

---

## 📚 Resources & Inspiration

This dotfiles setup was inspired by and uses code from various sources:

- [Homebrew](https://brew.sh/) - Package manager
- [Oh My Posh](https://ohmyposh.dev/) - Prompt theming engine
- [Neovim](https://neovim.io/) - Hyperextensible Vim-based text editor
- [GNU Stow](https://www.gnu.org/software/stow/) - Symlink farm manager
- Various dotfiles repositories from the community

### Useful Links

- [Awesome Dotfiles](https://github.com/webpro/awesome-dotfiles) - Curated list of dotfiles resources
- [GitHub Does Dotfiles](https://dotfiles.github.io/) - Guide to dotfiles on GitHub
- [Neovim Documentation](https://neovim.io/doc/) - Official Neovim docs
- [Zsh Documentation](https://zsh.sourceforge.io/Doc/) - Official Zsh docs

---

## 📄 License

This project is licensed under the **BSD 2-Clause License** - see the [LICENSE](LICENSE) file for details.

```
Copyright (c) 2025, Akash Goyal
All rights reserved.
```

---

## 🙏 Acknowledgments

- Thanks to all the open-source projects and maintainers
- The dotfiles community for inspiration and ideas
- Contributors who help improve these dotfiles

---

## 📧 Contact

**Akash Goyal**

- GitHub: [@itsmeakashgoyal](https://github.com/itsmeakashgoyal)
- Email: ag.akgoyal@gmail.com

---

<div align="center">

### ⭐ If you find these dotfiles helpful, please consider giving it a star!

**Made with ❤️ and ☕**

</div>
