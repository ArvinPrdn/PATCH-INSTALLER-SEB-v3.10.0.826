# ==================================================
# SEB LICENSE GENERATOR v2.1 - FIXED
# Enhanced with proper character validation
# ==================================================

# ===== KONFIGURASI =====
$LogFile = "license_log.csv"
$ValidChars = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789"  # Tidak ada I,1,O,0,S,5,8,B
$CompanyName = "SEB Software"
$Version = "2.1"

# ===== FUNGSI GENERATE LICENSE =====
function New-SEBSecureLicense {
    param(
        [Parameter(Mandatory=$true)]
        [string]$CustomerName,
        
        [string]$CustomerEmail = "",
        [string]$Company = "",
        [string]$ComputerName = "ANY-PC",
        [int]$DaysValid = 365,
        [string]$Product = "SEB Standard",
        [switch]$ForceChecksum
    )
    
    Write-Host "`n[INFO] Generating license for: $CustomerName" -ForegroundColor Gray
    
    # 1. BUAT BASE LICENSE (16 karakter)
    $licenseBase = ""
    for ($i = 0; $i -lt 16; $i++) {
        $licenseBase += $ValidChars[(Get-Random -Maximum $ValidChars.Length)]
    }
    
    # 2. FORMAT: XXXX-XXXX-XXXX-XXXX
    $formattedLicense = $licenseBase.Insert(4, '-').Insert(9, '-').Insert(14, '-')
    
    # 3. HITUNG CHECKSUM
    $cleanLicense = $formattedLicense -replace '-', ''
    $checksum = 0
    foreach ($char in $cleanLicense.ToCharArray()) {
        $checksum += [int][char]$char
    }
    
    # 4. VALIDASI & ADJUST CHECKSUM
    $checksumValid = ($checksum % 13) -eq 7
    
    if ((-not $checksumValid) -or $ForceChecksum) {
        Write-Host "[ADJUST] Adjusting checksum..." -ForegroundColor Yellow
        
        # Adjust karakter terakhir
        $lastChar = $cleanLicense[-1]
        $lastCharIndex = [Array]::IndexOf($ValidChars.ToCharArray(), $lastChar)
        
        # Cari index yang membuat checksum mod 13 = 7
        for ($i = 0; $i -lt $ValidChars.Length; $i++) {
            $testChar = $ValidChars[$i]
            $testChecksum = $checksum - [int][char]$lastChar + [int][char]$testChar
            
            if (($testChecksum % 13) -eq 7) {
                $newLicense = $cleanLicense.Substring(0, 15) + $testChar
                $formattedLicense = $newLicense.Insert(4, '-').Insert(9, '-').Insert(14, '-')
                $checksum = $testChecksum
                $checksumValid = $true
                break
            }
        }
    }
    
    # 5. TANGGAL
    $generatedDate = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $expiryDate = (Get-Date).AddDays($DaysValid).ToString("yyyy-MM-dd")
    $activationCode = [System.Guid]::NewGuid().ToString().Substring(0, 8).ToUpper()
    
    # 6. CREATE LICENSE OBJECT
    $license = [PSCustomObject]@{
        LicenseID = "SEB-" + (Get-Date -Format "yyyyMMddHHmmss") + "-" + (Get-Random -Maximum 1000)
        LicenseKey = $formattedLicense
        CustomerName = $CustomerName.Trim()
        CustomerEmail = $CustomerEmail.Trim()
        Company = $Company.Trim()
        ComputerName = $ComputerName.ToUpper()
        Product = $Product
        GeneratedDate = $generatedDate
        ActivationDate = ""
        ExpiryDate = $expiryDate
        DaysValid = $DaysValid
        Status = "Active"
        Checksum = $checksum
        ChecksumValid = $checksumValid
        ActivationCode = $activationCode
        Notes = ""
    }
    
    return $license
}

