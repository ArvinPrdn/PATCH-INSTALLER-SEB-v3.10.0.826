# ==================================================
# SEB LICENSE GENERATOR HYBRID
# Stable + Essential Features Only
# ==================================================

Clear-Host

# Show header
Write-Host "================================================" -ForegroundColor Cyan
Write-Host "        SEB LICENSE GENERATOR v1.5" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan

# Configuration
$LogFile = "licenses.csv"

# Function to generate license (SAMA dengan enhanced)
function New-SEBSecureLicense {
    param(
        [string]$CustomerName,
        [string]$ComputerName = "ANY-PC",
        [int]$DaysValid = 365
    )
    
    # Valid characters only
    $chars = "ACDEFGHJKLMNPQRTUVWXYZ234679"
    $licenseBase = ""
    
    # Generate 16 characters
    for ($i = 0; $i -lt 16; $i++) {
        $licenseBase += $chars[(Get-Random -Maximum $chars.Length)]
    }
    
    # Format: XXXX-XXXX-XXXX-XXXX
    $formattedLicense = $licenseBase.Insert(4, '-').Insert(9, '-').Insert(14, '-')
    
    # Calculate checksum
    $cleanLicense = $formattedLicense -replace '-', ''
    $checksum = 0
    foreach ($char in $cleanLicense.ToCharArray()) {
        $checksum += [int][char]$char
    }
    
    # Adjust last character for checksum validation
    $lastChar = $cleanLicense[-1]
    $lastCharIndex = [Array]::IndexOf($chars.ToCharArray(), $lastChar)
    
    for ($i = 0; $i -lt $chars.Length; $i++) {
        $testChar = $chars[$i]
        $testChecksum = $checksum - [int][char]$lastChar + [int][char]$testChar
        
        if (($testChecksum % 13) -eq 7) {
            $newLicense = $cleanLicense.Substring(0, 15) + $testChar
            $formattedLicense = $newLicense.Insert(4, '-').Insert(9, '-').Insert(14, '-')
            $checksum = $testChecksum
            break
        }
    }
    
    # Expiry date
    $expiryDate = (Get-Date).AddDays($DaysValid).ToString("yyyy-MM-dd")
    
    # Return license object
    return [PSCustomObject]@{
        LicenseKey = $formattedLicense
        CustomerName = $CustomerName
        ComputerName = $ComputerName
        GeneratedDate = (Get-Date -Format "yyyy-MM-dd HH:mm:ss")
        ExpiryDate = $expiryDate
        DaysValid = $DaysValid
        Checksum = $checksum
        ChecksumValid = ($checksum % 13 -eq 7)
    }
}

# Function to save to CSV (SIMPLE version)
function Save-License {
    param($License)
    
    # Create file if not exists
    if (-not (Test-Path $LogFile)) {
        "LicenseKey,CustomerName,ComputerName,GeneratedDate,ExpiryDate,DaysValid,Checksum,ChecksumValid" | Out-File -FilePath $LogFile -Encoding UTF8
    }
    
    # Add to CSV
    "$($License.LicenseKey),$($License.CustomerName),$($License.ComputerName),$($License.GeneratedDate),$($License.ExpiryDate),$($License.DaysValid),$($License.Checksum),$($License.ChecksumValid)" | Out-File -FilePath $LogFile -Append -Encoding UTF8
}

# Function to show menu
function Show-Menu {
    Write-Host "`n[1] Generate Single License" -ForegroundColor Green
    Write-Host "[2] Generate Multiple Licenses" -ForegroundColor Green
    Write-Host "[3] Validate License Key" -ForegroundColor Yellow
    Write-Host "[4] View License Database" -ForegroundColor Cyan
    Write-Host "[5] Exit" -ForegroundColor Red
    Write-Host "`n" + ("-" * 40) -ForegroundColor DarkGray
}

