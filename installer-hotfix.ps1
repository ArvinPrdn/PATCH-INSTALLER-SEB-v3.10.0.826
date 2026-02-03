# ==================================================
# SEB INSTALLER HOTFIX - NO ADMIN REQUIRED
# ==================================================

Clear-Host
Write-Host "=================================================" -ForegroundColor Cyan
Write-Host "         SEB SOFTWARE - HOTFIX INSTALLER" -ForegroundColor Cyan
Write-Host "=================================================" -ForegroundColor Cyan
Write-Host ""

# 1. TANYAKAN LICENSE KEY
Write-Host "[1] LICENSE ACTIVATION" -ForegroundColor Yellow
Write-Host "-" * 40 -ForegroundColor DarkGray

$licenseKey = Read-Host "Enter Your License Key"
$licenseKey = $licenseKey.ToUpper().Trim()

# VALIDASI SIMPLE
if ($licenseKey -notmatch '^[A-Z0-9]{4}-[A-Z0-9]{4}-[A-Z0-9]{4}-[A-Z0-9]{4}$') {
    Write-Host "[ERROR] Invalid license format!" -ForegroundColor Red
    Write-Host "Format: XXXX-XXXX-XXXX-XXXX" -ForegroundColor Yellow
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host "[OK] License format valid" -ForegroundColor Green

# 2. SIMPAN LICENSE (TANPA ADMIN)
Write-Host "`n[2] SAVING LICENSE..." -ForegroundColor Yellow

try {
    # Method 1: Simpan di AppData (100% work, no admin)
    $appDataPath = "$env:APPDATA\SEB"
    if (-not (Test-Path $appDataPath)) {
        New-Item -Path $appDataPath -ItemType Directory -Force | Out-Null
    }
    
    # Simpan license ke file
    $licenseInfo = @{
        LicenseKey = $licenseKey
        ComputerName = $env:COMPUTERNAME
        ActivationDate = (Get-Date -Format "yyyy-MM-dd HH:mm:ss")
        WindowsUser = $env:USERNAME
    }
    
    $licenseInfo | ConvertTo-Json | Out-File "$appDataPath\license.json" -Encoding UTF8
    Write-Host "[OK] License saved to: $appDataPath\license.json" -ForegroundColor Green
    
    # Method 2: Coba HKCU (optional)
    try {
        $regPath = "HKCU:\Software\SEB"
        if (-not (Test-Path $regPath)) {
            New-Item -Path $regPath -Force | Out-Null
        }
        Set-ItemProperty -Path $regPath -Name "LicenseKey" -Value $licenseKey -Force | Out-Null
        Write-Host "[OK] Also saved to registry" -ForegroundColor Green
    } catch {
        # Skip if can't write to registry
    }
    
} catch {
    Write-Host "[WARNING] Could not save license file: $_" -ForegroundColor Yellow
    Write-Host "Continuing installation anyway..." -ForegroundColor Gray
}

# 3. DOWNLOAD & INSTALL
Write-Host "`n[3] DOWNLOADING SOFTWARE..." -ForegroundColor Yellow

try {
    # GitHub URL (Base64 encoded)
    $base64Url = "aHR0cHM6Ly9naXRodWIuY29tL0FydmluUHJkbi9QQVRDSC1JTlNUQUxMRVItU0VCLXYzLjEwLjAuODI2L3JlbGVhc2VzL2Rvd25sb2FkL3YzLjEwLjAuODI2L3BhdGNoLXNlYi4xLmV4ZQ=="
    
    # Decode URL
    $githubUrl = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($base64Url))
    
    # Tambahkan timestamp untuk hindari cache
    $timestamp = Get-Date -Format "yyyyMMddHHmmss"
    $downloadUrl = $githubUrl + "?t=" + $timestamp
    
    # File output
    $outputFile = "$env:TEMP\seb-installer-$timestamp.exe"
    
    Write-Host "Downloading from GitHub..." -ForegroundColor Gray
    Write-Host "Please wait..." -ForegroundColor Gray
    
    # Download
    $ProgressPreference = 'SilentlyContinue'
    Invoke-WebRequest -Uri $downloadUrl -OutFile $outputFile -UseBasicParsing
    
    if (Test-Path $outputFile) {
        $sizeMB = [math]::Round((Get-Item $outputFile).Length / 1MB, 2)
        Write-Host "[OK] Downloaded: $sizeMB MB" -ForegroundColor Green
        
        # Install
        Write-Host "`n[4] INSTALLING..." -ForegroundColor Yellow
        $process = Start-Process -FilePath $outputFile -ArgumentList "/SILENT /NORESTART" -Wait -PassThru
        
        if ($process.ExitCode -eq 0) {
            Write-Host "[SUCCESS] Installation complete!" -ForegroundColor Green
        } else {
            Write-Host "[WARNING] Installer exited with code: $($process.ExitCode)" -ForegroundColor Yellow
        }
        
        # Cleanup
        Start-Sleep -Seconds 3
        Remove-Item $outputFile -Force -ErrorAction SilentlyContinue
        Write-Host "[CLEANUP] Temporary files removed" -ForegroundColor Gray
        
    } else {
        Write-Host "[ERROR] Download failed!" -ForegroundColor Red
        Read-Host "Press Enter to exit"
        exit 1
    }
    
} catch {
    Write-Host "[ERROR] Installation failed: $_" -ForegroundColor Red
    Write-Host "Please check internet connection and try again." -ForegroundColor Yellow
    Read-Host "Press Enter to exit"
    exit 1
}

