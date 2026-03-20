# Troubleshooting

[← Back to README](../README.md)

---

## `brew` command not found (Linux)

Linuxbrew needs its shell environment loaded. This should happen automatically via `.zshenv`, but if not:

```bash
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
```

## Stow conflicts with existing files

If `stow` reports a conflict, it means a real file (not a symlink) already exists at the target path. Back it up and retry:

```bash
mv ~/.config/nvim ~/.config/nvim.backup
make run
```

## Git config not found after install

Git reads its global config from `~/.config/git/config` (XDG path). If `~/.gitconfig` exists, Git prefers it and ignores the XDG path. Remove the old file:

```bash
rm ~/.gitconfig
git config user.name   # should now print your name
```

## Neovim plugins not loading

```bash
nvim --headless "+Lazy! sync" +qa
```

Or open Neovim and run `:Lazy sync`.

## Zsh completions broken

```bash
rm -f ~/.config/zsh/.zcompdump*
exec zsh
```

## Permission errors

```bash
sudo chown -R $(whoami) ~/dotfiles
```

## Full debug workflow

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
