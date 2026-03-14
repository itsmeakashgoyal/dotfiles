# Architecture

This document explains how the dotfiles repository is structured and how the pieces fit together.

---

## Core Concept: GNU Stow

Every top-level directory is a **Stow package**. Stow creates symlinks in `$HOME` that mirror the package's internal directory structure:

```
dotfiles/
└── zsh/                          ← Stow package
    ├── .zshenv                   → symlink at ~/.zshenv
    └── .config/
        └── zsh/                  → symlink at ~/.config/zsh/
            ├── .zshrc
            ├── .zprofile
            └── conf.d/
```

Running `stow zsh` from the repo root creates `~/.zshenv → ~/dotfiles/zsh/.zshenv` and `~/.config/zsh → ~/dotfiles/zsh/.config/zsh`.

Because the target files are symlinks back into the repo, edits take effect immediately — no re-linking required.

---

## Package Map

```
dotfiles/
├── git/      → ~/.config/git/          Git config, aliases, delta integration
├── zsh/      → ~/.zshenv               XDG pointer; sets ZDOTDIR
│             → ~/.config/zsh/          All Zsh config
├── nvim/     → ~/.config/nvim/         Neovim with Lazy.nvim
├── tmux/     → ~/.config/tmux/         Tmux with TPM
└── ohmyposh/ → ~/.config/ohmyposh/     Oh My Posh prompt theme
```

---

## Zsh Configuration Flow

```
zsh invoked
     │
     ▼
~/.zshenv  (always sourced — sets ZDOTDIR=$HOME/.config/zsh, XDG vars)
     │
     ▼ (login shell only)
~/.config/zsh/.zprofile  (PATH additions, Homebrew env)
     │
     ▼ (interactive shell)
~/.config/zsh/.zshrc
     ├── Powerlevel10k instant prompt (top, before anything else)
     ├── Zinit bootstrap
     ├── Plugins: completions → compinit → autosuggestions → syntax-highlighting → p10k
     └── source conf.d/*.zsh  (alphabetical order)
              ├── aliases.zsh
              ├── docker.zsh
              ├── exports.zsh
              ├── fzf.zsh
              ├── functions.zsh
              ├── git.zsh
              ├── options.zsh
              ├── python.zsh
              ├── startup.zsh
              └── private.zsh  ← gitignored, machine-local last
```

**Ordering constraint:** Powerlevel10k instant prompt must be the first thing in `.zshrc`. Any output before it causes a warning. The `conf.d/` files are sourced after all plugin initialization is done.

---

## Installation Flow

```
bootstrap.sh  (fresh machines without git)
     │  git clone + exec install.sh
     ▼
install.sh
     ├── 1. Source scripts/utils/_helper.sh  (logging, OS detection)
     ├── 2. packages/install.sh              (Homebrew + Brewfile bundle)
     ├── 3. chsh → zsh                       (set default shell)
     ├── 4. scripts/setup/_macOS.sh          (macOS system prefs)
     │      or scripts/setup/_linuxOS.sh     (apt packages, locale)
     ├── 5. stow --restow <each package>     (create all symlinks)
     └── 6. scripts/verification/health_check.sh
```

---

## Scripts Architecture

All scripts share a common utility layer:

```
scripts/
├── utils/
│   ├── _helper.sh         ← sourced by everything; provides:
│   │                         log_message(), info(), success(),
│   │                         warning(), error(), substep_info()
│   │                         check_required_commands()
│   │                         sudo_keep_alive()
│   │                         OS_TYPE detection
│   ├── _logger.sh         ← multi-level logging (TRACE→FATAL)
│   ├── _detect_os.sh      ← OS/arch detection helpers
│   ├── _cleanup.sh        ← backup and cleanup utilities
│   ├── _setup_ssh.sh      ← Ed25519 SSH key generation
│   ├── _install_nvim.sh   ← Neovim manual installer (fallback)
│   └── dutils             ← CLI tool wrapping helper functions
│
├── setup/
│   ├── _macOS.sh          ← defaults write system preferences
│   ├── _linuxOS.sh        ← apt-get packages, fonts, locale
│   ├── _sublime.sh        ← Sublime Text config deployment
│   └── _iterm.sh          ← iTerm2 plist deployment
│
└── verification/
    ├── health_check.sh         ← fast: symlinks, core tools (~5s)
    ├── verify_installation.sh  ← full: 40+ components, outputs score
    ├── system_info.sh          ← OS, hardware, dev tool versions
    └── check_packages.sh       ← Brewfile vs installed diff
```

---

## Neovim Plugin Architecture

```
nvim/.config/nvim/
├── init.lua                    ← 3-line entry: options, lazy, theme
└── lua/akgoyal/
    ├── core/
    │   ├── options.lua         ← vim.opt settings
    │   ├── keymaps.lua         ← global key bindings
    │   └── autocommands.lua    ← autocmd groups
    └── plugins/                ← one file per plugin (lazy.nvim specs)
        ├── lsp/
        │   ├── lspconfig.lua   ← server setup
        │   └── mason.lua       ← LSP installer
        ├── telescope.lua       ← fuzzy finder
        ├── treesitter.lua      ← syntax + textobjects
        ├── completion.lua      ← nvim-cmp + snippets
        └── ...
```

Lazy.nvim auto-discovers plugin specs from `lua/akgoyal/plugins/`. Adding a new plugin means creating a new file in that directory — no central registry to update.

---

## CI/CD Pipeline

```
push / PR to master
        │
        ▼
   ┌─────────┐
   │  lint   │  shellcheck + shfmt + yamllint + file permissions
   └────┬────┘
        │ (parallel)
   ┌────┴──────────────────┐
   ▼                       ▼
test-macos              test-ubuntu
  install.sh              install.sh
  verify packages         verify packages
  zsh config test         zsh config test
                          dutils commands test
   └────────────────┬──────────────────┘
                    ▼
               summary job
```

All jobs cache Homebrew packages keyed on `Brewfile` hash to speed up re-runs.

---

## XDG Base Directory Compliance

This setup fully follows the [XDG Base Directory Specification](https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html):

| XDG Variable | Default | What lives there |
|---|---|---|
| `XDG_CONFIG_HOME` | `~/.config` | All tool configs (`git/`, `zsh/`, `nvim/`, `tmux/`) |
| `XDG_DATA_HOME` | `~/.local/share` | Zinit plugins, Neovim data |
| `XDG_CACHE_HOME` | `~/.cache` | Zsh completion cache, Homebrew |
| `XDG_STATE_HOME` | `~/.local/state` | Shell history, logs |

`~/.zshenv` bootstraps all XDG variables and sets `ZDOTDIR=$XDG_CONFIG_HOME/zsh` so Zsh finds its config in the XDG location rather than `$HOME`.
