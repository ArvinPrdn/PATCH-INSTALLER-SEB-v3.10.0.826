<#
  admin\license-manager.ps1
  - Manage license database (customer-database.csv)
  - Features: view, search, import, export, set status, validate, revoke, backup, restore
  - PowerShell 5.1+; no admin required
#>

# --- Config
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
if (-not $ScriptDir) { $ScriptDir = (Get-Location).Path }
$DatabasePath = Join-Path $ScriptDir 'customer-database.csv'
$LogPath = Join-Path $ScriptDir 'license-manager.log'
$BackupDir = Join-Path $ScriptDir 'backups'
if (-not (Test-Path $BackupDir)) { New-Item -Path $BackupDir -ItemType Directory -Force | Out-Null }

function Write-Log {
  param([string]$Message, [string]$Level = 'INFO')
  try {
    $ts = (Get-Date).ToString('yyyy-MM-dd HH:mm:ss')
    "$ts [$Level] $Message" | Out-File -FilePath $LogPath -Append -Encoding UTF8 -ErrorAction SilentlyContinue
  } catch {}
}

# --- Utilities
function Ensure-Database {
  if (-not (Test-Path $DatabasePath)) {
    try {
      "Customer,Email,License,Status,CreatedOn,Notes" | Out-File -FilePath $DatabasePath -Encoding UTF8
      Write-Log "Created new database file at $DatabasePath"
    } catch {
      Write-Log "Failed to create database: $_" 'ERROR'
      throw
    }
  }
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

# --- Core operations
function Get-AllRecords {
  Ensure-Database
  try {
    return Import-Csv -Path $DatabasePath -ErrorAction Stop
  } catch {
    Write-Log "Failed to read database: $_" 'ERROR'
    throw
  }
}

function Show-All {
  try {
    $rows = Get-AllRecords
    if ($rows.Count -eq 0) {
      Write-Host "Database is empty." -ForegroundColor Yellow
      return
    }
    $rows | Format-Table -AutoSize
  } catch {
    Write-Log "Show-All failed: $_" 'ERROR'
    Write-Host "Error reading database. See log." -ForegroundColor Red
  }
}

function Search-Records {
  param([string]$Query)
  try {
    $rows = Get-AllRecords | Where-Object {
      $_.Customer -like "*$Query*" -or $_.Email -like "*$Query*" -or $_.License -like "*$Query*" -or $_.Status -like "*$Query*"
    }
    if ($rows.Count -eq 0) {
      Write-Host "No matches for '$Query'." -ForegroundColor Yellow
      return
    }
    $rows | Format-Table -AutoSize
  } catch {
    Write-Log "Search failed: $_" 'ERROR'
    Write-Host "Search error. See log." -ForegroundColor Red
  }
}

function Add-Record {
  param(
    [Parameter(Mandatory=$true)][string]$Customer,
    [string]$Email = '',
    [Parameter(Mandatory=$true)][string]$License,
    [string]$Status = 'Active',
    [string]$Notes = ''
  )
  Ensure-Database
  try {
    if (-not (Is-ValidFormat -key $License)) {
      throw "License format invalid."
    }
    $valid = Is-ValidLicense -key $License
    $created = (Get-Date).ToString('s')
    $line = '"{0}","{1}","{2}","{3}","{4}","{5}"' -f $Customer, $Email, $License, $Status, $created, $Notes
    Add-Content -Path $DatabasePath -Value $line -Encoding UTF8
    Write-Log "Added record: $License for $Customer (ChecksumValid=$valid)"
    Write-Host "Record added. Checksum valid: $valid" -ForegroundColor Green
  } catch {
    Write-Log "Add-Record failed: $_" 'ERROR'
    Write-Host "Failed to add record: $($_.Exception.Message)" -ForegroundColor Red
  }
}

function Import-FromCsv {
  param([Parameter(Mandatory=$true)][string]$Path)
  Ensure-Database
  try {
    $rows = Import-Csv -Path $Path -ErrorAction Stop
    foreach ($r in $rows) {
      $cust = $r.Customer
      $email = $r.Email
      $lic = $r.License
      $notes = if ($r.Notes) { $r.Notes } else { '' }
      if (-not $lic) { Write-Log "Skipping row without License: $($r | Out-String)" ; continue }
      Add-Record -Customer $cust -Email $email -License $lic -Notes $notes
    }
    Write-Host "Import completed." -ForegroundColor Green
  } catch {
    Write-Log "Import failed: $_" 'ERROR'
    Write-Host "Import error. See log." -ForegroundColor Red
  }
}

function Set-Status {
  param([Parameter(Mandatory=$true)][string]$LicenseKey, [ValidateSet('Active','Expired','Revoked')] [string]$Status)
  Ensure-Database
  try {
    $tmp = [IO.Path]::GetTempFileName()
    Import-Csv -Path $DatabasePath | ForEach-Object {
      if ($_.License -eq $LicenseKey) { $_.Status = $Status }
      $_
    } | Export-Csv -Path $tmp -NoTypeInformation -Encoding UTF8
    Move-Item -Path $tmp -Destination $DatabasePath -Force
    Write-Log "Set status $LicenseKey => $Status"
    Write-Host "Status updated." -ForegroundColor Green
  } catch {
    Write-Log "Set-Status failed: $_" 'ERROR'
    Write-Host "Failed to update status. See log." -ForegroundColor Red
  }
}

function Validate-All {
  try {
    $rows = Get-AllRecords
    $report = @()
    foreach ($r in $rows) {
      $ok = Is-ValidLicense -key $r.License
      $report += [PSCustomObject]@{
        Customer = $r.Customer
        License  = $r.License
        Status   = $r.Status
        ChecksumValid = $ok
      }
    }
    $report | Format-Table -AutoSize
  } catch {
    Write-Log "Validate-All failed: $_" 'ERROR'
    Write-Host "Validation error. See log." -ForegroundColor Red
  }
}

function Export-Database {
  param([ValidateSet('CSV','JSON','HTML')] [string]$Format, [Parameter(Mandatory=$true)][string]$OutPath)
  Ensure-Database
  try {
    $data = Import-Csv -Path $DatabasePath
    switch ($Format) {
      'CSV'  { $data | Export-Csv -Path $OutPath -NoTypeInformation -Force -Encoding UTF8 }
      'JSON' { $data | ConvertTo-Json -Depth 3 | Out-File -FilePath $OutPath -Encoding UTF8 -Force }
      'HTML' { $data | ConvertTo-Html -Title 'SEB License Database' | Out-File -FilePath $OutPath -Encoding UTF8 -Force }
    }
    Write-Log "Exported database to $OutPath as $Format"
    Write-Host "Exported to $OutPath" -ForegroundColor Green
  } catch {
    Write-Log "Export failed: $_" 'ERROR'
    Write-Host "Export error. See log." -ForegroundColor Red
  }
}

function Backup-Database {
  try {
    Ensure-Database
    $ts = (Get-Date).ToString('yyyyMMdd_HHmmss')
    $dest = Join-Path $BackupDir ("customer-database_$ts.csv")
    Copy-Item -Path $DatabasePath -Destination $dest -Force
    Write-Log "Backup created: $dest"
    Write-Host "Backup created: $dest" -ForegroundColor Green
  } catch {
    Write-Log "Backup failed: $_" 'ERROR'
    Write-Host "Backup error. See log." -ForegroundColor Red
  }
}

function Restore-Database {
  param([Parameter(Mandatory=$true)][string]$BackupFile)
  try {
    if (-not (Test-Path $BackupFile)) { throw "Backup file not found." }
    Copy-Item -Path $BackupFile -Destination $DatabasePath -Force
    Write-Log "Database restored from $BackupFile"
    Write-Host "Restore completed." -ForegroundColor Green
  } catch {
    Write-Log "Restore failed: $_" 'ERROR'
    Write-Host "Restore error. See log." -ForegroundColor Red
  }
}

function Remove-Record {
  param([Parameter(Mandatory=$true)][string]$LicenseKey)
  Ensure-Database
  try {
    $tmp = [IO.Path]::GetTempFileName()
    Import-Csv -Path $DatabasePath | Where-Object { $_.License -ne $LicenseKey } | Export-Csv -Path $tmp -NoTypeInformation -Encoding UTF8
    Move-Item -Path $tmp -Destination $DatabasePath -Force
    Write-Log "Removed record: $LicenseKey"
    Write-Host "Record removed." -ForegroundColor Green
  } catch {
    Write-Log "Remove-Record failed: $_" 'ERROR'
    Write-Host "Remove error. See log." -ForegroundColor Red
  }
}

# --- CLI Menu
function Show-Menu {
  Write-Host "SEB License Manager" -ForegroundColor Cyan
  Write-Host "1) Show all records"
  Write-Host "2) Search records"
  Write-Host "3) Add record"
  Write-Host "4) Import from CSV"
  Write-Host "5) Set license status"
  Write-Host "6) Validate all licenses"
  Write-Host "7) Export database"
  Write-Host "8) Backup database"
  Write-Host "9) Restore database from backup"
  Write-Host "10) Remove record"
  Write-Host "Q) Quit"
  $choice = Read-Host "Choose"
  switch ($choice.ToUpper()) {
    '1' { Show-All }
    '2' {
      $q = Read-Host "Search term"
      Search-Records -Query $q
    }
    '3' {
      $cust = Read-Host "Customer name"
      $email = Read-Host "Email (optional)"
      $lic = Read-Host "License key (XXXX-XXXX-XXXX-XXXX)"
      $notes = Read-Host "Notes (optional)"
      Add-Record -Customer $cust -Email $email -License $lic -Notes $notes
    }
    '4' {
      $path = Read-Host "Path to CSV to import"
      Import-FromCsv -Path $path
    }
    '5' {
      $lic = Read-Host "License key"
      $st = Read-Host "Status (Active/Expired/Revoked)"
      Set-Status -LicenseKey $lic -Status $st
    }
    '6' { Validate-All }
    '7' {
      $fmt = Read-Host "Format (CSV/JSON/HTML)"
      $out = Read-Host "Output path"
      Export-Database -Format $fmt -OutPath $out
    }
    '8' { Backup-Database }
    '9' {
      $b = Read-Host "Backup file path"
      Restore-Database -BackupFile $b
    }
    '10' {
      $lic = Read-Host "License key to remove"
      Remove-Record -LicenseKey $lic
    }
    default { Write-Host "Bye." -ForegroundColor Yellow }
  }
}

# --- Entry
try {
  Ensure-Database
  Show-Menu
} catch {
  Write-Log "Unhandled error in license-manager: $_" 'ERROR'
  Write-Host "An unexpected error occurred. Check log: $LogPath" -ForegroundColor Red
}