# dutils — Dotfiles Utility Tool

A single CLI entry point (`scripts/dutils/dutils`) that dispatches to the other scripts in this
directory. Each subcommand `exec`s its script directly, so there's no wrapper overhead.

## Quick Start

`dutils` is exposed on your `PATH` automatically by the `bin` Stow package —
`bin/.local/bin/dutils` is a symlink into this directory, so `make run` (or
`make stow pkg=bin`) creates `~/.local/bin/dutils` for you. Just ensure
`~/.local/bin` is on your `PATH` (it is by default in this repo's zsh config):

```bash
dutils help                # list all commands
dutils version             # show version
dutils <command> [options] # run a command
```

## Commands

### `cleanup` — remove dotfiles/Homebrew/Neovim/tmux configuration

```bash
dutils cleanup                   # interactive component picker
dutils cleanup nvim              # clean a specific component
dutils cleanup dotfiles tmux     # clean several
dutils cleanup -y all            # clean everything, no prompts
```

Components: `dotfiles` (remove Stow symlinks), `homebrew` (uninstall Homebrew + all packages),
`nvim` (remove Neovim config/data/cache), `tmux` (remove tmux config), `all`. The `dotfiles` and
`homebrew` components delegate to [`scripts/setup/uninstall.sh`](../setup/uninstall.sh) so there's
one implementation of "how teardown actually works" shared with `make uninstall`.

### `ssh-setup` — SSH keys + config for personal & work GitHub

```bash
dutils ssh-setup                                  # interactive: personal / work / both
dutils ssh-setup --profile personal -e you@gmail.com
dutils ssh-setup --profile work -e you@company.com --name "Your Name"
```

Cross-platform (macOS/Linux/Windows). Per profile it generates an Ed25519 key (never clobbering an
existing one), writes an idempotent `Host` alias into `~/.ssh/config`, adds the key to `ssh-agent`,
and copies the public key to your clipboard. The `Host` alias is what makes the git commit identity
follow the remote automatically — see [docs/SSH.md](../../docs/SSH.md). `ssh-keygen` is a
back-compat alias of `ssh-setup`.

### `detect-os` — print OS/arch detection

```bash
dutils detect-os
```

### `diff` — interactive two-file diff

```bash
dutils diff
```

Picks two files via `tv` (television), then live-diffs them with `entr` — updates automatically
as either file changes. Uses `delta` for the display if installed, otherwise plain `diff`.
Requires `tv`, `diff`, `entr` on `PATH` (`delta` optional). On Linux these come from Nix
(`nix/home.nix`) — see [`docs/NIX.md`](../../docs/NIX.md).

### `install-nvim` — install latest Neovim from GitHub releases (Linux only)

```bash
dutils install-nvim
```

Backs up the existing config to `~/linuxtoolbox/backup/nvim`, then installs to `/opt/nvim`. On
macOS, use `brew install neovim` instead.

### `list-functions` — list documented zsh functions

```bash
dutils list-functions
```

Parses `zsh/.config/zsh/conf.d/functions.zsh` for comment-then-function pairs and prints them as
a table.

### `debug` — run a script under `bash -x`

```bash
dutils debug my-script.sh arg1 arg2
```

## Script Organization

```text
scripts/dutils/
├── dutils                      # CLI entry point / dispatcher
├── cleanup.py                  # cleanup subcommand
├── ssh_setup.py                # ssh-setup subcommand (personal & work SSH keys/config, see docs/SSH.md)
├── diff_files_interactive.sh   # diff subcommand
├── install_nvim.py             # install-nvim subcommand
├── print_functions.py          # list-functions subcommand
├── run_with_xtrace.sh          # debug subcommand
├── profile_zsh.sh              # zsh startup profiler (invoked by `make bench-detail`, not dutils)
└── README.md                   # this file
```

Shared logging/OS-detection helpers used across the repo live one level up, in
[`scripts/lib/core.sh`](../lib/core.sh) and [`scripts/lib/os-detect.sh`](../lib/os-detect.sh) —
not in this directory.

## Troubleshooting

**`command not found: dutils`** — the `bin` package isn't stowed (`make stow pkg=bin`) or
`~/.local/bin` isn't on `PATH`.

**Permission denied** — `chmod +x ~/dotfiles/scripts/dutils/dutils ~/dotfiles/scripts/dutils/*.sh`.

**`diff-so-fancy`/`delta` not found** — not an error, `diff` just falls back to plain output.
Optional install: `brew install git-delta` (macOS) or add `git-delta` to `nix/home.nix` (Linux).

## Suggested aliases

Not defined anywhere in this repo — add to your own `.zshrc`/`99-private.zsh` if useful:

```zsh
alias dcl='dutils cleanup'
alias dssh='dutils ssh-setup'
alias dos='dutils detect-os'
alias ddiff='dutils diff'
alias dlf='dutils list-functions'
```

## Related Documentation

- Main dotfiles: [`/dotfiles/README.md`](../../README.md)
- Neovim: [`/dotfiles/nvim/.config/nvim/PLUGINS.md`](../../nvim/.config/nvim/PLUGINS.md)
- Tmux: [`/dotfiles/tmux/.config/tmux/README.md`](../../tmux/.config/tmux/README.md)