# ===== FUNGSI VALIDASI =====
function Test-LicenseFormat {
    param([string]$LicenseKey)
    
    Write-Host "`n[TEST] Testing license format: $LicenseKey" -ForegroundColor Cyan
    
    # 1. Format dasar
    if ($LicenseKey -notmatch '^[A-Z0-9]{4}-[A-Z0-9]{4}-[A-Z0-9]{4}-[A-Z0-9]{4}$') {
        Write-Host "[ERROR] Invalid format!" -ForegroundColor Red
        Write-Host "   Should be: XXXX-XXXX-XXXX-XXXX" -ForegroundColor Yellow
        return $false
    }
    
    # 2. Cek karakter invalid
    $invalidChars = @('I', 'O', 'S', '1', '0', '5', '8', 'B')
    $cleanKey = $LicenseKey -replace '-', ''
    
    foreach ($char in $invalidChars) {
        if ($cleanKey.Contains($char)) {
            Write-Host "[WARNING] Contains invalid character: $char" -ForegroundColor Yellow
            Write-Host "   Avoid: I, O, S, 1, 0, 5, 8, B" -ForegroundColor Yellow
        }
    }
    
    # 3. Cek checksum
    $checksum = 0
    foreach ($char in $cleanKey.ToCharArray()) {
        $checksum += [int][char]$char
    }
    
    $checksumValid = ($checksum % 13) -eq 7
    Write-Host "[CHECKSUM] Value: $checksum | Mod 13: $($checksum % 13) | Valid: $checksumValid" -ForegroundColor Gray
    
    if ($checksumValid) {
        Write-Host "[SUCCESS] License format is VALID!" -ForegroundColor Green
        return $true
    } else {
        Write-Host "[WARNING] Checksum invalid (should be mod 13 = 7)" -ForegroundColor Yellow
        return $false
    }
}

# ===== FUNGSI EKSPOR =====
function Export-License {
    param(
        [Parameter(Mandatory=$true)]
        $License,
        
        [string]$Format = "CSV",
        [string]$OutputPath = ""
    )
    
    if ([string]::IsNullOrEmpty($OutputPath)) {
        $OutputPath = "License_$($License.LicenseKey -replace '-', '_').txt"
    }
    
    switch ($Format.ToUpper()) {
        "CSV" {
            $License | Export-Csv -Path $LogFile -Append -NoTypeInformation -Encoding UTF8
            Write-Host "[SAVED] Added to: $LogFile" -ForegroundColor Green
        }
        
        "TXT" {
            $text = @"
===============================================
           SEB SOFTWARE LICENSE
===============================================
License ID   : $($License.LicenseID)
License Key  : $($License.LicenseKey)
Activation   : $($License.ActivationCode)

CUSTOMER INFORMATION
-----------------------------------------------
Name         : $($License.CustomerName)
Company      : $($License.Company)
Email        : $($License.CustomerEmail)

LICENSE DETAILS
-----------------------------------------------
Product      : $($License.Product)
Computer     : $($License.ComputerName)
Generated    : $($License.GeneratedDate)
Valid Until  : $($License.ExpiryDate)
Days Valid   : $($License.DaysValid)
Status       : $($License.Status)

INSTALLATION INSTRUCTIONS
-----------------------------------------------
1. Run installer-secure.ps1
2. Enter License Key when prompted
3. Use Activation Code if required

SUPPORT
-----------------------------------------------
Website: www.example.com
Email: support@example.com
Phone: (021) 1234-5678

===============================================
THIS LICENSE IS VALID ONLY FOR SPECIFIED USER
===============================================
"@
            $text | Out-File -FilePath $OutputPath -Encoding UTF8
            Write-Host "[SAVED] License exported to: $OutputPath" -ForegroundColor Green
        }
        
        "JSON" {
            $License | ConvertTo-Json | Out-File -FilePath $OutputPath -Encoding UTF8
            Write-Host "[SAVED] JSON exported to: $OutputPath" -ForegroundColor Green
        }
    }
}

# ===== MENU UTAMA =====
function Show-MainMenu {
    Clear-Host
    
    Write-Host @"
╔══════════════════════════════════════════════╗
║           SEB LICENSE GENERATOR v$Version            ║
║           $CompanyName                          ║
╚══════════════════════════════════════════════╝
"@ -ForegroundColor Cyan

    Write-Host "`n[1] Generate Single License" -ForegroundColor Green
    Write-Host "[2] Generate Bulk Licenses" -ForegroundColor Green
    Write-Host "[3] Validate License Key" -ForegroundColor Yellow
    Write-Host "[4] View License Database" -ForegroundColor Cyan
    Write-Host "[5] Export All Licenses" -ForegroundColor Magenta
    Write-Host "[6] Settings" -ForegroundColor Gray
    Write-Host "[0] Exit" -ForegroundColor Red
    
    Write-Host "`n" + ("─" * 50) -ForegroundColor DarkGray
    $choice = Read-Host "Select option (0-6)"
    
    return $choice
}

