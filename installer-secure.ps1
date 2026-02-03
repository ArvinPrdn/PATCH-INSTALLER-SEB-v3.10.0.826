# ==================================================
# SEB SECURE INSTALLER v3.10.0.826
# GitHub URL Protected Version
# ==================================================

# ===== LICENSE CHECK =====
function Test-LicenseValidity {
    param([string]$LicenseKey)
    
    # Pattern validation
    if ($LicenseKey -notmatch '^[A-Z0-9]{4}-[A-Z0-9]{4}-[A-Z0-9]{4}-[A-Z0-9]{4}$') {
        return @{Valid = $false; Message = "Format license salah!"}
    }
    
    # Simple checksum validation
    $cleanKey = $LicenseKey -replace '-', ''
    $sum = 0
    foreach ($char in $cleanKey.ToCharArray()) {
        $sum += [int][char]$char
    }
    
    if (($sum % 13) -ne 7) {  # Contoh validasi sederhana
        return @{Valid = $false; Message = "License key tidak valid!"}
    }
    
    return @{Valid = $true; Message = "License valid!"}
}

# ===== URL DECRYPTION =====
function Get-SecureDownloadUrl {
    param([string]$LicenseKey)
    
    # ENCRYPTED GITHUB URL (Base64 + simple XOR)
    $encryptedParts = @(
        "ZjY4NzM2MDcwNmU2OTc0Njg3MzovLyIs",
        "ImczNjY5NzQ2ODcyNzU2MjNkMmU2MzZj",
        "NmU2NDY5NzIyYzY5NmU2NDY1NzI3NDZl",
        "NjE2NDY1NmU3NDJlNjM2ZjZkL0EiLA=="
    )
    
    # 1. Gabungkan bagian
    $fullEncoded = -join $encryptedParts
    
    # 2. Decode Base64
    $base64Decoded = [System.Text.Encoding]::UTF8.GetString(
        [System.Convert]::FromBase64String($fullEncoded)
    )
    
    # 3. Simple XOR decryption dengan license key
    $keyBytes = [System.Text.Encoding]::UTF8.GetBytes($LicenseKey)
    $dataBytes = [System.Text.Encoding]::UTF8.GetBytes($base64Decoded)
    
    $decryptedBytes = @()
    for ($i = 0; $i -lt $dataBytes.Length; $i++) {
        $keyIndex = $i % $keyBytes.Length
        $decryptedBytes += $dataBytes[$i] -bxor $keyBytes[$keyIndex]
    }
    
    $decryptedUrl = [System.Text.Encoding]::UTF8.GetString($decryptedBytes)
    
    # 4. Parse URL yang didecrypt
    # Format: "https://github.com/ArvinPrdn/PATCH-INSTALLER-SEB-v3.10.0.826/releases/download/v3.10.0.826/patch-seb.1.exe"
    
    return $decryptedUrl
}

# ===== MAIN INSTALLER =====
Clear-Host
Write-Host @"
========================================================
           SEB SECURE INSTALLATION
           Version 3.10.0.826
========================================================
"@ -ForegroundColor Cyan

# 1. Minta license key
Write-Host "`n[1] LICENSE ACTIVATION" -ForegroundColor Yellow
Write-Host ("-" * 40) -ForegroundColor DarkGray

$licenseKey = Read-Host "Masukkan License Key (XXXX-XXXX-XXXX-XXXX)"
$licenseKey = $licenseKey.ToUpper().Trim()

# 2. Validasi license
$licenseCheck = Test-LicenseValidity -LicenseKey $licenseKey
if (-not $licenseCheck.Valid) {
    Write-Host "[ERROR] $($licenseCheck.Message)" -ForegroundColor Red
    Write-Host "Hubungi support untuk license yang valid." -ForegroundColor Yellow
    Read-Host "`nTekan Enter untuk keluar..."
    exit 1
}

Write-Host "[SUCCESS] License valid!" -ForegroundColor Green

# 3. Get secure download URL
Write-Host "`n[2] PREPARING SECURE DOWNLOAD" -ForegroundColor Yellow
Write-Host ("-" * 40) -ForegroundColor DarkGray

try {
    $downloadUrl = Get-SecureDownloadUrl -LicenseKey $licenseKey
    Write-Host "[INFO] Secure channel established" -ForegroundColor Green
} catch {
    Write-Host "[ERROR] Failed to prepare download" -ForegroundColor Red
    exit 1
}

# 4. Download file
Write-Host "`n[3] DOWNLOADING INSTALLER" -ForegroundColor Yellow
Write-Host ("-" * 40) -ForegroundColor DarkGray

$tempFile = "$env:TEMP\seb_$([Guid]::NewGuid().ToString().Substring(0,8)).exe"

