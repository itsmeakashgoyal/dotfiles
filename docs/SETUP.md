# Setup

How to install, personalize, update and remove these dotfiles on macOS, Linux and Windows.

- [Requirements](#requirements)
- [Install](#install)
- [First run](#first-run)
- [Git identities & SSH keys](#git-identities--ssh-keys)
- [Machine-local settings](#machine-local-settings)
- [Keeping up to date](#keeping-up-to-date)
- [Health checks](#health-checks)
- [Uninstall](#uninstall)
- [Troubleshooting](#troubleshooting)

---

## Requirements

| | macOS | Linux | Windows |
| --- | --- | --- | --- |
| OS | Apple Silicon or Intel | Ubuntu / Debian (apt) | Windows 10/11 (WSL2 recommended for the dev shell) |
| You need | `curl`, sudo | `curl`, sudo | `git`, PowerShell 7 (`pwsh`), Admin **or** Developer Mode |
| Packages come from | Homebrew (installed for you) | Nix + Home Manager, plus a few apt packages | Scoop |

- **Python >= 3.14** is the standard. The installer installs it if missing, and scripts re-launch
  themselves on a suitable interpreter (e.g. when plain `python3` is macOS's older one).
- The default zsh prompt is **Powerlevel10k**. For starship instead, set `DOTFILES_PROMPT=starship`
  in the environment before zsh starts (or edit the knob at the top of `zsh/.config/zsh/.zshrc`).

## Install

### macOS / Linux — one-liner

Needs no git and no SSH key: it clones over HTTPS (or downloads a tarball) into `~/dotfiles`,
then runs `install.sh`.

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/itsmeakashgoyal/dotfiles/master/bootstrap.sh)
bash <(curl -fsSL https://raw.githubusercontent.com/itsmeakashgoyal/dotfiles/master/bootstrap.sh) --yes   # no prompts
```

If `~/dotfiles` already exists, bootstrap offers to move it to `~/dotfiles.backup.<timestamp>`.

### macOS / Linux — manual clone

```bash
git clone https://github.com/itsmeakashgoyal/dotfiles.git ~/dotfiles
cd ~/dotfiles
make install dry=1     # preview every change, touch nothing (= ./install.sh --dry-run)
make install           # or: ./install.sh [--yes]
exec zsh
```

What `install.sh` does, in order:

| Step | macOS | Linux |
| --- | --- | --- |
| Packages | Homebrew + `brew/Brewfile` | apt deps (`scripts/setup/linux.sh`), then Nix + Home Manager (`scripts/setup/nix.sh`) |
| Python | `python@3.14` if missing | `uv python install 3.14` if missing |
| Shell | zsh set as login shell | same |
| Apps | Sublime Text + iTerm2 settings | Sublime Text settings |
| Symlinks | `make run` (Stow all packages) | same |
| tmux plugins | TPM + every `@plugin` (`make tmux`) | same |
| Rex (if installed) | Config, terminfo, Gruvbox theme + font (`make rex`) | — |
| Verify | quick health check | same |

The install log is written to `/tmp/dotfiles.log`.

Optional extras (macOS):

```bash
make macos-defaults dry=1   # preview curated system defaults
make macos-defaults         # apply   (undo=1 to revert)
make iterm                  # iTerm2 profile + prefs     (make sublime / make apps)
```

Linux-only Nix targets: `make nix-setup` (first-time Nix + Home Manager), `make nix-switch`
(apply `nix/home.nix`), `make nix-update` (update versions + switch).

### Windows

Recommended: install Ubuntu under **WSL2** and follow the Linux steps inside it. For native
PowerShell (Scoop packages + symlinks, no Stow):

```powershell
winget install Git.Git
winget install Microsoft.PowerShell
# Enable Developer Mode (Settings → System → For developers) or run as Administrator
# Then, in a new pwsh window:
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
irm https://raw.githubusercontent.com/itsmeakashgoyal/dotfiles/master/windows/install.ps1 | iex
```

From an existing clone (`~\dotfiles`):

```powershell
.\windows\install.ps1                  # -Force  -SkipPackages  -SkipSymlinks
pwsh -ExecutionPolicy Bypass -File windows\windows.ps1 -Force   # re-run setup only
```

- `-Force` backs up a real file/folder in the way (`<target>.backup.<timestamp>`) and links over it.
- The PowerShell profile is linked into your **real** Documents folder, including a OneDrive-redirected
  one (`OneDrive - <Tenant>\Documents`). Check with `$PROFILE`.
- `dutils` is put on `PATH` via `%USERPROFILE%\.local\bin`: open a new terminal after install.

## First run

One wizard for the per-machine bits; every step is optional and safe to re-run:

```bash
dutils init        # -y accepts the default at each step
```

1. Git identities + SSH keys (`dutils git-setup`)
2. Terminal theme: dark / light / auto (`dutils theme`)
3. Create an owner-only `99-private.zsh` for machine-local exports
4. Quick health check

Then `exec zsh`.

## Git identities & SSH keys

How it works:

- No name/email is tracked: git refuses to commit (`user.useConfigOnly`) until `dutils git-setup` has run.
- You create a **personal** profile plus any number of **work** profiles, each with its own email and SSH key.
- A repo picks its profile by **folder** (e.g. `~/work/`), **GitHub org** or **enterprise host**; otherwise the machine default applies.
- Clone with the normal URL from GitHub — the right key and identity are chosen automatically.
- Everything generated lives outside the repo in `~/.config/dotfiles/git/` and `~/.ssh/config.d/dotfiles`.

| Command | What it does |
| --- | --- |
| `dutils git-setup` | Wizard (first run), or add/edit/remove profiles |
| `dutils git-setup status [PATH]` | Profiles + which identity PATH (default: cwd) gets |
| `dutils git-setup add acme` | Add/update a profile (`--email --org --host --dir --key --sign --default`) |
| `dutils git-setup remove acme` | Remove a profile |
| `dutils git-setup default personal` | Change this machine's default profile |
| `dutils git-setup test` | `ssh -T` against every profile |
| `dutils git-setup apply` | Regenerate git + SSH config from `profiles.json` |
| `dutils git-setup migrate` | Import the old `config-local` / `github-private` setup |
| `git whoami` | `name <email>` for the current repo |

- Add each public key at <https://github.com/settings/keys> (the wizard copies it to the
  clipboard). With `--sign`, add it as a *Signing* key too.
- Windows: start the agent once — `Set-Service ssh-agent -StartupType Automatic; Start-Service ssh-agent`.

**Fresh machine:** bootstrap clones over HTTPS, so no key is needed up front. After `git-setup`
creates your keys, `dutils init` offers to switch the dotfiles remote from HTTPS to SSH.

## Machine-local settings

Work exports, tokens and per-machine tweaks go in a gitignored, owner-only (`chmod 600`) file
that is sourced last:

| Platform | File |
| --- | --- |
| zsh | `~/.config/zsh/conf.d/99-private.zsh` (created by `dutils init`) |
| PowerShell | `windows\powershell\Documents\PowerShell\profile.d\99-private.ps1` (in the repo) |

```zsh
export SOME_TOKEN=...
```

`DOTFILES_PROMPT` can't be set here (it's read before this file loads).

## Keeping up to date

| Command | What it does |
| --- | --- |
| `dutils sync` | `git pull --ff-only`, re-link (Stow / `windows.ps1`), then `dutils update` (`--no-update` to skip it) |
| `dutils update [brew nix mise zinit nvim]` | Upgrade Homebrew, Nix, mise runtimes, zsh plugins, Neovim plugins |
| `make update` | Re-stow all packages (picks up new/renamed files) |
| `make nix-update` | Linux: update Nix flake inputs + Home Manager switch |
| `scoop update --all` | Windows: upgrade Scoop packages |

Add a tool: edit `packages.toml`, run `dutils manifest generate`, then apply it with
`brew bundle --file brew/Brewfile` (macOS), `make nix-switch` (Linux) or re-run `windows.ps1`.
Add a new config package with `dutils new <name>`; link a single one with `make stow pkg=<name>`.

## Health checks

```bash
dutils health          # quick: symlinks, tools, configs        (make health)
dutils check           # full verification with a score         (make check)
dutils diagnose        # health + system info + packages        (make diagnose)
dutils packages        # installed tools vs packages.toml       (make packages)
dutils bench --real    # zsh first-prompt and per-Enter lag     (make bench-real)
dutils profile         # per-file startup timing                (make bench-detail)
```

## Uninstall

macOS / Linux:

```bash
make uninstall dry=1   # preview
make uninstall         # force=1 skips the confirmation
make delete            # only remove the symlinks
```

`make uninstall` restores the default shell, removes symlinks, caches and plugin data, then
removes **all** Homebrew and Nix packages and the managers themselves.

Windows:

```powershell
.\windows\windows.ps1 -Uninstall -DryRun   # preview
.\windows\windows.ps1 -Uninstall           # -Force: no prompt; -PurgeScoop: also remove Scoop; -SymlinksOnly
```

Neither touches the repo, `~/.ssh`, git config content or shell history.

## Troubleshooting

| Symptom | Fix |
| --- | --- |
| git refuses to commit ("no email was given") | `dutils git-setup` |
| `p10k configure` offers to edit `.zshrc` | Answer **No** — the config is already wired in |
| A command an installer added to `~/.zshrc` isn't found | `~/.zshrc` is not read (`ZDOTDIR=~/.config/zsh`); add the PATH line to `zsh/.config/zsh/conf.d/01-exports.zsh` |
| Stow reports a conflict | A real file is in the way: `mv ~/.config/nvim ~/.config/nvim.backup && make run` |
| Git ignores the dotfiles config | Remove `~/.gitconfig` (it overrides `~/.config/git/config`) |
| Linux: a Nix tool isn't found | `exec zsh`; still missing → `home-manager generations` / `make nix-switch` |
| tmux plugins missing (no resurrect/continuum, `⌃h/j/k/l` not crossing into nvim) | `make tmux` (installs TPM + plugins; `update=1` also updates them) |
| Broken zsh completions | `rm -f ~/.config/zsh/.zcompdump* && exec zsh` |
| Windows: wall of parser errors running `windows.ps1` | Use `pwsh` (PowerShell 7), not `powershell` |
| Windows: plain `PS C:\>` prompt, profile not loading | Compare `$PROFILE` with the linked path; `git pull`, re-run `windows.ps1 -Force`, open a new terminal |
| Windows: theme or env var change doesn't apply | Fully close Windows Terminal (all windows) and reopen it |
