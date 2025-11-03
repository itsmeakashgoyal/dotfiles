# 📦 Package Management

This directory contains all package definitions and installation scripts for the dotfiles.

## 📁 Structure

```
packages/
├── Brewfile              # Homebrew packages (macOS & Linux)
├── install.sh            # Main installation script
├── node_packages.txt     # npm packages (optional)
├── pnpm_packages.txt     # pnpm packages (optional)
├── pipx_packages.txt     # Python packages (optional)
├── ruby_packages.txt     # Ruby gems (optional)
└── rust_packages.txt     # Rust crates (optional)
```

## 🎯 Installation Strategy

### Automatic Installation (Default)

When you run `./install.sh`, **ALL packages are installed automatically**:

```bash
./install.sh
```

**Installation order:**
1. ✅ **Homebrew** - Package manager (if not present)
2. ✅ **Brewfile packages** (~70 packages) - Core tools via Homebrew
3. ✅ **Node packages** - Additional npm/pnpm packages
4. ✅ **Python packages** - Additional pipx packages
5. ✅ **Ruby gems** - Additional Ruby packages
6. ✅ **Rust crates** - Additional Rust packages

**No prompts, no flags - everything installs automatically as part of dotfiles setup.**

### What Gets Installed

#### From Brewfile (via Homebrew) - Priority 1
- Core utilities: bat, eza, fzf, ripgrep, tree, zoxide
- Development tools: git, neovim, helix, lazygit, gh
- Programming languages: node, python3, go, lua
- System monitoring: btop, htop, ctop, duf, procs
- Shell tools: shellcheck, shfmt, diff-so-fancy

#### Additional Packages (via language package managers) - Priority 2
Complementary packages installed via npm/pipx/gem/cargo:
- **Node**: TypeScript, language servers, CLI tools
- **Python**: LSP server + plugins (injected into python-lsp-server)
- **Ruby**: Bundle, Jekyll, neovim gem
- **Rust**: Specialized CLI tools

**Note:** Python LSP plugins (pylsp-mypy, python-lsp-isort, python-lsp-black) are automatically injected into python-lsp-server's environment using `pipx inject`, not installed as standalone packages.

### Deduplication & Smart Installation ✅

**The installer automatically skips already-installed packages:**

- ✅ **Checks before installing** - Won't reinstall if package exists
- ✅ **Fast re-runs** - Skip installed packages on subsequent runs
- ✅ **Cross-platform safe** - Works on both macOS and Linux
- ✅ **Package manager aware** - Each tool (npm, pipx, gem, cargo) checks its own registry

**Example output:**
```
✓ typescript already installed (skipping)
  Installing new-package...
✓ pylint already installed (skipping)
```

### Manual Installation (If Needed)

You can also run the package installer directly:

#### Install Node Packages (npm/pnpm)

```bash
INSTALL_NODE=1 ./packages/install.sh
```

#### Install Python Packages (pipx)

```bash
INSTALL_PYTHON=1 ./packages/install.sh
```

#### Install Ruby Gems

```bash
INSTALL_RUBY=1 ./packages/install.sh
```

#### Install Rust Crates

```bash
INSTALL_RUST=1 ./packages/install.sh
```

#### Install Everything

```bash
INSTALL_NODE=1 INSTALL_PYTHON=1 INSTALL_RUBY=1 INSTALL_RUST=1 ./packages/install.sh
```

## 📋 Package List Files

### Format

Each `.txt` file contains one package per line:

```
package-name
another-package
# Comments are ignored
```

### Purpose

These files contain **additional** packages installed via language-specific package managers. They complement the Brewfile by providing packages that:
- Are not available in Homebrew
- Are better managed by language-specific tools (npm, pipx, gem, cargo)
- Are language/framework specific development tools

## 🔧 Usage in Install Script

The main `install.sh` automatically installs everything:

```bash
# From install.sh (root directory)
export INSTALL_NODE=1
export INSTALL_PYTHON=1
export INSTALL_RUBY=1
export INSTALL_RUST=1
bash ${DOTFILES_DIR}/packages/install.sh
```

**Simple and automatic - no configuration needed!**

## 🎨 Customization

### Add Packages to Brewfile

Edit `Brewfile` and add your package:

```ruby
brew "package-name"           # CLI tool
cask "app-name"               # macOS app (cask)
```

Then run:

```bash
brew bundle --file=./packages/Brewfile
```

### Add Language Packages

Add package names to the appropriate `.txt` file:

- `node_packages.txt` - npm packages
- `pnpm_packages.txt` - pnpm packages  
- `pipx_packages.txt` - Python packages
- `ruby_packages.txt` - Ruby gems
- `rust_packages.txt` - Rust crates

Then run with the appropriate flag:

```bash
INSTALL_NODE=1 ./packages/install.sh
```

## 🚀 Best Practices

1. **Use Brewfile for core tools** - Everything you need should be here
2. **Use package lists for optional tools** - Language-specific packages go in txt files
3. **Comment out unused packages** - Don't install what you don't need
4. **Keep packages organized** - Group by category, sort alphabetically
5. **Document why** - Add comments for unusual or specific packages

## 🔍 Verification

Check what's installed:

```bash
# Homebrew packages
brew list

# Node packages
npm list -g --depth=0
pnpm list -g

# Python packages
pipx list

# Ruby gems
gem list

# Rust crates
cargo install --list
```

## 🧹 Cleanup

Remove unused packages:

```bash
# Homebrew
brew autoremove
brew cleanup

# Node
npm prune -g

# Python
pipx uninstall <package>

# Ruby
gem cleanup

# Rust
cargo uninstall <package>
```

