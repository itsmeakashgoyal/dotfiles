#
#  ▓▓▓▓▓▓▓▓▓▓
# ░▓ author ▓ Akash Goyal
# ░▓ file   ▓ powershell/Documents/PowerShell/Microsoft.PowerShell_profile.ps1
# ░▓▓▓▓▓▓▓▓▓▓
#
# PowerShell profile — Linux/macOS feel on Windows
# Tools: ripgrep · fzf (PSFzf) · bat · eza · zoxide · mise · starship · PSReadLine
#
# Install prerequisites once:
#   scoop install ripgrep fzf bat eza zoxide fd mise starship
#   Install-Module PSFzf, PSReadLine, Terminal-Icons -Scope CurrentUser

# ==============================================================================
# Helpers
# ==============================================================================
function _cmd { param($Name) [bool](Get-Command $Name -ErrorAction SilentlyContinue) }

# ==============================================================================
# PSReadLine — better editing + Vi mode
# ==============================================================================
if (Get-Module -ListAvailable PSReadLine) {
    Import-Module PSReadLine

    Set-PSReadLineOption -EditMode Vi
    Set-PSReadLineOption -BellStyle None
    Set-PSReadLineOption -HistorySearchCursorMovesToEnd
    Set-PSReadLineOption -PredictionSource HistoryAndPlugin
    Set-PSReadLineOption -PredictionViewStyle ListView
    Set-PSReadLineOption -Colors @{
        Command            = 'Cyan'
        Parameter          = 'DarkCyan'
        String             = 'Green'
        Operator           = 'DarkYellow'
        Variable           = 'Yellow'
        Comment            = 'DarkGray'
        InlinePrediction   = 'DarkGray'
        ListPrediction     = 'DarkCyan'
    }

    # Keep useful Emacs bindings in Insert mode (mirrors 13-vi-mode.zsh)
    Set-PSReadLineKeyHandler -ViMode Insert -Chord 'Ctrl+a' -Function BeginningOfLine
    Set-PSReadLineKeyHandler -ViMode Insert -Chord 'Ctrl+e' -Function EndOfLine
    Set-PSReadLineKeyHandler -ViMode Insert -Chord 'Ctrl+k' -Function KillLine
    Set-PSReadLineKeyHandler -ViMode Insert -Chord 'Ctrl+u' -Function BackwardKillLine
    Set-PSReadLineKeyHandler -ViMode Insert -Chord 'Ctrl+w' -Function BackwardKillWord
    Set-PSReadLineKeyHandler -ViMode Insert -Chord 'Ctrl+l' -Function ClearScreen

    # jk / kj to exit insert mode
    Set-PSReadLineKeyHandler -ViMode Insert -Chord 'j,k'    -Function ViCommandMode
    Set-PSReadLineKeyHandler -ViMode Insert -Chord 'k,j'    -Function ViCommandMode

    # History search with j/k in normal mode
    Set-PSReadLineKeyHandler -ViMode Command -Chord 'k' -Function HistorySearchBackward
    Set-PSReadLineKeyHandler -ViMode Command -Chord 'j' -Function HistorySearchForward
}

# ==============================================================================
# Terminal-Icons (Nerd Font file icons in listings)
# ==============================================================================
if (Get-Module -ListAvailable Terminal-Icons) {
    Import-Module Terminal-Icons
}

# ==============================================================================
# fzf — PSFzf module
# Ctrl+T  file picker  |  Ctrl+R  history  |  Alt+C  cd into dir
# ==============================================================================
if ((_cmd fzf) -and (Get-Module -ListAvailable PSFzf)) {
    Import-Module PSFzf

    $env:FZF_DEFAULT_OPTS = @'
--height=50% --layout=reverse --border=rounded --cycle
--bind=ctrl-j:down,ctrl-k:up
--color=fg:#c0caf5,bg:#1a1b26,hl:#bb9af7
--color=fg+:#c0caf5,bg+:#292e42,hl+:#7dcfff
--color=info:#7aa2f7,prompt:#7dcfff,pointer:#7dcfff
--color=marker:#9ece6a,spinner:#9ece6a,header:#9ece6a
'@

    # Use ripgrep as FZF source when inside a git repo, fd otherwise
    if (_cmd rg) {
        $env:FZF_DEFAULT_COMMAND = 'rg --files --hidden --glob "!.git"'
    } elseif (_cmd fd) {
        $env:FZF_DEFAULT_COMMAND = 'fd --type f --hidden --exclude .git'
    }

    Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+t'
    Set-PsFzfOption -PSReadlineChordReverseHistory 'Ctrl+r'
    Set-PsFzfOption -PSReadlineChordSetLocation 'Alt+c'
    Set-PsFzfOption -PSReadlineChordWildcard 'Ctrl+f'
}

# Fallback: manual Ctrl+R history when PSFzf is absent but fzf binary exists
elseif (_cmd fzf) {
    Set-PSReadLineKeyHandler -Chord 'Ctrl+r' -ScriptBlock {
        $result = Get-History | ForEach-Object { $_.CommandLine } |
            Sort-Object -Unique | fzf --tac --no-sort --height=40% --layout=reverse --border
        if ($result) {
            [Microsoft.PowerShell.PSConsoleReadLine]::RevertLine()
            [Microsoft.PowerShell.PSConsoleReadLine]::Insert($result)
        }
    }
}

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

# ==============================================================================
# Unix-like aliases and functions
# ==============================================================================

# Navigation
Set-Alias -Name which  -Value Get-Command
function ..    { Set-Location .. }
function ...   { Set-Location ..\.. }
function ....  { Set-Location ..\..\.. }
function ~     { Set-Location $HOME }

