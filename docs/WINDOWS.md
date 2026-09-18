# Windows

[← Back to README](../README.md)

Windows uses a separate, non-Stow install path (`install.ps1` → `scripts/setup/windows.ps1`)
— see [Installation](INSTALLATION.md#windows) for the one-liner and
[Architecture](ARCHITECTURE.md#windows) for how it's structured. This page covers the
Windows-specific configuration knobs and the issues actually hit while hardening that
path on a real corporate-managed machine (OneDrive redirection, EDR/AV overhead, a
pre-existing Windows Terminal color scheme) — and how to fix each if you hit them too.

---

## Configuration toggles

All three are environment variables, unset (off) by default. Set persistently with:

```powershell
[Environment]::SetEnvironmentVariable('<NAME>', '<value>', 'User')
```

Then open a new terminal — env vars set this way don't reach already-running processes
(including other tabs in an already-open Windows Terminal window; see
[Windows Terminal theme or env var changes don't apply](#windows-terminal-theme-or-env-var-changes-dont-apply) below).

| Variable | Values | What it does |
| --- | --- | --- |
| `DOTFILES_PROMPT` | `native` | Use a zero-subprocess native PowerShell prompt instead of starship. See [Native prompt](#native-prompt-dotfiles_promptnative). |
| `DOTFILES_MISE_ACTIVATE` | `1` | Turn on mise's automatic per-directory Python/Node/etc. version switching (off by default — costs ~200ms at shell startup). See [docs/PYTHON.md](PYTHON.md). |
| `DOTFILES_PROFILE_DEBUG` | `1` | Print how long each `profile.d/*.ps1` file (and some of their sub-sections) took to load, to `Measure-Command`-out startup slowness instead of guessing. |

### Native prompt (`DOTFILES_PROMPT=native`)

Starship (the default, shared with zsh on macOS/Linux via `starship.toml`) spawns a
fresh `starship.exe` process on every single prompt render. On a machine with
real-time EDR/AV scanning every new process, that's not the "a few ms" cost starship
advertises — measured on this setup: **~130ms with no git repo involved at all**, up
to **~650ms** in a large repo, before any fsmonitor/timeout tuning (see
[Prompt is slow / laggy](#prompt-is-slow--laggy-large-repos) below for the git-specific
half of that).

`powershell/Documents/PowerShell/profile.d/22-native-prompt.ps1` is an alternative
`function prompt {}` that reads git state directly from `.git`'s own files (`HEAD`,
`refs/heads/<branch>`, `packed-refs`) instead of shelling out to `git.exe` — no
subprocess spawn at all. Measured **~4ms average** render time, regardless of repo
size, since it never touches a process the OS/EDR has to scan.

Trade-offs versus starship, by design:

- No staged/modified/conflicted indicator. This is intentional, not a gap to fill in —
  it's exactly the check already disabled in `starship.toml`'s `[git_status]` for being
  too slow to compute without shelling out to `git status`; re-adding it here would mean
  reimplementing git's own status algorithm from scratch.
- No per-language icons (nodejs/rust/lua/...) — those need marker-file scans that add
  cost for a purely cosmetic win.
- Windows-only. starship stays the cross-platform default (shared `starship.toml` with
  zsh on macOS/Linux) — this is an opt-in alternative, not a replacement.

### mise activation (`DOTFILES_MISE_ACTIVATE=1`)

Off by default. `mise` itself is still fully on `PATH` regardless (`mise use`,
`mise install`, `mise exec` all work with zero startup cost) — this only gates the
`mise activate pwsh` hook that auto-switches tool versions when you `cd` into a
project with a pinned version. That hook costs ~200ms at shell startup plus a
subprocess spawn on every prompt render/directory change once active — worth it once
you're actually relying on per-project auto-switching (see [docs/PYTHON.md](PYTHON.md)),
wasted cost if you're not.

### Startup profiling (`DOTFILES_PROFILE_DEBUG=1`)

```powershell
[Environment]::SetEnvironmentVariable('DOTFILES_PROFILE_DEBUG', '1', 'User')
# open a new terminal
```

Prints one magenta `[ NNNms] filename.ps1` line per `profile.d` file as it loads, plus
finer sub-section timings (module imports, `zoxide init`, `mise activate`,
`starship init`) for `00-psreadline.ps1` and `20-tools.ps1` specifically. Turn it back
off the same way (`SetEnvironmentVariable` with an empty/`$null` value) once you're
done — it's meant for diagnosing a specific slowdown, not left on permanently.

---

## Troubleshooting

### Prompt / starship / fzf keybindings don't load at all

**Symptom**: the installer reports symlinks created successfully and a health-check
score, but a new terminal shows the plain default `PS C:\...>` prompt — no starship,
no `Ctrl+R` fzf history.

**Cause**: on a machine where OneDrive's Known Folder Move redirects `Documents`
(common on corporate-managed machines — `%USERPROFILE%\OneDrive - <Tenant>\Documents`
instead of `%USERPROFILE%\Documents`), PowerShell's real `$PROFILE` lives under the
OneDrive path. If the installer symlinked to the plain, unredirected path instead, it
created a file PowerShell never actually loads — two different files, one of them
silently unused. (Fixed as of this repo tracking `[Environment]::GetFolderPath('MyDocuments')`
instead of hardcoding `$env:USERPROFILE\Documents` in `scripts/setup/windows.ps1` — if
you're on an older clone, `git pull` first.)

**Fix**:

```powershell
$PROFILE   # shows the path PowerShell actually uses — compare it by eye against
           # $env:USERPROFILE\Documents\PowerShell\Microsoft.PowerShell_profile.ps1
cd ~\dotfiles
git pull
pwsh -ExecutionPolicy Bypass -File scripts\setup\windows.ps1 -Force
```

Then open a **brand-new** terminal (not just `. $PROFILE`).

### Running `windows.ps1` throws a wall of parser errors

**Symptom**: errors like `Unexpected token '}'`, `Missing '(' after 'if'`, or
`The '<' operator is reserved for future use` scattered through the script, none of
which point at anything actually wrong in that file.

**Cause**: the script was run with `powershell` (Windows PowerShell 5.1) instead of
`pwsh` (PowerShell 7). The script has no BOM and uses Unicode box-drawing/checkmark
characters (`━`, `✓`, `✗`, `→`) throughout; Windows PowerShell 5.1 reads BOM-less
`.ps1` files using the legacy system codepage and mangles those multi-byte sequences,
which cascades into nonsense parse errors partway through the file. PowerShell 7
always reads scripts as UTF-8 regardless of BOM.

**Fix**: use `pwsh`, not `powershell`:

```powershell
pwsh -ExecutionPolicy Bypass -File scripts\setup\windows.ps1 -Force
```

### `✗ Target exists (use -Force to overwrite): ...\.config\git`

Something (often a prior manual git install/config) already created a real directory
at that path — the installer won't silently overwrite real files. Back it up and
re-run with `-Force`:

```powershell
Move-Item "$env:USERPROFILE\.config\git" "$env:USERPROFILE\.config\git.backup"
pwsh -ExecutionPolicy Bypass -File scripts\setup\windows.ps1 -Force
```

### PowerShell startup takes ~2 seconds

Turn on [`DOTFILES_PROFILE_DEBUG`](#startup-profiling-dotfiles_profile_debug1) and open
a new terminal to see exactly which `profile.d` file(s) are slow instead of guessing.
What's already been found and fixed on this setup, roughly in order of impact:

- **`Terminal-Icons` import** (~500ms) — only worth importing when `eza` is *absent*.
  `ls`/`ll`/`la`/`l`/`lt`/`llt` already route through `eza --icons` when it's installed,
  which bypasses PowerShell's own `Get-ChildItem`/`Format-Table` formatting entirely, so
  Terminal-Icons was dead weight loaded for a code path nothing hit. Automatic — nothing
  to configure.
- **`mise activate`** (~200ms) — see [mise activation](#mise-activation-dotfiles_mise_activate1)
  above; off by default now.
- **`starship init` / `zoxide init`** (~130-650ms each, repo-size / spawn-cost
  dependent) — now **cached**: `Import-CachedInit` in `20-tools.ps1` runs the tool
  once, writes the generated init to `%LOCALAPPDATA%\dotfiles\psinit`, and
  dot-sources that on every later start (regenerating only when the tool binary
  changes). The subprocess spawn — the expensive part on Windows — happens only
  on a cache miss. For starship specifically you can also drop the prompt
  subprocess entirely with [the native prompt option](#native-prompt-dotfiles_promptnative).
- **`PSFzf` import** (~430ms) — real functionality (`Ctrl+T`/`Ctrl+R` fzf
  bindings); no free win available there.

### Prompt is slow / laggy (large repos)

**Symptom**: pressing Enter repeatedly feels sluggish, worst in large repos; possibly
paired with `[WARN] - (starship::utils): Executing command "...git.exe" timed out` in
the terminal output.

**Cause**: starship's `git_status` module runs several `git` plumbing calls per
render, each doing a full working-tree scan — slow on a large repo, worse still on
Windows where per-process overhead (real-time EDR/AV scanning every new `git.exe`
launch) adds a fixed ~80-90ms *before* any actual work starts. Confirmed by direct
measurement on this setup: a bare `git status` cost 421ms in one large repo (vs. ~85ms
for `git rev-parse HEAD`, which does no tree walk).

**What this repo already does about it**:

- `git/.config/git/config` sets `core.fsmonitor = true` and `feature.manyFiles = true`.
  Git's built-in filesystem watcher (Git ≥2.37, no external Watchman needed) lets
  `git status`-family commands skip the full tree walk after the first call in a
  session — measured a drop from 421ms → ~155ms once the daemon was actually running
  (`git fsmonitor--daemon status` confirms; expect **one slow render** the first time
  you touch a given repo in a session while the daemon spins up, then it stays fast).
- `starship.toml` raised `command_timeout` from 100 → 300ms so that now-~150ms check
  actually completes and renders instead of being killed and discarded a few ms before
  finishing (100ms was silently wasting the full cost for zero benefit).
- `starship.toml`'s `[git_status]` has `disabled = true` — even fsmonitor-accelerated,
  staged/modified/conflicted status stayed 300-650ms-class on the largest repos tested.
  `git_branch`/`git_commit` stay on; they're single ref reads, not a tree walk, and cost
  only the fixed ~80-90ms process-spawn overhead. Delete that line (it's commented with
  the reasoning right above it) if you want the dirty-indicator back and can tolerate
  the latency for your repos.

**If it's still slow after that**: check whether fsmonitor is actually running for the
specific repo (`git fsmonitor--daemon status` from inside it) — a "not running" result
usually means something is blocking it (corporate EDR restricting low-level directory
watch APIs, or the repo living on a network/mapped drive rather than local NTFS).
Otherwise, consider [the native prompt](#native-prompt-dotfiles_promptnative), which
sidesteps `git.exe` entirely.

### Tofu box / missing icon in the prompt (e.g. a diamond before the branch name)

A Nerd Font glyph that isn't rendering — either the codepoint isn't in the font
actually being used, or the terminal's font setting isn't a Nerd Font variant at all.
`starship.toml`'s `[git_branch]` explicitly sets `symbol = ""` for exactly this reason
(its built-in default is a Powerline glyph that's font-dependent). If you see this
elsewhere, confirm the terminal font is set to `JetBrainsMono NF` (installed via the
Scoop `nerd-fonts` bucket) — `scripts/setup/windows.ps1`'s `Install-TerminalTheme` sets
this automatically for Windows Terminal; other terminal apps need it set manually.

### Windows Terminal theme or env var changes don't apply

`scripts/setup/windows.ps1`'s `Install-TerminalTheme` merges a Tokyo Night color scheme
(`settings/windows-terminal/tokyo-night.json` — tracked in this repo, not hardcoded in
the script) into your Windows Terminal `settings.json` and sets it as the default
profile color scheme + font, backing up the original first
(`settings.json.backup.<timestamp>`, next to the original — safe to delete once you've
confirmed you don't need it). It only overwrites the `Tokyo Night` scheme entry and the
`profiles.defaults` color scheme/font — your own profiles, keybindings, and any other
scheme stay untouched.

If a change (this theme, or an env var toggle above) doesn't seem to apply: **Windows
Terminal tabs inherit the environment from when the Windows Terminal *process* itself
started**, not per-tab. A new tab in an already-running Windows Terminal window won't
see anything changed since that window opened. Fully close Windows Terminal (all
windows; check it's not still in the system tray) and reopen it.

---

## See also

- [Installation](INSTALLATION.md) — the installer itself, prerequisites
- [Architecture](ARCHITECTURE.md#windows) — how the Windows install path is structured
- [Python](PYTHON.md) — mise + uv, referenced by the mise activation toggle above
- [Troubleshooting](TROUBLESHOOTING.md) — macOS/Linux-focused issues
