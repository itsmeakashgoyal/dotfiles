#
#  ▓▓▓▓▓▓▓▓▓▓
# ░▓ author ▓ Akash Goyal
# ░▓ file   ▓ powershell/Documents/PowerShell/profile.d/22-native-prompt.ps1
# ░▓▓▓▓▓▓▓▓▓▓
#
# Opt-in, zero-subprocess alternative to the starship prompt set up in
# 20-tools.ps1. Every external-binary prompt (starship, oh-my-posh, ...)
# pays a per-render process-spawn cost that's ~80-650ms on this kind of
# managed Windows machine (confirmed by direct measurement — see the git
# fsmonitor/command_timeout work in starship.toml and git/.config/git/config
# for the investigation). This reads git state straight out of the .git
# directory's own files instead of shelling out to git.exe, so a render
# costs low-single-digit ms with no subprocess at all.
#
# Feature parity is deliberately narrower than starship: directory, branch
# name / short commit hash, `took Xs` for slow commands, vi-mode indicator,
# exit-status coloring. No staged/modified/ahead-behind indicator or
# language icons — the former is exactly what we already disabled in
# starship.toml for being too slow to compute without shelling out, so
# reintroducing it here without git.exe would mean re-implementing git's
# own status algorithm from scratch; the latter needs per-language marker
# file scans that add cost for a purely cosmetic win.
#
# Enable with (falls back to starship — set up in 20-tools.ps1 — otherwise):
#   [Environment]::SetEnvironmentVariable('DOTFILES_PROMPT', 'native', 'User')
if ($env:DOTFILES_PROMPT -ne 'native') { return }

# ==============================================================================
# Git state, read from .git's own files — no `git` subprocess
# ==============================================================================
function __dotfiles_native_find_gitdir {
    param([string]$Path)
    $dir = $Path
    while ($dir) {
        $gitEntry = Join-Path $dir '.git'
        if (Test-Path -LiteralPath $gitEntry -PathType Container) {
            return $gitEntry
        }
        if (Test-Path -LiteralPath $gitEntry -PathType Leaf) {
            # Worktree/submodule: a file containing "gitdir: <path>" instead
            # of an actual .git directory.
            $content = Get-Content -LiteralPath $gitEntry -Raw -ErrorAction SilentlyContinue
            if ($content -match 'gitdir:\s*(.+)') {
                $target = $Matches[1].Trim()
                if (-not [System.IO.Path]::IsPathRooted($target)) {
                    $target = Join-Path $dir $target
                }
                $resolved = Resolve-Path -LiteralPath $target -ErrorAction SilentlyContinue
                if ($resolved) { return $resolved.Path }
            }
            return $null
        }
        # -LiteralPath and -Parent can't be combined on this PowerShell
        # version ("Parameter set cannot be resolved") — confirmed directly,
        # not just on a root path but on ordinary ones too. -Path -Parent
        # works; the only cost is wildcard chars ([, ], *, ?) in a directory
        # name would be misinterpreted, an acceptable trade-off for walking
        # up a path that's already a real, existing directory.
        $parent = Split-Path -Path $dir -Parent
        if ([string]::IsNullOrEmpty($parent) -or $parent -eq $dir) { return $null }
        $dir = $parent
    }
    return $null
}

function __dotfiles_native_resolve_ref {
    param([string]$GitDir, [string]$RefName)
    $loose = Join-Path $GitDir $RefName
    if (Test-Path -LiteralPath $loose -PathType Leaf) {
        return (Get-Content -LiteralPath $loose -Raw -ErrorAction SilentlyContinue).Trim()
    }
    # Fall back to packed-refs (loose always wins when both exist, matching
    # git's own resolution order) — a plain refs/heads/<branch> ref hasn't
    # been repacked out from under an active branch, but this repo's own
    # packed-refs shows plenty of refs/remotes/* and refs/tags/* entries
    # that only live there.
    $packed = Join-Path $GitDir 'packed-refs'
    if (Test-Path -LiteralPath $packed -PathType Leaf) {
        $escaped = [regex]::Escape($RefName)
        foreach ($line in Get-Content -LiteralPath $packed) {
            if ($line -match "^([0-9a-f]{4,64}) $escaped$") {
                return $Matches[1]
            }
        }
    }
    return $null
}

function __dotfiles_native_git_info {
    param([string]$Path)
    $gitDir = __dotfiles_native_find_gitdir $Path
    if (-not $gitDir) { return $null }

    $headFile = Join-Path $gitDir 'HEAD'
    if (-not (Test-Path -LiteralPath $headFile -PathType Leaf)) { return $null }
    $head = (Get-Content -LiteralPath $headFile -Raw -ErrorAction SilentlyContinue)
    if ([string]::IsNullOrEmpty($head)) { return $null }
    $head = $head.Trim()

    $branch = $null
    $sha = $null
    if ($head -match '^ref:\s*(.+)$') {
        $refName = $Matches[1].Trim()
        $branch = $refName -replace '^refs/heads/', ''
        $sha = __dotfiles_native_resolve_ref -GitDir $gitDir -RefName $refName
    } elseif ($head -match '^[0-9a-f]{4,40}$') {
        # Detached HEAD: HEAD itself already holds the commit SHA.
        $sha = $head
    }

    [PSCustomObject]@{ Branch = $branch; Sha = $sha }
}