# ===== MENU 1: GENERATE SINGLE =====
function Menu-GenerateSingle {
    Clear-Host
    Write-Host "`n" + ("═" * 50) -ForegroundColor Green
    Write-Host "          GENERATE SINGLE LICENSE           " -ForegroundColor Green
    Write-Host ("═" * 50) -ForegroundColor Green
    
    # Input data
    $customer = Read-Host "`nCustomer Name"
    if ([string]::IsNullOrWhiteSpace($customer)) {
        Write-Host "[ERROR] Customer name is required!" -ForegroundColor Red
        Read-Host "`nPress Enter to continue..."
        return
    }
    
    $email = Read-Host "Customer Email (optional)"
    $company = Read-Host "Company (optional)"
    $computer = Read-Host "Computer Name [default: ANY-PC]"
    if ([string]::IsNullOrWhiteSpace($computer)) { $computer = "ANY-PC" }
    
    $days = Read-Host "Valid for (days) [default: 365]"
    if ([string]::IsNullOrWhiteSpace($days)) { $days = 365 } else { $days = [int]$days }
    
    $product = Read-Host "Product [default: SEB Standard]"
    if ([string]::IsNullOrWhiteSpace($product)) { $product = "SEB Standard" }
    
    # Generate license
    Write-Host "`n" + ("─" * 50) -ForegroundColor DarkGray
    Write-Host "Generating secure license..." -ForegroundColor Yellow
    
    $license = New-SEBSecureLicense -CustomerName $customer `
                                    -CustomerEmail $email `
                                    -Company $company `
                                    -ComputerName $computer `
                                    -DaysValid $days `
                                    -Product $product
    
    # Display result
    Write-Host "`n" + ("═" * 50) -ForegroundColor Cyan
    Write-Host "          LICENSE GENERATED!           " -ForegroundColor Cyan
    Write-Host ("═" * 50) -ForegroundColor Cyan
    
    Write-Host "`n📋 LICENSE DETAILS:" -ForegroundColor Yellow
    Write-Host "   Customer   : $($license.CustomerName)" -ForegroundColor White
    Write-Host "   Company    : $($license.Company)" -ForegroundColor White
    Write-Host "   Computer   : $($license.ComputerName)" -ForegroundColor White
    Write-Host "   Product    : $($license.Product)" -ForegroundColor White
    
    Write-Host "`n🔑 LICENSE KEY:" -ForegroundColor Yellow
    Write-Host "   " -NoNewline
    Write-Host "$($license.LicenseKey)" -ForegroundColor Green -BackgroundColor DarkGray
    
    Write-Host "`n📅 VALIDITY:" -ForegroundColor Yellow
    Write-Host "   Generated  : $($license.GeneratedDate)" -ForegroundColor White
    Write-Host "   Expires    : $($license.ExpiryDate)" -ForegroundColor White
    Write-Host "   Days Valid : $($license.DaysValid)" -ForegroundColor White
    
    Write-Host "`n🔐 ACTIVATION:" -ForegroundColor Yellow
    Write-Host "   Code       : $($license.ActivationCode)" -ForegroundColor Magenta
    Write-Host "   Status     : $($license.Status)" -ForegroundColor White
    
    # Validasi format
    Write-Host "`n✅ VALIDATION:" -ForegroundColor Yellow
    $isValid = Test-LicenseFormat -LicenseKey $license.LicenseKey
    if ($isValid) {
        Write-Host "   Format     : VALID (ready for installer)" -ForegroundColor Green
    } else {
        Write-Host "   Format     : NEEDS ADJUSTMENT" -ForegroundColor Red
    }
    
    # Save options
    Write-Host "`n💾 SAVE OPTIONS:" -ForegroundColor Yellow
    Write-Host "[1] Save to database only" -ForegroundColor Gray
    Write-Host "[2] Save + Export as text file" -ForegroundColor Gray
    Write-Host "[3] Save + Export as JSON" -ForegroundColor Gray
    Write-Host "[4] Don't save" -ForegroundColor Gray
    
    $saveChoice = Read-Host "`nSelect (1-4)"
    
    switch ($saveChoice) {
        "1" {
            Export-License -License $license -Format "CSV"
        }
        "2" {
            Export-License -License $license -Format "CSV"
            Export-License -License $license -Format "TXT"
        }
        "3" {
            Export-License -License $license -Format "CSV"
            Export-License -License $license -Format "JSON"
        }
        default {
            Write-Host "[INFO] License not saved to database" -ForegroundColor Yellow
        }
    }
    
    # Copy to clipboard
    $copy = Read-Host "`nCopy License Key to clipboard? (Y/N)"
    if ($copy -in @('Y', 'y')) {
        $license.LicenseKey | Set-Clipboard
        Write-Host "[INFO] License key copied to clipboard!" -ForegroundColor Green
    }
    
    Read-Host "`nPress Enter to continue..."
}