# 4. UPDATE LAUNCHER JIKA PERLU
Write-Host "`n[5] UPDATING LAUNCHER..." -ForegroundColor Yellow

try {
    # Check if launcher exists
    $launcherPath = "$env:APPDATA\SEB\launcher-fixed.ps1"
    
    if (-not (Test-Path $launcherPath)) {
        # Buat launcher baru yang baca dari file (bukan registry)
        $launcherCode = @'
# ==================================================
# SEB LAUNCHER - HOTFIX VERSION
# Reads license from file, not registry
# ==================================================

$licenseFile = "$env:APPDATA\SEB\license.json"

if (Test-Path $licenseFile) {
    $license = Get-Content $licenseFile | ConvertFrom-Json
    Write-Host "License: $($license.LicenseKey)" -ForegroundColor Green
    Write-Host "Computer: $($license.ComputerName)" -ForegroundColor Gray
    
    # Lanjutkan ke aplikasi
    $appPath = "C:\Program Files\SEB\seb-app.exe"
    if (Test-Path $appPath) {
        Start-Process $appPath
    } else {
        Write-Host "Application not found!" -ForegroundColor Red
    }
} else {
    Write-Host "License not found! Please reinstall." -ForegroundColor Red
    Read-Host "Press Enter to exit"
}
'@
        
        $launcherCode | Out-File $launcherPath -Encoding UTF8
        Write-Host "[OK] New launcher created" -ForegroundColor Green
    }
    
} catch {
    Write-Host "[WARNING] Could not update launcher" -ForegroundColor Yellow
}

# 5. FINAL MESSAGE
Write-Host "`n" + ("=" * 60) -ForegroundColor Green
Write-Host "         INSTALLATION COMPLETED SUCCESSFULLY!" -ForegroundColor Green
Write-Host ("=" * 60) -ForegroundColor Green

Write-Host "`n✅ YOUR SOFTWARE IS READY TO USE!" -ForegroundColor Cyan
Write-Host "`n📋 IMPORTANT INFORMATION:" -ForegroundColor Yellow
Write-Host "   License Key: $licenseKey" -ForegroundColor White
Write-Host "   Saved to: %APPDATA%\SEB\license.json" -ForegroundColor White
Write-Host "   Computer: $env:COMPUTERNAME" -ForegroundColor White
Write-Host "   User: $env:USERNAME" -ForegroundColor White

Write-Host "`n🚀 NEXT STEPS:" -ForegroundColor Yellow
Write-Host "   1. Find 'SEB' in Start Menu" -ForegroundColor White
Write-Host "   2. Launch the application" -ForegroundColor White
Write-Host "   3. It should work without issues" -ForegroundColor Green

Write-Host "`n📞 IF YOU HAVE PROBLEMS:" -ForegroundColor Cyan
Write-Host "   Contact support with this information:" -ForegroundColor White
Write-Host "   - License Key above" -ForegroundColor Gray
Write-Host "   - Computer Name above" -ForegroundColor Gray
Write-Host "   - Error message if any" -ForegroundColor Gray

Write-Host "`nPress Enter to exit..." -ForegroundColor Gray
Read-Host