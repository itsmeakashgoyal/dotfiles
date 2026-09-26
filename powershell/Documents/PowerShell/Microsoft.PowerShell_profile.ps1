#
#  ▓▓▓▓▓▓▓▓▓▓
# ░▓ author ▓ Akash Goyal
# ░▓ file   ▓ powershell/Documents/PowerShell/Microsoft.PowerShell_profile.ps1
# ░▓▓▓▓▓▓▓▓▓▓
#
# PowerShell profile — Linux/macOS feel on Windows
# Tools: ripgrep · television (tv) · atuin · bat · eza · zoxide · mise · uv · starship · PSReadLine
#
# This profile is intentionally thin: it resolves its own location (it's a
# symlink into the dotfiles repo, created by scripts/setup/windows.ps1) and
# dot-sources the section files in profile.d/, mirroring how zsh sources
# conf.d/*.zsh. Add or edit a section by dropping a NN-name.ps1 in profile.d/.
#
# Install prerequisites once:
#   scoop install ripgrep television atuin bat eza zoxide fd mise starship uv
#   Install-Module PSReadLine, Terminal-Icons -Scope CurrentUser

# Shared helpers used across every section file below.
function _cmd { param($Name) [bool](Get-Command $Name -ErrorAction SilentlyContinue) }

# Default editor, matching zsh's 01-exports.zsh — nothing else in this profile
# set these, so anything relying on $env:EDITOR (e.g. rgf in 20-tools.ps1) had
# no fallback of its own beyond a literal, always-empty value.
if (-not $env:EDITOR) { $env:EDITOR = 'nvim' }
if (-not $env:VISUAL) { $env:VISUAL = $env:EDITOR }

# `<tool> init <shell>` spawns the tool on every prompt/shell start — the
# expensive part on Windows (per-process spawn + EDR/AV overhead). Cache the
# generated init to a file and dot-source that instead, regenerating only
# when the tool binary changes. Get-Command/Get-Item are in-process; the
# spawn only happens on a cache miss. Mirrors cached_init in zsh's
# 01-exports.zsh. Lives here (not in a later-loading profile.d file) because
# 10-television.ps1/11-atuin.ps1 need it and load before 20-tools.ps1 does.
function Import-CachedInit {
    param([string]$Name, [string]$Bin, [scriptblock]$Init)
    $cmd = Get-Command $Bin -ErrorAction SilentlyContinue
    if (-not $cmd) { return }
    $dir = Join-Path $env:LOCALAPPDATA "dotfiles\psinit"
    $cache = Join-Path $dir "$Name.ps1"
    $keyFile = Join-Path $dir "$Name.key"
    $key = "{0}:{1}" -f $cmd.Source, (Get-Item $cmd.Source).LastWriteTimeUtc.Ticks
    if ((-not (Test-Path $cache)) -or (-not (Test-Path $keyFile)) -or
        ((Get-Content $keyFile -Raw -ErrorAction SilentlyContinue).Trim() -ne $key)) {
        New-Item -ItemType Directory -Force -Path $dir | Out-Null
        (& $Init | Out-String) | Set-Content -Path $cache -Encoding UTF8
        Set-Content -Path $keyFile -Value $key -Encoding UTF8
    }
    . $cache
}

# Resolve this profile's real directory. $PROFILE is the symlink in $HOME; its
# .Target points back into the repo (absolute path), so profile.d/ is found in
# the repo without needing its own symlink. Falls back to $PROFILE's own dir if
# it isn't a symlink (e.g. a plain copy).
$__self  = Get-Item -LiteralPath $PROFILE -Force
$__real  = if ($__self.Target) { $__self.Target } else { $PROFILE }
$__confd = Join-Path (Split-Path -Parent $__real) 'profile.d'

# `foreach` statement (not ForEach-Object) so each `. $file` dot-sources into
# THIS profile scope - functions/aliases/vars must persist to the session.
#
# Each file is wrapped in try/catch: an uncaught terminating error in one file
# (e.g. an integration whose binary vanished) would otherwise abort the entire
# foreach and silently skip every file after it — including starship's prompt
# init further down the alphabet. Surface the error and keep going instead.
#
# Set $env:DOTFILES_PROFILE_DEBUG=1 (before launching pwsh) to print how long
# each profile.d file took, to find slow startup contributors without
# guessing.
$__debug = [bool]$env:DOTFILES_PROFILE_DEBUG
if (Test-Path $__confd) {
    foreach ($__f in Get-ChildItem -Path $__confd -Filter '*.ps1' | Sort-Object Name) {
        # __fileSw (not __sw) deliberately — profile.d files are dot-sourced
        # into this same scope and some of them keep their own $__sw for
        # sub-section timing; a shared name here would get clobbered/removed
        # by theirs before this loop reads it back.
        $__fileSw = if ($__debug) { [System.Diagnostics.Stopwatch]::StartNew() }
        try {
            . $__f.FullName
        } catch {
            Write-Warning "profile.d/$($__f.Name) failed to load: $_"
        }
        if ($__debug) {
            Write-Host ("  [{0,6:N0}ms] {1}" -f $__fileSw.Elapsed.TotalMilliseconds, $__f.Name) -ForegroundColor Magenta
        }
    }
}
Remove-Variable __self, __real, __confd, __f, __debug, __fileSw -ErrorAction SilentlyContinue

# ==============================================================================
# Startup
# ==============================================================================
Write-Host "  PS $($PSVersionTable.PSVersion)  •  " -NoNewline -ForegroundColor DarkGray
Write-Host (Split-Path -Leaf $PROFILE) -NoNewline -ForegroundColor DarkCyan
Write-Host "  loaded" -ForegroundColor DarkGray
