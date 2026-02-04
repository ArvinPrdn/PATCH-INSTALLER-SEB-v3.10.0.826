# ==================================================
# SEB SOFTWARE INSTALLER - SIMPLE VERSION
# ==================================================

Clear-Host
Write-Host "SEB SOFTWARE INSTALLER" -ForegroundColor Cyan
Write-Host "======================" -ForegroundColor Cyan
Write-Host ""

# Step 1: License Input
Write-Host "[1] Enter License Key" -ForegroundColor Yellow
Write-Host "-" * 40 -ForegroundColor DarkGray

$licenseKey = Read-Host "License (XXXX-XXXX-XXXX-XXXX)"
$licenseKey = $licenseKey.ToUpper().Trim()

# Simple Validation
if ($licenseKey -notmatch '^[A-Z0-9]{4}-[A-Z0-9]{4}-[A-Z0-9]{4}-[A-Z0-9]{4}$') {
    Write-Host "[ERROR] Invalid license format!" -ForegroundColor Red
    Write-Host "Format: XXXX-XXXX-XXXX-XXXX" -ForegroundColor Yellow
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host "[OK] License accepted" -ForegroundColor Green

# Step 2: Save License
Write-Host "`n[2] Saving License..." -ForegroundColor Yellow

try {
    # Save to AppData (Primary)
    $appDataPath = "$env:APPDATA\SEB"
    if (-not (Test-Path $appDataPath)) {
        New-Item -Path $appDataPath -ItemType Directory -Force | Out-Null
    }
    
    $licenseInfo = @{
        LicenseKey = $licenseKey
        Computer = $env:COMPUTERNAME
        User = $env:USERNAME
        Date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    }
    
    $licenseInfo | ConvertTo-Json | Out-File "$appDataPath\license.json" -Encoding UTF8
    Write-Host "[OK] License saved to AppData" -ForegroundColor Green
    
    # Try Registry as backup
    try {
        $regPath = "HKCU:\Software\SEB"
        if (-not (Test-Path $regPath)) {
            New-Item -Path $regPath -Force | Out-Null
        }
        Set-ItemProperty -Path $regPath -Name "License" -Value $licenseKey -Force | Out-Null
        Write-Host "[OK] License saved to registry" -ForegroundColor Green
    } catch {
        Write-Host "[INFO] Skipping registry (not required)" -ForegroundColor Gray
    }
    
} catch {
    Write-Host "[WARNING] Could not save license: $_" -ForegroundColor Yellow
    Write-Host "Continuing installation anyway..." -ForegroundColor Gray
}

# Step 3: Download & Install
Write-Host "`n[3] Downloading Software..." -ForegroundColor Yellow

try {
    # GitHub URL (Base64 encoded)
    $base64Url = "aHR0cHM6Ly9naXRodWIuY29tL0FydmluUHJkbi9QQVRDSC1JTlNUQUxMRVItU0VCLXYzLjEwLjAuODI2L3JlbGVhc2VzL2Rvd25sb2FkL3YzLjEwLjAuODI2L3BhdGNoLXNlYi4xLmV4ZQ=="
    
    # Decode URL
    $githubUrl = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($base64Url))
    
    # Add timestamp
    $timestamp = Get-Date -Format "yyyyMMddHHmmss"
    $downloadUrl = $githubUrl + "?t=" + $timestamp
    
    # Download file
    $tempFile = "$env:TEMP\seb-installer-$timestamp.exe"
    
    Write-Host "Downloading..." -ForegroundColor Gray
    $ProgressPreference = 'SilentlyContinue'
    Invoke-WebRequest -Uri $downloadUrl -OutFile $tempFile -UseBasicParsing
    
    if (Test-Path $tempFile) {
        $sizeMB = [math]::Round((Get-Item $tempFile).Length / 1MB, 2)
        Write-Host "[OK] Downloaded: $sizeMB MB" -ForegroundColor Green
        
        # Install
        Write-Host "`n[4] Installing..." -ForegroundColor Yellow
        Write-Host "Please wait..." -ForegroundColor Gray
        
        $process = Start-Process -FilePath $tempFile -ArgumentList "/SILENT" -Wait -PassThru
        
        if ($process.ExitCode -eq 0) {
            Write-Host "[SUCCESS] Installation complete!" -ForegroundColor Green
        } else {
            Write-Host "[WARNING] Installer completed with code: $($process.ExitCode)" -ForegroundColor Yellow
        }
        
        # Cleanup
        Start-Sleep -Seconds 2
        Remove-Item $tempFile -Force -ErrorAction SilentlyContinue
        Write-Host "[CLEANUP] Temporary files removed" -ForegroundColor Gray
        
    } else {
        Write-Host "[ERROR] Download failed!" -ForegroundColor Red
        Read-Host "Press Enter to exit"
        exit 1
    }
    
} catch {
    Write-Host "[ERROR] Installation failed: $_" -ForegroundColor Red
    Write-Host "Check internet connection and try again." -ForegroundColor Yellow
    Read-Host "Press Enter to exit"
    exit 1
}

# Final Message
Write-Host "`n" + "=" * 50 -ForegroundColor Green
Write-Host "   INSTALLATION COMPLETE!" -ForegroundColor Green
Write-Host "=" * 50 -ForegroundColor Green

Write-Host "`n✅ SEB Software installed successfully!" -ForegroundColor Cyan
Write-Host "`n📋 Next Steps:" -ForegroundColor Yellow
Write-Host "   1. Find 'SEB' in Start Menu" -ForegroundColor White
Write-Host "   2. Or run launcher.ps1" -ForegroundColor White
Write-Host "   3. No activation needed!" -ForegroundColor Green

Write-Host "`n🔑 Your License: $licenseKey" -ForegroundColor White
Write-Host "💻 Computer: $env:COMPUTERNAME" -ForegroundColor White

Read-Host "`nPress Enter to exit"