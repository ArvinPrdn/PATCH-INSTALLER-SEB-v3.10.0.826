# Script untuk generate License Keys baru
function New-LicenseKey {
    param(
        [string]$CustomerName,
        [string]$UserID,
        [string]$ExpiryDate,
        [int]$MaxInstalls = 1
    )
    
    # Generate random license key
    $chars = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789"
    $key = ""
    for ($i = 0; $i -lt 16; $i++) {
        $key += $chars[(Get-Random -Maximum $chars.Length)]
        if (($i + 1) % 4 -eq 0 -and $i -lt 15) {
            $key += "-"
        }
    }
    
    # Tambahkan ke $ValidLicenses di installer
    $licenseInfo = @"
    "$key" = @{
        UserID = "$UserID"
        CustomerName = "$CustomerName"
        ExpiryDate = "$ExpiryDate"
        MaxInstalls = $MaxInstalls
        InstallCount = 0
    }
"@
    
    Write-Host "License Key untuk $CustomerName:" -ForegroundColor Green
    Write-Host "License Key: $key" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Tambahkan ke installer:" -ForegroundColor Yellow
    Write-Host $licenseInfo
    Write-Host ""
    
    # Buat file license untuk dikirim ke customer
    $licenseFile = @"
===========================================
YOUR SOFTWARE - LICENSE KEY
===========================================
Customer: $CustomerName
User ID: $UserID
License Key: $key
Expiry Date: $ExpiryDate
Max Installations: $MaxInstalls

Cara Install:
1. Jalankan installer.exe
2. Masukkan License Key di atas
3. Ikuti instruksi instalasi

Support: support@yourcompany.com
===========================================
"@
    
    $licenseFile | Out-File -FilePath "License_$UserID.txt" -Encoding UTF8
    Write-Host "File license disimpan: License_$UserID.txt" -ForegroundColor Green
}

# Contoh generate license
New-LicenseKey -CustomerName "PT. Contoh Customer" -UserID "CUST004" -ExpiryDate "2024-12-31" -MaxInstalls 2
