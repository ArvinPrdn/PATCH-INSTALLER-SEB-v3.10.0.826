# ==================================================
# SEB LICENSE GENERATOR v3.10.0.826
# Professional License Management System
# ==================================================
# Features:
# ✓ Generate single licenses with customer info
# ✓ Bulk license generation from CSV
# ✓ License validation & checksum verification
# ✓ Database management (JSON storage)
# ✓ Export to CSV/JSON/HTML
# ✓ Search & filter capabilities
# ✓ License status management
# ==================================================

# ===== CONFIGURATION =====
$ErrorActionPreference = 'Stop'
$script:LicenseDB = "$PSScriptRoot\licenses.json"
$script:LogFile = "$PSScriptRoot\license_generator_$(Get-Date -Format 'yyyyMMdd').log"

# ===== LOGGING FUNCTION =====
function Write-Log {
    param([string]$Message, [string]$Level = "INFO")

    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "[$timestamp] [$Level] $Message"

    switch ($Level) {
        "ERROR"   { Write-Host $logMessage -ForegroundColor Red }
        "WARNING" { Write-Host $logMessage -ForegroundColor Yellow }
        "SUCCESS" { Write-Host $logMessage -ForegroundColor Green }
        "INFO"    { Write-Host $logMessage -ForegroundColor Cyan }
        default   { Write-Host $logMessage -ForegroundColor White }
    }

    $logMessage | Out-File -FilePath $script:LogFile -Append -Encoding UTF8
}

# ===== LICENSE VALIDATION =====
function Test-LicenseKey {
    param([string]$LicenseKey)

    # 1. Format validation
    if ($LicenseKey -notmatch '^[A-Z0-9]{4}-[A-Z0-9]{4}-[A-Z0-9]{4}-[A-Z0-9]{4}$') {
        return @{Valid = $false; Message = "Invalid format! Must be XXXX-XXXX-XXXX-XXXX"}
    }

    # 2. Character validation
    $cleanKey = $LicenseKey -replace '-', ''
    if ($cleanKey -notmatch '^[A-Z0-9]{16}$') {
        return @{Valid = $false; Message = "Invalid characters! Only A-Z and 0-9 allowed"}
    }

    # 3. Checksum validation
    $sum = 0
    foreach ($char in $cleanKey.ToCharArray()) {
        $sum += [int][char]$char
    }

    $checksum = ($sum * 13 + 7) % 26
    $expectedChecksum = (($sum % 17) + 65)

    if ($checksum -ne $expectedChecksum) {
        return @{Valid = $false; Message = "Checksum validation failed"}
    }

    # 4. Invalid patterns
    $invalidPatterns = @("0000-0000-0000-0000", "1111-1111-1111-1111", "AAAA-AAAA-AAAA-AAAA")
    if ($invalidPatterns -contains $LicenseKey) {
        return @{Valid = $false; Message = "Invalid license pattern"}
    }

    return @{Valid = $true; Message = "License is valid"; CleanKey = $cleanKey}
}

# ===== LICENSE GENERATION =====
function Generate-LicenseKey {
    $chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'
    $attempts = 0
    $maxAttempts = 10000

    do {
        $key = ""
        for ($i = 0; $i -lt 16; $i++) {
            $key += $chars[(Get-Random -Minimum 0 -Maximum $chars.Length)]
        }
        $formattedKey = $key.Insert(4, "-").Insert(9, "-").Insert(14, "-")

        $validation = Test-LicenseKey -LicenseKey $formattedKey
        $attempts++

        if ($attempts -ge $maxAttempts) {
            throw "Failed to generate valid license key after $maxAttempts attempts"
        }
    } while (-not $validation.Valid)

    return @{Key = $formattedKey; CleanKey = $validation.CleanKey; Attempts = $attempts}
}

# ===== DATABASE MANAGEMENT =====
function Load-LicenseDB {
    if (Test-Path $script:LicenseDB) {
        try {
            $db = Get-Content $script:LicenseDB -Raw | ConvertFrom-Json
            return $db
        } catch {
            Write-Log "Error loading license database: $_" -Level "ERROR"
            return @()
        }
    }
    return @()
}

function Save-LicenseDB {
    param([array]$Licenses)

    try {
        $Licenses | ConvertTo-Json -Depth 10 | Out-File $script:LicenseDB -Encoding UTF8
        Write-Log "License database saved successfully" -Level "SUCCESS"
    } catch {
        Write-Log "Error saving license database: $_" -Level "ERROR"
        throw
    }
}

