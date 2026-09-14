#
#  ▓▓▓▓▓▓▓▓▓▓
# ░▓ author ▓ Akash Goyal
# ░▓ file   ▓ powershell/Documents/PowerShell/profile.d/30-python.ps1
# ░▓▓▓▓▓▓▓▓▓▓
#
# uv: Python virtual environment management. Mirrors mkvenv/rmvenv/venv in
# zsh/.config/zsh/conf.d/08-python.zsh - same names, defaults, and behavior, so
# the workflow in docs/PYTHON.md is identical on every platform. mise (20-tools)
# still decides which Python interpreter uv uses.

$VENV_DEFAULT_DIR = '.venv'

# uv lays venvs out per-OS: Scripts\Activate.ps1 on native Windows, but
# bin/activate.ps1 (lowercase) when uv itself runs on macOS/Linux - which
# happens if you're using PowerShell 7+ there instead of zsh. Check both so
# this works regardless of which OS is actually running the script.
function _venvActivateScript {
    param([string]$EnvDir)
    $winStyle = Join-Path $EnvDir 'Scripts' 'Activate.ps1'
    $posixStyle = Join-Path $EnvDir 'bin' 'activate.ps1'
    if (Test-Path $winStyle) { return $winStyle }
    if (Test-Path $posixStyle) { return $posixStyle }
    return $null
}

function mkvenv {
    param(
        [string]$EnvDir = $VENV_DEFAULT_DIR,
        [string]$PyVersion
    )

    if (-not (_cmd uv)) { Write-Error "uv is not installed (see docs/PYTHON.md)"; return }
    if (Test-Path $EnvDir) { Write-Error "Environment '$EnvDir' already exists"; return }

    Write-Host "Creating new virtual environment '$EnvDir'..."
    if ($PyVersion) { uv venv --python $PyVersion $EnvDir } else { uv venv $EnvDir }
    if ($LASTEXITCODE -ne 0) { Write-Error "Failed to create virtual environment '$EnvDir'."; return }

    $activateScript = _venvActivateScript $EnvDir
    if (-not $activateScript) {
        Write-Error "Failed to activate virtual environment '$EnvDir'. Activation script not found."
        return
    }
    . $activateScript

    Write-Host 'Virtual environment created and activated successfully'
    Write-Host "Location: $(Join-Path (Get-Location) $EnvDir)"
    Write-Host "Python version: $(python --version)"
    Write-Host 'Install packages with: uv pip install <package>'
}

function rmvenv {
    param([string]$EnvDir = $VENV_DEFAULT_DIR)

    if (-not (Test-Path $EnvDir)) { Write-Error "Environment '$EnvDir' does not exist"; return }

    $fullPath = (Resolve-Path $EnvDir -ErrorAction SilentlyContinue).Path
    if ($env:VIRTUAL_ENV -eq $fullPath) { deactivate }

    Remove-Item -Recurse -Force $EnvDir
    Write-Host "Removed virtual environment: $EnvDir"
}

function venv {
    param([string]$EnvDir = $VENV_DEFAULT_DIR)

    if (-not (Test-Path $EnvDir)) { Write-Error "Environment '$EnvDir' does not exist"; return }

    $activateScript = _venvActivateScript $EnvDir
    if (-not $activateScript) { Write-Error 'Failed to activate virtual environment'; return }
    . $activateScript

    Write-Host "Activated virtual environment: $EnvDir"
    Write-Host "Python version: $(python --version)"
}
