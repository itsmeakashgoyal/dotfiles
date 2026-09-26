#
#  ▓▓▓▓▓▓▓▓▓▓
# ░▓ author ▓ Akash Goyal
# ░▓ file   ▓ windows/windows.ps1
# ░▓▓▓▓▓▓▓▓▓▓
#
# Windows setup: install Scoop, packages, create symlinks, configure Neovim.
# Run as: powershell -ExecutionPolicy Bypass -File windows/windows.ps1
#
# Pass -Uninstall for the reverse: removes every symlink in $SYMLINK_MAP, the
# PATH entry this script adds, generated Neovim data, the PowerShell modules
# it installed, and reverts the Windows Terminal theme (from the backup this
# script made before touching it) — the Windows counterpart to
# scripts/setup/uninstall.sh. Combine with -DryRun to preview, -Force to skip
# the confirmation prompt, and -PurgeScoop to ALSO remove Scoop itself and
# every package it manages (opt-in: Scoop is a general package manager, more
# likely to be used for things outside these dotfiles than this script
# installed, so unlike uninstall.sh's mandatory Homebrew/Nix removal, purging
# it here is not the default). Add -SymlinksOnly to remove just the symlinks
# and PATH entry — this is what `dutils cleanup dotfiles` calls, mirroring
# the "unstow,sweep"-only scope of that same component on macOS/Linux.
#   .\windows.ps1 -Uninstall
#   .\windows.ps1 -Uninstall -DryRun
#   .\windows.ps1 -Uninstall -Force -PurgeScoop
#   .\windows.ps1 -Uninstall -Force -SymlinksOnly

#Requires -Version 5.1

