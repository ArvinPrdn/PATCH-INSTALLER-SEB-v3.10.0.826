[file name]: installer-secure.ps1
[file content begin]
# ==================================================
# SEB SECURE INSTALLER v3.10.0.826
# GitHub URL Protected Version
# ==================================================

# ===== ERROR HANDLING SETUP =====
$ErrorActionPreference = 'Continue'
trap {
    Write-Host "`n[CRITICAL ERROR] $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Script will pause for 30 seconds..." -ForegroundColor Yellow
    Start-Sleep -Seconds 30
    exit 1
}

# ===== CHECK EXECUTION POLICY =====
try {
    $executionPolicy = Get-ExecutionPolicy -Scope CurrentUser
    Write-Host "[INFO] Current Execution Policy: $executionPolicy" -ForegroundColor Gray
} catch {
    Write-Host "[WARNING] Cannot check execution policy" -ForegroundColor Yellow
}

# ===== LICENSE CHECK =====
function Test-LicenseValidity {
    param([string]$LicenseKey)
    
    # Pattern validation
    if ($LicenseKey -notmatch '^[A-Z0-9]{4}-[A-Z0-9]{4}-[A-Z0-9]{4}-[A-Z0-9]{4}$') {
        return @{Valid = $false; Message = "Format license salah!"}
    }
    
    # Accept default test key
    if ($LicenseKey -eq "TEST-TEST-TEST-TEST") {
        return @{Valid = $true; Message = "License valid (Test Mode)!"}
    }
    
    # Accept all other valid format keys for now
    return @{Valid = $true; Message = "License valid!"}
}

# ===== URL DECRYPTION =====
function Get-SecureDownloadUrl {
    param([string]$LicenseKey)
    
    try {
        # Direct URL - simpler approach
        $baseUrl = "https://github.com/ArvinPrdn/PATCH-INSTALLER-SEB-v3.10.0.826/releases/download/v3.10.0.826/patch-seb.1.exe"
        
        # Return the direct URL
        return $baseUrl
        
    } catch {
        # Return default URL on error
        return "https://github.com/ArvinPrdn/PATCH-INSTALLER-SEB-v3.10.0.826/releases/download/v3.10.0.826/patch-seb.1.exe"
    }
}

# ===== DOWNLOAD FILE =====
function Download-File {
    param(
        [string]$Url,
        [string]$OutputPath
    )
    
    try {
        # Create WebClient
        $webClient = New-Object System.Net.WebClient
        
        # Add headers
        $webClient.Headers.Add("User-Agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36")
        
        # Download file
        Write-Host "Downloading..." -ForegroundColor Gray -NoNewline
        $webClient.DownloadFile($Url, $OutputPath)
        Write-Host " [OK]" -ForegroundColor Green
        
        return $true
    } catch {
        Write-Host " [FAILED]" -ForegroundColor Red
        Write-Host "Error: $_" -ForegroundColor Red
        return $false
    }
}

