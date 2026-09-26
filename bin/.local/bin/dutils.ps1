#
#  ▓▓▓▓▓▓▓▓▓▓
# ░▓ author ▓ Akash Goyal
# ░▓ file   ▓ bin/.local/bin/dutils.ps1
# ░▓▓▓▓▓▓▓▓▓▓
#
# Thin wrapper putting the dutils CLI on PATH as a bare `dutils` command on
# native Windows PowerShell — mirrors bin/.local/bin/dutils (a plain symlink
# to scripts/dutils/dutils, applied by Stow on macOS/Linux). Stow doesn't run
# on Windows, so this needs its own real file rather than reusing that
# symlink; windows.ps1 symlinks *this* file into place instead (see
# packages.toml's windows-only `bin` [[stow]] entry) and adds its target
# directory to PATH. Confirmed directly: PowerShell resolves a bare command
# name to a same-named .ps1 on PATH without needing the extension typed,
# even though .PS1 isn't in $env:PATHEXT (that's a legacy cmd.exe list;
# PowerShell's own command resolution checks a separate, wider set).
#
# Resolves its own symlink target the same way
# Microsoft.PowerShell_profile.ps1 does, since this file is itself symlinked
# into place — $PSCommandPath here is the symlink's own path, not the repo's.
$__self = Get-Item -LiteralPath $PSCommandPath -Force
$__real = if ($__self.Target) { $__self.Target } else { $PSCommandPath }

# $__real is <repo>\bin\.local\bin\dutils.ps1 — climb back up to <repo>:
# .local\bin\dutils.ps1 -> .local\bin -> .local -> bin -> <repo>.
$__binLocalBin = Split-Path -Path $__real -Parent
$__binLocal = Split-Path -Path $__binLocalBin -Parent
$__binDir = Split-Path -Path $__binLocal -Parent
$__repoDir = Split-Path -Path $__binDir -Parent
$__dutilsScript = Join-Path $__repoDir "scripts\dutils\dutils"

$__python = if (Get-Command python3 -ErrorAction SilentlyContinue) { "python3" } else { "python" }
& $__python $__dutilsScript @args
exit $LASTEXITCODE
