#
#  ▓▓▓▓▓▓▓▓▓▓
# ░▓ author ▓ Akash Goyal
# ░▓ file   ▓ powershell/Documents/PowerShell/profile.d/20-tools.ps1
# ░▓▓▓▓▓▓▓▓▓▓
#
# CLI tool integrations: ripgrep, eza, bat, zoxide, mise, starship.

$__dbg = [bool]$env:DOTFILES_PROFILE_DEBUG
$__sw = if ($__dbg) { [System.Diagnostics.Stopwatch]::StartNew() }

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

    # Interactive ripgrep → fzf (live search, opens result in $EDITOR)
    function rgf {
        param([string]$Query = '')
        if (-not (_cmd fzf)) { Write-Warning 'fzf not found'; return }
        $result = rg --line-number --no-heading --color=always --smart-case $Query |
            fzf --ansi --delimiter=':' --preview 'bat --style=numbers --color=always --highlight-line {2} {1}' `
                --preview-window 'right:60%:+{2}+3/3'
        if ($result) {
            $parts = $result -split ':', 3
            & ${env:EDITOR:-nvim} "+$($parts[1])" $parts[0]
        }
    }
}

# ==============================================================================
# eza (ls replacement)
# ==============================================================================
if (_cmd eza) {
    $EZA_BASE = 'eza --icons --group-directories-first --color=always'

    function ls   { Invoke-Expression "$EZA_BASE $args" }
    function ll   { Invoke-Expression "$EZA_BASE -la --git --git-repos $args" }
    function la   { Invoke-Expression "$EZA_BASE -a $args" }
    function l    { Invoke-Expression "$EZA_BASE -l $args" }
    function lt   { Invoke-Expression "$EZA_BASE --tree --level=2 $args" }
    function llt  { Invoke-Expression "$EZA_BASE --tree --level=3 -la --git $args" }
} else {
    # Fallback: colorized Get-ChildItem
    function ll { Get-ChildItem -Force @args }
    function la { Get-ChildItem -Force @args }
}

# ==============================================================================
# bat (cat replacement)
# ==============================================================================
if (_cmd bat) {
    $env:BAT_THEME = 'tokyonight_night'
    $env:BAT_STYLE = 'numbers,changes,header'

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
    Invoke-Expression (& { (zoxide init powershell | Out-String) })
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
# Starship (default prompt — same starship.toml as zsh, replaces Powerlevel10k
# which could never run on PowerShell in the first place)
# ==============================================================================
if (_cmd starship) {
    $env:STARSHIP_CONFIG = "$HOME\.config\starship\starship.toml"
    if ($__dbg) { $__sw.Restart() }
    (& starship init powershell) | Out-String | Invoke-Expression
    if ($__dbg) { Write-Host ("    - {0,6:N0}ms starship init" -f $__sw.Elapsed.TotalMilliseconds) -ForegroundColor DarkMagenta }
}

Remove-Variable __dbg, __sw -ErrorAction SilentlyContinue