# ===== MENU 2: GENERATE BULK =====
function Menu-GenerateBulk {
    Clear-Host
    Write-Host "`n" + ("═" * 50) -ForegroundColor Green
    Write-Host "          GENERATE BULK LICENSES           " -ForegroundColor Green
    Write-Host ("═" * 50) -ForegroundColor Green
    
    Write-Host @"
Input format (one per line):
CustomerName,Email,Company,ComputerName,Days,Product

Example:
John Doe,john@company.com,ACME Inc,PC-01,365,SEB Pro
Jane Smith,jane@company.com,XYZ Corp,LAPTOP-02,180,SEB Basic

Press Enter on empty line to finish.
"@ -ForegroundColor Gray
    
    $licenses = @()
    $count = 1
    
    while ($true) {
        Write-Host "`n─── License #$count ───" -ForegroundColor DarkGray
        $inputLine = Read-Host "Entry (or press Enter to finish)"
        
        if ([string]::IsNullOrWhiteSpace($inputLine)) {
            break
        }
        
        $parts = $inputLine -split ','
        if ($parts.Count -lt 1) {
            Write-Host "[SKIP] Invalid format" -ForegroundColor Red
            continue
        }
        
        try {
            $license = New-SEBSecureLicense -CustomerName $parts[0].Trim() `
                                            -CustomerEmail $(if ($parts.Count -gt 1) { $parts[1].Trim() } else { "" }) `
                                            -Company $(if ($parts.Count -gt 2) { $parts[2].Trim() } else { "" }) `
                                            -ComputerName $(if ($parts.Count -gt 3) { $parts[3].Trim() } else { "ANY-PC" }) `
                                            -DaysValid $(if ($parts.Count -gt 4) { [int]$parts[4].Trim() } else { 365 }) `
                                            -Product $(if ($parts.Count -gt 5) { $parts[5].Trim() } else { "SEB Standard" })
            
            $licenses += $license
            Write-Host "[OK] Generated: $($license.LicenseKey)" -ForegroundColor Green
            $count++
            
        } catch {
            Write-Host "[ERROR] Failed: $_" -ForegroundColor Red
        }
    }
    
    if ($licenses.Count -gt 0) {
        # Save all
        $licenses | Export-Csv -Path "bulk_licenses_$(Get-Date -Format 'yyyyMMdd_HHmmss').csv" -NoTypeInformation -Encoding UTF8
        
        Write-Host "`n" + ("═" * 50) -ForegroundColor Cyan
        Write-Host "          BULK GENERATION COMPLETE           " -ForegroundColor Cyan
        Write-Host ("═" * 50) -ForegroundColor Cyan
        
        Write-Host "`n📊 SUMMARY:" -ForegroundColor Yellow
        Write-Host "   Total Licenses : $($licenses.Count)" -ForegroundColor White
        Write-Host "   Saved to       : bulk_licenses_$(Get-Date -Format 'yyyyMMdd_HHmmss').csv" -ForegroundColor White
        
        # Preview
        $preview = Read-Host "`nPreview licenses? (Y/N)"
        if ($preview -in @('Y', 'y')) {
            Write-Host "`n─── GENERATED LICENSES ───" -ForegroundColor DarkGray
            foreach ($license in $licenses) {
                Write-Host "`n$($license.CustomerName)" -ForegroundColor White
                Write-Host "  Key: $($license.LicenseKey)" -ForegroundColor Cyan
                Write-Host "  Exp: $($license.ExpiryDate)" -ForegroundColor Gray
            }
        }
    } else {
        Write-Host "`n[INFO] No licenses generated" -ForegroundColor Yellow
    }
    
    Read-Host "`nPress Enter to continue..."
}

# ===== MENU 3: VALIDATE =====
function Menu-Validate {
    Clear-Host
    Write-Host "`n" + ("═" * 50) -ForegroundColor Yellow
    Write-Host "          VALIDATE LICENSE KEY           " -ForegroundColor Yellow
    Write-Host ("═" * 50) -ForegroundColor Yellow
    
    $licenseKey = Read-Host "`nEnter License Key to validate"
    
    if (-not [string]::IsNullOrWhiteSpace($licenseKey)) {
        $isValid = Test-LicenseFormat -LicenseKey $licenseKey
        
        if ($isValid) {
            # Cek di database jika ada
            if (Test-Path $LogFile) {
                $existing = Import-Csv -Path $LogFile | Where-Object { $_.LicenseKey -eq $licenseKey }
                if ($existing) {
                    Write-Host "`n📋 DATABASE RECORD:" -ForegroundColor Cyan
                    Write-Host "   Customer : $($existing.CustomerName)" -ForegroundColor White
                    Write-Host "   Generated: $($existing.GeneratedDate)" -ForegroundColor White
                    Write-Host "   Status   : $($existing.Status)" -ForegroundColor White
                }
            }
        }
    }
    
    Read-Host "`nPress Enter to continue..."
}

# ===== MENU 4: VIEW DATABASE =====
function Menu-ViewDatabase {
    Clear-Host
    Write-Host "`n" + ("═" * 50) -ForegroundColor Cyan
    Write-Host "          LICENSE DATABASE           " -ForegroundColor Cyan
    Write-Host ("═" * 50) -ForegroundColor Cyan
    
    if (Test-Path $LogFile) {
        $licenses = Import-Csv -Path $LogFile
        
        Write-Host "`n📊 STATISTICS:" -ForegroundColor Yellow
        Write-Host "   Total Licenses : $($licenses.Count)" -ForegroundColor White
        Write-Host "   Active         : $(($licenses | Where-Object { $_.Status -eq 'Active' }).Count)" -ForegroundColor Green
        Write-Host "   Expired        : $(($licenses | Where-Object { 
            [datetime]$_.ExpiryDate -lt (Get-Date) 
        }).Count)" -ForegroundColor Red
        
        # Filter options
        Write-Host "`n🔍 FILTER OPTIONS:" -ForegroundColor Yellow
        Write-Host "[1] Show all" -ForegroundColor Gray
        Write-Host "[2] Show active only" -ForegroundColor Gray
        Write-Host "[3] Show by customer name" -ForegroundColor Gray
        Write-Host "[4] Search license key" -ForegroundColor Gray
        
        $filter = Read-Host "`nSelect filter (1-4)"
        
        switch ($filter) {
            "2" {
                $licenses = $licenses | Where-Object { $_.Status -eq 'Active' }
            }
            "3" {
                $name = Read-Host "Enter customer name (partial)"
                $licenses = $licenses | Where-Object { $_.CustomerName -like "*$name*" }
            }
            "4" {
                $key = Read-Host "Enter license key (partial)"
                $licenses = $licenses | Where-Object { $_.LicenseKey -like "*$key*" }
            }
        }
        
        # Display
        if ($licenses.Count -gt 0) {
            Write-Host "`n─── LICENSE LIST ($($licenses.Count) found) ───" -ForegroundColor DarkGray
            
            foreach ($license in $licenses) {
                Write-Host "`n• $($license.CustomerName)" -ForegroundColor White
                Write-Host "  Key: $($license.LicenseKey)" -ForegroundColor Cyan
                Write-Host "  Exp: $($license.ExpiryDate) | Status: $($license.Status)" -ForegroundColor Gray
            }
        } else {
            Write-Host "`n[INFO] No licenses found with selected filter" -ForegroundColor Yellow
        }
    } else {
        Write-Host "`n[INFO] No license database found" -ForegroundColor Yellow
        Write-Host "Generate some licenses first!" -ForegroundColor Gray
    }
    
    Read-Host "`nPress Enter to continue..."
}

