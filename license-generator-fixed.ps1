# ==================================================
# PATCH INSTALLER SEB - LICENSE GENERATOR (FIXED)
# ==================================================

Clear-Host

Write-Host @"
========================================================
         PATCH INSTALLER SEB - LICENSE GENERATOR        
========================================================
"@ -ForegroundColor Magenta

# ===== FUNGSI GENERATE LICENSE =====
function New-LicenseKey {
    param(
        [string]$CustomerName,
        [string]$ComputerName,
        [int]$DaysValid = 365  # 1 tahun
    )
    
    # 1. Buat unique ID berdasarkan nama + komputer + tanggal
    $uniqueString = "$CustomerName|$ComputerName|$(Get-Date -Format 'yyyyMMdd')"
    
    # 2. Generate MD5 hash
    $hash = [System.BitConverter]::ToString(
        [System.Security.Cryptography.MD5]::Create().ComputeHash(
            [System.Text.Encoding]::UTF8.GetBytes($uniqueString)
        )
    ).Replace('-', '').ToUpper()
    
    # 3. Format license key (XXXX-XXXX-XXXX-XXXX)
    $licenseKey = $hash.Substring(0, 4) + "-" + 
                  $hash.Substring(4, 4) + "-" + 
                  $hash.Substring(8, 4) + "-" + 
                  $hash.Substring(12, 4)
    
    # 4. Calculate expiry date
    $expiryDate = (Get-Date).AddDays($DaysValid).ToString("yyyy-MM-dd")
    
    return @{
        LicenseKey = $licenseKey
        CustomerName = $CustomerName
        ComputerName = $ComputerName.ToUpper()
        ExpiryDate = $expiryDate
        GeneratedDate = (Get-Date -Format "yyyy-MM-dd")
    }
}

# ===== MENU UTAMA =====
Write-Host "`n[1] Generate Single License" -ForegroundColor Cyan
Write-Host "[2] Generate Bulk Licenses" -ForegroundColor Cyan
Write-Host "[3] Verify License Key" -ForegroundColor Cyan
Write-Host "[4] Exit" -ForegroundColor Cyan

Write-Host "`n" + ("-" * 50) -ForegroundColor DarkGray
$choice = Read-Host "Pilih menu (1-4)"

switch ($choice) {
    "1" {
        # Generate single license
        Clear-Host
        Write-Host "`n" + ("=" * 50) -ForegroundColor Green
        Write-Host "          GENERATE SINGLE LICENSE          " -ForegroundColor Green
        Write-Host ("=" * 50) -ForegroundColor Green
        
        $customerName = Read-Host "`nCustomer Name"
        $computerName = Read-Host "Computer Name"
        $daysValid = Read-Host "Valid for (days) [default: 365]"
        
        if ([string]::IsNullOrWhiteSpace($daysValid)) {
            $daysValid = 365
        }
        
        $license = New-LicenseKey -CustomerName $customerName -ComputerName $computerName -DaysValid $daysValid
        
        Write-Host "`n" + ("-" * 50) -ForegroundColor DarkGray
        Write-Host "[SUCCESS] LICENSE GENERATED SUCCESSFULLY!" -ForegroundColor Green
        Write-Host ("-" * 50) -ForegroundColor DarkGray
        
        Write-Host "`n[INFO] LICENSE DETAILS:" -ForegroundColor Yellow
        Write-Host "   Customer    : $($license.CustomerName)" -ForegroundColor White
        Write-Host "   Computer    : $($license.ComputerName)" -ForegroundColor White
        Write-Host "   License Key : " -NoNewline
        Write-Host "$($license.LicenseKey)" -ForegroundColor Cyan
        Write-Host "   Generated   : $($license.GeneratedDate)" -ForegroundColor White
        Write-Host "   Valid Until : $($license.ExpiryDate)" -ForegroundColor White
        
        # Save to CSV
        $license | Export-Csv -Path "licenses.csv" -Append -NoTypeInformation
        Write-Host "`n[SAVED] License saved to licenses.csv" -ForegroundColor Gray
    }
    
    "2" {
        # Generate bulk licenses
        Clear-Host
        Write-Host "`n" + ("=" * 50) -ForegroundColor Green
        Write-Host "          GENERATE BULK LICENSES          " -ForegroundColor Green
        Write-Host ("=" * 50) -ForegroundColor Green
        
        Write-Host "`nEnter customer data (Format: CustomerName,ComputerName,DaysValid)"
        Write-Host "Example: Budi Santoso,PC-IT-01,365" -ForegroundColor Gray
        Write-Host "Press Enter on empty line to finish`n" -ForegroundColor Gray
        
        $licenses = @()
        $counter = 1
        
        while ($true) {
            $inputLine = Read-Host "Customer #$counter"
            if ([string]::IsNullOrWhiteSpace($inputLine)) {
                break
            }
            
            $parts = $inputLine -split ','
            if ($parts.Count -ge 2) {
                $customerName = $parts[0].Trim()
                $computerName = $parts[1].Trim()
                $daysValid = if ($parts.Count -ge 3) { [int]$parts[2].Trim() } else { 365 }
                
                $license = New-LicenseKey -CustomerName $customerName -ComputerName $computerName -DaysValid $daysValid
                
                $licenses += $license
                $counter++
            }
        }
        
        if ($licenses.Count -gt 0) {
            # Save all to CSV
            $licenses | Export-Csv -Path "bulk_licenses_$(Get-Date -Format 'yyyyMMdd').csv" -NoTypeInformation
            
            Write-Host "`n" + ("-" * 50) -ForegroundColor DarkGray
            Write-Host "            GENERATED LICENSES              " -ForegroundColor Cyan
            Write-Host ("-" * 50) -ForegroundColor DarkGray
            
            foreach ($license in $licenses) {
                Write-Host "`n$($license.CustomerName)" -ForegroundColor White
                Write-Host "  Computer: $($license.ComputerName)" -ForegroundColor Gray
                Write-Host "  License: $($license.LicenseKey)" -ForegroundColor Cyan
                Write-Host "  Expires: $($license.ExpiryDate)" -ForegroundColor Gray
            }
            
            Write-Host "`n[SAVED] Saved to: bulk_licenses_$(Get-Date -Format 'yyyyMMdd').csv" -ForegroundColor Green
        }
    }
    
    "3" {
        # Verify license key
        Clear-Host
        Write-Host "`n" + ("=" * 50) -ForegroundColor Green
        Write-Host "            VERIFY LICENSE KEY            " -ForegroundColor Green
        Write-Host ("=" * 50) -ForegroundColor Green
        
        $licenseKey = Read-Host "`nEnter License Key"
        $computerName = Read-Host "Enter Computer Name"
        
        # Simple verification logic
        $isValid = $licenseKey -match '^[A-Z0-9]{4}-[A-Z0-9]{4}-[A-Z0-9]{4}-[A-Z0-9]{4}$'
        
        if ($isValid) {
            Write-Host "`n[SUCCESS] LICENSE KEY FORMAT VALID!" -ForegroundColor Green
            Write-Host "   Computer: $computerName" -ForegroundColor White
            Write-Host "   Status: Ready for activation" -ForegroundColor White
        } else {
            Write-Host "`n[ERROR] INVALID LICENSE KEY FORMAT!" -ForegroundColor Red
            Write-Host "   Format harus: XXXX-XXXX-XXXX-XXXX" -ForegroundColor Yellow
        }
    }
    
    "4" {
        exit 0
    }
}

Write-Host "`n`nPress any key to exit..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
