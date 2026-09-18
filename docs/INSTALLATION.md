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
| `build-essential` | Needed to build some Nix/Home Manager packages |
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

### 4. (Optional) Personalize with `dutils init`

A short, idempotent wizard for the per-machine bits the installer can't guess —
git identity (work vs personal), SSH keys, decrypting secrets, and picking a
theme:

```bash
dutils init
```

---

## What the Installer Does

The installer runs through these stages in order:

| Stage | What happens |
| --- | --- |
| **Default shell** | Adds `zsh` to `/etc/shells` if missing, then sets it as your login shell via `chsh`. |
| **Package manager (macOS)** | Installs Homebrew, updates it, then installs every formula and cask listed in `brew/Brewfile`. |
| **Package manager (Linux)** | Runs `scripts/setup/linux.sh` (apt system deps only), then `scripts/setup/nix.sh` (installs Nix + applies `nix/home.nix` via Home Manager for CLI tools — Homebrew/Linuxbrew is **not** used on Linux). |
| **macOS-only extras** | `scripts/setup/sublime.sh` and `scripts/setup/iterm.sh` deploy settings from `settings/` (skipped in CI). |
| **Stow** | Removes any old manual symlinks, then runs `make run` to stow every package listed in `STOW_PACKAGES` (`make print-STOW_PACKAGES` to see the current list — 8 packages as of this writing). |
| **Verification** | Runs `scripts/verify/check.sh --quick` to confirm everything is linked and working. |

---

## Platform-Specific Notes

### macOS

- Homebrew installs to `/opt/homebrew` on Apple Silicon and `/usr/local` on Intel Macs. The installer handles both.
- GUI apps (casks) in the Brewfile are macOS-only and are skipped on Linux automatically.
- There's no automated Finder/Dock/trackpad preference setup currently — only Sublime Text and iTerm2 settings deployment are automated (`scripts/setup/sublime.sh`, `scripts/setup/iterm.sh`).

### Linux

- **Linux does not use Homebrew or Linuxbrew.** CLI tools (eza, bat, fd, zoxide, ripgrep, neovim, ...) come from **Nix + Home Manager** instead — see [`NIX.md`](NIX.md). `scripts/setup/linux.sh` only installs apt system dependencies (build tools, stow, zsh, fontconfig); `scripts/setup/nix.sh` installs Nix itself and applies `nix/home.nix`.
- After installation, if a Nix-provided tool isn't found in a new shell, make sure the Home Manager profile is on `PATH` — see [`NIX.md`](NIX.md) for the exact `source` line.

### Windows

Windows doesn't use Stow or this same `install.sh` — see the [README's Windows section](../README.md) for the one-line installer. Two usage patterns are both supported:

- **WSL2** (recommended for the actual dev shell): install Ubuntu via WSL2, then follow the Linux instructions above from inside it — all 8 Stow packages work completely unmodified there.
- **Native PowerShell**: `install.ps1` clones the repo and delegates to `scripts/setup/windows.ps1`, which installs packages via Scoop, creates symlinks with a hand-rolled equivalent of Stow, and sets up a native PowerShell profile.

Many people use both: WSL2 for nvim/tmux/zsh/git day to day, native PowerShell/Windows Terminal for everything else.

---

## (Optional) SSH Key Setup

Generate SSH keys and `~/.ssh/config` aliases for separate **personal** and
**work** GitHub identities (cross-platform):

```bash
dutils ssh-setup                       # interactive: personal / work / both
dutils ssh-setup --profile personal -e you@gmail.com
dutils ssh-setup --profile work -e you@company.com --name "Your Name"
```

Per profile it generates an Ed25519 key (never clobbering an existing one), sets
`600`/`644` perms, writes an idempotent `Host` alias into `~/.ssh/config`, adds
the key to `ssh-agent`, and copies the public key to your clipboard. The `Host`
alias makes the git commit email follow the remote automatically.

See **[docs/SSH.md](SSH.md)** for the full model (how the identity is chosen per
repo, `config-local`, enterprise hosts, Windows notes).