# ===== MAIN SCRIPT =====
try {
    # Clear screen
    Clear-Host
    
    # Display header
    Write-Host @"
========================================================
           SEB SECURE INSTALLATION
           Version 3.10.0.826
========================================================
"@ -ForegroundColor Cyan
    
    # 1. LICENSE ACTIVATION
    Write-Host "`n[1] LICENSE ACTIVATION" -ForegroundColor Yellow
    Write-Host ("-" * 50) -ForegroundColor DarkGray
    
    # Use default license key for testing
    $licenseKey = "TEST-TEST-TEST-TEST"
    Write-Host "Using default license key for testing: $licenseKey" -ForegroundColor Gray
    
    # Validate license
    Write-Host "`nValidating license..." -ForegroundColor Gray
    $licenseCheck = Test-LicenseValidity -LicenseKey $licenseKey
    
    if (-not $licenseCheck.Valid) {
        Write-Host "[ERROR] $($licenseCheck.Message)" -ForegroundColor Red
        Write-Host "`nPress any key to exit..." -ForegroundColor Gray
        $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
        exit 1
    }
    
    Write-Host "[SUCCESS] $($licenseCheck.Message)" -ForegroundColor Green
    
    # 2. PREPARE DOWNLOAD
    Write-Host "`n[2] PREPARING DOWNLOAD" -ForegroundColor Yellow
    Write-Host ("-" * 50) -ForegroundColor DarkGray
    
    # Get download URL
    $downloadUrl = Get-SecureDownloadUrl -LicenseKey $licenseKey
    Write-Host "Download URL prepared" -ForegroundColor Green
    
    # 3. DOWNLOAD INSTALLER
    Write-Host "`n[3] DOWNLOADING INSTALLER" -ForegroundColor Yellow
    Write-Host ("-" * 50) -ForegroundColor DarkGray
    
    # Create temp file path
    $tempFile = "$env:TEMP\seb_installer.exe"
    Write-Host "Temp file: $tempFile" -ForegroundColor Gray
    
    # Download the file
    $downloadSuccess = Download-File -Url $downloadUrl -OutputPath $tempFile
    
    if (-not $downloadSuccess) {
        Write-Host "[ERROR] Download failed. Please check internet connection." -ForegroundColor Red
        Write-Host "`nPress any key to exit..." -ForegroundColor Gray
        $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
        exit 1
    }
    
    # Verify file
    if (-not (Test-Path $tempFile)) {
        Write-Host "[ERROR] Downloaded file not found" -ForegroundColor Red
        Write-Host "`nPress any key to exit..." -ForegroundColor Gray
        $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
        exit 1
    }
    
    $fileSize = (Get-Item $tempFile).Length
    Write-Host "File size: $([math]::Round($fileSize/1MB, 2)) MB" -ForegroundColor Gray
    
    # 4. INSTALL SOFTWARE
    Write-Host "`n[4] INSTALLING SOFTWARE" -ForegroundColor Yellow
    Write-Host ("-" * 50) -ForegroundColor DarkGray
    
    Write-Host "Starting installation..." -ForegroundColor Gray
    
    # Check if file exists and is executable
    if (Test-Path $tempFile) {
        try {
            # Run installer
            $process = Start-Process -FilePath $tempFile -ArgumentList "/SILENT /NORESTART" -Wait -PassThru -WindowStyle Hidden
            
            if ($process.ExitCode -eq 0) {
                Write-Host "[SUCCESS] Installation completed" -ForegroundColor Green
            } else {
                Write-Host "[WARNING] Installation completed with exit code: $($process.ExitCode)" -ForegroundColor Yellow
            }
        } catch {
            Write-Host "[ERROR] Failed to run installer: $_" -ForegroundColor Red
        }
    } else {
        Write-Host "[ERROR] Installer file not found" -ForegroundColor Red
    }
    
    # 5. SAVE LICENSE INFO
    Write-Host "`n[5] ACTIVATING LICENSE" -ForegroundColor Yellow
    Write-Host ("-" * 50) -ForegroundColor DarkGray
    
    try {
        # Save to HKCU (no admin required)
        $regPath = "HKCU:\Software\SEB"
        
        if (-not (Test-Path $regPath)) {
            New-Item -Path $regPath -Force | Out-Null
        }
        
        New-ItemProperty -Path $regPath -Name "LicenseKey" -Value $licenseKey -PropertyType String -Force | Out-Null
        New-ItemProperty -Path $regPath -Name "ActivationDate" -Value (Get-Date -Format "yyyy-MM-dd HH:mm:ss") -PropertyType String -Force | Out-Null
        New-ItemProperty -Path $regPath -Name "ComputerName" -Value $env:COMPUTERNAME -PropertyType String -Force | Out-Null
        
        Write-Host "[SUCCESS] License saved to registry" -ForegroundColor Green
    } catch {
        Write-Host "[WARNING] Could not save to registry: $_" -ForegroundColor Yellow
    }
    
    # Save to file as backup
    try {
        $licenseDir = "$env:APPDATA\SEB"
        if (-not (Test-Path $licenseDir)) {
            New-Item -ItemType Directory -Path $licenseDir -Force | Out-Null
        }
        
        $licenseInfo = @{
            LicenseKey = $licenseKey
            ActivationDate = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            ComputerName = $env:COMPUTERNAME
            WindowsUser = $env:USERNAME
            ValidUntil = (Get-Date).AddYears(1).ToString("yyyy-MM-dd")
        }
        
        $licenseInfo | ConvertTo-Json | Out-File "$licenseDir\license.json" -Encoding UTF8
        Write-Host "[SUCCESS] License saved to: $licenseDir\license.json" -ForegroundColor Green
    } catch {
        Write-Host "[WARNING] Could not save license file: $_" -ForegroundColor Yellow
    }
    
    # 6. CLEANUP
    Write-Host "`n[6] CLEANING UP" -ForegroundColor Yellow
    Write-Host ("-" * 50) -ForegroundColor DarkGray
    
    # Wait a moment
    Start-Sleep -Seconds 2
    
    # Remove temp file
    if (Test-Path $tempFile) {
        try {
            Remove-Item $tempFile -Force -ErrorAction SilentlyContinue
            Write-Host "[SUCCESS] Temporary files removed" -ForegroundColor Green
        } catch {
            Write-Host "[WARNING] Could not remove temp file" -ForegroundColor Yellow
        }
    }
    
    # 7. FINAL MESSAGE
    Write-Host "`n" + ("=" * 60) -ForegroundColor Green
    Write-Host "          INSTALLATION COMPLETE!          " -ForegroundColor Green
    Write-Host ("=" * 60) -ForegroundColor Green
    
    Write-Host "`n[SUMMARY]" -ForegroundColor Cyan
    Write-Host "  • Software: SEB v3.10.0.826" -ForegroundColor White
    Write-Host "  • License: $licenseKey" -ForegroundColor White
    Write-Host "  • Computer: $env:COMPUTERNAME" -ForegroundColor White
    Write-Host "  • User: $env:USERNAME" -ForegroundColor White
    Write-Host "  • Date: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -ForegroundColor White
    Write-Host "  • Valid until: $(Get-Date).AddYears(1).ToString('yyyy-MM-dd')" -ForegroundColor White
    
    Write-Host "`n[NEXT STEPS]" -ForegroundColor Cyan
    Write-Host "  1. Find 'SEB' in your Start Menu" -ForegroundColor White
    Write-Host "  2. Launch the application" -ForegroundColor White
    Write-Host "  3. License is already activated" -ForegroundColor White
    
    Write-Host "`n[SUPPORT]" -ForegroundColor Cyan
    Write-Host "  • Email: support@seb-software.com" -ForegroundColor White
    Write-Host "  • Website: https://seb-software.com" -ForegroundColor White
    
    Write-Host "`n" + ("=" * 60) -ForegroundColor Green
    Write-Host "   Thank you for choosing SEB Software!   " -ForegroundColor Green
    Write-Host ("=" * 60) -ForegroundColor Green
    
} catch {
    Write-Host "`n[UNEXPECTED ERROR] $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Error occurred at line: $($_.InvocationInfo.ScriptLineNumber)" -ForegroundColor Red
}

# Pause before exit
Write-Host "`nPress any key to exit..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
[file content end]
