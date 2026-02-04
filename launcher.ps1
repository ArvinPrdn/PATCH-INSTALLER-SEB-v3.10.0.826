<#
  user\launcher.ps1
  - Read license from JSON -> Registry -> Backup file
  - Validate format & checksum
  - Launch application if valid
  - Show support contact if invalid
#>

# Config
$AppDataDir = Join-Path $env:APPDATA 'SEB'
$JsonPath = Join-Path $AppDataDir 'license.json'
$RegPath = 'HKCU:\Software\SEB'
$BackupPath = 'C:\ProgramData\SEB\license.txt'
$LogPath = Join-Path $AppDataDir 'logs\launcher.log'
$SupportContact = 'support@seb-software.example'  # change to real support

function Write-Log {
  param([string]$Message, [string]$Level='INFO')
  try {
    $dir = Split-Path $LogPath
    if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
    "$((Get-Date).ToString('s')) [$Level] $Message" | Out-File -FilePath $LogPath -Append -Encoding UTF8 -ErrorAction SilentlyContinue
  } catch {}
}

function Compute-Checksum {
  param([string]$key)
  $sum = 0
  foreach ($c in $key.ToCharArray()) { $sum += [int][char]$c }
  return $sum % 13
}

function Validate-License {
  param([string]$key)
  if ($null -eq $key) { return $false }
  if ($key -notmatch '^[A-Z0-9]{4}-[A-Z0-9]{4}-[A-Z0-9]{4}-[A-Z0-9]{4}$') { return $false }
  return (Compute-Checksum -key $key) -eq 7
}

function Read-License {
  try {
    if (Test-Path $JsonPath) {
      try {
        $j = Get-Content $JsonPath -Raw | ConvertFrom-Json
        if ($j.license) { Write-Log "License read from JSON"; return $j.license }
      } catch { Write-Log "JSON read error: $_" 'WARN' }
    }
    if (Test-Path $RegPath) {
      try {
        $val = Get-ItemProperty -Path $RegPath -Name License -ErrorAction SilentlyContinue
        if ($val -and $val.License) { Write-Log "License read from Registry"; return $val.License }
      } catch { Write-Log "Registry read error: $_" 'WARN' }
    }
    if (Test-Path $BackupPath) {
      try {
        $txt = Get-Content $BackupPath -ErrorAction SilentlyContinue
        if ($txt) { Write-Log "License read from Backup file"; return $txt.Trim() }
      } catch { Write-Log "Backup read error: $_" 'WARN' }
    }
    return $null
  } catch {
    Write-Log "Read-License failed: $_" 'ERROR'
    return $null
  }
}

# Launch logic
try {
  $license = Read-License
  if (-not (Validate-License -key $license)) {
    Write-Host "License invalid or not found." -ForegroundColor Red
    Write-Host "Please run the installer or contact support: $SupportContact" -ForegroundColor Yellow
    Write-Log "Invalid license: $license" 'WARN'
    exit 1
  }

  Write-Host "License valid. Launching application..." -ForegroundColor Green
  Write-Log "Valid license: $license"

  # Replace with actual installed exe path
  $appExe = Join-Path $env:ProgramFiles 'SEB\SEBApp.exe'
  if (-not (Test-Path $appExe)) {
    Write-Host "Application not found. Ensure installation completed." -ForegroundColor Red
    Write-Log "App exe not found: $appExe" 'ERROR'
    exit 2
  }

  try {
    Start-Process -FilePath $appExe
    Write-Log "Application started: $appExe"
    exit 0
  } catch {
    Write-Log "Failed to start app: $_" 'ERROR'
    Write-Host "Failed to start application. Check logs." -ForegroundColor Red
    exit 3
  }
} catch {
  Write-Log "Unhandled launcher error: $_" 'ERROR'
  Write-Host "An unexpected error occurred. See log." -ForegroundColor Red
  exit 99
}