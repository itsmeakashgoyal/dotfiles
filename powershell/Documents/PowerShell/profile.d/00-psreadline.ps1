#
#  ▓▓▓▓▓▓▓▓▓▓
# ░▓ author ▓ Akash Goyal
# ░▓ file   ▓ powershell/Documents/PowerShell/profile.d/00-psreadline.ps1
# ░▓▓▓▓▓▓▓▓▓▓
#
# PSReadLine (editing + Vi mode) and Terminal-Icons. Dot-sourced by the profile.

$__dbg = [bool]$env:DOTFILES_PROFILE_DEBUG
$__sw = if ($__dbg) { [System.Diagnostics.Stopwatch]::StartNew() }

# ==============================================================================
# PSReadLine — better editing + Vi mode
# ==============================================================================
if (Get-Module -ListAvailable PSReadLine) {
    Import-Module PSReadLine
    if ($__dbg) { Write-Host ("    - {0,6:N0}ms Import-Module PSReadLine" -f $__sw.Elapsed.TotalMilliseconds) -ForegroundColor DarkMagenta }

    Set-PSReadLineOption -EditMode Vi
    Set-PSReadLineOption -BellStyle None
    Set-PSReadLineOption -HistorySearchCursorMovesToEnd
    Set-PSReadLineOption -PredictionSource HistoryAndPlugin
    Set-PSReadLineOption -PredictionViewStyle ListView
    # Tokyo Night palette — same one 10-fzf.ps1's $FZF_DEFAULT_OPTS and
    # 20-tools.ps1's $BAT_THEME use, so prompt/fzf/bat/editing colors all match.
    Set-PSReadLineOption -Colors @{
        Command            = '#7AA2F7'
        Parameter          = '#7DCFFF'
        String             = '#9ECE6A'
        Operator           = '#E0AF68'
        Variable           = '#BB9AF7'
        Comment            = '#565F89'
        InlinePrediction   = '#565F89'
        ListPrediction     = '#7DCFFF'
        ListPredictionSelected = '#283457'
        Selection          = '#283457'
        Emphasis           = '#F7768E'
        Error              = '#F7768E'
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
# Only worth importing when eza is absent: 20-tools.ps1 redefines ls/ll/la/l/
# lt/llt to shell out to `eza --icons` when it's installed, which bypasses
# PowerShell's own Format-Table/Get-ChildItem formatting entirely — Terminal-
# Icons would just be dead weight loaded for a code path nothing hits.
if (-not (_cmd eza) -and (Get-Module -ListAvailable Terminal-Icons)) {
    if ($__dbg) { $__sw.Restart() }
    Import-Module Terminal-Icons
    if ($__dbg) { Write-Host ("    - {0,6:N0}ms Import-Module Terminal-Icons" -f $__sw.Elapsed.TotalMilliseconds) -ForegroundColor DarkMagenta }
}

Remove-Variable __dbg, __sw -ErrorAction SilentlyContinue