# ==============================================================================
# Tokyo Night ANSI helpers — same palette as starship.toml/fzf/bat/PSReadLine
# ==============================================================================
$script:__dotfiles_esc = [char]27
function __dotfiles_native_fg {
    param([string]$Hex)
    $r = [Convert]::ToInt32($Hex.Substring(0, 2), 16)
    $g = [Convert]::ToInt32($Hex.Substring(2, 2), 16)
    $b = [Convert]::ToInt32($Hex.Substring(4, 2), 16)
    "$($script:__dotfiles_esc)[38;2;$r;$g;${b}m"
}
# No "dim"/faint (SGR 2) helper here on purpose — this terminal renders it
# as very low contrast, stacked on top of an already-muted color or not.
# Legibility comes from picking a properly muted color directly instead.
$script:__dotfiles_reset = "$($script:__dotfiles_esc)[0m"
$script:__dotfiles_bold = "$($script:__dotfiles_esc)[1m"
$script:__dotfiles_italic = "$($script:__dotfiles_esc)[3m"

# ==============================================================================
# The prompt itself
# ==============================================================================
function prompt {
    # Same $?/$LASTEXITCODE save-and-restore dance starship's own generated
    # prompt function uses (verified by inspecting it directly on this
    # machine) — every PowerShell statement below would otherwise clobber
    # the exit status of whatever command the user just ran, before we're
    # done reading it.
    $origDollarQuestion = $global:?
    $origLastExitCode = $global:LASTEXITCODE

    $path = $PWD.Path
    if ($HOME -and $path.StartsWith($HOME, [System.StringComparison]::OrdinalIgnoreCase)) {
        $path = '~' + $path.Substring($HOME.Length)
    }

    $line = "$($script:__dotfiles_bold)$($script:__dotfiles_italic)$(__dotfiles_native_fg '7AA2F7')$path$($script:__dotfiles_reset)"

    $gitInfo = __dotfiles_native_git_info $PWD.Path
    if ($gitInfo) {
        if ($gitInfo.Sha) {
            $short = $gitInfo.Sha.Substring(0, [Math]::Min(7, $gitInfo.Sha.Length))
            $line += " $(__dotfiles_native_fg '565F89')($short)$($script:__dotfiles_reset)"
        }
        if ($gitInfo.Branch) {
            $line += " on $(__dotfiles_native_fg 'BB9AF7')$($gitInfo.Branch)$($script:__dotfiles_reset)"
        } elseif ($gitInfo.Sha) {
            $line += " on $(__dotfiles_native_fg 'BB9AF7')HEAD (detached)$($script:__dotfiles_reset)"
        }
    }

    # `took Xs`, only for slow commands — mirrors starship's cmd_duration
    # default min_time of 2000ms so it doesn't clutter fast commands.
    if ($lastCmd = Get-History -Count 1) {
        $durationMs = ($lastCmd.EndExecutionTime - $lastCmd.StartExecutionTime).TotalMilliseconds
        if ($durationMs -ge 2000) {
            $seconds = [Math]::Round($durationMs / 1000, 1)
            $line += " $($script:__dotfiles_italic)$(__dotfiles_native_fg '9ECE6A')took ${seconds}s$($script:__dotfiles_reset)"
        }
    }

    $exitCodeForPrompt = if (-not $origDollarQuestion) { $origLastExitCode } else { 0 }
    # Guarded: this type comes from the PSReadLine module (00-psreadline.ps1
    # loads before this file in normal profile order, so it's normally
    # available) — but a prompt function throwing would leave the shell
    # with no usable prompt at all, so never let a missing/unloaded
    # PSReadLine take the whole prompt down over a vi-mode cosmetic.
    $isViCommandMode = $false
    try { $isViCommandMode = [Microsoft.PowerShell.PSConsoleReadLine]::InViCommandMode() } catch {}
    $charSymbol = if ($isViCommandMode) { '❮' } else { '❯' }
    # Bare "dim" with no color underneath rides on whatever the terminal's
    # default foreground happens to be — on a dark background that's
    # frequently near-invisible (it was: this exact bug is why the ❯ all but
    # vanished after every prompt block). Always give it an explicit,
    # visible color instead.
    $charColor = if ($exitCodeForPrompt -ne 0) { "$($script:__dotfiles_bold)$(__dotfiles_native_fg 'F7768E')" } elseif ($isViCommandMode) { "$($script:__dotfiles_bold)$(__dotfiles_native_fg 'C0CAF5')" } else { __dotfiles_native_fg '7DCFFF' }

    $promptText = "`n$line`n$charColor$charSymbol$($script:__dotfiles_reset) "
    Set-PSReadLineOption -ExtraPromptLineCount ($promptText.Split("`n").Length - 1)

    $global:LASTEXITCODE = $origLastExitCode
    if ($global:? -ne $origDollarQuestion) {
        if ($origDollarQuestion) {
            1 + 1
        } else {
            Write-Error '' -ErrorAction 'Ignore'
        }
    }

    $promptText
}
