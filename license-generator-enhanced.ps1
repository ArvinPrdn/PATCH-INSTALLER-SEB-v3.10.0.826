# ==================================================
# ENHANCED LICENSE GENERATOR
# With URL encryption compatibility
# ==================================================

function New-SEBLicense {
    param(
        [string]$CustomerName,
        [string]$ComputerName = "ANY-PC",
        [int]$DaysValid = 365
    )
    
    # Generate unique ID
    $seed = "$CustomerName|$ComputerName|$(Get-Date -Format 'yyyyMMddHHmmss')|$(Get-Random -Maximum 999999)"
    $hashInput = [System.Text.Encoding]::UTF8.GetBytes($seed)
    
    # Double hash untuk keamanan
    $md5 = [System.Security.Cryptography.MD5]::Create()
    $hash1 = $md5.ComputeHash($hashInput)
    $hash2 = $md5.ComputeHash($hash1)
    
    # Format: XXXX-XXXX-XXXX-XXXX
    $licenseKey = [System.BitConverter]::ToString($hash2).Replace('-', '').Substring(0, 16)
    $licenseKey = $licenseKey.Insert(4, '-').Insert(9, '-').Insert(14, '-').ToUpper()
    
    # Validasi checksum (untuk installer)
    $cleanKey = $licenseKey -replace '-', ''
    $checksum = 0
    foreach ($char in $cleanKey.ToCharArray()) {
        $checksum += [int][char]$char
    }
    
    # Ensure checksum mod 13 = 7 (sesuai validasi di installer)
    $currentMod = $checksum % 13
    if ($currentMod -ne 7) {
        # Adjust last character untuk match checksum
        $adjustment = (7 - $currentMod) % 13
        $lastCharCode = [int][char]$cleanKey[15]
        $newLastCharCode = (($lastCharCode + $adjustment - 48) % 26) + 48
        
        if ($newLastCharCode -gt 57) {  # Jika melebihi '9'
            $newLastCharCode = 65 + ($newLastCharCode - 58)  # Pindah ke 'A'
        }
        
        $newLastChar = [char]$newLastCharCode
        $licenseKey = $licenseKey.Substring(0, 18) + $newLastChar
    }
    
    # Expiry date
    $expiryDate = (Get-Date).AddDays($DaysValid).ToString("yyyy-MM-dd")
    
    return @{
        LicenseKey = $licenseKey
        CustomerName = $CustomerName
        ComputerName = $ComputerName.ToUpper()
        ExpiryDate = $expiryDate
        GeneratedDate = (Get-Date -Format "yyyy-MM-dd HH:mm:ss")
        DaysValid = $DaysValid
        Checksum = $checksum
    }
}

# Menu utama
Clear-Host
Write-Host @"
========================================
   SEB LICENSE GENERATOR v2.0
   With URL Protection System
========================================
"@ -ForegroundColor Magenta

Write-Host "`n[1] Generate Single License" -ForegroundColor Cyan
Write-Host "[2] Generate Bulk Licenses" -ForegroundColor Cyan
Write-Host "[3] Test License Validation" -ForegroundColor Cyan
Write-Host "[4] Update Installer Script" -ForegroundColor Cyan
Write-Host "[5] Exit" -ForegroundColor Cyan

$choice = Read-Host "`nPilih menu (1-5)"

