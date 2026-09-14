#
#  ▓▓▓▓▓▓▓▓▓▓
# ░▓ author ▓ Akash Goyal
# ░▓ file   ▓ powershell/Documents/PowerShell/profile.d/00-psreadline.ps1
# ░▓▓▓▓▓▓▓▓▓▓
#
# PSReadLine (editing + Vi mode) and Terminal-Icons. Dot-sourced by the profile.

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