# ===== LICENSE OPERATIONS =====
function Add-License {
    param(
        [string]$CustomerName,
        [string]$CustomerEmail,
        [string]$ProductVersion = "3.10.0.826",
        [int]$ValidityYears = 1,
        [string]$Notes = ""
    )

    $db = Load-LicenseDB

    # Generate unique license
    $existingKeys = $db | ForEach-Object { $_.LicenseKey }
    $attempts = 0
    do {
        $gen = Generate-LicenseKey
        $licenseKey = $gen.Key
        $attempts++
    } while ($existingKeys -contains $licenseKey -and $attempts -lt 100)

    if ($existingKeys -contains $licenseKey) {
        throw "Failed to generate unique license key"
    }

    $license = @{
        Id = [guid]::NewGuid().ToString()
        LicenseKey = $licenseKey
        CustomerName = $CustomerName
        CustomerEmail = $CustomerEmail
        ProductVersion = $ProductVersion
        GeneratedDate = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        ExpiryDate = (Get-Date).AddYears($ValidityYears).ToString("yyyy-MM-dd")
        Status = "Active"
        Notes = $Notes
        Checksum = $gen.CleanKey
    }

    $db += $license
    Save-LicenseDB -Licenses $db

    Write-Log "License generated for $CustomerName ($CustomerEmail): $licenseKey" -Level "SUCCESS"
    return $license
}

function Bulk-GenerateLicenses {
    param([string]$CsvPath)

    if (-not (Test-Path $CsvPath)) {
        throw "CSV file not found: $CsvPath"
    }

    $csvData = Import-Csv $CsvPath
    $db = Load-LicenseDB
    $generated = @()

    foreach ($row in $csvData) {
        try {
            $license = Add-License -CustomerName $row.CustomerName -CustomerEmail $row.CustomerEmail -ProductVersion $row.ProductVersion -ValidityYears ([int]$row.ValidityYears) -Notes $row.Notes
            $generated += $license
            Write-Host "Generated: $($license.LicenseKey) for $($license.CustomerName)" -ForegroundColor Green
        } catch {
            Write-Log "Failed to generate license for $($row.CustomerName): $_" -Level "ERROR"
        }
    }

    Write-Log "Bulk generation completed: $($generated.Count) licenses generated" -Level "SUCCESS"
    return $generated
}

function Update-LicenseStatus {
    param([string]$LicenseId, [string]$Status, [string]$Reason = "")

    $validStatuses = @("Active", "Expired", "Revoked", "Suspended")
    if ($Status -notin $validStatuses) {
        throw "Invalid status. Must be one of: $($validStatuses -join ', ')"
    }

    $db = Load-LicenseDB
    $license = $db | Where-Object { $_.Id -eq $LicenseId }

    if (-not $license) {
        throw "License not found: $LicenseId"
    }

    $license.Status = $Status
    $license.LastModified = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $license.RevocationReason = $Reason
    $license.RevokedBy = $env:USERNAME
    $license.RevokedDate = if ($Status -eq "Revoked") { Get-Date -Format "yyyy-MM-dd HH:mm:ss" } else { $null }

    Save-LicenseDB -Licenses $db
    Write-Log "License $LicenseId status updated to $Status by $($env:USERNAME)" -Level "SUCCESS"
}

function Extend-License {
    param([string]$LicenseId, [int]$AdditionalYears = 1)

    $db = Load-LicenseDB
    $license = $db | Where-Object { $_.Id -eq $LicenseId }

    if (-not $license) {
        throw "License not found: $LicenseId"
    }

    $currentExpiry = [DateTime]::Parse($license.ExpiryDate)
    $newExpiry = $currentExpiry.AddYears($AdditionalYears)
    $license.ExpiryDate = $newExpiry.ToString("yyyy-MM-dd")
    $license.LastModified = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $license.ExtendedBy = $env:USERNAME
    $license.ExtensionDate = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

    Save-LicenseDB -Licenses $db
    Write-Log "License $LicenseId extended by $AdditionalYears years to $($license.ExpiryDate)" -Level "SUCCESS"
}

function Revoke-License {
    param([string]$LicenseKey, [string]$Reason = "Administrative revocation")

    $db = Load-LicenseDB
    $license = $db | Where-Object { $_.LicenseKey -eq $LicenseKey }

    if (-not $license) {
        throw "License not found: $LicenseKey"
    }

    if ($license.Status -eq "Revoked") {
        Write-Log "License $LicenseKey is already revoked" -Level "WARNING"
        return
    }

    Update-LicenseStatus -LicenseId $license.Id -Status "Revoked" -Reason $Reason
    Write-Log "License $LicenseKey revoked: $Reason" -Level "SUCCESS"
}

function Get-ExpiredLicenses {
    $db = Load-LicenseDB
    $today = Get-Date

    $expired = $db | Where-Object {
        [DateTime]::Parse($_.ExpiryDate) -lt $today -and $_.Status -ne "Expired"
    }

    return $expired
}

