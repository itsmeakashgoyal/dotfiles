# Installation

[← Back to README](../README.md)

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

## Fresh Machine (One-liner Bootstrap)

If you don't have `git` yet or want a fully hands-off start, use the bootstrap script:

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/itsmeakashgoyal/dotfiles/master/bootstrap.sh)"
```

This downloads the repo (via `git`, `curl`, or `wget` -- whichever is available), then runs the installer.

## Standard Install

### 1. Clone the repository

```bash
git clone https://github.com/itsmeakashgoyal/dotfiles.git ~/dotfiles
cd ~/dotfiles
```

### 2. Run the installer

```bash
make install
```

Or equivalently:

```bash
./install.sh
```

### 3. Activate the new shell

```bash
exec zsh
```

That's it. Open a new terminal and everything is ready.

---

## What the Installer Does

The installer runs through these stages in order:

| Stage | What happens |
| --- | --- |
| **Homebrew** | Installs Homebrew (or Linuxbrew on Linux), updates it, then installs every formula and cask listed in `packages/Brewfile`. |
| **Default shell** | Adds `zsh` to `/etc/shells` if missing, then sets it as your login shell via `chsh`. |
| **OS-specific setup** | Runs `scripts/setup/macos.sh` (Finder, Dock, trackpad, keyboard preferences) or `scripts/setup/linux.sh` (essential apt packages, fonts, locale). |
| **Stow** | Removes any old manual symlinks, then runs `stow --restow` for each package: `git`, `zsh`, `nvim`, `tmux`. |
| **Verification** | Runs `scripts/verify/check.sh --quick` to confirm everything is linked and working. |

---

## Platform-Specific Notes

### macOS

- Homebrew installs to `/opt/homebrew` on Apple Silicon and `/usr/local` on Intel Macs. The installer handles both.
- The macOS setup script (`scripts/setup/macos.sh`) configures system preferences (Finder, Dock, keyboard repeat, trackpad). Review it and remove any settings you don't want before running.
- GUI apps (casks) in the Brewfile are macOS-only and are skipped on Linux automatically.

### Linux

- The installer uses [Linuxbrew](https://docs.brew.sh/Homebrew-on-Linux) for package management, keeping the Brewfile portable across both platforms.
- After installation, if `brew` is not found in a new shell, run:

  ```bash
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
  ```

- The Linux setup script (`scripts/setup/linux.sh`) installs base development packages via `apt` (compilers, libraries, fonts).

---

## (Optional) SSH Key Setup

Generate and configure SSH keys for GitHub or other services.

### Usage

```bash
./scripts/utils/_setup_ssh.sh -e EMAIL [-t KEY_TYPE]
```

| Flag | Description | Default |
| --- | --- | --- |
| `-e` | Email address for the SSH key (required) | -- |
| `-t` | Key type: `ed25519` or `rsa` | `ed25519` |
| `-h` | Show help | -- |

### Examples

```bash
# Generate an Ed25519 key (recommended)
./scripts/utils/_setup_ssh.sh -e you@example.com

# Generate an RSA key (for legacy systems that don't support Ed25519)
./scripts/utils/_setup_ssh.sh -e you@example.com -t rsa
```

### What it does

1. Generates the key at `~/.ssh/id_<type>` (prompts for a new name if one already exists)
2. Starts `ssh-agent` and adds the key
3. Sets correct permissions (`600` for private key, `644` for public key)
4. Copies the public key to your clipboard (macOS via `pbcopy`, Linux via `xclip`)
