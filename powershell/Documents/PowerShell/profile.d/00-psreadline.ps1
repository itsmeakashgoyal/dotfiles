#
#  ▓▓▓▓▓▓▓▓▓▓
# ░▓ author ▓ Akash Goyal
# ░▓ file   ▓ powershell/Documents/PowerShell/profile.d/00-psreadline.ps1
# ░▓▓▓▓▓▓▓▓▓▓
#
# PSReadLine (editing) and Terminal-Icons. Dot-sourced by the profile.

$__dbg = [bool]$env:DOTFILES_PROFILE_DEBUG
$__sw = if ($__dbg) { [System.Diagnostics.Stopwatch]::StartNew() }

# ==============================================================================
# PSReadLine — better editing
# ==============================================================================
# Emacs, not Vi: Vi's modal editing has a Command mode that intercepts plain
# letters as motions instead of inserting them (`k`/`j` for history, `h`/`l`
# for cursor movement, etc.) — easy to land in accidentally (Esc) and from
# the outside just looks like "the k key stopped working". Emacs mode has no
# modes to land in at all, and already provides Ctrl+A/E/K/U/W/L natively
# (verified directly against this PSReadLine version — no custom
# `Set-PSReadLineKeyHandler` calls needed to get them, unlike Vi Insert mode).
if (Get-Module -ListAvailable PSReadLine) {
    Import-Module PSReadLine
    if ($__dbg) { Write-Host ("    - {0,6:N0}ms Import-Module PSReadLine" -f $__sw.Elapsed.TotalMilliseconds) -ForegroundColor DarkMagenta }

    Set-PSReadLineOption -EditMode Emacs
    Set-PSReadLineOption -BellStyle None
    Set-PSReadLineOption -HistorySearchCursorMovesToEnd
    Set-PSReadLineOption -PredictionSource HistoryAndPlugin
    Set-PSReadLineOption -PredictionViewStyle ListView
    # Gruvbox Dark palette — same one 10-fzf.ps1's $FZF_DEFAULT_OPTS,
    # 20-tools.ps1's $BAT_THEME, and 22-native-prompt.ps1 use, so prompt/fzf/
    # bat/editing colors and the Windows Terminal scheme
    # (settings/windows-terminal/gruvbox-dark.json) all match.
    Set-PSReadLineOption -Colors @{
        Command            = '#83A598'
        Parameter          = '#8EC07C'
        String             = '#B8BB26'
        Operator           = '#FE8019'
        Variable           = '#D3869B'
        Comment            = '#928374'
        InlinePrediction   = '#928374'
        ListPrediction     = '#8EC07C'
        ListPredictionSelected = '#504945'
        Selection          = '#504945'
        Emphasis           = '#FB4934'
        Error              = '#FB4934'
    }
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
