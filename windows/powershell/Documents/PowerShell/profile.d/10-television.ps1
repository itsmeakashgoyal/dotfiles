#
#  ▓▓▓▓▓▓▓▓▓▓
# ░▓ author ▓ Akash Goyal
# ░▓ file   ▓ windows/powershell/Documents/PowerShell/profile.d/10-television.ps1
# ░▓▓▓▓▓▓▓▓▓▓
#
# Television (tv) — sole fuzzy finder, replaces fzf/PSFzf entirely, matching
# zsh/.config/zsh/conf.d/09-television.zsh on macOS/Linux. Provides:
#   Ctrl+T  — smart autocomplete (context-aware: files/dirs/branches)
#   Ctrl+R  — shell history search (overridden by atuin — see 11-atuin.ps1,
#             which loads after this file and takes Ctrl+R back, same split
#             as the zsh side)
#   Alt+C   — cd into a fuzzy-selected directory
#   Tab     — after a space: tv smart autocomplete; mid-word or empty line:
#             PowerShell's own completion (mirrors zsh's _tv_or_complete)

if (-not (_cmd tv)) { return }

$__dbg = [bool]$env:DOTFILES_PROFILE_DEBUG

# `tv init power-shell` (hyphenated — confirmed via `tv init --help`) is a
# complete, official PowerShell integration: it registers argument
# completion for tv's own CLI, defines Invoke-TvSmartAutocomplete and
# Invoke-TvShellHistory, and binds them to Ctrl+T/Ctrl+R itself via
# Set-PSReadLineKeyHandler. Cached the same way zoxide/starship are — see
# Import-CachedInit in the main profile.
$__sw = if ($__dbg) { [System.Diagnostics.Stopwatch]::StartNew() }
. Import-CachedInit -Name tv -Bin tv -Init { tv init power-shell }
if ($__dbg) { Write-Host ("    - {0,6:N0}ms tv init" -f $__sw.Elapsed.TotalMilliseconds) -ForegroundColor DarkMagenta }

# Alt+C: cd into a fuzzy-selected directory (the `dirs` channel — reads
# television/.config/television/cable/dirs.toml, source `fd -t d`, preview
# `eza`). Mirrors the cursor-save/restore dance tv's own Ctrl+T/Ctrl+R
# handlers use above (Invoke-TvSmartAutocomplete/Invoke-TvShellHistory) —
# same reasoning: this runs mid-line-edit from a PSReadLine handler, not as
# an ordinary top-level command, so the console needs the same care to avoid
# corrupting the prompt's redraw. Uses Set-Location directly rather than the
# channel's own `actions.cd` (which shells out via `$SHELL`, a POSIX-only
# concept) — no dependency on tv's config.toml `shell` setting at all.
if (_cmd fd) {
    Set-PSReadLineKeyHandler -Chord 'Alt+c' -ScriptBlock {
        $originalPromptY = [Console]::CursorTop
        $savedCursorX = [Console]::CursorLeft
        [Console]::WriteLine()

        $psi = New-Object System.Diagnostics.ProcessStartInfo
        $psi.FileName = 'tv'
        $psi.Arguments = 'dirs --no-status-bar --inline'
        $psi.UseShellExecute = $false
        $psi.RedirectStandardOutput = $true
        $psi.WorkingDirectory = $PWD.Path

        $process = New-Object System.Diagnostics.Process
        $process.StartInfo = $psi
        $process.Start() | Out-Null
        $selected = $process.StandardOutput.ReadToEnd().Trim()
        $process.WaitForExit()

        [Console]::CursorTop = $originalPromptY
        [Console]::CursorLeft = $savedCursorX

        if ($selected -and (Test-Path -LiteralPath $selected -PathType Container)) {
            Set-Location -LiteralPath $selected
        }
        [Microsoft.PowerShell.PSConsoleReadLine]::InvokePrompt()
    }
}

# Tab: mirrors zsh's _tv_or_complete exactly — after a space, tv's own smart
# autocomplete (context-aware: files/dirs/branches based on what's already
# typed); mid-word or on an empty line, PowerShell's native completion
# (cycling through matches), unchanged from default behavior.
Set-PSReadLineKeyHandler -Chord 'Tab' -ScriptBlock {
    $line = $null
    $cursor = $null
    [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)
    $lhs = $line.Substring(0, $cursor)
    if ($lhs.Length -gt 0 -and $lhs[-1] -eq ' ') {
        Invoke-TvSmartAutocomplete
    } else {
        [Microsoft.PowerShell.PSConsoleReadLine]::TabCompleteNext()
    }
}

Remove-Variable __dbg, __sw -ErrorAction SilentlyContinue
