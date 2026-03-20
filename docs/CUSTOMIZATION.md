# Customization

[← Back to README](../README.md)

---

## Git

Edit `git/.config/git/config` and update the `[user]` section:

```ini
[user]
    name = Your Name
    email = your.email@example.com
```

Git discovers this config automatically via the XDG path (`~/.config/git/config`). No environment variable needed.

---

## Zsh

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

---

## Neovim

| Task | File |
| --- | --- |
| Add a plugin | Create a file in `nvim/.config/nvim/lua/akgoyal/plugins/` |
| Change keymaps | `nvim/.config/nvim/lua/akgoyal/core/keymaps.lua` |
| Change colorscheme | `nvim/.config/nvim/lua/akgoyal/plugins/colorscheme.lua` |
| Filetype settings | `nvim/.config/nvim/after/ftplugin/<filetype>.lua` |

---

## Tmux

Edit `tmux/.config/tmux/tmux.conf` directly. Changes apply on the next tmux session or after:

```bash
tmux source ~/.config/tmux/tmux.conf
```

---
