<#
  user\installer.ps1
  - Animated ASCII welcome
  - System info
  - License prompt with realtime validation
  - Multi-layer license storage (AppData JSON, HKCU, ProgramData backup)
  - Secure GitHub download (supports Base64 or plain URL)
  - Silent install support (/SILENT)
  - Cleanup and post-install instructions
#>

param([switch]$SILENT)

# Config
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
if (-not $ScriptDir) { $ScriptDir = (Get-Location).Path }
$AssetsDir = Join-Path $ScriptDir '..\assets'
$AsciiFile = Join-Path $AssetsDir 'ascii-art.txt'
$ConfigFile = Join-Path $AssetsDir 'config.json'
$AppDataDir = Join-Path $env:APPDATA 'SEB'
$JsonPath = Join-Path $AppDataDir 'license.json'
$RegPath = 'HKCU:\Software\SEB'
$BackupPath = 'C:\ProgramData\SEB\license.txt'
$LogDir = Join-Path $AppDataDir 'logs'
$LogPath = Join-Path $LogDir 'installer.log'

function Write-Log {
  param([string]$Message, [string]$Level='INFO')
  try {
    if (-not (Test-Path $LogDir)) { New-Item -ItemType Directory -Path $LogDir -Force | Out-Null }
    $ts = (Get-Date).ToString('yyyy-MM-dd HH:mm:ss')
    "$ts [$Level] $Message" | Out-File -FilePath $LogPath -Append -Encoding UTF8 -ErrorAction SilentlyContinue
    # rotate logs older than 7 days
    Get-ChildItem -Path $LogDir -Filter '*.log' -ErrorAction SilentlyContinue | Where-Object { $_.LastWriteTime -lt (Get-Date).AddDays(-7) } | Remove-Item -Force -ErrorAction SilentlyContinue
  } catch {}
}

function Show-Ascii {
  param([int]$speedMs = 6)
  if (Test-Path $AsciiFile) {
    try {
      Get-Content $AsciiFile | ForEach-Object {
        foreach ($c in $_.ToCharArray()) {
          Write-Host -NoNewline $c
          Start-Sleep -Milliseconds $speedMs
        }
        Write-Host ''
      }
    } catch { Write-Log "ASCII display failed: $_" 'WARN' }
  } else {
    Write-Host "SEB Installer" -ForegroundColor Cyan
  }
}

function Show-SystemInfo {
  try {
    $os = Get-CimInstance -ClassName Win32_OperatingSystem -ErrorAction SilentlyContinue
    $cpu = Get-CimInstance -ClassName Win32_Processor -ErrorAction SilentlyContinue | Select-Object -First 1
    Write-Host "Computer: $env:COMPUTERNAME" -ForegroundColor Yellow
    Write-Host "User: $env:USERNAME" -ForegroundColor Yellow
    if ($os) { Write-Host "OS: $($os.Caption) $($os.OSArchitecture)" -ForegroundColor Yellow }
    if ($cpu) { Write-Host "CPU: $($cpu.Name)" -ForegroundColor Yellow }
  } catch {
    Write-Log "System info failed: $_" 'WARN'
  }
}

function Compute-Checksum {
  param([string]$key)
  $sum = 0
  foreach ($c in $key.ToCharArray()) { $sum += [int][char]$c }
  return $sum % 13
}

function Validate-LicenseFormat {
  param([string]$key)
  return $key -match '^[A-Z0-9]{4}-[A-Z0-9]{4}-[A-Z0-9]{4}-[A-Z0-9]{4}$'
}

function Validate-License {
  param([string]$key)
  if (-not (Validate-LicenseFormat -key $key)) { return $false }
  return (Compute-Checksum -key $key) -eq 7
}

function Save-LicenseMulti {
  param([string]$key)
  try {
    if (-not (Test-Path $AppDataDir)) { New-Item -ItemType Directory -Path $AppDataDir -Force | Out-Null }
    $payload = @{ license = $key; saved = (Get-Date).ToString('s') } | ConvertTo-Json
    $payload | Out-File -FilePath $JsonPath -Encoding UTF8 -Force

    if (-not (Test-Path $RegPath)) { New-Item -Path $RegPath -Force | Out-Null }
    Set-ItemProperty -Path $RegPath -Name License -Value $key -Force

    try {
      $backupDir = Split-Path $BackupPath
      if (-not (Test-Path $backupDir)) { New-Item -ItemType Directory -Path $backupDir -Force | Out-Null }
      $key | Out-File -FilePath $BackupPath -Encoding ASCII -Force
      (Get-Item $BackupPath).Attributes = 'Hidden'
    } catch {
      Write-Log "ProgramData backup failed, will continue: $_" 'WARN'
    }

    Write-Log "Saved license to JSON, Registry, Backup (if possible)"
    return $true
  } catch {
    Write-Log "Save-LicenseMulti failed: $_" 'ERROR'
    return $false
  }
}