try {
    # Add custom headers untuk identifikasi
    $headers = @{
        "User-Agent" = "SEB-Installer/3.10"
        "X-License-ID" = ($licenseKey -replace '-', '').Substring(0, 8)
        "X-Request-Time" = (Get-Date -Format "yyyyMMddHHmmss")
    }
    
    Write-Host "Downloading secure package..." -ForegroundColor Gray
    Invoke-WebRequest -Uri $downloadUrl -Headers $headers -OutFile $tempFile -UseBasicParsing
    Write-Host "[OK] Download completed" -ForegroundColor Green
    
    # 5. Verify file
    if (-not (Test-Path $tempFile)) {
        throw "Downloaded file not found"
    }
    
    $fileSize = (Get-Item $tempFile).Length
    if ($fileSize -lt 1000000) {  # Minimal 1MB
        throw "File size invalid"
    }
    
    Write-Host "File size: $([math]::Round($fileSize/1MB, 2)) MB" -ForegroundColor Gray
    
    # 6. Install
    Write-Host "`n[4] INSTALLING SOFTWARE" -ForegroundColor Yellow
    Write-Host ("-" * 40) -ForegroundColor DarkGray
    
    Write-Host "Running installer..." -ForegroundColor Gray
    $process = Start-Process -FilePath $tempFile -ArgumentList "/SILENT /NORESTART" -PassThru -WindowStyle Hidden
    $process.WaitForExit()
    
    if ($process.ExitCode -eq 0) {
        Write-Host "[OK] Installation successful" -ForegroundColor Green
    } else {
        Write-Host "[WARNING] Installation completed with code: $($process.ExitCode)" -ForegroundColor Yellow
    }
    
    # 7. Save license info
    Write-Host "`n[5] ACTIVATING LICENSE" -ForegroundColor Yellow
    Write-Host ("-" * 40) -ForegroundColor DarkGray
    
    $regPath = "HKLM:\SOFTWARE\SEB\License"
    if (-not (Test-Path $regPath)) {
        New-Item -Path $regPath -Force | Out-Null
    }
    
    New-ItemProperty -Path $regPath -Name "Key" -Value $licenseKey -PropertyType String -Force | Out-Null
    New-ItemProperty -Path $regPath -Name "ActivatedDate" -Value (Get-Date -Format "yyyy-MM-dd") -PropertyType String -Force | Out-Null
    New-ItemProperty -Path $regPath -Name "ComputerID" -Value $env:COMPUTERNAME -PropertyType String -Force | Out-Null
    New-ItemProperty -Path $regPath -Name "WindowsUser" -Value $env:USERNAME -PropertyType String -Force | Out-Null
    
    Write-Host "[OK] License activated for this computer" -ForegroundColor Green
    
    # 8. Cleanup
    Write-Host "`n[6] CLEANING UP" -ForegroundColor Yellow
    Write-Host ("-" * 40) -ForegroundColor DarkGray
    
    Start-Sleep -Seconds 2
    if (Test-Path $tempFile) {
        Remove-Item $tempFile -Force -ErrorAction SilentlyContinue
        Write-Host "[OK] Temporary files removed" -ForegroundColor Green
    }
    
    # 9. Success message
    Write-Host "`n" + ("=" * 50) -ForegroundColor Green
    Write-Host "       INSTALLATION COMPLETE!        " -ForegroundColor Green
    Write-Host ("=" * 50) -ForegroundColor Green
    
    Write-Host "`n[SUCCESS] SEB v3.10.0.826 installed successfully!" -ForegroundColor Cyan
    Write-Host "   License  : $licenseKey" -ForegroundColor White
    Write-Host "   Computer : $env:COMPUTERNAME" -ForegroundColor White
    Write-Host "   User     : $env:USERNAME" -ForegroundColor White
    Write-Host "   Date     : $(Get-Date -Format 'yyyy-MM-dd HH:mm')" -ForegroundColor White
    
    Write-Host "`n[INFO] Application shortcuts:" -ForegroundColor Yellow
    Write-Host "   • Start Menu > SEB" -ForegroundColor White
    Write-Host "   • Desktop shortcut (if selected during install)" -ForegroundColor White
    
    Write-Host "`n[IMPORTANT] License is locked to this computer." -ForegroundColor Magenta
    Write-Host "   Cannot be transferred to another PC." -ForegroundColor Gray
    
} catch {
    Write-Host "[ERROR] Installation failed: $_" -ForegroundColor Red
    Write-Host "Please check your internet connection and try again." -ForegroundColor Yellow
}

# 10. Exit
Write-Host "`nPress Enter to exit..." -ForegroundColor Gray
Read-Host
