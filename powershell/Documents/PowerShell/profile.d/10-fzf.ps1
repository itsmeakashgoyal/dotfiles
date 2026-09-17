#
#  ▓▓▓▓▓▓▓▓▓▓
# ░▓ author ▓ Akash Goyal
# ░▓ file   ▓ powershell/Documents/PowerShell/profile.d/10-fzf.ps1
# ░▓▓▓▓▓▓▓▓▓▓
#
# fzf integration (PSFzf module, with a manual Ctrl+R fallback).

# ==============================================================================
# fzf — PSFzf module
# Ctrl+T  file picker  |  Ctrl+R  history  |  Alt+C  cd into dir
# ==============================================================================
# Import-Module PSFzf throws a terminating error (not just a non-terminating
# warning) if it can't find the fzf binary on PATH at import time, which would
# otherwise skip straight past the manual-fallback `elseif` below. Try/catch so
# any import failure still degrades to the manual Ctrl+R binding.
$__psfzfImported = $false
if ((_cmd fzf) -and (Get-Module -ListAvailable PSFzf)) {
    try {
        Import-Module PSFzf -ErrorAction Stop
        $__psfzfImported = $true
    } catch {
        Write-Warning "PSFzf import failed, falling back to manual Ctrl+R: $_"
    }
}

if ($__psfzfImported) {
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

# Fallback: manual Ctrl+R history when PSFzf is absent/failed but fzf binary exists
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

Remove-Variable __psfzfImported -ErrorAction SilentlyContinue
