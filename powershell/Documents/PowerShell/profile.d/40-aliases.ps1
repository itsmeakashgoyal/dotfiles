#
#  ▓▓▓▓▓▓▓▓▓▓
# ░▓ author ▓ Akash Goyal
# ░▓ file   ▓ powershell/Documents/PowerShell/profile.d/40-aliases.ps1
# ░▓▓▓▓▓▓▓▓▓▓
#
# Unix-like aliases and functions (navigation, file ops, system, sudo).

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
            if (-not $force) { Write-Error "rm: ${p}: No such file or directory" }
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
            Write-Error "rmdir: ${dir}: No such directory"; continue
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
