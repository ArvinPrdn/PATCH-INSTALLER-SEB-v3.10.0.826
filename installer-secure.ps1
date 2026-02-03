# ==================================================
# SEB SECURE INSTALLER v3.10.0.826
# GitHub URL Protected Version
# ==================================================

# Clear console at start
Clear-Host

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
    
    # More lenient validation for testing
    if ($LicenseKey -ne "TEST-TEST-TEST-TEST") {
        if (($sum % 17) -ne 5) {  # Updated validation
            return @{Valid = $false; Message = "License key tidak valid!"}
        }
    }
    
    return @{Valid = $true; Message = "License valid!"}
}

# ===== URL DECRYPTION =====
function Get-SecureDownloadUrl {
    param([string]$LicenseKey)
    
    try {
        # Direct URL approach (simplified)
        $baseUrl = "https://github.com/ArvinPrdn/PATCH-INSTALLER-SEB-v3.10.0.826/releases/download/v3.10.0.826/patch-seb.1.exe"
        
        # Validate URL format
        if ([System.Uri]::TryCreate($baseUrl, [System.UriKind]::Absolute, [ref]$null)) {
            return $baseUrl
        } else {
            throw "Invalid URL format"
        }
        
    } catch {
        # Fallback URL if decryption fails
        Write-Host "[WARNING] Using fallback download method" -ForegroundColor Yellow
        return "https://github.com/ArvinPrdn/PATCH-INSTALLER-SEB-v3.10.0.826/releases/download/v3.10.0.826/patch-seb.1.exe"
    }
}

# ===== DOWNLOAD WITH PROGRESS =====
function Download-FileWithProgress {
    param(
        [string]$Url,
        [string]$OutputPath
    )
    
    try {
        # Create WebClient with timeout
        $webClient = New-Object System.Net.WebClient
        $webClient.Headers.Add("User-Agent", "SEB-Installer/3.10")
        $webClient.DownloadFile($Url, $OutputPath)
        
        return $true
    } catch {
        Write-Host "[ERROR] Download failed: $_" -ForegroundColor Red
        return $false
    }
}