switch ($choice) {
    "1" {
        Clear-Host
        Write-Host "`n" + ("="*50) -ForegroundColor Green
        Write-Host "          GENERATE SINGLE LICENSE          " -ForegroundColor Green
        Write-Host ("="*50) -ForegroundColor Green
        
        $customer = Read-Host "`nCustomer Name"
        $computer = Read-Host "Computer Name [default: ANY-PC]"
        $days = Read-Host "Valid for (days) [default: 365]"
        
        if ([string]::IsNullOrWhiteSpace($computer)) { $computer = "ANY-PC" }
        if ([string]::IsNullOrWhiteSpace($days)) { $days = 365 }
        
        $license = New-SEBLicense -CustomerName $customer -ComputerName $computer -DaysValid $days
        
        Write-Host "`n" + ("-"*50) -ForegroundColor DarkGray
        Write-Host "[SUCCESS] LICENSE GENERATED!" -ForegroundColor Green
        Write-Host ("-"*50) -ForegroundColor DarkGray
        
        Write-Host "`nLicense Details:" -ForegroundColor Yellow
        Write-Host "  Customer   : $($license.CustomerName)" -ForegroundColor White
        Write-Host "  Computer   : $($license.ComputerName)" -ForegroundColor White
        Write-Host "  License    : $($license.LicenseKey)" -ForegroundColor Cyan
        Write-Host "  Generated  : $($license.GeneratedDate)" -ForegroundColor White
        Write-Host "  Expires    : $($license.ExpiryDate)" -ForegroundColor White
        Write-Host "  Valid Days : $($license.DaysValid)" -ForegroundColor White
        
        # Save to CSV
        $license | Export-Csv -Path "licenses.csv" -Append -NoTypeInformation
        Write-Host "`n[SAVED] License saved to licenses.csv" -ForegroundColor Gray
        
        # Show usage instructions
        Write-Host "`n[INSTRUCTIONS] Give this to user:" -ForegroundColor Magenta
        Write-Host "1. Send installer-secure.ps1 to user" -ForegroundColor White
        Write-Host "2. User runs the script" -ForegroundColor White
        Write-Host "3. Enter license: $($license.LicenseKey)" -ForegroundColor Cyan
        Write-Host "4. Installation will proceed" -ForegroundColor White
    }
    
    "3" {
        Clear-Host
        Write-Host "`n" + ("="*50) -ForegroundColor Green
        Write-Host "          TEST LICENSE VALIDATION          " -ForegroundColor Green
        Write-Host ("="*50) -ForegroundColor Green
        
        $testKey = Read-Host "`nEnter License Key to test"
        
        # Simulate installer validation
        if ($testKey -match '^[A-Z0-9]{4}-[A-Z0-9]{4}-[A-Z0-9]{4}-[A-Z0-9]{4}$') {
            $cleanKey = $testKey -replace '-', ''
            $sum = 0
            foreach ($char in $cleanKey.ToCharArray()) {
                $sum += [int][char]$char
            }
            
            if (($sum % 13) -eq 7) {
                Write-Host "`n[VALID] License key would PASS installer validation!" -ForegroundColor Green
                Write-Host "Checksum: $sum" -ForegroundColor White
                Write-Host "Mod 13: $($sum % 13)" -ForegroundColor White
            } else {
                Write-Host "`n[INVALID] License key would FAIL installer validation!" -ForegroundColor Red
                Write-Host "Checksum: $sum" -ForegroundColor White
                Write-Host "Mod 13: $($sum % 13) (should be 7)" -ForegroundColor Yellow
            }
        } else {
            Write-Host "`n[INVALID] Wrong format!" -ForegroundColor Red
            Write-Host "Should be: XXXX-XXXX-XXXX-XXXX" -ForegroundColor Yellow
        }
    }
    
    "4" {
        Clear-Host
        Write-Host "`n" + ("="*50) -ForegroundColor Green
        Write-Host "          UPDATE INSTALLER SCRIPT          " -ForegroundColor Green
        Write-Host ("="*50) -ForegroundColor Green
        
        $githubUrl = Read-Host "`nEnter GitHub .exe URL"
        Write-Host "`nEncrypting URL..." -ForegroundColor Yellow
        
        # Simple encryption untuk demo
        $bytes = [System.Text.Encoding]::UTF8.GetBytes($githubUrl)
        $base64 = [Convert]::ToBase64String($bytes)
        
        Write-Host "`nEncrypted URL (Base64):" -ForegroundColor Cyan
        Write-Host $base64 -ForegroundColor White
        
        Write-Host "`nAdd this to installer-secure.ps1:" -ForegroundColor Yellow
        Write-Host @'
    # Decode GitHub URL
    $base64Url = "PASTE_BASE64_HERE"
    $githubUrl = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($base64Url))
'@ -ForegroundColor Gray
    }
}

Write-Host "`nPress Enter to continue..." -ForegroundColor Gray
Read-Host