# ===== MENU 5: EXPORT ALL =====
function Menu-ExportAll {
    Clear-Host
    Write-Host "`n" + ("═" * 50) -ForegroundColor Magenta
    Write-Host "          EXPORT LICENSES           " -ForegroundColor Magenta
    Write-Host ("═" * 50) -ForegroundColor Magenta
    
    if (Test-Path $LogFile) {
        $licenses = Import-Csv -Path $LogFile
        
        Write-Host "`n📁 EXPORT FORMATS:" -ForegroundColor Yellow
        Write-Host "[1] CSV (Original format)" -ForegroundColor Gray
        Write-Host "[2] Excel (XLSX)" -ForegroundColor Gray
        Write-Host "[3] JSON" -ForegroundColor Gray
        Write-Host "[4] HTML Report" -ForegroundColor Gray
        Write-Host "[5] Text Summary" -ForegroundColor Gray
        
        $format = Read-Host "`nSelect format (1-5)"
        
        $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
        
        switch ($format) {
            "1" {
                $output = "licenses_export_$timestamp.csv"
                $licenses | Export-Csv -Path $output -NoTypeInformation -Encoding UTF8
                Write-Host "[SAVED] Exported to: $output" -ForegroundColor Green
            }
            
            "2" {
                # Requires ImportExcel module
                if (Get-Module -ListAvailable -Name ImportExcel) {
                    $output = "licenses_export_$timestamp.xlsx"
                    $licenses | Export-Excel -Path $output -WorksheetName "Licenses"
                    Write-Host "[SAVED] Exported to: $output" -ForegroundColor Green
                } else {
                    Write-Host "[ERROR] ImportExcel module not installed!" -ForegroundColor Red
                    Write-Host "Install with: Install-Module -Name ImportExcel" -ForegroundColor Yellow
                }
            }
            
            "3" {
                $output = "licenses_export_$timestamp.json"
                $licenses | ConvertTo-Json | Out-File -FilePath $output -Encoding UTF8
                Write-Host "[SAVED] Exported to: $output" -ForegroundColor Green
            }
            
            "4" {
                $output = "licenses_report_$timestamp.html"
                $html = @"
<!DOCTYPE html>
<html>
<head>
    <title>SEB Licenses Report</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        table { border-collapse: collapse; width: 100%; }
        th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
        th { background-color: #4CAF50; color: white; }
        tr:nth-child(even) { background-color: #f2f2f2; }
        .expired { color: red; font-weight: bold; }
        .active { color: green; }
    </style>
</head>
<body>
    <h1>SEB Licenses Report</h1>
    <p>Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')</p>
    <p>Total Licenses: $($licenses.Count)</p>
    
    <table>
        <tr>
            <th>License Key</th>
            <th>Customer</th>
            <th>Company</th>
            <th>Expiry Date</th>
            <th>Status</th>
        </tr>
"@
                
                foreach ($license in $licenses) {
                    $statusClass = if ($license.Status -eq 'Active') { "active" } else { "expired" }
                    $html += @"
        <tr>
            <td>$($license.LicenseKey)</td>
            <td>$($license.CustomerName)</td>
            <td>$($license.Company)</td>
            <td>$($license.ExpiryDate)</td>
            <td class="$statusClass">$($license.Status)</td>
        </tr>
"@
                }
                
                $html += @"
    </table>
</body>
</html>
"@
                
                $html | Out-File -FilePath $output -Encoding UTF8
                Write-Host "[SAVED] HTML report: $output" -ForegroundColor Green
            }
            
            "5" {
                $output = "licenses_summary_$timestamp.txt"
                $text = @"
SEB LICENSES SUMMARY
====================
Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
Total: $($licenses.Count) licenses

"@
                
                foreach ($license in $licenses) {
                    $text += @"
------------------------------------------------
License: $($license.LicenseKey)
Customer: $($license.CustomerName)
Company: $($license.Company)
Email: $($license.CustomerEmail)
Generated: $($license.GeneratedDate)
Expires: $($license.ExpiryDate)
Status: $($license.Status)
Product: $($license.Product)
Computer: $($license.ComputerName)

"@
                }
                
                $text | Out-File -FilePath $output -Encoding UTF8
                Write-Host "[SAVED] Text summary: $output" -ForegroundColor Green
            }
        }
    } else {
        Write-Host "`n[INFO] No license database found" -ForegroundColor Yellow
    }
    
    Read-Host "`nPress Enter to continue..."
}

# ===== MENU 6: SETTINGS =====
function Menu-Settings {
    Clear-Host
    Write-Host "`n" + ("═" * 50) -ForegroundColor Gray
    Write-Host "          SETTINGS           " -ForegroundColor Gray
    Write-Host ("═" * 50) -ForegroundColor Gray
    
    Write-Host "`n⚙️ CURRENT SETTINGS:" -ForegroundColor Yellow
    Write-Host "   Log File     : $LogFile" -ForegroundColor White
    Write-Host "   Valid Chars  : $ValidChars" -ForegroundColor White
    Write-Host "   Company      : $CompanyName" -ForegroundColor White
    Write-Host "   Version      : $Version" -ForegroundColor White
    
    Write-Host "`n🔧 CONFIGURATION OPTIONS:" -ForegroundColor Yellow
    Write-Host "[1] Change log file location" -ForegroundColor Gray
    Write-Host "[2] Change valid characters" -ForegroundColor Gray
    Write-Host "[3] Change company name" -ForegroundColor Gray
    Write-Host "[4] Backup database" -ForegroundColor Gray
    Write-Host "[5] Reset database" -ForegroundColor Red
    Write-Host "[6] Test license generation" -ForegroundColor Gray
    
    $setting = Read-Host "`nSelect option (1-6)"
    
    switch ($setting) {
        "1" {
            $newLog = Read-Host "Enter new log file path"
            if (-not [string]::IsNullOrWhiteSpace($newLog)) {
                $LogFile = $newLog
                Write-Host "[UPDATED] Log file: $LogFile" -ForegroundColor Green
            }
        }
        
        "5" {
            $confirm = Read-Host "Are you sure you want to reset database? (YES/NO)"
            if ($confirm -eq "YES") {
                if (Test-Path $LogFile) {
                    Remove-Item -Path $LogFile -Force
                    Write-Host "[RESET] Database cleared" -ForegroundColor Red
                }
            }
        }
        
        "6" {
            Write-Host "`n🧪 TESTING LICENSE GENERATION:" -ForegroundColor Yellow
            for ($i = 1; $i -le 5; $i++) {
                $testLicense = New-SEBSecureLicense -CustomerName "Test User $i" -ForceChecksum
                $isValid = Test-LicenseFormat -LicenseKey $testLicense.LicenseKey
                Write-Host "   Test $i : $($testLicense.LicenseKey) - Valid: $isValid" -ForegroundColor Gray
            }
        }
    }
    
    Read-Host "`nPress Enter to continue..."
}

# ===== MAIN LOOP =====
function Main {
    # Initialize log file if not exists
    if (-not (Test-Path $LogFile)) {
        # Create with header
        $sample = New-SEBSecureLicense -CustomerName "Sample User" -DaysValid 365
        $sample | Export-Csv -Path $LogFile -NoTypeInformation -Encoding UTF8
    }
    
    while ($true) {
        $choice = Show-MainMenu
        
        switch ($choice) {
            "1" { Menu-GenerateSingle }
            "2" { Menu-GenerateBulk }
            "3" { Menu-Validate }
            "4" { Menu-ViewDatabase }
            "5" { Menu-ExportAll }
            "6" { Menu-Settings }
            "0" { 
                Write-Host "`nThank you for using SEB License Generator!" -ForegroundColor Cyan
                Start-Sleep -Seconds 1
                exit 0 
            }
            default {
                Write-Host "`n[ERROR] Invalid selection!" -ForegroundColor Red
                Start-Sleep -Seconds 1
            }
        }
    }
}

# ===== START APPLICATION =====
try {
    # Check if running as admin (optional)
    $isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    
    if (-not $isAdmin) {
        Write-Host "[WARNING] Running without administrator privileges" -ForegroundColor Yellow
        Write-Host "Some features may require elevation." -ForegroundColor Gray
        Start-Sleep -Seconds 2
    }
    
    Main
} catch {
    Write-Host "[FATAL ERROR] $_" -ForegroundColor Red
    Read-Host "Press Enter to exit..."
}