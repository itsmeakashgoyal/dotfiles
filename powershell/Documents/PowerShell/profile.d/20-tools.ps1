#
#  ▓▓▓▓▓▓▓▓▓▓
# ░▓ author ▓ Akash Goyal
# ░▓ file   ▓ powershell/Documents/PowerShell/profile.d/20-tools.ps1
# ░▓▓▓▓▓▓▓▓▓▓
#
# CLI tool integrations: ripgrep, eza, bat, zoxide, mise, starship.

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
    Invoke-Expression (& { (zoxide init powershell | Out-String) })
}

# ==============================================================================
# mise (runtime version manager — replaces pyenv, which has no native
# Windows support at all)
# ==============================================================================
if (_cmd mise) {
    (& mise activate pwsh) | Out-String | Invoke-Expression
}

# ==============================================================================
# Starship (default prompt — same starship.toml as zsh, replaces Powerlevel10k
# which could never run on PowerShell in the first place)
# ==============================================================================
if (_cmd starship) {
    $env:STARSHIP_CONFIG = "$HOME\.config\starship\starship.toml"
    (& starship init powershell) | Out-String | Invoke-Expression
}
