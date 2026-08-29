# Architecture

This document explains how the dotfiles repository is structured and how the pieces fit together.

---

## Core Concept: GNU Stow

Every top-level directory is a **Stow package**. Stow creates symlinks in `$HOME` that mirror the package's internal directory structure:

```text
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

This is macOS/Linux-only. Windows doesn't run Stow at all — see [Windows](#windows) below.

---

## Package Map

The Makefile's `STOW_PACKAGES` variable (`make print-STOW_PACKAGES`) is the single source of truth for which packages exist:

```text
dotfiles/
├── git/         → ~/.config/git/          Git config, aliases, delta integration
├── zsh/         → ~/.zshenv               XDG pointer; sets ZDOTDIR
│                → ~/.config/zsh/          All Zsh config (conf.d/, .zshrc)
├── nvim/        → ~/.config/nvim/         Neovim with Lazy.nvim
├── tmux/        → ~/.config/tmux/         Tmux config
├── television/  → ~/.config/television/   Fuzzy finder + "cable" channel configs
├── bin/         → ~/.local/bin/           Custom scripts (yank, zoxide-edit)
├── atuin/       → ~/.config/atuin/        Shell history search
├── fastfetch/   → ~/.config/fastfetch/    System info display
└── starship/    → ~/.config/starship/     Cross-shell prompt (default)
```

`powershell/` is a tenth package-shaped directory that mirrors this same layout, but is deliberately **not** in `STOW_PACKAGES` — Windows uses its own symlink function instead of Stow (see [Windows](#windows)).

---

## Zsh Configuration Flow

```text
zsh invoked
     │
     ▼