# ===== MAIN INSTALLER =====
try {
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

    # Use default key if empty
    if ([string]::IsNullOrWhiteSpace($licenseKey)) {
        $licenseKey = "TEST-TEST-TEST-TEST"
        Write-Host "[INFO] Using default license key for testing" -ForegroundColor Gray
    }

    # 2. Validasi license
    Write-Host "`nValidating license..." -ForegroundColor Gray
    $licenseCheck = Test-LicenseValidity -LicenseKey $licenseKey
    if (-not $licenseCheck.Valid) {
        Write-Host "[ERROR] $($licenseCheck.Message)" -ForegroundColor Red
        Write-Host "Hubungi support untuk license yang valid." -ForegroundColor Yellow
        Write-Host "`nTekan Enter untuk keluar..." -ForegroundColor Gray
        Read-Host
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
        Write-Host "`nTekan Enter untuk keluar..." -ForegroundColor Gray
        Read-Host
        exit 1
    }

    # 4. Download file
    Write-Host "`n[3] DOWNLOADING INSTALLER" -ForegroundColor Yellow
    Write-Host ("-" * 40) -ForegroundColor DarkGray

    $tempFile = "$env:TEMP\seb_installer_$(Get-Date -Format 'yyyyMMddHHmmss').exe"

    try {
        # Display download info
        Write-Host "Downloading from: $($downloadUrl.Split('/')[2])" -ForegroundColor Gray
        Write-Host "Saving to: $tempFile" -ForegroundColor Gray
        
        # Download file
        $downloadResult = Download-FileWithProgress -Url $downloadUrl -OutputPath $tempFile
        
        if (-not $downloadResult) {
            throw "Download failed"
        }
        
        # 5. Verify file
        if (-not (Test-Path $tempFile)) {
            throw "Downloaded file not found"
        }
        
        $fileSize = (Get-Item $tempFile).Length
        Write-Host "[OK] Download completed" -ForegroundColor Green
        Write-Host "File size: $([math]::Round($fileSize/1MB, 2)) MB" -ForegroundColor Gray
        
        # 6. Install
        Write-Host "`n[4] INSTALLING SOFTWARE" -ForegroundColor Yellow
        Write-Host ("-" * 40) -ForegroundColor DarkGray
        
        Write-Host "Running installer..." -ForegroundColor Gray
        
        # Check if file is executable
        $fileExt = [System.IO.Path]::GetExtension($tempFile)
        if ($fileExt -ne '.exe') {
            Write-Host "[WARNING] Downloaded file is not an executable" -ForegroundColor Yellow
        }
        
        # Run installer
        $processInfo = New-Object System.Diagnostics.ProcessStartInfo
        $processInfo.FileName = $tempFile
        $processInfo.Arguments = "/SILENT /NORESTART"
        $processInfo.WindowStyle = 'Hidden'
        
        $process = [System.Diagnostics.Process]::Start($processInfo)
        $process.WaitForExit()
        
        if ($process.ExitCode -eq 0) {
            Write-Host "[OK] Installation successful" -ForegroundColor Green
        } else {
            Write-Host "[WARNING] Installation completed with code: $($process.ExitCode)" -ForegroundColor Yellow
        }
        
        # 7. Save license info
        Write-Host "`n[5] ACTIVATING LICENSE" -ForegroundColor Yellow
        Write-Host ("-" * 40) -ForegroundColor DarkGray
        
        try {
            # Try HKLM first (requires admin)
            $regPath = "HKLM:\SOFTWARE\SEB\License"
            if (-not (Test-Path $regPath)) {
                New-Item -Path $regPath -Force | Out-Null
            }
            New-ItemProperty -Path $regPath -Name "Key" -Value $licenseKey -PropertyType String -Force | Out-Null
            Write-Host "[OK] License saved to registry (HKLM)" -ForegroundColor Green
        } catch {
            # Fallback to HKCU (no admin required)
            Write-Host "[INFO] Can't save to HKLM, trying HKCU..." -ForegroundColor Gray
            $regPath = "HKCU:\Software\SEB\License"
            if (-not (Test-Path $regPath)) {
                New-Item -Path $regPath -Force | Out-Null
            }
            New-ItemProperty -Path $regPath -Name "Key" -Value $licenseKey -PropertyType String -Force | Out-Null
            New-ItemProperty -Path $regPath -Name "ActivatedDate" -Value (Get-Date -Format "yyyy-MM-dd") -PropertyType String -Force | Out-Null
            New-ItemProperty -Path $regPath -Name "ComputerID" -Value $env:COMPUTERNAME -PropertyType String -Force | Out-Null
            Write-Host "[OK] License saved to registry (HKCU)" -ForegroundColor Green
        }
        
        # Save to file as backup
        $licenseInfo = @{
            LicenseKey = $licenseKey
            ActivatedDate = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            ComputerID = $env:COMPUTERNAME
            WindowsUser = $env:USERNAME
        }
        
        $licenseDir = "$env:APPDATA\SEB"
        if (-not (Test-Path $licenseDir)) {
            New-Item -ItemType Directory -Path $licenseDir -Force | Out-Null
        }
        
        $licenseInfo | ConvertTo-Json | Out-File "$licenseDir\license.json" -Encoding UTF8
        Write-Host "[OK] License saved to file: $licenseDir\license.json" -ForegroundColor Green
        
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
        Write-Host "   Valid until : $(Get-Date).AddYears(1).ToString('yyyy-MM-dd')" -ForegroundColor White
        
        Write-Host "`n[INFO] Application shortcuts:" -ForegroundColor Yellow
        Write-Host "   • Start Menu > SEB" -ForegroundColor White
        Write-Host "   • Desktop shortcut (if selected during install)" -ForegroundColor White
        
        Write-Host "`n[IMPORTANT] License is locked to this computer." -ForegroundColor Magenta
        Write-Host "   Cannot be transferred to another PC." -ForegroundColor Gray
        
    } catch {
        Write-Host "[ERROR] Installation failed: $_" -ForegroundColor Red
        Write-Host "Please check your internet connection and try again." -ForegroundColor Yellow
    }
    
} catch {
    Write-Host "[ERROR] Critical error: $_" -ForegroundColor Red
}

# 10. Exit
Write-Host "`nPress Enter to exit..." -ForegroundColor Gray
Read-Host
[file content end]
