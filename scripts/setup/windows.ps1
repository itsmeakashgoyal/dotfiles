#  ▓▓▓▓▓▓▓▓▓▓
# ░▓ author ▓ Akash Goyal
# ░▓ file   ▓ scripts/setup/windows.ps1
# ░▓▓▓▓▓▓▓▓▓▓
#
# Windows setup: install Scoop, packages, create symlinks, configure Neovim.
# Run as: powershell -ExecutionPolicy Bypass -File scripts/setup/windows.ps1

#Requires -Version 5.1

param(
    [switch]$Force,
    [switch]$SkipPackages,
    [switch]$SkipSymlinks
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# ==============================================================================
# Configuration
# ==============================================================================
$DOTFILES_DIR = "$env:USERPROFILE\dotfiles"
$NVIM_CONFIG = "$env:LOCALAPPDATA\nvim"
$NVIM_DATA = "$env:LOCALAPPDATA\nvim-data"

# Symlink map: source (relative to $DOTFILES_DIR) -> target
$SYMLINK_MAP = @{
    "nvim\.config\nvim"           = $NVIM_CONFIG
    "git\.config\git"             = "$env:USERPROFILE\.config\git"
    "tmux\.config\tmux"           = "$env:USERPROFILE\.config\tmux"
    "television\.config\television" = "$env:USERPROFILE\.config\television"
    "atuin\.config\atuin"         = "$env:USERPROFILE\.config\atuin"
    "fastfetch\.config\fastfetch" = "$env:USERPROFILE\.config\fastfetch"
    "powershell\Documents\PowerShell\Microsoft.PowerShell_profile.ps1" = "$env:USERPROFILE\Documents\PowerShell\Microsoft.PowerShell_profile.ps1"
}

# Scoop packages to install
$SCOOP_PACKAGES = @(
    # Core CLI tools
    "git"
    "curl"
    "wget"
    # Editor
    "neovim"
    # Search & navigation
    "ripgrep"
    "fd"
    "bat"
    "eza"
    "fzf"
    "zoxide"
    "television"
    # Git tools
    "lazygit"
    "delta"
    # Development
    "nodejs"
    "python"
    "lua"
    "stylua"
    "shellcheck"
    "make"
    "gcc"
    # Neovim dependencies
    "tree-sitter"
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

    # Add required buckets
    $buckets = @("extras", "nerd-fonts", "versions")
    foreach ($bucket in $buckets) {
        $existing = scoop bucket list 2>$null | Select-String -Pattern "^$bucket\s"
        if (-not $existing) {
            Write-Step "Adding bucket: $bucket"
            scoop bucket add $bucket 2>$null
        }
    }

    # Install main packages
    foreach ($pkg in $SCOOP_PACKAGES) {
        $installed = scoop list $pkg 2>$null | Select-String -Pattern $pkg
        if ($installed) {
            Write-Ok "$pkg (already installed)"
        }
        else {
            Write-Step "Installing $pkg..."
            scoop install $pkg 2>$null
            if ($LASTEXITCODE -eq 0) {
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
            $installed = scoop list $pkg 2>$null | Select-String -Pattern $pkg
            if ($installed) {
                Write-Ok "$pkg (already installed)"
            }
            else {
                Write-Step "Installing $pkg from $bucket..."
                scoop install $pkg 2>$null
                if ($LASTEXITCODE -eq 0) {
                    Write-Ok "$pkg installed"
                }
                else {
                    Write-Fail "$pkg failed (non-fatal)"
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
            return
        }
    }

    New-Item -ItemType SymbolicLink -Path $Target -Target $sourcePath -Force | Out-Null
    Write-Ok "$Source → $Target"
}

function Install-Symlinks {
    Write-Section "Creating Symlinks"

    foreach ($entry in $SYMLINK_MAP.GetEnumerator()) {
        New-DotfileSymlink -Source $entry.Key -Target $entry.Value
    }

    # Also link profile for Windows PowerShell 5.1
    New-DotfileSymlink `
        -Source "powershell\Documents\PowerShell\Microsoft.PowerShell_profile.ps1" `
        -Target "$env:USERPROFILE\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1"

    Write-Ok "All symlinks created"
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
# Health Check
# ==============================================================================
function Test-Installation {
    Write-Section "Health Check"

    $tools = @("nvim", "git", "ripgrep", "fd", "bat", "lazygit", "node", "python3")
    $passed = 0
    $total = $tools.Count

    foreach ($tool in $tools) {
        # ripgrep binary is 'rg', python3 might be 'python'
        $cmd = switch ($tool) {
            "ripgrep" { "rg" }
            "python3" { if (Get-Command python3 -ErrorAction SilentlyContinue) { "python3" } else { "python" } }
            default { $tool }
        }
        if (Get-Command $cmd -ErrorAction SilentlyContinue) {
            Write-Ok "$tool"
            $passed++
        }
        else {
            Write-Fail "$tool not found"
        }
    }

    # Check symlinks
    Write-Host ""
    Write-Step "Checking symlinks..."
    foreach ($entry in $SYMLINK_MAP.GetEnumerator()) {
        $target = $entry.Value
        if (Test-Path $target) {
            $item = Get-Item $target -Force
            if ($item.Attributes -band [IO.FileAttributes]::ReparsePoint) {
                Write-Ok "$target (symlink)"
                $passed++
            }
            else {
                Write-Fail "$target (exists but not a symlink)"
            }
        }
        else {
            Write-Fail "$target (missing)"
        }
        $total++
    }

    Write-Host ""
    Write-Host "  Score: $passed/$total checks passed" -ForegroundColor $(if ($passed -eq $total) { "Green" } else { "Yellow" })
}

# ==============================================================================
# PowerShell Modules
# ==============================================================================
function Install-PsModules {
    Write-Section "PowerShell Modules"

    $modules = @("PSReadLine", "PSFzf", "Terminal-Icons")
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
# Main
# ==============================================================================
function Main {
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

    # Step 1: Scoop
    if (-not $SkipPackages) {
        Write-Section "Package Manager"
        Install-Scoop
        Install-ScoopPackages
    }
    else {
        Write-Step "Skipping package installation (-SkipPackages)"
    }

    # Step 2: Symlinks
    if (-not $SkipSymlinks) {
        Install-Symlinks
    }
    else {
        Write-Step "Skipping symlink creation (-SkipSymlinks)"
    }

    # Step 3: PowerShell modules
    if (-not $SkipPackages) {
        Install-PsModules
    }

    # Step 4: Neovim
    Install-NeovimPlugins
    Install-GuiConfig

    # Step 5: Health check
    Test-Installation

    Write-Banner "Setup Complete!"
    Write-Host "  Next steps:" -ForegroundColor Cyan
    Write-Host "    1. Open a new terminal to pick up PATH changes"
    Write-Host "    2. Run 'nvim' to install plugins (lazy.nvim will bootstrap)"
    Write-Host "    3. Inside nvim, run ':checkhealth' to verify"
    Write-Host "    4. Install a Nerd Font in your terminal (JetBrainsMono NF recommended)"
    Write-Host "    5. Reload your PowerShell profile: . `$PROFILE"
    Write-Host ""
}

Main
