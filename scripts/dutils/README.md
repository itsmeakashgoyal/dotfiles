# dutils — Dotfiles Utility Tool

A single CLI entry point (`scripts/dutils/dutils`) that dispatches to the other scripts in this
directory. Each subcommand `exec`s its script directly, so there's no wrapper overhead.

## Quick Start

`dutils` isn't symlinked onto your `PATH` by anything in this repo — that's a manual, one-time step:

```bash
export PATH="$HOME/.local/bin:$PATH"   # add to your shell config if not already there
ln -sf ~/dotfiles/scripts/dutils/dutils ~/.local/bin/dutils
```

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

### `ssh-keygen` — generate an SSH key

```bash
dutils ssh-keygen -e you@example.com            # ed25519 (default)
dutils ssh-keygen -e you@example.com -t rsa     # rsa
```

Adds the key to `ssh-agent`, copies the public key to your clipboard, and prompts for a new name
if one already exists at that path.

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
├── setup_ssh.sh                # ssh-keygen subcommand (also directly runnable, see docs/INSTALLATION.md)
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

**`command not found: dutils`** — the symlink from Quick Start above is missing or `~/.local/bin`
isn't on `PATH`.

**Permission denied** — `chmod +x ~/dotfiles/scripts/dutils/dutils ~/dotfiles/scripts/dutils/*.sh`.

**`diff-so-fancy`/`delta` not found** — not an error, `diff` just falls back to plain output.
Optional install: `brew install git-delta` (macOS) or add `git-delta` to `nix/home.nix` (Linux).

## Suggested aliases

Not defined anywhere in this repo — add to your own `.zshrc`/`99-private.zsh` if useful:

```zsh
alias dcl='dutils cleanup'
alias dssh='dutils ssh-keygen'
alias dos='dutils detect-os'
alias ddiff='dutils diff'
alias dlf='dutils list-functions'
```

## Related Documentation

- Main dotfiles: [`/dotfiles/README.md`](../../README.md)
- Neovim: [`/dotfiles/nvim/.config/nvim/PLUGINS.md`](../../nvim/.config/nvim/PLUGINS.md)
- Tmux: [`/dotfiles/tmux/.config/tmux/README.md`](../../tmux/.config/tmux/README.md)