function Cleanup-ExpiredLicenses {
    $expired = Get-ExpiredLicenses
    $count = 0

    foreach ($license in $expired) {
        Update-LicenseStatus -LicenseId $license.Id -Status "Expired"
        $count++
    }

    Write-Log "Marked $count licenses as expired" -Level "SUCCESS"
    return $count
}

function Search-Licenses {
    param(
        [string]$SearchTerm = "",
        [string]$Status = "",
        [string]$CustomerName = ""
    )

    $db = Load-LicenseDB

    $results = $db

    if ($SearchTerm) {
        $results = $results | Where-Object {
            $_.LicenseKey -like "*$SearchTerm*" -or
            $_.CustomerName -like "*$SearchTerm*" -or
            $_.CustomerEmail -like "*$SearchTerm*"
        }
    }

    if ($Status) {
        $results = $results | Where-Object { $_.Status -eq $Status }
    }

    if ($CustomerName) {
        $results = $results | Where-Object { $_.CustomerName -like "*$CustomerName*" }
    }

    return $results
}

function Export-Licenses {
    param([string]$Format = "CSV", [string]$OutputPath = "")

    if (-not $OutputPath) {
        $OutputPath = "$PSScriptRoot\licenses_export_$(Get-Date -Format 'yyyyMMdd_HHmmss').$($Format.ToLower())"
    }

    $db = Load-LicenseDB

    switch ($Format.ToUpper()) {
        "CSV" {
            $db | Export-Csv -Path $OutputPath -NoTypeInformation -Encoding UTF8
        }
        "JSON" {
            $db | ConvertTo-Json -Depth 10 | Out-File $OutputPath -Encoding UTF8
        }
        "HTML" {
            $html = @"
<!DOCTYPE html>
<html>
<head>
    <title>SEB License Database</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        table { border-collapse: collapse; width: 100%; }
        th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
        th { background-color: #f2f2f2; }
        tr:nth-child(even) { background-color: #f9f9f9; }
        .status-active { color: green; }
        .status-expired { color: red; }
        .status-revoked { color: orange; }
    </style>
</head>
<body>
    <h1>SEB License Database</h1>
    <p>Generated on $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")</p>
    <table>
        <tr>
            <th>License Key</th>
            <th>Customer Name</th>
            <th>Email</th>
            <th>Status</th>
            <th>Generated Date</th>
            <th>Expiry Date</th>
        </tr>
"@

            foreach ($license in $db) {
                $statusClass = "status-$($license.Status.ToLower())"
                $html += @"
        <tr>
            <td>$($license.LicenseKey)</td>
            <td>$($license.CustomerName)</td>
            <td>$($license.CustomerEmail)</td>
            <td class="$statusClass">$($license.Status)</td>
            <td>$($license.GeneratedDate)</td>
            <td>$($license.ExpiryDate)</td>
        </tr>
"@
            }

            $html += @"
    </table>
</body>
</html>
"@

            $html | Out-File $OutputPath -Encoding UTF8
        }
        default {
            throw "Unsupported format: $Format. Use CSV, JSON, or HTML"
        }
    }

    Write-Log "Licenses exported to $OutputPath in $Format format" -Level "SUCCESS"
    return $OutputPath
}

# ===== MENU SYSTEM =====
function Show-Menu {
    Clear-Host
    Write-Host @"
╔══════════════════════════════════════════════════════════╗
║              SEB LICENSE GENERATOR v3.10.0.826            ║
╠══════════════════════════════════════════════════════════╣
║  1. Generate Single License                              ║
║  2. Bulk Generate from CSV                               ║
║  3. View All Licenses                                    ║
║  4. Search Licenses                                      ║
║  5. Update License Status                                ║
║  6. Export Licenses                                      ║
║  7. Validate License Key                                 ║
║  8. Exit                                                 ║
╚══════════════════════════════════════════════════════════╝
"@ -ForegroundColor Cyan
}

function Start-LicenseGenerator {
    Write-Log "SEB License Generator started" -Level "INFO"

    do {
        Show-Menu
        $choice = Read-Host "`nSelect option (1-8)"

        switch ($choice) {
            "1" {
                Write-Host "`n=== GENERATE SINGLE LICENSE ===" -ForegroundColor Yellow
                $customerName = Read-Host "Customer Name"
                $customerEmail = Read-Host "Customer Email"
                $validityYears = Read-Host "Validity Years (default 1)"
                if ([string]::IsNullOrWhiteSpace($validityYears)) { $validityYears = 1 }
                $notes = Read-Host "Notes (optional)"

                try {
                    $license = Add-License -CustomerName $customerName -CustomerEmail $customerEmail -ValidityYears ([int]$validityYears) -Notes $notes
                    Write-Host "`n✅ License Generated Successfully!" -ForegroundColor Green
                    Write-Host "License Key: $($license.LicenseKey)" -ForegroundColor Cyan
                    Write-Host "Customer: $($license.CustomerName)" -ForegroundColor White
                    Write-Host "Expires: $($license.ExpiryDate)" -ForegroundColor White
                } catch {
                    Write-Host "`n❌ Error: $_" -ForegroundColor Red
                }
            }

            "2" {
                Write-Host "`n=== BULK GENERATE FROM CSV ===" -ForegroundColor Yellow
                $csvPath = Read-Host "CSV File Path"
                if (Test-Path $csvPath) {
                    try {
                        $results = Bulk-GenerateLicenses -CsvPath $csvPath
                        Write-Host "`n✅ Bulk generation completed: $($results.Count) licenses generated" -ForegroundColor Green
                    } catch {
                        Write-Host "`n❌ Error: $_" -ForegroundColor Red
                    }
                } else {
                    Write-Host "`n❌ CSV file not found: $csvPath" -ForegroundColor Red
                }
            }

            "3" {
                Write-Host "`n=== ALL LICENSES ===" -ForegroundColor Yellow
                $db = Load-LicenseDB
                if ($db.Count -eq 0) {
                    Write-Host "No licenses found in database" -ForegroundColor Yellow
                } else {
                    Write-Host "Total Licenses: $($db.Count)" -ForegroundColor Cyan
                    Write-Host ("-" * 80) -ForegroundColor DarkGray
                    foreach ($license in $db) {
                        $statusColor = switch ($license.Status) {
                            "Active" { "Green" }
                            "Expired" { "Red" }
                            "Revoked" { "Yellow" }
                            default { "White" }
                        }
                        Write-Host "$($license.LicenseKey) | $($license.CustomerName) | $($license.Status)" -ForegroundColor $statusColor
                    }
                }
            }

            "4" {
                Write-Host "`n=== SEARCH LICENSES ===" -ForegroundColor Yellow
                $searchTerm = Read-Host "Search term (license key, customer name, or email)"
                $results = Search-Licenses -SearchTerm $searchTerm

                if ($results.Count -eq 0) {
                    Write-Host "No licenses found matching '$searchTerm'" -ForegroundColor Yellow
                } else {
                    Write-Host "Found $($results.Count) license(s):" -ForegroundColor Green
                    foreach ($license in $results) {
                        Write-Host "$($license.LicenseKey) - $($license.CustomerName) ($($license.Status))" -ForegroundColor Cyan
                    }
                }
            }

            "5" {
                Write-Host "`n=== UPDATE LICENSE STATUS ===" -ForegroundColor Yellow
                $licenseId = Read-Host "License ID"
                $status = Read-Host "New Status (Active/Expired/Revoked/Suspended)"

                try {
                    Update-LicenseStatus -LicenseId $licenseId -Status $status
                    Write-Host "`n✅ License status updated successfully" -ForegroundColor Green
                } catch {
                    Write-Host "`n❌ Error: $_" -ForegroundColor Red
                }
            }

            "6" {
                Write-Host "`n=== EXPORT LICENSES ===" -ForegroundColor Yellow
                $format = Read-Host "Export format (CSV/JSON/HTML)"
                try {
                    $outputPath = Export-Licenses -Format $format
                    Write-Host "`n✅ Licenses exported to: $outputPath" -ForegroundColor Green
                } catch {
                    Write-Host "`n❌ Error: $_" -ForegroundColor Red
                }
            }

            "7" {
                Write-Host "`n=== VALIDATE LICENSE KEY ===" -ForegroundColor Yellow
                $key = Read-Host "License Key to validate"
                $validation = Test-LicenseKey -LicenseKey $key

                if ($validation.Valid) {
                    Write-Host "`n✅ License is VALID" -ForegroundColor Green
                } else {
                    Write-Host "`n❌ License is INVALID: $($validation.Message)" -ForegroundColor Red
                }
            }

            "8" {
                Write-Host "`nGoodbye!" -ForegroundColor Cyan
                break
            }

            default {
                Write-Host "`n❌ Invalid option. Please select 1-8." -ForegroundColor Red
            }
        }

        if ($choice -ne "8") {
            Read-Host "`nPress Enter to continue..."
        }

    } while ($choice -ne "8")
}

# ===== START APPLICATION =====
try {
    if ($PSVersionTable.PSVersion.Major -lt 3) {
        Write-Host "Error: PowerShell 3.0 or higher required" -ForegroundColor Red
        exit 1
    }

    Start-LicenseGenerator

} catch {
    Write-Host "`n❌ UNEXPECTED ERROR: $($_.Exception.Message)" -ForegroundColor Red
    Write-Log "Unexpected error: $_" -Level "ERROR"
} finally {
    Write-Host "`nPress any key to exit..." -ForegroundColor Gray
    $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
}
