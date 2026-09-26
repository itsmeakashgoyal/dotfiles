#
#  ▓▓▓▓▓▓▓▓▓▓
# ░▓ author ▓ Akash Goyal
# ░▓ file   ▓ powershell/Documents/PowerShell/profile.d/11-atuin.ps1
# ░▓▓▓▓▓▓▓▓▓▓
#
# Atuin — magical shell history
# https://github.com/atuinsh/atuin
#
# Loads after 10-television.ps1 so atuin takes Ctrl+R (history search) while
# television keeps Ctrl+T — same split as zsh/.config/zsh/conf.d/10-atuin.zsh.
# Also rebinds UpArrow to atuin search (a step beyond what fzf/PSFzf ever
# did here — atuin's own PowerShell integration wires that up for free).

if (-not (_cmd atuin)) { return }

$__dbg = [bool]$env:DOTFILES_PROFILE_DEBUG

# `atuin init powershell` (no hyphen — different spelling than tv's
# `power-shell`, confirmed via `atuin init --help`) wraps
# $Function:PSConsoleHostReadLine to record every command into atuin's own
# history database automatically, and binds Ctrl+R + UpArrow to
# `atuin search`. Cached the same way tv/zoxide/starship are.
$__sw = if ($__dbg) { [System.Diagnostics.Stopwatch]::StartNew() }
. Import-CachedInit -Name atuin -Bin atuin -Init { atuin init powershell }
if ($__dbg) { Write-Host ("    - {0,6:N0}ms atuin init" -f $__sw.Elapsed.TotalMilliseconds) -ForegroundColor DarkMagenta }

Remove-Variable __dbg, __sw -ErrorAction SilentlyContinue
