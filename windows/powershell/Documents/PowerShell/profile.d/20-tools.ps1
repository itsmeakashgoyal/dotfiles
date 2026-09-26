#
#  ▓▓▓▓▓▓▓▓▓▓
# ░▓ author ▓ Akash Goyal
# ░▓ file   ▓ windows/powershell/Documents/PowerShell/profile.d/20-tools.ps1
# ░▓▓▓▓▓▓▓▓▓▓
#
# CLI tool integrations: ripgrep, eza, bat, zoxide, mise, starship.

$__dbg = [bool]$env:DOTFILES_PROFILE_DEBUG
$__sw = if ($__dbg) { [System.Diagnostics.Stopwatch]::StartNew() }

# Import-CachedInit lives in the main profile now (Microsoft.PowerShell_profile.ps1)
# — 10-television.ps1/11-atuin.ps1 need it too and load before this file does.

# ==============================================================================
# ripgrep
# ==============================================================================
if (_cmd rg) {
    # Point rg at a config file (create it if missing)
    $rgConfig = "$HOME\.config\ripgrep\config"
    if (-not (Test-Path $rgConfig)) {
        $null = New-Item -ItemType File -Path $rgConfig -Force
        @'
--smart-case
--hidden
--glob=!.git/*
--glob=!node_modules/*
--glob=!*.lock
--colors=line:style:bold
--colors=match:fg:yellow
'@ | Set-Content $rgConfig
    }
    $env:RIPGREP_CONFIG_PATH = $rgConfig

    # grep → rg with context lines
    function grep {
        param([Parameter(ValueFromRemainingArguments)][string[]]$Args)
        rg @Args
    }

    # Interactive ripgrep → television (live search, opens result in $EDITOR).
    # tv reads stdin as its source when invoked with no channel — confirmed
    # directly, same usage pattern as fzf's own piping (06-git.zsh's
    # `... | tv | ...` functions rely on the same thing). No preview pane
    # here: tv's ad-hoc --preview-command field-splitting/shell-execution
    # behavior isn't something I could safely verify without risking a hung
    # interactive session — the field split for jumping to file:line below
    # is plain PowerShell, unrelated to tv's own templating.
    function rgf {
        param([string]$Query = '')
        if (-not (_cmd tv)) { Write-Warning 'television (tv) not found'; return }
        if (-not (_cmd nvim)) { Write-Warning 'nvim not found'; return }
        $result = rg --line-number --no-heading --color=always --smart-case $Query | tv --ansi
        if ($result) {
            $parts = $result -split ':', 3
            # ${env:EDITOR:-nvim} is bash syntax, not PowerShell — it was being
            # parsed as a literal env-var named "EDITOR:-nvim" (always $null,
            # confirmed directly), so this threw on every use. $env:EDITOR is
            # set to nvim by default in the main profile; ?? covers the case
            # a user overrides it to something else.
            & ($env:EDITOR ?? 'nvim') "+$($parts[1])" $parts[0]
        }
    }
}

# Fuzzy-find a file with tv, open it in nvim (mirrors zsh's fv()).
function fv {
    if (-not (_cmd fd)) { Write-Warning 'fd not found'; return }
    if (-not (_cmd tv)) { Write-Warning 'television (tv) not found'; return }
    if (-not (_cmd nvim)) { Write-Warning 'nvim not found'; return }
    $selected = fd --type f --hidden --exclude .git | tv
    if ($selected) { nvim $selected }
}

# ==============================================================================
# eza (ls replacement)
# ==============================================================================
if (_cmd eza) {
    $EZA_BASE = 'eza --icons --group-directories-first --color=always'

    # Confirmed directly (reproducible in any directory, repo or not): unlike
    # GNU ls, this eza build does NOT default to the current directory when
    # given zero positional args — bare `eza` prints nothing at all, silently.
    # Since `ls`/`ll`/etc. are typed bare far more often than with an explicit
    # path, every one of these was broken for its single most common usage
    # until an explicit `.` is passed through.
    function script:_ezaArgs { if ($args) { $args } else { @('.') } }

    # PowerShell resolves a built-in alias before a same-named function
    # (confirmed directly: `ls`/`cat`/`man` all silently ran the built-in
    # Get-ChildItem/Get-Content/help instead of these, every time) — remove
    # the alias first so the function below actually takes over.
    Remove-Item Alias:ls -Force -ErrorAction SilentlyContinue
    function ls   { Invoke-Expression "$EZA_BASE $(_ezaArgs @args)" }
    function ll   { Invoke-Expression "$EZA_BASE -la --git --git-repos $(_ezaArgs @args)" }
    function la   { Invoke-Expression "$EZA_BASE -a $(_ezaArgs @args)" }
    function l    { Invoke-Expression "$EZA_BASE -l $(_ezaArgs @args)" }
    function lt   { Invoke-Expression "$EZA_BASE --tree --level=2 $(_ezaArgs @args)" }
    function llt  { Invoke-Expression "$EZA_BASE --tree --level=3 -la --git $(_ezaArgs @args)" }

    # zsh's tre() pipes GNU `tree` through `less` — Windows has neither by
    # default. eza's own --tree view already covers colorized/git-aware tree
    # output (this is also why the scoop `tree` package was dropped — nothing
    # here needs it over eza), paged through `more` since there's no `less`.
    function tre  {
        param([Parameter(ValueFromRemainingArguments)][string[]]$Args)
        Invoke-Expression "$EZA_BASE --tree --git-ignore $(_ezaArgs @Args)" | more
    }
} else {
    # Fallback: colorized Get-ChildItem
    function ll { Get-ChildItem -Force @args }
    function la { Get-ChildItem -Force @args }
}

# ==============================================================================
# bat (cat replacement)
# ==============================================================================
if (_cmd bat) {
    $env:BAT_THEME = 'gruvbox-dark'
    $env:BAT_STYLE = 'numbers,changes,header'

    # Same alias-shadowing issue as ls above — cat/man are also built-in aliases.
    Remove-Item Alias:cat, Alias:man -Force -ErrorAction SilentlyContinue
    function cat  {
        param([Parameter(ValueFromRemainingArguments)][string[]]$Args)
        bat @Args
    }
    function man  {
        param([string]$Topic)
        Get-Help $Topic -Full | bat --plain --language=man
    }
}

# ==============================================================================
# zoxide (smart cd)
# ==============================================================================
if (_cmd zoxide) {
    if ($__dbg) { $__sw.Restart() }
    # `.` (dot-source) the call itself, not just what it dot-sources
    # internally — Import-CachedInit is a plain function, so calling it
    # normally traps zoxide's `z` function inside Import-CachedInit's own
    # function-call scope, gone the instant it returns (confirmed directly:
    # this is the exact bug already fixed elsewhere in this profile for the
    # mise/starship timing wrapper). Dot-sourcing the call runs it in this
    # file's scope instead.
    . Import-CachedInit -Name zoxide -Bin zoxide -Init { zoxide init powershell }
    if ($__dbg) { Write-Host ("    - {0,6:N0}ms zoxide init" -f $__sw.Elapsed.TotalMilliseconds) -ForegroundColor DarkMagenta }
}

# ==============================================================================
# mise (runtime version manager — replaces pyenv, which has no native
# Windows support at all)
# ==============================================================================
# `mise activate` wraps $function:prompt and re-runs `mise hook-env` on
# every prompt render / directory change — a subprocess spawn on every
# Enter — and the initial activation call itself costs ~200ms at shell
# startup even before that. Same trade-off 08-python.zsh made for mise on
# the zsh side (see that file's comment for the measurements), just gated
# differently here since a PowerShell-side deferred/one-shot hook can't be
# verified as scope-safe the way zsh's precmd hook is. Off by default:
# `mise` itself is still fully on PATH regardless (`mise use`, `mise
# install`, `mise exec` all work with zero startup cost) — this only gates
# the automatic per-directory version switching. Turn it on once you
# actually need that:
#   [Environment]::SetEnvironmentVariable('DOTFILES_MISE_ACTIVATE', '1', 'User')
if ($env:DOTFILES_MISE_ACTIVATE -and (_cmd mise)) {
    if ($__dbg) { $__sw.Restart() }
    $__miseInit = (& mise activate pwsh) | Out-String
    if ($__miseInit.Trim()) {
        $__miseInit | Invoke-Expression
    } else {
        Write-Warning "mise activate produced no output — mise integration skipped"
    }
    Remove-Variable __miseInit -ErrorAction SilentlyContinue
    if ($__dbg) { Write-Host ("    - {0,6:N0}ms mise activate" -f $__sw.Elapsed.TotalMilliseconds) -ForegroundColor DarkMagenta }
}

# ==============================================================================
# Starship (opt-in — 22-native-prompt.ps1 is the default prompt)
# ==============================================================================
# Skipped unless DOTFILES_PROMPT=starship, because 22-native-prompt.ps1 would
# overwrite $function:prompt a moment later anyway — initialising starship here
# would pay for a prompt nothing renders. Skipping also avoids dot-sourcing the
# cached init and, on a cache miss, a starship.exe spawn (emulated x64 on
# Windows ARM) at every shell start.
if (($env:DOTFILES_PROMPT -eq 'starship') -and (_cmd starship)) {
    $env:STARSHIP_CONFIG = "$HOME\.config\starship\starship.toml"
    if ($__dbg) { $__sw.Restart() }
    . Import-CachedInit -Name starship -Bin starship -Init { starship init powershell }
    if ($__dbg) { Write-Host ("    - {0,6:N0}ms starship init" -f $__sw.Elapsed.TotalMilliseconds) -ForegroundColor DarkMagenta }
}

Remove-Variable __dbg, __sw -ErrorAction SilentlyContinue