function mkcd {
    param([string]$Path)
    New-Item -ItemType Directory -Path $Path -Force | Out-Null
    Set-Location $Path
}

# Remove
function rm {
    param(
        [switch]$rf,
        [switch]$r,
        [switch]$f,
        [Parameter(ValueFromRemainingArguments)][string[]]$Paths
    )
    $recurse = $rf -or $r
    $force   = $rf -or $f
    foreach ($p in $Paths) {
        if (-not (Test-Path $p)) {
            if (-not $force) { Write-Error "rm: $p: No such file or directory" }
            continue
        }
        Remove-Item -Path $p -Recurse:$recurse -Force:$force -ErrorAction $(if ($force) { 'SilentlyContinue' } else { 'Stop' })
    }
}

function rmdir {
    param(
        [switch]$parents,
        [Parameter(ValueFromRemainingArguments)][string[]]$Paths
    )
    foreach ($dir in $Paths) {
        if (-not (Test-Path $dir -PathType Container)) {
            Write-Error "rmdir: $dir: No such directory"; continue
        }
        if ($parents) {
            # Remove directory and walk up removing newly-empty parents (like rmdir -p)
            $target = (Resolve-Path $dir).Path
            Remove-Item $target -Force -ErrorAction Stop
            $parent = Split-Path $target -Parent
            while ($parent -and (Test-Path $parent) -and -not (Get-ChildItem $parent)) {
                Remove-Item $parent -Force -ErrorAction SilentlyContinue
                $parent = Split-Path $parent -Parent
            }
        } else {
            Remove-Item $dir -Force -ErrorAction Stop
        }
    }
}

# Files
function touch {
    param([string[]]$Paths)
    foreach ($p in $Paths) {
        if (Test-Path $p) { (Get-Item $p).LastWriteTime = Get-Date }
        else              { New-Item -ItemType File -Path $p -Force | Out-Null }
    }
}

function find {
    param([Parameter(ValueFromRemainingArguments)][string[]]$Args)
    if (_cmd fd) { fd @Args }
    else         { Get-ChildItem -Recurse @Args }
}

function head {
    param([string]$Path, [int]$Lines = 10)
    Get-Content $Path | Select-Object -First $Lines
}

function tail {
    param([string]$Path, [int]$Lines = 10, [switch]$f)
    if ($f) { Get-Content $Path -Wait | Select-Object -Last $Lines }
    else    { Get-Content $Path | Select-Object -Last $Lines }
}

# System
function env   { Get-ChildItem Env: | Sort-Object Name }
function path  { $env:PATH -split [IO.Path]::PathSeparator }

function df {
    Get-PSDrive -PSProvider FileSystem |
        Select-Object Name,
            @{N='Used(GB)'; E={[math]::Round($_.Used/1GB,2)}},
            @{N='Free(GB)'; E={[math]::Round($_.Free/1GB,2)}},
            @{N='Total(GB)';E={[math]::Round(($_.Used+$_.Free)/1GB,2)}} |
        Format-Table -AutoSize
}

function du {
    param([string]$Path = '.')
    Get-ChildItem $Path -Recurse -ErrorAction SilentlyContinue |
        Measure-Object -Property Length -Sum |
        ForEach-Object { "{0:N2} MB — $Path" -f ($_.Sum / 1MB) }
}

function psg {
    param([string]$Name)
    Get-Process | Where-Object { $_.Name -like "*$Name*" } | Format-Table -AutoSize
}

function pkill {
    param([string]$Name)
    Get-Process $Name -ErrorAction SilentlyContinue | Stop-Process -Force
}

function reload { . $PROFILE; Write-Host 'Profile reloaded.' -ForegroundColor Green }

# Sudo (gsudo if available, else elevation prompt)
if (_cmd gsudo) { Set-Alias sudo gsudo }
else {
    function sudo {
        param([Parameter(ValueFromRemainingArguments)][string[]]$Args)
        Start-Process pwsh -Verb RunAs -ArgumentList ("-NoExit", "-Command", ($Args -join ' '))
    }
}

# ==============================================================================
# Git shortcuts
# ==============================================================================
function g     { git @args }
function gs    { git status -sb }
function ga    { git add @args }
function gaa   { git add -A }
function gc    { git commit -m @args }
function gca   { git commit --amend --no-edit }
function gp    { git push @args }
function gpl   { git pull --rebase }
function gf    { git fetch --all --prune }
function gco   { git checkout @args }
function gb    { git branch @args }
function gbd   { git branch -d @args }
function gd    { git diff @args }
function gds   { git diff --staged }
function glog  { git log --oneline --graph --decorate --all }
function gst   { git stash @args }
function gstp  { git stash pop }
function grb   { git rebase @args }
function gri   { git rebase -i @args }
function gcp   { git cherry-pick @args }
function grh   { git reset --hard @args }
function grs   { git restore @args }

# Interactive git log with fzf preview
function glf {
    if (-not (_cmd fzf)) { glog; return }
    git log --oneline --color=always |
        fzf --ansi --no-sort --reverse --tiebreak=index `
            --preview 'git show --color=always {1}' `
            --preview-window 'right:60%' `
            --bind 'enter:execute(git show --color=always {1} | bat --paging=always)'
}

# ==============================================================================
# Startup
# ==============================================================================
Write-Host "  PS $($PSVersionTable.PSVersion)  •  " -NoNewline -ForegroundColor DarkGray
Write-Host (Split-Path -Leaf $PROFILE) -NoNewline -ForegroundColor DarkCyan
Write-Host "  loaded" -ForegroundColor DarkGray
