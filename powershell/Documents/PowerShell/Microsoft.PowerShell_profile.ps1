#
#  ▓▓▓▓▓▓▓▓▓▓
# ░▓ author ▓ Akash Goyal
# ░▓ file   ▓ powershell/Documents/PowerShell/Microsoft.PowerShell_profile.ps1
# ░▓▓▓▓▓▓▓▓▓▓
#
# PowerShell profile — Linux/macOS feel on Windows
# Tools: ripgrep · fzf (PSFzf) · bat · eza · zoxide · mise · uv · starship · PSReadLine
#
# This profile is intentionally thin: it resolves its own location (it's a
# symlink into the dotfiles repo, created by scripts/setup/windows.ps1) and
# dot-sources the section files in profile.d/, mirroring how zsh sources
# conf.d/*.zsh. Add or edit a section by dropping a NN-name.ps1 in profile.d/.
#
# Install prerequisites once:
#   scoop install ripgrep fzf bat eza zoxide fd mise starship uv
#   Install-Module PSFzf, PSReadLine, Terminal-Icons -Scope CurrentUser

# Shared helper used across every section file below.
function _cmd { param($Name) [bool](Get-Command $Name -ErrorAction SilentlyContinue) }

# Resolve this profile's real directory. $PROFILE is the symlink in $HOME; its
# .Target points back into the repo (absolute path), so profile.d/ is found in
# the repo without needing its own symlink. Falls back to $PROFILE's own dir if
# it isn't a symlink (e.g. a plain copy).
$__self  = Get-Item -LiteralPath $PROFILE -Force
$__real  = if ($__self.Target) { $__self.Target } else { $PROFILE }
$__confd = Join-Path (Split-Path -Parent $__real) 'profile.d'

# `foreach` statement (not ForEach-Object) so each `. $file` dot-sources into
# THIS profile scope - functions/aliases/vars must persist to the session.
if (Test-Path $__confd) {
    foreach ($__f in Get-ChildItem -Path $__confd -Filter '*.ps1' | Sort-Object Name) {
        . $__f.FullName
    }
}
Remove-Variable __self, __real, __confd, __f -ErrorAction SilentlyContinue

# ==============================================================================
# Startup
# ==============================================================================
Write-Host "  PS $($PSVersionTable.PSVersion)  •  " -NoNewline -ForegroundColor DarkGray
Write-Host (Split-Path -Leaf $PROFILE) -NoNewline -ForegroundColor DarkCyan
Write-Host "  loaded" -ForegroundColor DarkGray