~/.zshenv  (always sourced — sets ZDOTDIR=$HOME/.config/zsh, XDG vars incl.
            XDG_DOTFILES_DIR, self-located via zsh's %x + :A)
     │
     ▼ (login shell only)
~/.config/zsh/.zprofile  (PATH additions, Homebrew env)
     │
     ▼ (interactive shell)
~/.config/zsh/.zshrc
     ├── Zinit bootstrap + all plugin declarations (completions, autosuggestions,
     │   syntax-highlighting, OMZP::git/sudo) — plugins are declared directly
     │   in .zshrc, not in conf.d/
     ├── Starship init (eval "$(starship init zsh)"), reading
     │   ~/.config/starship/starship.toml — the default prompt
     └── source conf.d/*.zsh  (numeric order, not alphabetical)
              ├── 00-logo.zsh              ASCII greeting (interactive, non-tmux)
              ├── 01-exports.zsh           PATH, OS detection, env vars
              ├── 02-options.zsh           Shell options, history, completion
              ├── 03-startup.zsh           Completion system init
              ├── 04-aliases.zsh           eza/bat/tmux/docker/system aliases
              ├── 05-functions.zsh         Utility functions
              ├── 06-git.zsh               Git aliases + functions (gs, gco, ...)
              ├── 07-docker.zsh            Docker container/image management
              ├── 08-python.zsh            mise/venv management
              ├── 09-television.zsh        Fuzzy finder keybindings
              ├── 10-atuin.zsh             Shell history search (Ctrl+R)
              ├── 11-colored-man-pages.zsh
              ├── 12-prompt-styles.zsh     6 hand-rolled pure-zsh prompt alternatives
              │                            (zero-dependency fallback to Starship)
              ├── 13-vi-mode.zsh
              ├── 14-abbreviations.zsh
              ├── 15-nix.zsh               Nix/Home Manager PATH (Linux)
              └── 99-private.zsh           ← gitignored, machine-local, last
```

**Ordering constraint:** the `conf.d/` files are sourced after all Zinit plugin declarations and the Starship init.

---

## Installation Flow

```text
bootstrap.sh  (fresh machines without git)
     │  git clone + exec install.sh
     ▼
install.sh
     ├── 1. Self-locate DOTFILES_DIR (BASH_SOURCE-based), source scripts/lib/core.sh
     ├── 2. Set default shell → zsh
     ├── 3. OS branch:
     │        macOS  → packages/install.sh   (Homebrew + Brewfile bundle)
     │        Linux  → scripts/setup/linux.sh (apt system deps)
     │                 + scripts/setup/nix.sh (Nix + Home Manager: CLI tools)
     ├── 4. macOS only: scripts/setup/sublime.sh, scripts/setup/iterm.sh (settings/)
     ├── 5. make run   (stow every package in STOW_PACKAGES)
     └── 6. scripts/verify/check.sh --quick
```

Linux does **not** use Linuxbrew — that was retired in favor of Nix + Home Manager (`nix/home.nix`) for CLI tools, with `apt` handling only system-level build dependencies. See [`NIX.md`](NIX.md) for details.

There is no `scripts/setup/macos.sh` — macOS system-preference tweaks aren't currently automated; only Sublime Text and iTerm2 settings deployment are (`sublime.sh`, `iterm.sh`).

---

## Scripts Architecture

```text
scripts/
├── lib/
│   ├── core.sh          ← sourced by every bash entry-point script:
│   │                         logging (log::*, plus legacy info()/success()/...)
│   │                         pkg::*/util:: helpers, run_script(), print_error()
│   │                         side effects: creates ~/linuxtoolbox, /tmp/dotfiles.log
│   ├── os-detect.sh      ← os::is_mac / os::is_linux / os::arch / os::detail
│   │                         split out of core.sh so it has NO side effects —
│   │                         safe to source from zsh's interactive startup too
│   └── osdetect.py       ← same API, for the Python scripts below
│
├── setup/
│   ├── linux.sh          ← apt system deps only (Ubuntu/Debian)
│   ├── nix.sh            ← installs Nix + applies nix/home.nix (Linux CLI tools)
│   ├── sublime.sh        ← Sublime Text config deployment (macOS)
│   ├── iterm.sh          ← iTerm2 plist deployment (macOS)
│   ├── uninstall.sh      ← full teardown: shell, symlinks, Nix, Homebrew
│   └── windows.ps1       ← Windows equivalent (Scoop, symlinks, PS modules)
│
├── verify/
│   ├── check.sh          ← thin shim, execs check.py
│   └── check.py          ← the real implementation (OOP): --quick/--full/
│                             --packages/--system/--all, dispatched by
│                             `make health/check/packages/sysinfo/diagnose`
│
├── utils/
│   ├── cleanup.py        ← symlink/Homebrew cleanup helpers
│   ├── install_nvim.py   ← manual Neovim installer (Linux fallback)
│   ├── _setup_ssh.sh     ← Ed25519/RSA SSH key generation
│   ├── profile_zsh.sh    ← zprof startup profiling (`make bench-detail`)
│   └── dutils            ← CLI wrapping various helper functions
│
└── motd/                 ← Ubuntu /etc/update-motd.d banner scripts — manual
                              install only, see scripts/motd/README.md
```

There is a single verification implementation (`check.py`), not several separate scripts — `make health`, `make check`, `make sysinfo`, `make packages`, and `make diagnose` all dispatch into it with different mode flags.

---

## Neovim Plugin Architecture

```text
nvim/.config/nvim/
├── init.lua                    ← 3 lines: core, lazy.lua, current-theme
└── lua/
    ├── current-theme.lua
    └── akgoyal/
        ├── core/
        │   ├── init.lua        ← requires options.lua + keymaps.lua
        │   ├── options.lua     ← vim.opt settings
        │   └── keymaps.lua     ← global key bindings
        ├── lazy.lua            ← bootstraps lazy.nvim, imports plugins/ + plugins/lsp/
        └── plugins/            ← one file per plugin (lazy.nvim specs), ~45 files
            └── lsp/
                └── mason.lua   ← mason + mason-lspconfig + nvim-lspconfig + nvim-cmp
```

Lazy.nvim auto-discovers plugin specs from `lua/akgoyal/plugins/` (and `plugins/lsp/`). Adding a new plugin means creating a new file in that directory — no central registry to update. Most plugin files declare an `event`/`cmd`/`ft`/`keys` lazy-load trigger; a few (colorscheme, mason, snacks) are intentionally eager.

---

## CI/CD Pipeline

```text
push / PR to master
        │
        ▼
   ┌─────────┐
   │  lint   │  shellcheck + shfmt + yamllint + file permissions + py_compile
   └────┬────┘
        │ (parallel)
   ┌────┴──────────────────────────┐
   ▼                ▼               ▼
test-macos       test-ubuntu    test-windows (soft-gated, continue-on-error)
  install.sh       install.sh      windows.ps1 install
  verify packages  verify (Nix)    verify PowerShell profile symlink
  zsh config test  zsh config test
  nvim config test nvim config test
                   dutils test
  uninstall        uninstall
  verify uninstall verify uninstall
   └────────────────┬──────────────┘
                    ▼
               summary job
        (gates on lint + test-macos + test-ubuntu;
         test-windows is informational only for now)
```

The zsh-config-test step actually sources `.zshrc` (not just `.zshenv`) and asserts real exit codes on missing aliases — earlier versions of this pipeline swallowed all failures here, so it could never actually fail.

---

## Windows

Windows has a separate, non-Stow installation path since GNU Stow doesn't run natively there:

```text
install.ps1                          ← entry point (mirrors install.sh)
     │  clone/update repo, checks Admin/Developer Mode
     ▼
scripts/setup/windows.ps1
     ├── Scoop package manager + package list
     ├── New-DotfileSymlink          ← hand-rolled symlink function per
     │                                  entry in $SYMLINK_MAP (cross-referenced
     │                                  against STOW_PACKAGES, kept in sync by hand)
     ├── PowerShell modules (PSReadLine, PSFzf, Terminal-Icons)
     ├── Neovim GUI config (ginit.vim for nvim-qt/Neovide)
     └── Test-Installation           ← health check; exits non-zero under
                                        $env:CI when incomplete
```

`powershell/Documents/PowerShell/Microsoft.PowerShell_profile.ps1` mirrors the zsh conf.d functionality (aliases, PSReadLine Vi-mode, fzf bindings) for native PowerShell use. The recommended daily-driver path for the actual dev shell (nvim/tmux/zsh/git/television/atuin/fastfetch/bin scripts) is **WSL2** — all 8 Stow packages work there completely unmodified, since WSL2 is just Ubuntu from Stow's point of view.

---

## XDG Base Directory Compliance

This setup fully follows the [XDG Base Directory Specification](https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html):

| XDG Variable | Default | What lives there |
|---|---|---|
| `XDG_CONFIG_HOME` | `~/.config` | All tool configs (`git/`, `zsh/`, `nvim/`, `tmux/`, ...) |
| `XDG_DATA_HOME` | `~/.local/share` | Zinit plugins, Neovim data |
| `XDG_CACHE_HOME` | `~/.cache` | Zsh completion cache, Homebrew |
| `XDG_STATE_HOME` | `~/.local/state` | Shell history, logs |
| `XDG_DOTFILES_DIR` | repo root (self-located) | Where this repo actually lives |

`~/.zshenv` bootstraps all XDG variables and sets `ZDOTDIR=$XDG_CONFIG_HOME/zsh` so Zsh finds its config in the XDG location rather than `$HOME`.
