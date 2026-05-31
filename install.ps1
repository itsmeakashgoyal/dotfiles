#  ▓▓▓▓▓▓▓▓▓▓
# ░▓ author ▓ Akash Goyal
# ░▓ file   ▓ install.ps1
# ░▓▓▓▓▓▓▓▓▓▓
#
# Windows installer entry point — equivalent to install.sh for macOS/Linux.
#
# Usage (run in PowerShell as Administrator or with Developer Mode enabled):
#   Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
#   .\install.ps1
#
# Or one-liner from a fresh machine:
#   irm https://raw.githubusercontent.com/itsmeakashgoyal/dotfiles/master/install.ps1 | iex

#Requires -Version 5.1

param(
    [switch]$Force,
    [switch]$SkipPackages,
    [switch]$SkipSymlinks
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$DOTFILES_DIR = "$env:USERPROFILE\dotfiles"
$REPO_URL = "https://github.com/itsmeakashgoyal/dotfiles.git"

# ==============================================================================
# Logging
# ==============================================================================
function Write-Banner {
    param([string]$Message)
    Write-Host ""
    Write-Host "====================================================" -ForegroundColor Green
    Write-Host " $Message" -ForegroundColor Green
    Write-Host "====================================================" -ForegroundColor Green
    Write-Host ""
}

function Write-Step {
    param([string]$Step, [string]$Message)
    Write-Host "[$Step] " -NoNewline -ForegroundColor Blue
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

# ==============================================================================
# Prerequisites
# ==============================================================================
function Test-Prerequisites {
    Write-Step "1/5" "Checking prerequisites..."

    # Check for git
    if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
        Write-Fail "Git is not installed."
        Write-Host "  Install git first: winget install Git.Git" -ForegroundColor Yellow
        exit 1
    }
    Write-Ok "Git found: $(git --version)"

    # Check Developer Mode or Admin
    $isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(
        [Security.Principal.WindowsBuiltInRole]::Administrator
    )
    $devMode = $false
    try {
        $regPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock"
        $devMode = (Get-ItemProperty -Path $regPath -Name AllowDevelopmentWithoutDevLicense -ErrorAction SilentlyContinue).AllowDevelopmentWithoutDevLicense -eq 1
    }
    catch {}

    if ($isAdmin) {
        Write-Ok "Running as Administrator"
    }
    elseif ($devMode) {
        Write-Ok "Developer Mode enabled (symlinks OK without admin)"
    }
    else {
        Write-Host ""
        Write-Host "  WARNING: Neither Admin nor Developer Mode detected." -ForegroundColor Yellow
        Write-Host "  Symlinks may fail. Enable Developer Mode:" -ForegroundColor Yellow
        Write-Host "    Settings → System → For Developers → Developer Mode" -ForegroundColor Yellow
        Write-Host ""
    }

    Write-Ok "Prerequisites OK"
}

# ==============================================================================
# Clone/Update Dotfiles
# ==============================================================================
function Get-Dotfiles {
    Write-Step "2/5" "Setting up dotfiles repository..."

    if (Test-Path (Join-Path $DOTFILES_DIR ".git")) {
        Write-Ok "Dotfiles already cloned at $DOTFILES_DIR"
        Write-Host "  Pulling latest changes..." -ForegroundColor Yellow
        Push-Location $DOTFILES_DIR
        git pull --rebase 2>$null
        Pop-Location
        Write-Ok "Updated to latest"
    }
    elseif (Test-Path $DOTFILES_DIR) {
        Write-Fail "$DOTFILES_DIR exists but is not a git repo"
        if ($Force) {
            $backupPath = "$DOTFILES_DIR.backup.$(Get-Date -Format 'yyyyMMddHHmmss')"
            Write-Host "  Backing up to $backupPath" -ForegroundColor Yellow
            Move-Item $DOTFILES_DIR $backupPath
            git clone $REPO_URL $DOTFILES_DIR
            Write-Ok "Cloned fresh copy"
        }
        else {
            Write-Host "  Use -Force to backup and re-clone" -ForegroundColor Yellow
            exit 1
        }
    }
    else {
        Write-Host "  Cloning $REPO_URL..." -ForegroundColor Yellow
        git clone $REPO_URL $DOTFILES_DIR
        Write-Ok "Cloned to $DOTFILES_DIR"
    }
}

# ==============================================================================
# Main
# ==============================================================================
function Main {
    Write-Banner "Dotfiles Windows Installer"
    Write-Host "  Platform: Windows $([System.Environment]::OSVersion.Version)" -ForegroundColor Cyan
    Write-Host "  User:     $env:USERNAME" -ForegroundColor Cyan
    Write-Host ""

    # Step 1: Prerequisites
    Test-Prerequisites

    # Step 2: Clone/update repo
    Get-Dotfiles

    # Step 3-5: Delegate to setup script
    Write-Step "3/5" "Running Windows setup..."
    $setupScript = Join-Path $DOTFILES_DIR "scripts\setup\windows.ps1"

    if (-not (Test-Path $setupScript)) {
        Write-Fail "Setup script not found: $setupScript"
        exit 1
    }

    $params = @{}
    if ($Force) { $params["Force"] = $true }
    if ($SkipPackages) { $params["SkipPackages"] = $true }
    if ($SkipSymlinks) { $params["SkipSymlinks"] = $true }

    & $setupScript @params

    Write-Step "5/5" "Done!"
}

Main
