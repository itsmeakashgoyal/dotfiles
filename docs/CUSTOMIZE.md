# Customize this setup

How to change and personalise the dotfiles. Edit the files in the repo: they are
symlinked into `$HOME`, so most changes apply in a new shell.

- [Theme](#theme)
- [Prompt](#prompt)
- [iTerm2](#iterm2)
- [Sublime Text](#sublime-text)
- [Shell](#shell)
- [Python](#python)
- [Add a tool or package](#add-a-tool-or-package)
- [Git](#git)
- [macOS defaults](#macos-defaults)

## Theme

Every tool uses Gruvbox Dark by default. `dutils theme` switches the terminal only.

```bash
dutils theme            # status
dutils theme dark       # Gruvbox Dark (default)
dutils theme light      # Gruvbox Light
dutils theme auto       # follow the OS light/dark setting
dutils theme toggle     # dark ↔ light
dutils theme apply      # re-render from the saved mode
```

| Follows `dutils theme` | Applies |
| --- | --- |
| iTerm2 (Dynamic Profile) | immediately |
| bat + delta (`$BAT_THEME`), starship palette | new shell (`exec zsh`) |
| Neovim | restart Neovim |
| tmux status bar, completion menus, fzf | automatically (they use the terminal's ANSI colours) |

Always Gruvbox Dark: eza (`eza/.config/eza/theme.yml`), yazi (flavor in `yazi/.config/yazi/theme.toml`), and man pages (bat, via `$BAT_THEME`).

The mode is saved per machine in `~/.config/dotfiles/theme`. Sublime Text is not
affected. To make it follow the OS, set both `"theme"` and `"color_scheme"` to
`"auto"` in `settings/sublime/Preferences.sublime-settings`.

## Prompt

The default zsh prompt is Powerlevel10k, and starship is the fallback.

| Task | How |
| --- | --- |
| Restyle Powerlevel10k | `p10k configure`. It writes back to `zsh/.config/zsh/.p10k.zsh` in the repo. Answer **No** if it offers to edit `.zshrc` |
| Tweak Powerlevel10k by hand | Edit `zsh/.config/zsh/.p10k.zsh`, then `exec zsh` |
| Switch to starship | `export DOTFILES_PROMPT=starship` in the environment, or change `: "${DOTFILES_PROMPT:=p10k}"` at the top of `zsh/.config/zsh/.zshrc` |
| Edit starship | `starship/.config/starship/starship.toml` (has both `gruvbox_dark` and `gruvbox_light` palettes) |

`DOTFILES_PROMPT` does **not** work in `99-private.zsh`, because that file loads
after the prompt. After a change, check prompt speed with `dutils bench --real`
(first prompt, per-Enter lag, typing lag).

## iTerm2

iTerm2 uses a Dynamic Profile generated from `settings/iterm/profile.json`.

1. Edit `settings/iterm/profile.json`. Shared settings go under `"common"`, and
   per-profile overrides go under `"profiles"` (Gruvbox, Gruvbox Hotkey). Keys
   are iTerm2's own profile keys.
2. Run `dutils theme apply`. iTerm2 reloads the profile live.

Colours are added by `dutils theme`. Don't put them in `profile.json`.

To set the default profile and the global preferences (the `defaults write`
lines in `scripts/setup/iterm.sh`), quit iTerm2 and run `make iterm` from
Terminal.app.

## Sublime Text

Every file in `settings/sublime/` is symlinked into Sublime's `Packages/User`
folder, so repo edits apply live.

Run `make sublime` on macOS/Linux to link the settings and install Package
Control. On Windows, `windows/windows.ps1` does this.

| Change | File |
| --- | --- |
| Font, theme, editor settings | `Preferences.sublime-settings` |
| Packages (LSP, Terminus, GitGutter, …) | `Package Control.sublime-settings` |
| Language servers (clangd, pyright, ruff) | `LSP.sublime-settings` |
| Key bindings | `Default.sublime-keymap` |
| Tab bar look | `Adaptive.sublime-theme` |
| Colours | `Gruvbox Dark/Light.sublime-color-scheme` |
| Build systems | `C++ Single File.sublime-build`, `Python3.sublime-build` |

Sublime itself rewrites `Preferences` and `Package Control` settings. Review
`git diff` before committing them.

## Shell

Zsh config is in `zsh/.config/zsh/`. `.zshrc` sources every
`conf.d/*.zsh` file in name order.

| Add / change | Where |
| --- | --- |
| Aliases | `conf.d/04-aliases.zsh` |
| Functions | `conf.d/05-functions.zsh` |
| `PATH` / environment variables | `conf.d/01-exports.zsh` |
| Options, history, completion | `conf.d/02-options.zsh` |
| A new topic | a new `conf.d/NN-name.zsh` file (pick a free number below 99) |
| Machine-local settings, work exports, secrets | `conf.d/99-private.zsh` |

**Projects.** `p` / `⌃G` / tmux `prefix f` search for git repos under `~/Workspace ~/ws ~/work ~/personal ~/code ~/projects ~/dotfiles`. Change with `export DOTFILES_PROJECT_ROOTS="$HOME/src:$HOME/work"` in `99-private.zsh`.

**Work shortcuts** (build/test commands for a work repo) belong in `99-private.zsh` too, never in tracked files.

**Private overrides.** `99-private.zsh` is gitignored and loads last. `.zshrc`
resets its permissions to owner-only (600). Never put secrets in tracked files.

**Keep startup fast.** Avoid `$(...)` and external commands at startup or in
prompt hooks. Use builtins instead (`${commands[x]}`, `$(<file)`, `$OSTYPE`),
and cache `tool init zsh` output with `cached_init` (from `01-exports.zsh`).
Measure with `dutils bench --real`, then apply changes with `exec zsh`.

## Python

Python 3.14 is the standard: mise selects the interpreter, and uv manages venvs
and packages.

| Task | Command |
| --- | --- |
| Change the global default | edit `mise/.config/mise/config.toml` (`python = "3.14"`) |
| Pin a project | `mise use python@3.12` in the project (writes `mise.toml`), or add a `.python-version` |
| Apply an edited `mise.toml` in the current directory | `cd .` |
| See the active version | `mise current` |
| Create and activate `.venv` | `mkvenv` (or `mkvenv <name>`, or `mkvenv <name> 3.12`) |
| Activate an existing venv | `venv` (or `venv <name>`) |
| Deactivate / delete | `deactivate` / `rmvenv` (or `rmvenv <name>`) |
| Install packages | `uv pip install <pkg>` (`-r requirements.txt`) |
| Lock / sync | `uv pip compile requirements.in -o requirements.txt`, then `uv pip sync requirements.txt` |
| Project mode | `uv init`, `uv add <pkg>`, `uv run <cmd>`, `uv sync` |
| Other runtimes (Node, …) | `mise use node@20` (add `--global` for every directory) |

`UV_PYTHON_PREFERENCE=system` (set in `conf.d/08-python.zsh`) makes `uv venv`
use the Python that mise selected, not a Python that uv downloaded. uv venvs
include no `pip`: use `uv pip`, or `uv venv --seed`.

## Add a tool or package

`packages.toml` defines what gets installed on every platform. Don't edit the
`BEGIN/END GENERATED` blocks in the Brewfile, `nix/home.nix`, `windows.ps1`,
`linux.sh` or the Makefile by hand.

**Add a CLI tool or app:**

1. Add a `[[package]]` entry to `packages.toml`. Leave out any package manager
   that doesn't have the tool.

   ```toml
   [[package]]
   name     = "jq"
   desc     = "JSON processor"
   category = "Essential CLI Tools"
   brew     = "jq"        # cask = true for macOS apps
   nix      = "jq"
   scoop    = "jq"
   ```

2. Run `dutils manifest generate` to rewrite the generated lists.
3. Run `dutils manifest check`. CI runs the same check.
4. Commit `packages.toml` together with the regenerated files, then install the tool (e.g.
   `brew bundle --file brew/Brewfile`).

Optional fields: `verify` (command to check for, `""` for none), `critical`,
`check = "quick"|"full"|"none"`, `brew_os`. Run `dutils manifest list` to see
what gets installed on each platform. `dutils packages` compares that list with
what is installed.

**Add a config (Stow) package:**

```bash
dutils new mytool         # creates mytool/.config/mytool/ + a [[stow]] entry, regenerates
# put config files in mytool/.config/mytool/, then:
make stow pkg=mytool
```

For a package that links straight into `$HOME`, run `dutils new mytool --home`.
Then add a `[[stow]]` entry by hand (`package`, `target`, optional `source`,
`platforms`, `windows_target`) and run `dutils manifest generate`.

## Git

| Change | Where |
| --- | --- |
| Aliases | `[alias]` section of `git/.config/git/config` |
| Diff viewer (delta) | `[delta]` section in the same file |
| Pull, push and merge behaviour | `[pull]`, `[push]`, `[merge]`, `[rebase]` sections in the same file |
| Name, email, SSH keys, signing | `dutils git-setup` |

The tracked config has no identity. `dutils git-setup` writes your profiles
(personal, plus work profiles matched by folder, GitHub org or host) to
`~/.config/dotfiles/git/config`, outside the repo. Until you run it, git refuses
to commit. See [Setup → Git identities](SETUP.md#git-identities--ssh-keys).

## macOS defaults

These are optional system settings for Finder, keyboard repeat, the trackpad and
screenshots. They are not applied by `make install`.

```bash
make macos-defaults dry=1   # preview
make macos-defaults         # apply (saves the old values first)
make macos-defaults undo=1  # restore the saved values
```

To add or change a setting, edit the `DEFAULTS` table in
`scripts/setup/macos-defaults.sh`. Each line is `domain|key|type|value`. The
original values are saved once, to
`~/.local/state/dotfiles/macos-defaults.snapshot`. Key-repeat changes need a
re-login.
