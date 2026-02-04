<#
  user\uninstaller.ps1
  - Clean uninstall: remove files, license data, registry entries, shortcuts
  - Confirmation prompt
#>

# Config
$AppDataDir = Join-Path $env:APPDATA 'SEB'
$JsonPath = Join-Path $AppDataDir 'license.json'
$RegPath = 'HKCU:\Software\SEB'
$BackupPath = 'C:\ProgramData\SEB\license.txt'
$InstallDir = Join-Path $env:ProgramFiles 'SEB'
$LogPath = Join-Path $AppDataDir 'logs\uninstaller.log'

function Write-Log {
  param([string]$Message, [string]$Level='INFO')
  try {
    $dir = Split-Path $LogPath
    if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
    "$((Get-Date).ToString('s')) [$Level] $Message" | Out-File -FilePath $LogPath -Append -Encoding UTF8 -ErrorAction SilentlyContinue
  } catch {}
}

function Confirm-Action {
  param([string]$Message)
  $resp = Read-Host "$Message (Y/N)"
  return $resp.Trim().ToUpper() -eq 'Y'
}

function Remove-IfExists {
  param([string]$path)
  try {
    if (Test-Path $path) {
      Remove-Item -Path $path -Recurse -Force -ErrorAction Stop
      Write-Log "Removed: $path"
    } else {
      Write-Log "Not found (skip): $path"
    }
  } catch {
    Write-Log "Failed to remove $path: $_" 'ERROR'
  }
}

function Remove-RegistryKey {
  param([string]$key)
  try {
    if (Test-Path $key) {
      Remove-Item -Path $key -Recurse -Force -ErrorAction Stop
      Write-Log "Removed registry key: $key"
    } else {
      Write-Log "Registry key not found: $key"
    }
  } catch {
    Write-Log "Failed to remove registry key $key: $_" 'ERROR'
  }
}

# Main
try {
  Write-Host "SEB Uninstaller" -ForegroundColor Cyan
  if (-not (Confirm-Action -Message "Are you sure you want to uninstall SEB and remove all data?")) {
    Write-Host "Aborted." -ForegroundColor Yellow
    exit 0
  }

  try {
    Get-Process -Name 'SEBApp' -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
    Write-Log "Stopped SEBApp processes if any."
  } catch { Write-Log "Stop process failed: $_" 'WARN' }

  Remove-IfExists -path $InstallDir
  Remove-IfExists -path $AppDataDir
  Remove-IfExists -path $BackupPath
  Remove-RegistryKey -key $RegPath

  $startMenu = Join-Path $env:APPDATA 'Microsoft\Windows\Start Menu\Programs\SEB'
  Remove-IfExists -path $startMenu
  $desktopShortcut = Join-Path ([Environment]::GetFolderPath('Desktop')) 'SEB.lnk'
  Remove-IfExists -path $desktopShortcut

  Write-Host "Uninstall completed." -ForegroundColor Green
  Write-Log "Uninstall completed successfully."
  exit 0
} catch {
  Write-Log "Unhandled uninstaller error: $_" 'ERROR'
  Write-Host "An error occurred during uninstall. Check log: $LogPath" -ForegroundColor Red
  exit 1
}