# Main program
try {
    while ($true) {
        Clear-Host
        Write-Host "================================================" -ForegroundColor Cyan
        Write-Host "        SEB LICENSE GENERATOR v1.5" -ForegroundColor Cyan
        Write-Host "================================================" -ForegroundColor Cyan
        
        Show-Menu
        
        $choice = Read-Host "Select option (1-5)"
        
        switch ($choice) {
            "1" {
                # Generate Single License
                Clear-Host
                Write-Host "`n" + ("=" * 40) -ForegroundColor Green
                Write-Host "   GENERATE SINGLE LICENSE" -ForegroundColor Green
                Write-Host ("=" * 40) -ForegroundColor Green
                
                $customer = Read-Host "`nCustomer Name"
                
                if ([string]::IsNullOrWhiteSpace($customer)) {
                    Write-Host "[ERROR] Customer name required!" -ForegroundColor Red
                    Read-Host "`nPress Enter to continue..."
                    continue
                }
                
                $computer = Read-Host "Computer Name [default: ANY-PC]"
                $days = Read-Host "Valid for (days) [default: 365]"
                
                if ([string]::IsNullOrWhiteSpace($computer)) { $computer = "ANY-PC" }
                if ([string]::IsNullOrWhiteSpace($days)) { $days = 365 }
                
                Write-Host "`nGenerating license..." -ForegroundColor Yellow
                
                # Generate license
                $license = New-SEBSecureLicense -CustomerName $customer -ComputerName $computer -DaysValid $days
                
                # Show results
                Write-Host "`n" + ("-" * 40) -ForegroundColor Cyan
                Write-Host "   LICENSE GENERATED!" -ForegroundColor Cyan
                Write-Host ("-" * 40) -ForegroundColor Cyan
                
                Write-Host "`nCustomer    : $($license.CustomerName)" -ForegroundColor White
                Write-Host "Computer    : $($license.ComputerName)" -ForegroundColor White
                Write-Host "License Key : " -NoNewline
                Write-Host "$($license.LicenseKey)" -ForegroundColor Green -BackgroundColor Black
                Write-Host "Generated   : $($license.GeneratedDate)" -ForegroundColor Gray
                Write-Host "Expires     : $($license.ExpiryDate)" -ForegroundColor White
                Write-Host "Checksum    : $($license.Checksum) (mod 13 = $($license.Checksum % 13))" -ForegroundColor Gray
                
                # Save to database
                Save-License -License $license
                Write-Host "`n[SAVED] Added to database: $LogFile" -ForegroundColor Green
                
                # Export as text file
                $textFile = "License_$($license.CustomerName)_$(Get-Date -Format 'yyyyMMdd').txt"
                $textContent = @"
================================
SEB SOFTWARE LICENSE
================================
Customer: $($license.CustomerName)
Computer: $($license.ComputerName)

LICENSE KEY:
$($license.LicenseKey)

VALIDITY:
Generated: $($license.GeneratedDate)
Expires: $($license.ExpiryDate)
Days Valid: $($license.DaysValid)

CHECKSUM: $($license.Checksum) (Valid: $($license.ChecksumValid))

INSTALLATION:
1. Run installer-secure.ps1
2. Enter license key when prompted
================================
"@
                
                $textContent | Out-File -FilePath $textFile -Encoding UTF8
                Write-Host "[EXPORT] Text file: $textFile" -ForegroundColor Cyan
                
                Read-Host "`nPress Enter to continue..."
            }
            
            "2" {
                # Generate Multiple Licenses
                Clear-Host
                Write-Host "`n" + ("=" * 40) -ForegroundColor Green
                Write-Host "   GENERATE MULTIPLE LICENSES" -ForegroundColor Green
                Write-Host ("=" * 40) -ForegroundColor Green
                
                Write-Host "`nEnter customer names (one per line)."
                Write-Host "Press Enter on empty line to finish.`n" -ForegroundColor Gray
                
                $licenses = @()
                $count = 1
                
                while ($true) {
                    Write-Host "Customer #$count : " -NoNewline -ForegroundColor Gray
                    $customer = Read-Host
                    
                    if ([string]::IsNullOrWhiteSpace($customer)) {
                        break
                    }
                    
                    $license = New-SEBSecureLicense -CustomerName $customer
                    $licenses += $license
                    Save-License -License $license
                    
                    Write-Host "  License: $($license.LicenseKey)" -ForegroundColor Green
                    $count++
                }
                
                if ($licenses.Count -gt 0) {
                    Write-Host "`n" + ("-" * 40) -ForegroundColor Cyan
                    Write-Host "   SUMMARY" -ForegroundColor Cyan
                    Write-Host ("-" * 40) -ForegroundColor Cyan
                    
                    Write-Host "`nTotal generated: $($licenses.Count)" -ForegroundColor White
                    Write-Host "Saved to: $LogFile" -ForegroundColor White
                    
                    # Show preview
                    foreach ($license in $licenses) {
                        Write-Host "`n$($license.CustomerName)" -ForegroundColor White
                        Write-Host "  $($license.LicenseKey)" -ForegroundColor Cyan
                    }
                }
                
                Read-Host "`nPress Enter to continue..."
            }
            
            "3" {
                # Validate License
                Clear-Host
                Write-Host "`n" + ("=" * 40) -ForegroundColor Yellow
                Write-Host "   VALIDATE LICENSE KEY" -ForegroundColor Yellow
                Write-Host ("=" * 40) -ForegroundColor Yellow
                
                $inputKey = Read-Host "`nEnter License Key"
                $inputKey = $inputKey.ToUpper().Trim()
                
                # Check format
                if ($inputKey -match '^[A-Z0-9]{4}-[A-Z0-9]{4}-[A-Z0-9]{4}-[A-Z0-9]{4}$') {
                    Write-Host "`n[PASS] Format valid" -ForegroundColor Green
                    
                    # Calculate checksum
                    $cleanKey = $inputKey -replace '-', ''
                    $checksum = 0
                    foreach ($char in $cleanKey.ToCharArray()) {
                        $checksum += [int][char]$char
                    }
                    
                    $modResult = $checksum % 13
                    $isValid = ($modResult -eq 7)
                    
                    Write-Host "Checksum: $checksum" -ForegroundColor White
                    Write-Host "Mod 13: $modResult" -ForegroundColor White
                    
                    if ($isValid) {
                        Write-Host "[PASS] Checksum valid (mod 13 = 7)" -ForegroundColor Green
                        Write-Host "`n✅ This license is READY for installer!" -ForegroundColor Green
                    } else {
                        Write-Host "[FAIL] Checksum should be mod 13 = 7" -ForegroundColor Red
                        Write-Host "`n❌ This license may not work!" -ForegroundColor Red
                    }
                    
                    # Check in database
                    if (Test-Path $LogFile) {
                        $found = Import-Csv $LogFile | Where-Object { $_.LicenseKey -eq $inputKey }
                        if ($found) {
                            Write-Host "`n📋 Found in database:" -ForegroundColor Cyan
                            Write-Host "   Customer: $($found.CustomerName)" -ForegroundColor White
                            Write-Host "   Computer: $($found.ComputerName)" -ForegroundColor White
                            Write-Host "   Expires: $($found.ExpiryDate)" -ForegroundColor White
                        }
                    }
                    
                } else {
                    Write-Host "`n[FAIL] Invalid format!" -ForegroundColor Red
                    Write-Host "Should be: XXXX-XXXX-XXXX-XXXX" -ForegroundColor Yellow
                }
                
                Read-Host "`nPress Enter to continue..."
            }
            
            "4" {
                # View Database
                Clear-Host
                Write-Host "`n" + ("=" * 40) -ForegroundColor Cyan
                Write-Host "   LICENSE DATABASE" -ForegroundColor Cyan
                Write-Host ("=" * 40) -ForegroundColor Cyan
                
                if (Test-Path $LogFile) {
                    $licenses = Import-Csv $LogFile
                    
                    Write-Host "`n📊 STATISTICS:" -ForegroundColor Yellow
                    Write-Host "Total licenses: $($licenses.Count)" -ForegroundColor White
                    
                    # Show recent licenses
                    Write-Host "`n─── RECENT LICENSES (max 10) ───" -ForegroundColor DarkGray
                    
                    $recent = $licenses | Select-Object -Last 10
                    foreach ($license in $recent) {
                        Write-Host "`n$($license.CustomerName)" -ForegroundColor White
                        Write-Host "  Key: $($license.LicenseKey)" -ForegroundColor Cyan
                        Write-Host "  Exp: $($license.ExpiryDate)" -ForegroundColor Gray
                    }
                    
                    # Export option
                    Write-Host "`n📤 EXPORT OPTIONS:" -ForegroundColor Yellow
                    Write-Host "[1] Export all as CSV" -ForegroundColor Gray
                    Write-Host "[2] Export all as text" -ForegroundColor Gray
                    Write-Host "[3] Back to menu" -ForegroundColor Gray
                    
                    $exportChoice = Read-Host "`nSelect option"
                    
                    if ($exportChoice -eq "1") {
                        $exportFile = "licenses_export_$(Get-Date -Format 'yyyyMMdd_HHmmss').csv"
                        $licenses | Export-Csv -Path $exportFile -NoTypeInformation
                        Write-Host "[EXPORT] Saved to: $exportFile" -ForegroundColor Green
                    }
                    elseif ($exportChoice -eq "2") {
                        $exportFile = "licenses_export_$(Get-Date -Format 'yyyyMMdd_HHmmss').txt"
                        $text = "SEB LICENSES EXPORT`n$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')`n`n"
                        
                        foreach ($license in $licenses) {
                            $text += "Customer: $($license.CustomerName)`n"
                            $text += "License: $($license.LicenseKey)`n"
                            $text += "Computer: $($license.ComputerName)`n"
                            $text += "Expires: $($license.ExpiryDate)`n"
                            $text += "─" * 30 + "`n`n"
                        }
                        
                        $text | Out-File -FilePath $exportFile -Encoding UTF8
                        Write-Host "[EXPORT] Saved to: $exportFile" -ForegroundColor Green
                    }
                    
                } else {
                    Write-Host "`n[INFO] No license database found" -ForegroundColor Yellow
                    Write-Host "Generate some licenses first!" -ForegroundColor Gray
                }
                
                Read-Host "`nPress Enter to continue..."
            }
            
            "5" {
                # Exit
                Write-Host "`nThank you for using SEB License Generator!" -ForegroundColor Cyan
                Write-Host "Exiting..." -ForegroundColor Gray
                Start-Sleep -Seconds 2
                exit 0
            }
            
            default {
                Write-Host "`nInvalid choice! Please select 1-5." -ForegroundColor Red
                Start-Sleep -Seconds 1
            }
        }
    }
} catch {
    Write-Host "`n[ERROR] An error occurred: $_" -ForegroundColor Red
    Read-Host "Press Enter to exit..."
}