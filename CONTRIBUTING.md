# Contributing

Rules and layout for changing this repo (for humans and AI agents alike).

## Layout

Each top-level folder is a [GNU Stow](https://www.gnu.org/software/stow/) package that mirrors `$HOME`:
`stow nvim` links `nvim/.config/nvim` → `~/.config/nvim`. Windows uses `windows/windows.ps1` instead of Stow.

| Path | What |
| --- | --- |
| `zsh/` | `.zshenv` + `.config/zsh/` (`.zshrc`, `.p10k.zsh`, numbered `conf.d/*.zsh`) |
| `git/ nvim/ tmux/ starship/ atuin/ television/ yazi/ fastfetch/ readline/ mise/` | Tool configs (Stow packages) |
| `bin/` | `~/.local/bin` scripts, incl. the `dutils` CLI symlink |
| `settings/` | iTerm2 profile (`iterm/profile.json`) and Sublime Text settings |
| `windows/` | PowerShell profile + `install.ps1` / `windows.ps1` |
| `scripts/dutils/` | `dutils` CLI (Python ≥ 3.14) |
| `scripts/setup/` | Per-OS install steps; `scripts/lib/` shared shell/Python helpers; `scripts/verify/` health checks |
| `packages.toml` | **Single source** of every package on every OS + the Stow package list |
| `brew/Brewfile`, `nix/home.nix`, `windows/windows.ps1`, `Makefile` | Contain **generated** regions (from `packages.toml`) |

## Rules

- **Packages:** edit `packages.toml`, then `dutils manifest generate`. Never hand-edit between `# BEGIN GENERATED` / `# END GENERATED` markers (`dutils manifest check` fails CI on drift).
- **New Stow package:** `dutils new <name>` (or add the folder + a `[[stow]]` entry, then `dutils manifest generate`).
- **Secrets / identities:** never commit them. Machine-local exports go in `zsh/.config/zsh/conf.d/99-private.zsh` (gitignored, owner-only). Git identities live in `~/.config/dotfiles/git/` (`dutils git-setup`), the tracked git config has none.
- **Shell scripts:** `#!/bin/bash`, `set -euo pipefail`, source `scripts/lib/core.sh`, use its `info`/`success`/`warning`/`error` for output, pass `shellcheck -x`. Style is hand-aligned: **don't run `shfmt -w`** on the repo.
- **Python:** requires ≥ 3.14 (entry points call `scripts/lib/pyreq.py`), stdlib only.
- **Zsh speed:** nothing may fork at startup or on every prompt when a builtin works (`$OSTYPE` not `uname`, `${commands[x]}` not `$(command -v x)`, `$(<file)` not `cat`). Wrap `tool init zsh` in `cached_init`. Nothing may print after p10k's instant prompt. Check with `dutils bench --real`.
- **Docs:** how-to only, in `README.md` + `docs/{SETUP,CHEATSHEET,CUSTOMIZE}.md`. Update them with the change.

## Check before committing

```bash
find . -name "*.sh" ! -name profile_zsh.sh -exec shellcheck -x {} +   # lint shell
dutils manifest check                                               # generated lists in sync
make health                                                         # links + tools
dutils bench --real                                                 # if you touched zsh
```

CI (`.github/workflows/build_and_test.yml`) runs lint, then a full install + uninstall on macOS, Ubuntu and Windows.

## Commits

[Conventional commits](https://www.conventionalcommits.org/): `feat(zsh): …`, `fix(git): …`, `docs: …`, `chore: …`. Target `master`; CI must pass.