param(
    [switch]$Force,
    [switch]$SkipPackages,
    [switch]$SkipSymlinks,
    [switch]$Uninstall,
    [switch]$DryRun,
    [switch]$PurgeScoop,
    [switch]$SymlinksOnly
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
# PS 7.3+ treats a native command's stderr output as a terminating error when
# $ErrorActionPreference is "Stop" (harmless no-op on PS 5.1, which has no such
# preference). Scoop/git write routine noise to stderr; without this, that
# noise aborts the whole script instead of hitting the non-fatal handling below.
$PSNativeCommandUseErrorActionPreference = $false

# ==============================================================================
# Configuration
# ==============================================================================
# This script lives at <repo>\windows\windows.ps1, so the repo root is one
# level up from $PSScriptRoot. Falls back to the historical default if
# $PSScriptRoot is ever empty (e.g. dot-sourced in an unusual context).
$DOTFILES_DIR = if ($PSScriptRoot) { Split-Path $PSScriptRoot -Parent } else { "$env:USERPROFILE\dotfiles" }
$NVIM_CONFIG = "$env:LOCALAPPDATA\nvim"
$NVIM_DATA = "$env:LOCALAPPDATA\nvim-data"

# Symlink map: source (relative to $DOTFILES_DIR) -> target
#
# Windows doesn't use Stow, so this hashtable is a hand-maintained
# equivalent of the Makefile's STOW_PACKAGES list (`make print-STOW_PACKAGES`)
# — keep it in sync by hand when packages are added/removed there. Notably
# missing today: bin/ (~/.local/bin custom scripts) has no Windows PATH
# equivalent wired up yet.
$SYMLINK_MAP = @{
    # BEGIN GENERATED: symlinks (dutils manifest generate)
    "git\.config\git"                                                          = "$env:USERPROFILE\.config\git"
    "nvim\.config\nvim"                                                        = "$env:LOCALAPPDATA\nvim"
    "television\.config\television"                                            = "$env:USERPROFILE\.config\television"
    "atuin\.config\atuin"                                                      = "$env:USERPROFILE\.config\atuin"
    "fastfetch\.config\fastfetch"                                              = "$env:USERPROFILE\.config\fastfetch"
    "starship\.config\starship"                                                = "$env:USERPROFILE\.config\starship"
    "yazi\.config\yazi"                                                        = "$env:USERPROFILE\.config\yazi"
    "bin\.local\bin\dutils.ps1"                                                = "$env:USERPROFILE\.local\bin\dutils.ps1"
    "readline\.inputrc"                                                        = "$env:USERPROFILE\.inputrc"
    "windows\powershell\Documents\PowerShell\Microsoft.PowerShell_profile.ps1" = "$([Environment]::GetFolderPath("MyDocuments"))\PowerShell\Microsoft.PowerShell_profile.ps1"
    # END GENERATED: symlinks

    # Sublime Text — link each settings file into the User packages dir so the
    # repo stays the live source of truth (Package Control installed separately).
    "settings\sublime\Package Control.sublime-settings"  = "$env:APPDATA\Sublime Text\Packages\User\Package Control.sublime-settings"
    "settings\sublime\Preferences.sublime-settings"      = "$env:APPDATA\Sublime Text\Packages\User\Preferences.sublime-settings"
    "settings\sublime\LSP.sublime-settings"              = "$env:APPDATA\Sublime Text\Packages\User\LSP.sublime-settings"
    "settings\sublime\Gruvbox Dark.sublime-color-scheme"  = "$env:APPDATA\Sublime Text\Packages\User\Gruvbox Dark.sublime-color-scheme"
    "settings\sublime\Adaptive.sublime-theme"            = "$env:APPDATA\Sublime Text\Packages\User\Adaptive.sublime-theme"
    "settings\sublime\Default.sublime-keymap"            = "$env:APPDATA\Sublime Text\Packages\User\Default.sublime-keymap"
    "settings\sublime\C++ Single File.sublime-build"     = "$env:APPDATA\Sublime Text\Packages\User\C++ Single File.sublime-build"
    "settings\sublime\Python3.sublime-build"             = "$env:APPDATA\Sublime Text\Packages\User\Python3.sublime-build"
}

# Scoop packages to install
$SCOOP_PACKAGES = @(
    # BEGIN GENERATED: scoop (dutils manifest generate)
    # Essential CLI Tools
    "git"         # Real git (macOS ships only a Command Line Tools stub)
    "age"         # Modern file encryption (secrets, via dutils secrets)
    "atuin"       # Shell history search (Rust)
    "bat"         # Cat with syntax highlighting (Rust)
    "eza"         # Better ls (Rust)
    "fastfetch"   # System info tool (C)
    "fd"          # Better find (Rust)
    "gh"          # GitHub CLI
    "delta"       # Better git diff (Rust)
    "hyperfine"   # Command-line benchmarking tool (Rust)
    "lazygit"     # Terminal UI for git
    "mise"        # Runtime version manager (replaces pyenv)
    "uv"          # Fast Python venv/package manager (Rust) - works with mise-pinned interpreters
    "starship"    # Cross-shell prompt (default, replaced Powerlevel10k)
    "ripgrep"     # Better grep (Rust)
    "television"  # Fuzzy finder with channels (Rust)
    "yazi"        # Terminal file manager (Rust)
    "zoxide"      # Smart cd (Rust)

    # System Monitoring
    "btop"        # System monitor
    "procs"       # Better ps (Rust)

    # Editors
    "neovim"      # Vim-based text editor

    # Lua Toolchain
    "lua"         # Lua interpreter
    "stylua"      # Lua formatter

    # Shell Tooling
    "shellcheck"  # Shell script linter
    "shfmt"       # Shell formatter

    # Compilers & Build Tools
    "gcc"         # GNU compiler

    # Windows Only
    "curl"        # HTTP client
    "wget"        # HTTP downloader
    "make"        # Build tool
    "nodejs"      # Node.js runtime (Neovim providers, LSP servers)
    "python"      # Python 3 (required by the dutils CLI)
    "tree-sitter" # Neovim treesitter CLI dependency
    # END GENERATED: scoop
)

$SCOOP_BUCKET_PACKAGES = @{
    "nerd-fonts" = @("JetBrainsMono-NF", "FiraCode-NF")
}

# ==============================================================================
# Logging
# ==============================================================================
function Write-Step {
    param([string]$Message)
    Write-Host "  → " -NoNewline -ForegroundColor Yellow
    Write-Host $Message
}

function Write-Ok {
    param([string]$Message)
    Write-Host "  ✓ " -NoNewline -ForegroundColor Green
    Write-Host $Message
}

function Write-Fail {
    param([string]$Message)
    Write-Host "  ✗ " -NoNewline -ForegroundColor Red
    Write-Host $Message
}

function Write-Banner {
    param([string]$Message)
    Write-Host ""
    Write-Host "====================================================" -ForegroundColor Green
    Write-Host " $Message" -ForegroundColor Green
    Write-Host "====================================================" -ForegroundColor Green
    Write-Host ""
}

function Write-Section {
    param([string]$Message)
    Write-Host ""
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Blue
    Write-Host "  $Message" -ForegroundColor Blue
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Blue
}

# ==============================================================================
# Scoop Installation & Packages
# ==============================================================================
function Invoke-Scoop {
    # `scoop` resolves to a .ps1 shim on PATH, so calling it directly runs it
    # in-process (same PowerShell scope) — when Scoop's own `abort` helper
    # fires (e.g. hitting a corrupted bucket checkout during its self-update),
    # it calls `exit`, which kills this whole installer instead of just the
    # scoop call. Re-launching the same PowerShell executable as a real child
    # process (via Start-Process) forces a genuine process boundary, so a
    # scoop-internal exit only ends that child, and Start-Process reports the
    # child's real exit code (unlike routing through cmd.exe's shim, which
    # was found to always report 0 regardless of the underlying failure).
    # Retries absorb the transient "file in use" / "could not lock config
    # file" failures seen from AV/EDR scanners on managed machines mid-clone.
    #
    # Deliberately does NOT redirect stdout: Scoop's table output (used by
    # the "already installed" checks below) renders empty when redirected,
    # so this only wraps state-changing calls (bucket add / install) where
    # we don't need to parse output — read-only queries call scoop directly.
    param(
        [Parameter(Mandatory, ValueFromRemainingArguments)]
        [string[]]$ScoopArgs
    )
    $maxAttempts = 3
    $hostExe = (Get-Process -Id $PID).Path
    $scoopScript = (Get-Command scoop.ps1 -ErrorAction SilentlyContinue).Source
    if (-not $scoopScript) { $scoopScript = "$env:USERPROFILE\scoop\shims\scoop.ps1" }
    $argList = @("-NoProfile", "-NonInteractive", "-File", $scoopScript) + $ScoopArgs

    for ($attempt = 1; $attempt -le $maxAttempts; $attempt++) {
        # Start-Process itself can fail before the child ever runs (host exe
        # missing, path not executable, ...). That throws rather than returning
        # a process, and without the catch the failure surfaced only as three
        # silent retries and a bare "failed (non-fatal)" — no reason given.
        $proc = $null
        try {
            $proc = Start-Process -FilePath $hostExe -ArgumentList $argList -NoNewWindow -Wait -PassThru
        }
        catch {
            Write-Fail "Could not launch scoop (attempt $attempt/$maxAttempts): $($_.Exception.Message)"
        }
        if ($null -ne $proc -and $proc.ExitCode -eq 0) { return $true }
        if ($attempt -lt $maxAttempts) { Start-Sleep -Seconds 2 }
    }
    return $false
}

function Repair-ScoopBuckets {
    # A bucket dir can end up with a half-finished .git checkout (missing
    # HEAD/config, just empty objects/refs) after a network blip or AV/EDR
    # file-lock mid-clone. Scoop then hard-exits the next time anything
    # triggers its bucket self-update (e.g. `scoop install git`), taking this
    # whole script down with it — see Invoke-Scoop above. Fix any broken
    # bucket up front so self-update never hits that failure.
    #
    # Quarantines (renames) the broken dir rather than deleting it outright:
    # if re-adding the bucket then fails too (offline, disk full, ...), a
    # *missing* bucket dir is worse than a broken one — Scoop's own manifest
    # lookups (e.g. `scoop list` for a package from that bucket) throw an
    # uncaught exception when the dir doesn't exist at all, which — unlike a
    # merely-broken checkout — takes this script down. So on failure, restore
    # the quarantined dir to get back to the (still broken, but not missing)
    # starting state instead.
    $bucketsRoot = "$env:USERPROFILE\scoop\buckets"
    if (-not (Test-Path $bucketsRoot)) { return }

    Get-ChildItem $bucketsRoot -Directory | ForEach-Object {
        $bucket = $_.Name
        $originalPath = $_.FullName
        $gitDir = Join-Path $originalPath ".git"
        $headFile = Join-Path $gitDir "HEAD"
        # Two ways a bucket ends up unusable, both from the same interrupted
        # clone: a .git that exists but has no HEAD yet, or a bucket directory
        # with no .git at all. Checking only the first missed the second, even
        # though a bucket that isn't a git repo is exactly what makes Scoop's
        # self-update throw.
        $brokenCheckout = (Test-Path $gitDir) -and -not (Test-Path $headFile)
        $notARepo = -not (Test-Path $gitDir)
        if ($brokenCheckout -or $notARepo) {
            $why = if ($notARepo) { "no .git directory" } else { "incomplete .git checkout" }
            Write-Step "Repairing broken bucket: $bucket ($why)"
            # -NewName takes a NAME, not a path (a path only works because it
            # happens to resolve to the same parent). Pass leaf names so the
            # rename and the restore are unambiguous, and so the restore does
            # not depend on $_.FullName still reporting the pre-rename path.
            $quarantineName = "$bucket.broken.$(Get-Date -Format 'yyyyMMddHHmmss')"
            $quarantinePath = Join-Path $bucketsRoot $quarantineName
            Rename-Item -Path $originalPath -NewName $quarantineName
            if (Invoke-Scoop bucket add $bucket) {
                Write-Ok "$bucket bucket repaired"
                Remove-Item $quarantinePath -Recurse -Force -ErrorAction SilentlyContinue
            }
            else {
                Write-Fail "Could not repair $bucket bucket — restoring previous state (non-fatal, continuing)"
                Rename-Item -Path $quarantinePath -NewName $bucket
            }
        }
    }
}

function Test-ScoopPackageInstalled {
    # Scoop's own internals (core.ps1) have been observed to throw an
    # uncaught, terminating exception here rather than a catchable non-zero
    # exit — e.g. `Get-ChildItem` erroring on a bucket path that doesn't
    # exist. That exception would otherwise propagate through this in-process
    # `scoop list` call and, with $ErrorActionPreference = "Stop" at script
    # scope, abort the whole installer. Treat any such failure as "not
    # installed" and let the normal install path retry it instead.
    param([string]$Package)
    try {
        # -SimpleMatch: the package name is a literal, not a pattern. Without
        # it, a name containing regex metacharacters (`+`, `.`, `[`) would be
        # interpreted as a pattern — `notepad++` is the obvious one, and `.`
        # silently matches any character, which can report a different package
        # as this one.
        $result = scoop list $Package 2>$null | Select-String -SimpleMatch -Pattern $Package
        return [bool]$result
    }
    catch {
        Write-Fail "Could not check install state for $Package ($($_.Exception.Message)) — will attempt install"
        return $false
    }
}

function Install-Scoop {
    if (Get-Command scoop -ErrorAction SilentlyContinue) {
        Write-Ok "Scoop already installed"
        return
    }

    Write-Step "Installing Scoop package manager..."
    Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression
    Write-Ok "Scoop installed"
}

function Install-ScoopPackages {
    Write-Section "Installing Scoop Packages"

    # Fix any bucket left over from a previous interrupted run before we do
    # anything else that could trigger Scoop's self-update against it.
    Repair-ScoopBuckets

    # Add required buckets. Checked via the bucket dir on disk rather than
    # parsing `scoop bucket list`'s table output — that table never matched
    # the "^$bucket\s" pattern here (rendering/column quirks), so this used
    # to silently re-attempt adding already-present buckets every run.
    $buckets = @("extras", "nerd-fonts", "versions")
    foreach ($bucket in $buckets) {
        $bucketDir = "$env:USERPROFILE\scoop\buckets\$bucket"
        if (-not (Test-Path $bucketDir)) {
            Write-Step "Adding bucket: $bucket"
            if (-not (Invoke-Scoop bucket add $bucket)) {
                Write-Fail "Failed to add bucket: $bucket (non-fatal, continuing)"
            }
        }
    }

    # Install main packages
    foreach ($pkg in $SCOOP_PACKAGES) {
        $installed = Test-ScoopPackageInstalled -Package $pkg
        if ($installed) {
            Write-Ok "$pkg (already installed)"
        }
        else {
            Write-Step "Installing $pkg..."
            if (Invoke-Scoop install $pkg) {
                Write-Ok "$pkg installed"
            }
            else {
                Write-Fail "$pkg failed to install (non-fatal)"
            }
        }
    }

    # Install bucket-specific packages (fonts, etc.)
    foreach ($bucket in $SCOOP_BUCKET_PACKAGES.Keys) {
        foreach ($pkg in $SCOOP_BUCKET_PACKAGES[$bucket]) {
            $installed = Test-ScoopPackageInstalled -Package $pkg
            if ($installed) {
                Write-Ok "$pkg (already installed)"
            }
            else {
                Write-Step "Installing $pkg from $bucket..."
                if (Invoke-Scoop install $pkg) {
                    Write-Ok "$pkg installed"
                }
                else {
                    Write-Fail "$pkg failed (non-fatal) — it may be locked by another process (e.g. a font already loaded); close other apps and retry with: scoop install $pkg"
                }
            }
        }
    }

    Write-Ok "Package installation complete"
}

# ==============================================================================
# Symlink Management
# ==============================================================================
function New-DotfileSymlink {
    param(
        [string]$Source,
        [string]$Target
    )

    $sourcePath = Join-Path $DOTFILES_DIR $Source

    if (-not (Test-Path $sourcePath)) {
        Write-Fail "Source not found: $sourcePath"
        return
    }

    # Create parent directory if it doesn't exist
    $parentDir = Split-Path $Target -Parent
    if (-not (Test-Path $parentDir)) {
        New-Item -ItemType Directory -Path $parentDir -Force | Out-Null
    }

    # Handle existing target
    if (Test-Path $Target) {
        $item = Get-Item $Target -Force
        if ($item.Attributes -band [IO.FileAttributes]::ReparsePoint) {
            # Existing symlink — remove and recreate
            Write-Step "Replacing existing symlink: $Target"
            Remove-Item $Target -Force
        }
        elseif ($Force) {
            # Real directory/file — back up then remove
            $backupPath = "$Target.backup.$(Get-Date -Format 'yyyyMMddHHmmss')"
            Write-Step "Backing up existing: $Target → $backupPath"
            Move-Item $Target $backupPath
        }
        else {
            Write-Fail "Target exists (use -Force to overwrite): $Target"
            return $false
        }
    }

    New-Item -ItemType SymbolicLink -Path $Target -Target $sourcePath -Force | Out-Null
    Write-Ok "$Source → $Target"
    return $true
}

function Install-Symlinks {
    Write-Section "Creating Symlinks"

    $blocked = 0

    foreach ($entry in $SYMLINK_MAP.GetEnumerator()) {
        if (-not (New-DotfileSymlink -Source $entry.Key -Target $entry.Value)) { $blocked++ }
    }

    # Also link profile for Windows PowerShell 5.1. Same OneDrive Known Folder
    # Move concern as the generated PowerShell 7 entry (see packages.toml's
    # powershell [[stow]] entry) — Documents isn't always $env:USERPROFILE\Documents.
    $documentsDir = [Environment]::GetFolderPath('MyDocuments')
    if (-not (New-DotfileSymlink `
                -Source "windows\powershell\Documents\PowerShell\Microsoft.PowerShell_profile.ps1" `
                -Target "$documentsDir\WindowsPowerShell\Microsoft.PowerShell_profile.ps1")) { $blocked++ }

    if ($blocked -gt 0) {
        Write-Host ""
        Write-Host "  $blocked symlink(s) skipped because a real file/directory is already there." -ForegroundColor Yellow
        Write-Host "  Re-run with -Force to back up (as <target>.backup.<timestamp>) and replace them:" -ForegroundColor Yellow
        Write-Host "    .\install.ps1 -Force" -ForegroundColor Yellow
    }
    else {
        Write-Ok "All symlinks created"
    }
}

# ==============================================================================
# PATH
# ==============================================================================
function Install-LocalBinOnPath {
    Write-Section "PATH"

    # Puts dutils on PATH as a bare `dutils` command — mirrors what the `bin`
    # Stow package does on macOS/Linux (~/.local/bin, added to PATH by the
    # shell config). bin\.local\bin\dutils.ps1 is symlinked into
    # $env:USERPROFILE\.local\bin by $SYMLINK_MAP above; this just makes sure
    # that directory is actually on PATH so it resolves as a bare command.
    $localBin = "$env:USERPROFILE\.local\bin"
    $currentPath = [Environment]::GetEnvironmentVariable('PATH', 'User')
    $entries = @(($currentPath -split ';') | Where-Object { $_ } | ForEach-Object { $_.TrimEnd('\') })
    if ($entries -contains $localBin.TrimEnd('\')) {
        Write-Ok "$localBin already on PATH"
        return
    }

    $newPath = if ($currentPath) { "$currentPath;$localBin" } else { $localBin }
    [Environment]::SetEnvironmentVariable('PATH', $newPath, 'User')
    Write-Ok "Added $localBin to PATH (open a new terminal to pick it up)"
}

# ==============================================================================
# Neovim Setup
# ==============================================================================
function Install-NeovimPlugins {
    Write-Section "Neovim Setup"

    if (-not (Get-Command nvim -ErrorAction SilentlyContinue)) {
        Write-Fail "Neovim not found — skipping plugin setup"
        return
    }

    Write-Step "Neovim config linked to: $NVIM_CONFIG"

    # Verify lazy.nvim will bootstrap on first launch
    if (Test-Path (Join-Path $NVIM_CONFIG "lua")) {
        Write-Ok "Neovim config detected — plugins will install on first launch"
        Write-Step "Run 'nvim' to trigger lazy.nvim bootstrap"
    }
    else {
        Write-Fail "Neovim config not found at $NVIM_CONFIG — check symlinks"
    }
}

# ==============================================================================
# GUI Configuration
# ==============================================================================
function Install-SublimePackageControl {
    Write-Section "Sublime Text"
    $installed = "$env:APPDATA\Sublime Text\Installed Packages"
    $pkg = Join-Path $installed "Package Control.sublime-package"
    if (Test-Path $pkg) {
        Write-Ok "Package Control already present"
        return
    }
    New-Item -ItemType Directory -Force -Path $installed | Out-Null
    $url = "https://github.com/wbond/package_control/releases/latest/download/Package.Control.sublime-package"
    try {
        Invoke-WebRequest -Uri $url -OutFile $pkg -UseBasicParsing
        Write-Ok "Package Control installed — listed packages install on next launch"
    }
    catch {
        Write-Fail "Could not download Package Control: $_"
    }
}

function Install-GuiConfig {
    Write-Section "GUI Configuration"

    $ginit = Join-Path $NVIM_CONFIG "ginit.vim"
    if (Test-Path $ginit) {
        Write-Ok "ginit.vim already exists"
        return
    }

    $ginitContent = @'
" GUI-specific settings for nvim-qt and Neovide on Windows
if exists('g:GuiLoaded')
    " nvim-qt settings
    GuiFont! JetBrainsMono\ Nerd\ Font:h11
    GuiTabline 0
    GuiPopupmenu 0
    let g:GuiWindowOpacity = 1.0
    nnoremap <silent> <F10> :call ToggleTransparency()<CR>
    nnoremap <silent> <F11> :call GuiWindowFullScreen(!g:GuiWindowFullScreen)<CR>
    function! ToggleTransparency()
        if g:GuiWindowOpacity == 1.0
            let g:GuiWindowOpacity = 0.9
        else
            let g:GuiWindowOpacity = 1.0
        endif
        call GuiWindowOpacity(g:GuiWindowOpacity)
    endfunction
endif

if exists('g:neovide')
    " Neovide settings
    set guifont=JetBrainsMono\ Nerd\ Font:h11
    let g:neovide_remember_window_size = v:true
    let g:neovide_transparency = 1.0
    nnoremap <silent> <F10> :lua vim.g.neovide_transparency = vim.g.neovide_transparency == 1.0 and 0.8 or 1.0<CR>
    nnoremap <silent> <F11> :let g:neovide_fullscreen = !g:neovide_fullscreen<CR>
endif
'@
    Set-Content -Path $ginit -Value $ginitContent -Encoding UTF8
    Write-Ok "Created ginit.vim for nvim-qt and Neovide"
}

# ==============================================================================
# Windows Terminal Theme
# ==============================================================================
function Install-TerminalTheme {
    Write-Section "Windows Terminal Theme"

    # Store-installed vs unpackaged Windows Terminal use different settings
    # locations; check both.
    $settingsPath = @(
        "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json",
        "$env:LOCALAPPDATA\Microsoft\Windows Terminal\settings.json"
    ) | Where-Object { Test-Path $_ } | Select-Object -First 1

    if (-not $settingsPath) {
        Write-Fail "Windows Terminal settings.json not found — skipping (install Windows Terminal for a themed prompt)"
        return
    }

    # Tracked in the repo (windows/windows-terminal/gruvbox-dark.json), not
    # hardcoded here — one reviewable file, consistent with settings/iterm/
    # and settings/sublime/ for the same kind of GUI-app config export on
    # macOS.
    $schemeFile = Join-Path $DOTFILES_DIR "windows\windows-terminal\gruvbox-dark.json"
    if (-not (Test-Path $schemeFile)) {
        Write-Fail "Color scheme file not found: $schemeFile — skipping"
        return
    }

    try {
        $settings = Get-Content $settingsPath -Raw | ConvertFrom-Json
        $gruvboxDark = Get-Content $schemeFile -Raw | ConvertFrom-Json

        # Replace any prior "Gruvbox Dark" entry (re-run safety) and keep the rest.
        $settings.schemes = @($settings.schemes | Where-Object { $_.name -ne "Gruvbox Dark" }) + $gruvboxDark

        if (-not $settings.profiles.defaults) {
            $settings.profiles | Add-Member -MemberType NoteProperty -Name defaults -Value ([PSCustomObject]@{}) -Force
        }
        $settings.profiles.defaults | Add-Member -MemberType NoteProperty -Name colorScheme -Value "Gruvbox Dark" -Force

        if (-not $settings.profiles.defaults.font) {
            $settings.profiles.defaults | Add-Member -MemberType NoteProperty -Name font -Value ([PSCustomObject]@{}) -Force
        }
        $settings.profiles.defaults.font | Add-Member -MemberType NoteProperty -Name face -Value "JetBrainsMono NF" -Force

        # Back up before touching the user's live settings — this is app
        # state outside $DOTFILES_DIR, not something re-running the installer
        # can regenerate.
        $backupPath = "$settingsPath.backup.$(Get-Date -Format 'yyyyMMddHHmmss')"
        Copy-Item $settingsPath $backupPath
        ($settings | ConvertTo-Json -Depth 20) | Set-Content -Path $settingsPath -Encoding UTF8

        Write-Ok "Windows Terminal set to Gruvbox Dark + JetBrainsMono NF (backup: $backupPath)"
    }
    catch {
        Write-Fail "Windows Terminal theme update failed (non-fatal): $_"
    }
}

# ==============================================================================
# Health Check
# ==============================================================================
function Test-Installation {
    Write-Section "Health Check"

    # Used to be a hand-maintained, 8-tool list that couldn't help drifting
    # from packages.toml (checked 8 of the 34 packages this script actually
    # installs — a failed `mise` or `delta` install was invisible here despite
    # `dutils health` already knowing how to check the real manifest, and
    # correctly resolving the OneDrive-safe PowerShell profile symlink, on
    # every platform). Delegate to it instead of maintaining a second copy.
    $py = if (Get-Command python3 -ErrorAction SilentlyContinue) { "python3" } else { "python" }
    & $py (Join-Path $DOTFILES_DIR "scripts\verify\check.py") --quick
    $passed = ($LASTEXITCODE -eq 0)

    # In CI, an incomplete health check is a real failure, not just a status
    # line — mirrors install.sh's `[[ -n "$CI" ]]` strictness convention.
    # Interactive/personal runs stay lenient (report and continue).
    if ($env:CI -and -not $passed) {
        Write-Host "::error::Health check reported failures" -ForegroundColor Red
        exit 1
    }
}

# ==============================================================================
# PowerShell Modules
# ==============================================================================
function Install-PsModules {
    Write-Section "PowerShell Modules"

    # PSReadLine only needs installing on Windows PowerShell (Desktop edition,
    # 5.1) — its inbox version there is a genuinely old 2.0.0 that predates
    # -Colors/prediction support. pwsh (Core) already ships a current one
    # (confirmed directly: 7.6.6 bundles 2.4.5 — newer than what Install-Module
    # was pulling down here, 2.4.4 — so this was pure wasted install time on
    # modern PowerShell, not a functional gap).
    $modules = if ($PSVersionTable.PSEdition -eq "Desktop") { @("PSReadLine", "Terminal-Icons") } else { @("Terminal-Icons") }
    foreach ($mod in $modules) {
        if (Get-Module -ListAvailable $mod -ErrorAction SilentlyContinue) {
            Write-Ok "$mod (already installed)"
        } else {
            Write-Step "Installing $mod..."
            try {
                Install-Module $mod -Scope CurrentUser -Force -AllowClobber -ErrorAction Stop
                Write-Ok "$mod installed"
            } catch {
                Write-Fail "$mod failed: $_"
            }
        }
    }
}

# ==============================================================================
# Uninstall
# ==============================================================================
# Confirmation gate, honoring -Force/-DryRun the same way scripts/setup/
# uninstall.sh's confirm_gate does.
function Confirm-Uninstall {
    param([string]$Prompt)
    if ($DryRun) { Write-Step "[dry-run] would ask: $Prompt"; return $true }
    if ($Force) { return $true }
    $yn = Read-Host "  ? $Prompt [y/N]"
    return $yn -match '^[Yy]$'
}

function Remove-DotfileSymlinks {
    Write-Section "Removing Symlinks"

    $removed = 0
    $targets = @($SYMLINK_MAP.Values)
    # Windows PowerShell 5.1 links its profile to a different path than the
    # generated pwsh entry (see Install-Symlinks) — not in $SYMLINK_MAP itself.
    $documentsDir = [Environment]::GetFolderPath('MyDocuments')
    $targets += "$documentsDir\WindowsPowerShell\Microsoft.PowerShell_profile.ps1"

    foreach ($target in $targets) {
        if (-not (Test-Path $target)) { continue }
        $item = Get-Item $target -Force
        if (-not ($item.Attributes -band [IO.FileAttributes]::ReparsePoint)) {
            Write-Fail "$target exists but isn't a symlink — leaving it alone (may be a -Force backup target)"
            continue
        }
        if ($DryRun) {
            Write-Step "[dry-run] would remove symlink: $target"
        }
        else {
            Remove-Item $target -Force
            Write-Ok "Removed symlink: $target"
        }
        $removed++
    }

    if ($removed -eq 0) { Write-Ok "No dotfiles symlinks found." }
}

function Remove-LocalBinFromPath {
    Write-Section "PATH"

    $localBin = "$env:USERPROFILE\.local\bin"
    $currentPath = [Environment]::GetEnvironmentVariable('PATH', 'User')
    $entries = @(($currentPath -split ';') | Where-Object { $_ })
    $kept = @($entries | Where-Object { $_.TrimEnd('\') -ne $localBin.TrimEnd('\') })

    if ($kept.Count -eq $entries.Count) {
        Write-Ok "$localBin not on PATH — nothing to remove."
        return
    }
    if ($DryRun) {
        Write-Step "[dry-run] would remove $localBin from the user PATH"
        return
    }
    [Environment]::SetEnvironmentVariable('PATH', ($kept -join ';'), 'User')
    Write-Ok "Removed $localBin from PATH"
}

function Remove-GeneratedNvimData {
    Write-Section "Generated Neovim Data"

    # lazy.nvim plugins + nvim state/shada/cache all live under one dir on
    # Windows (unlike macOS/Linux's separate data/state/cache XDG dirs) —
    # regenerated on next launch, so safe to wipe entirely.
    if (Test-Path $NVIM_DATA) {
        if ($DryRun) { Write-Step "[dry-run] would remove $NVIM_DATA" }
        else { Remove-Item $NVIM_DATA -Recurse -Force; Write-Ok "Removed $NVIM_DATA" }
    }
    else {
        Write-Ok "$NVIM_DATA not present — nothing to remove."
    }
}

function Uninstall-PsModules {
    Write-Section "PowerShell Modules"

    # Only the ones Install-PsModules installs — PSReadLine ships inbox, so
    # removing a user-scope copy just reverts to that, never leaves the shell
    # without one.
    foreach ($mod in @("PSReadLine", "Terminal-Icons")) {
        if (-not (Get-InstalledModule $mod -ErrorAction SilentlyContinue)) {
            Write-Ok "$mod (not installed via PowerShellGet — nothing to remove)"
            continue
        }
        if ($DryRun) {
            Write-Step "[dry-run] would uninstall module: $mod"
            continue
        }
        try {
            Uninstall-Module $mod -AllVersions -Force -ErrorAction Stop
            Write-Ok "Uninstalled $mod"
        }
        catch {
            Write-Fail "Could not uninstall $mod (non-fatal): $_"
        }
    }
}

function Restore-TerminalTheme {
    Write-Section "Windows Terminal Theme"

    $settingsPath = @(
        "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json",
        "$env:LOCALAPPDATA\Microsoft\Windows Terminal\settings.json"
    ) | Where-Object { Test-Path $_ } | Select-Object -First 1

    if (-not $settingsPath) {
        Write-Ok "Windows Terminal not found — nothing to revert."
        return
    }

    # Install-TerminalTheme always makes a timestamped backup before writing;
    # the newest one is the pre-Gruvbox state.
    $backup = Get-ChildItem -Path (Split-Path $settingsPath) -Filter "$(Split-Path $settingsPath -Leaf).backup.*" -ErrorAction SilentlyContinue |
        Sort-Object Name -Descending | Select-Object -First 1

    if (-not $backup) {
        Write-Ok "No settings.json backup found — theme left as-is (nothing this script can safely revert)."
        return
    }

    if ($DryRun) {
        Write-Step "[dry-run] would restore $settingsPath from $($backup.Name)"
        return
    }
    Copy-Item $backup.FullName $settingsPath -Force
    Write-Ok "Restored Windows Terminal settings from $($backup.Name)"
}

function Remove-ScoopPackages {
    Write-Section "Scoop Packages"

    if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {
        Write-Ok "Scoop not installed — nothing to remove."
        return
    }

    $allPkgs = @($SCOOP_PACKAGES) + @($SCOOP_BUCKET_PACKAGES.Values | ForEach-Object { $_ })
    foreach ($pkg in $allPkgs) {
        if (-not (Test-ScoopPackageInstalled -Package $pkg)) { continue }
        if ($DryRun) {
            Write-Step "[dry-run] would run: scoop uninstall $pkg"
            continue
        }
        if (Invoke-Scoop uninstall $pkg) { Write-Ok "Removed $pkg" }
        else { Write-Fail "Could not remove $pkg (non-fatal)" }
    }

    if ($PurgeScoop) {
        Write-Warning-Line "Purging Scoop itself — this removes EVERY package it manages, not just the ones above."
        if ($DryRun) {
            Write-Step "[dry-run] would run: scoop uninstall scoop --purge"
            return
        }
        if (Invoke-Scoop uninstall scoop --purge) { Write-Ok "Scoop fully removed" }
        else { Write-Fail "Scoop self-uninstall failed — remove $env:USERPROFILE\scoop manually if needed" }
    }
    else {
        Write-Ok "Scoop itself left installed (pass -PurgeScoop to remove it entirely)."
    }
}

function Write-Warning-Line {
    param([string]$Message)
    Write-Host "  ! $Message" -ForegroundColor Yellow
}

function Invoke-Uninstall {
    Write-Banner "Dotfiles Windows Uninstall"
    if ($DryRun) { Write-Warning-Line "DRY-RUN MODE — nothing will actually be changed." }

    Write-Host ""
    if ($SymlinksOnly) {
        Write-Host "  This removes every symlink windows.ps1 created and its PATH entry" -ForegroundColor Cyan
        Write-Host "  only — Scoop packages, Neovim data, PowerShell modules, and the" -ForegroundColor Cyan
        Write-Host "  Windows Terminal theme are left as-is." -ForegroundColor Cyan
    }
    else {
        Write-Host "  This removes every symlink windows.ps1 created, its PATH entry," -ForegroundColor Cyan
        Write-Host "  generated Neovim data, the PowerShell modules it installed, and" -ForegroundColor Cyan
        Write-Host "  reverts the Windows Terminal theme." -ForegroundColor Cyan
        if ($PurgeScoop) {
            Write-Warning-Line "Also purging Scoop entirely (-PurgeScoop) — every package it manages goes too."
        }
        else {
            Write-Host "  Scoop's own packages this script installed will be removed; Scoop" -ForegroundColor Cyan
            Write-Host "  itself is left alone unless you pass -PurgeScoop." -ForegroundColor Cyan
        }
    }
    Write-Host "  The repo, your dotfiles' own git history, and your data (atuin" -ForegroundColor Cyan
    Write-Host "  history, ssh keys, secrets) are left untouched." -ForegroundColor Cyan
    Write-Host ""

    if (-not (Confirm-Uninstall "Proceed with uninstall?")) {
        Write-Fail "Uninstall aborted."
        return
    }

    Remove-DotfileSymlinks
    Remove-LocalBinFromPath

    if (-not $SymlinksOnly) {
        Remove-GeneratedNvimData
        Uninstall-PsModules
        Restore-TerminalTheme
        Remove-ScoopPackages
    }

    Write-Host ""
    if ($DryRun) {
        Write-Host "  Dry-run complete — no changes were made." -ForegroundColor Green
    }
    else {
        Write-Host "  Dotfiles uninstalled." -ForegroundColor Green
        Write-Host "  Open a new terminal for the PATH change to take effect." -ForegroundColor Cyan
        Write-Host "  The repo is still at: $DOTFILES_DIR (delete it manually if you want it gone)." -ForegroundColor Cyan
    }
}

# ==============================================================================
# Main
# ==============================================================================
function Main {
    if ($Uninstall) {
        Invoke-Uninstall
        return
    }

    Write-Banner "Dotfiles Windows Setup"

    # Check we're running as admin (needed for symlinks on older Windows)
    $isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(
        [Security.Principal.WindowsBuiltInRole]::Administrator
    )
    if (-not $isAdmin) {
        Write-Host ""
        Write-Host "  NOTE: Running without admin. Symlinks require Developer Mode enabled" -ForegroundColor Yellow
        Write-Host "        or run this script as Administrator." -ForegroundColor Yellow
        Write-Host "        Settings → Update & Security → For Developers → Developer Mode" -ForegroundColor Yellow
        Write-Host ""
    }

    # Check dotfiles directory
    if (-not (Test-Path $DOTFILES_DIR)) {
        Write-Fail "Dotfiles directory not found at $DOTFILES_DIR"
        Write-Step "Clone your dotfiles first: git clone <repo> $DOTFILES_DIR"
        exit 1
    }

    # Each step wrapped in try/catch — same reasoning as the PowerShell
    # profile's own per-file loader: with $ErrorActionPreference = "Stop" at
    # script scope, one step's uncaught error (a network hiccup in Sublime's
    # download, a malformed Windows Terminal settings.json, ...) used to kill
    # the *entire* script, silently skipping every step after it, including
    # the final health check. Surface the failure, keep going, and report a
    # summary at the end instead — mirrors uninstall.sh's own Summary block.
    $__failures = @()
    function Invoke-Step {
        param([string]$Name, [scriptblock]$Body)
        try {
            & $Body
        }
        catch {
            Write-Fail "$Name failed: $_"
            $script:__failures += $Name
        }
    }

    # Step 1: Scoop
    if (-not $SkipPackages) {
        Invoke-Step "Package Manager" {
            Write-Section "Package Manager"
            Install-Scoop
            Install-ScoopPackages
        }
    }
    else {
        Write-Step "Skipping package installation (-SkipPackages)"
    }

    # Step 2: Symlinks
    if (-not $SkipSymlinks) {
        Invoke-Step "Symlinks" {
            Install-Symlinks
            Install-LocalBinOnPath
        }
    }
    else {
        Write-Step "Skipping symlink creation (-SkipSymlinks)"
    }

    # Step 3: PowerShell modules
    if (-not $SkipPackages) {
        Invoke-Step "PowerShell Modules" { Install-PsModules }
    }

    # Step 4: Neovim + editors
    Invoke-Step "Neovim Setup" { Install-NeovimPlugins }
    Invoke-Step "GUI Configuration" { Install-GuiConfig }
    Invoke-Step "Sublime Text" { Install-SublimePackageControl }

    # Step 5: Windows Terminal theme
    Invoke-Step "Windows Terminal Theme" { Install-TerminalTheme }

    # Step 6: Health check (always runs, even if an earlier step failed —
    # that's exactly when seeing the real state matters most)
    Test-Installation

    if ($__failures.Count -gt 0) {
        Write-Host ""
        Write-Host "  ⚠ $($__failures.Count) step(s) failed and were skipped:" -ForegroundColor Yellow
        $__failures | ForEach-Object { Write-Host "    - $_" -ForegroundColor Yellow }
        Write-Host "  Everything else above still completed. Re-run windows.ps1 to retry" -ForegroundColor Yellow
        Write-Host "  just the failed step(s) — steps are idempotent." -ForegroundColor Yellow
    }

    Write-Banner "Setup Complete!"
    Write-Host "  Next steps:" -ForegroundColor Cyan
    Write-Host "    1. Open a new terminal to pick up PATH changes"
    Write-Host "    2. Run 'nvim' to install plugins (lazy.nvim will bootstrap)"
    Write-Host "    3. Inside nvim, run ':checkhealth' to verify"
    Write-Host "    4. Install a Nerd Font in your terminal (JetBrainsMono NF recommended)"
    Write-Host "    5. Reload your PowerShell profile: . `$PROFILE"
    Write-Host ""

    if ($env:CI -and $__failures.Count -gt 0) {
        Write-Host "::error::$($__failures.Count) setup step(s) failed: $($__failures -join ', ')" -ForegroundColor Red
        exit 1
    }
}

Main