function Decode-GitHubUrl {
  param([string]$b64)
  try {
    $bytes = [System.Convert]::FromBase64String($b64)
    return [System.Text.Encoding]::UTF8.GetString($bytes)
  } catch {
    Write-Log "Base64 decode failed: $_" 'ERROR'
    throw
  }
}

function Download-FromUrl {
  param([string]$url, [string]$outFile)
  try {
    Write-Host "Downloading package..." -ForegroundColor Cyan
    $wc = New-Object System.Net.WebClient
    $wc.Headers.Add('User-Agent','SEB-Installer')
    $downloadComplete = $false
    $wc.DownloadProgressChanged += {
      param($s,$e)
      Write-Host -NoNewline "`rProgress: $($e.ProgressPercentage)% "
    }
    $wc.DownloadFileAsync([Uri]$url, $outFile)
    while ($wc.IsBusy) { Start-Sleep -Milliseconds 200 }
    Write-Host "`rProgress: 100% "
    Write-Log "Downloaded $url to $outFile"
    return $true
  } catch {
    Write-Log "Download failed: $_" 'ERROR'
    return $false
  }
}

function Run-Installer {
  param([string]$installerPath, [switch]$Silent)
  try {
    if ($Silent) {
      Start-Process -FilePath (Get-Command powershell).Source -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$installerPath`" -SILENT" -Wait -NoNewWindow
    } else {
      Start-Process -FilePath (Get-Command powershell).Source -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$installerPath`"" -Wait
    }
    Write-Log "Installer executed: $installerPath (Silent=$Silent)"
    return $true
  } catch {
    Write-Log "Run-Installer failed: $_" 'ERROR'
    return $false
  }
}

function Cleanup-Temp {
  param([string]$path)
  try {
    if (Test-Path $path) { Remove-Item -Path $path -Recurse -Force -ErrorAction SilentlyContinue }
    Write-Log "Cleaned temp: $path"
  } catch { Write-Log "Cleanup failed: $_" 'WARN' }
}

# Main flow
try {
  Show-Ascii -speedMs 6
  Show-SystemInfo

  do {
    $inputKey = Read-Host "Enter license key (format XXXX-XXXX-XXXX-XXXX)"
    $inputKey = $inputKey.Trim().ToUpper()
    if (-not (Validate-LicenseFormat -key $inputKey)) {
      Write-Host "Invalid format. Use A-Z and 0-9 with dashes." -ForegroundColor Red
      $valid = $false
      continue
    }
    if (-not (Validate-License -key $inputKey)) {
      Write-Host "Checksum invalid." -ForegroundColor Red
      $valid = $false
      continue
    }
    $valid = $true
  } until ($valid)

  if (-not (Save-LicenseMulti -key $inputKey)) {
    Write-Host "Failed to save license to all locations. Check logs." -ForegroundColor Red
    exit 1
  }

  # Read config: supports either github_b64 or github_url
  $url = $null
  if (Test-Path $ConfigFile) {
    try {
      $cfg = Get-Content $ConfigFile -Raw | ConvertFrom-Json
      if ($cfg.github_b64) { $url = Decode-GitHubUrl -b64 $cfg.github_b64 }
      elseif ($cfg.github_url) { $url = $cfg.github_url }
    } catch { Write-Log "Config read failed: $_" 'WARN' }
  }

  if ($url) {
    $tmp = Join-Path $env:TEMP ('seb_installer_' + [guid]::NewGuid().ToString() + '.ps1')
    if (Download-FromUrl -url $url -outFile $tmp) {
      $installed = Run-Installer -installerPath $tmp -Silent:$SILENT
      Cleanup-Temp -path $tmp
      if ($installed) {
        Write-Host "Installation completed successfully." -ForegroundColor Green
        Write-Host "Next steps: Launch the app via launcher.ps1 or Start Menu." -ForegroundColor Yellow
        exit 0
      } else {
        Write-Host "Installer failed. Check logs." -ForegroundColor Red
        exit 2
      }
    } else {
      Write-Host "Download failed. Check network or logs." -ForegroundColor Red
      exit 3
    }
  } else {
    Write-Host "No download URL configured. License saved." -ForegroundColor Green
    exit 0
  }
} catch {
  Write-Log "Unhandled installer error: $_" 'ERROR'
  Write-Host "An unexpected error occurred. See log: $LogPath" -ForegroundColor Red
  exit 99
}