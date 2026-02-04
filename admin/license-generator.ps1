<#
  admin\license-generator.ps1
  - Generate single or bulk licenses
  - Validate format & checksum
  - Manage customer-database.csv
  - Export / Search / Mark status
  - PowerShell 5.1+ (no admin required)
#>

# Config
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
if (-not $ScriptDir) { $ScriptDir = (Get-Location).Path }
$DatabasePath = Join-Path $ScriptDir 'customer-database.csv'
$LogPath = Join-Path $ScriptDir 'license-generator.log'

function Write-Log {
  param([string]$Message, [string]$Level = 'INFO')
  try {
    $ts = (Get-Date).ToString('yyyy-MM-dd HH:mm:ss')
    "$ts [$Level] $Message" | Out-File -FilePath $LogPath -Append -Encoding UTF8 -ErrorAction SilentlyContinue
  } catch {}
}

function Compute-Checksum {
  param([string]$key)
  $sum = 0
  foreach ($c in $key.ToCharArray()) { $sum += [int][char]$c }
  return $sum % 13
}

function Is-ValidFormat {
  param([string]$key)
  return $key -match '^[A-Z0-9]{4}-[A-Z0-9]{4}-[A-Z0-9]{4}-[A-Z0-9]{4}$'
}

function Is-ValidLicense {
  param([string]$key)
  if (-not (Is-ValidFormat -key $key)) { return $false }
  return (Compute-Checksum -key $key) -eq 7
}

function Get-RandomChar {
  param([string]$chars)
  return $chars[(Get-Random -Maximum $chars.Length)]
}

function New-LicenseKey {
  param([int]$attemptLimit = 20000)
  $chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'
  for ($i = 0; $i -lt $attemptLimit; $i++) {
    $raw = -join (1..16 | ForEach-Object { Get-RandomChar -chars $chars })
    $key = $raw.Substring(0,4) + '-' + $raw.Substring(4,4) + '-' + $raw.Substring(8,4) + '-' + $raw.Substring(12,4)
    if ((Compute-Checksum -key $key) -eq 7) { return $key }
  }
  throw "Failed to generate license within attempt limit."
}

function Ensure-Database {
  if (-not (Test-Path $DatabasePath)) {
    try {
      "Customer,Email,License,Status,CreatedOn,Notes" | Out-File -FilePath $DatabasePath -Encoding UTF8
    } catch {
      Write-Log "Failed to create database: $_" 'ERROR'
      throw
    }
  }
}

function Add-LicenseRecord {
  param(
    [string]$Customer,
    [string]$Email = '',
    [string]$License,
    [string]$Status = 'Active',
    [string]$Notes = ''
  )
  Ensure-Database
  $line = '"{0}","{1}","{2}","{3}","{4}","{5}"' -f $Customer, $Email, $License, $Status, (Get-Date).ToString('s'), $Notes
  try {
    Add-Content -Path $DatabasePath -Value $line -Encoding UTF8
    Write-Log "Added license $License for $Customer"
  } catch {
    Write-Log "Failed to add record: $_" 'ERROR'
    throw
  }
}

function New-LicensesFromCsv {
  param([string]$InputCsv)
  try {
    $rows = Import-Csv -Path $InputCsv -ErrorAction Stop
  } catch {
    Write-Log "Failed to read bulk CSV: $_" 'ERROR'
    throw
  }
  foreach ($r in $rows) {
    $license = New-LicenseKey
    Add-LicenseRecord -Customer $r.Customer -Email $r.Email -License $license -Notes $r.Notes
    Write-Host "Generated: $license for $($r.Customer)" -ForegroundColor Green
  }
}

function Get-LicenseRecord {
  param([string]$Query)
  Ensure-Database
  try {
    Import-Csv -Path $DatabasePath | Where-Object {
      $_.Customer -like "*$Query*" -or $_.Email -like "*$Query*" -or $_.License -like "*$Query*"
    }
  } catch {
    Write-Log "Search failed: $_" 'ERROR'
    throw
  }
}

function Export-Database {
  param([ValidateSet('CSV','JSON','HTML')] [string]$Format, [string]$OutPath)
  Ensure-Database
  $data = Import-Csv -Path $DatabasePath
  try {
    switch ($Format) {
      'CSV'  { $data | Export-Csv -Path $OutPath -NoTypeInformation -Force }
      'JSON' { $data | ConvertTo-Json -Depth 3 | Out-File -FilePath $OutPath -Encoding UTF8 -Force }
      'HTML' { $data | ConvertTo-Html -Title 'SEB License Database' | Out-File -FilePath $OutPath -Encoding UTF8 -Force }
    }
    Write-Log "Exported database to $OutPath"
  } catch {
    Write-Log "Export failed: $_" 'ERROR'
    throw
  }
}

function Set-LicenseStatus {
  param([string]$LicenseKey, [ValidateSet('Active','Expired','Revoked')] [string]$Status)
  Ensure-Database
  try {
    $tmp = [IO.Path]::GetTempFileName()
    Import-Csv -Path $DatabasePath | ForEach-Object {
      if ($_.License -eq $LicenseKey) { $_.Status = $Status }
      $_
    } | Export-Csv -Path $tmp -NoTypeInformation
    Move-Item -Path $tmp -Destination $DatabasePath -Force
    Write-Log "Set $LicenseKey => $Status"
  } catch {
    Write-Log "Failed to set status: $_" 'ERROR'
    throw
  }
}

function Show-Menu {
  Write-Host "SEB License Generator - Admin" -ForegroundColor Cyan
  Write-Host "1) Generate single license"
  Write-Host "2) Generate bulk from CSV"
  Write-Host "3) Search license"
  Write-Host "4) Export database"
  Write-Host "5) Mark license status"
  Write-Host "Q) Quit"
  $choice = Read-Host "Choose"
  switch ($choice.ToUpper()) {
    '1' {
      $cust = Read-Host "Customer name"
      $email = Read-Host "Email (optional)"
      $lic = New-LicenseKey
      Add-LicenseRecord -Customer $cust -Email $email -License $lic
      Write-Host "License: $lic" -ForegroundColor Green
    }
    '2' {
      $path = Read-Host "Path to CSV (Customer,Email,Notes)"
      New-LicensesFromCsv -InputCsv $path
    }
    '3' {
      $q = Read-Host "Search term (customer/email/license)"
      Get-LicenseRecord -Query $q | Format-Table -AutoSize
    }
    '4' {
      $fmt = Read-Host "Format (CSV/JSON/HTML)"
      $out = Read-Host "Output path"
      Export-Database -Format $fmt -OutPath $out
      Write-Host "Exported to $out" -ForegroundColor Green
    }
    '5' {
      $lic = Read-Host "License key"
      $st = Read-Host "Status (Active/Expired/Revoked)"
      Set-LicenseStatus -LicenseKey $lic -Status $st
      Write-Host "Updated" -ForegroundColor Green
    }
    default { Write-Host "Bye." -ForegroundColor Yellow }
  }
}

try {
  Ensure-Database
  Show-Menu
} catch {
  Write-Log "Unhandled error: $_" 'ERROR'
  Write-Host "An error occurred. Check log: $LogPath" -ForegroundColor Red
}