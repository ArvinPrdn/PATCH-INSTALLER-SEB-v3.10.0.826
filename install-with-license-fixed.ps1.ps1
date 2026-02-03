# ==================================================
# PATCH INSTALLER SEB v3.10.0.826
# With License Activation System (FIXED)
# ==================================================

# ===== LICENSE SYSTEM =====
$licenseRegistryPath = "HKLM:\SOFTWARE\PATCH-INSTALLER-SEB"
$licenseValueName = "LicenseKey"

function Test-License {
    # Cek apakah license sudah diaktivasi
    try {
        if (Test-Path $licenseRegistryPath) {
            $licenseKey = Get-ItemProperty -Path $licenseRegistryPath -Name $licenseValueName -ErrorAction SilentlyContinue
            if ($licenseKey.$licenseValueName) {
                return @{
                    Activated = $true
                    LicenseKey = $licenseKey.$licenseValueName
                    Message = "License already activated"
                }
            }
        }
        return @{Activated = $false; Message = "License not found"}
    } catch {
        return @{Activated = $false; Message = "Error checking license"}
    }
}

function Activate-License {
    param([string]$LicenseKey)
    
    # Validasi format license key
    if ($LicenseKey -notmatch '^[A-Z0-9]{4}-[A-Z0-9]{4}-[A-Z0-9]{4}-[A-Z0-9]{4}$') {
        return @{Success = $false; Message = "Invalid license key format!"}
    }
    
    try {
        # Simpan license ke registry
        if (-not (Test-Path $licenseRegistryPath)) {
            New-Item -Path $licenseRegistryPath -Force | Out-Null
        }
        
        New-ItemProperty -Path $licenseRegistryPath -Name $licenseValueName -Value $LicenseKey -PropertyType String -Force | Out-Null
        
        # Tambahkan activation date
        New-ItemProperty -Path $licenseRegistryPath -Name "ActivationDate" -Value (Get-Date -Format "yyyy-MM-dd") -PropertyType String -Force | Out-Null
        
        New-ItemProperty -Path $licenseRegistryPath -Name "ComputerName" -Value $env:COMPUTERNAME -PropertyType String -Force | Out-Null
        
        return @{Success = $true; Message = "License activated successfully!"}
    } catch {
        return @{Success = $false; Message = "Activation failed: $_"}
    }
}

# ===== MAIN INSTALLER =====
Clear-Host

# ===== ASCII LOGO =====
Write-Host @"
========================================================
        PATCH INSTALLER SEB v3.10.0.826       
========================================================
"@ -ForegroundColor Cyan

# ===== CEK LICENSE =====
Write-Host "`n[CHECK] Checking license..." -ForegroundColor Yellow
$licenseCheck = Test-License

if ($licenseCheck.Activated) {
    Write-Host "[SUCCESS] LICENSE ACTIVATED!" -ForegroundColor Green
    Write-Host "   License Key: $($licenseCheck.LicenseKey)" -ForegroundColor White
    Write-Host "   Computer: $env:COMPUTERNAME" -ForegroundColor White
    
    # Skip activation, langsung install
    Write-Host "`n[INFO] Proceeding to installation..." -ForegroundColor Cyan
} else {
    # Tampilkan activation screen
    Write-Host "`n[REQUIRED] LICENSE ACTIVATION REQUIRED" -ForegroundColor Yellow
    Write-Host "   Please enter your license key`n" -ForegroundColor White
    
    $activationSuccess = $false
    $maxAttempts = 3
    
    for ($attempt = 1; $attempt -le $maxAttempts; $attempt++) {
        Write-Host "[Attempt $attempt/$maxAttempts]" -ForegroundColor Gray
        Write-Host ("-" * 40) -ForegroundColor DarkGray
        
        $licenseKey = Read-Host "License Key (XXXX-XXXX-XXXX-XXXX)"
        
        $result = Activate-License -LicenseKey $licenseKey.ToUpper()
        
        if ($result.Success) {
            $activationSuccess = $true
            Write-Host "`n[SUCCESS] $($result.Message)" -ForegroundColor Green
            Write-Host "   Your software is now activated!" -ForegroundColor White
            break
        } else {
            Write-Host "[ERROR] $($result.Message)" -ForegroundColor Red
        }
    }
    
    if (-not $activationSuccess) {
        Write-Host "`n[FAILED] ACTIVATION FAILED!" -ForegroundColor Red
        Write-Host "   Please contact support for a valid license key." -ForegroundColor Yellow
        Write-Host "`nPress Enter to exit..." -ForegroundColor Gray
        Read-Host
        exit 1
    }
}

# ===== DOWNLOAD & INSTALL =====
Write-Host "`n" + ("=" * 60) -ForegroundColor Green
Write-Host "        DOWNLOADING INSTALLER...        " -ForegroundColor Green
Write-Host ("=" * 60) -ForegroundColor Green

$Url = "https://github.com/ArvinPrdn/PATCH-INSTALLER-SEB-v3.10.0.826/releases/download/v3.10.0.826/patch-seb.1.exe"
$Out = "$env:TEMP\patch-seb.exe"

try {
    # Download
    Write-Host "`n[1] Downloading..." -ForegroundColor Yellow
    Invoke-WebRequest -Uri $Url -OutFile $Out -UseBasicParsing
    Write-Host "[OK] Download completed" -ForegroundColor Green
    
    # Install
    Write-Host "`n[2] Installing..." -ForegroundColor Yellow
    Start-Process -FilePath $Out -Wait
    Write-Host "[OK] Installation completed" -ForegroundColor Green
    
    # Cleanup
    Write-Host "`n[3] Cleaning up..." -ForegroundColor Yellow
    if (Test-Path $Out) {
        Remove-Item $Out -Force
    }
    Write-Host "[OK] Cleanup completed" -ForegroundColor Green
    
} catch {
    Write-Host "[ERROR] Error: $_" -ForegroundColor Red
    exit 1
}

# ===== FINAL MESSAGE =====
Write-Host "`n" + ("=" * 60) -ForegroundColor Cyan
Write-Host "        INSTALLATION COMPLETED        " -ForegroundColor Green
Write-Host ("=" * 60) -ForegroundColor Cyan

Write-Host "`n[SUCCESS] YOUR SOFTWARE IS NOW ACTIVATED!" -ForegroundColor Magenta
Write-Host "   License: $(if ($licenseCheck.Activated) {$licenseCheck.LicenseKey} else {'Activated'})" -ForegroundColor White
Write-Host "   Computer: $env:COMPUTERNAME" -ForegroundColor White
Write-Host "   Date: $(Get-Date -Format 'yyyy-MM-dd')" -ForegroundColor White

Write-Host "`n[NEXT] What to do next:" -ForegroundColor Yellow
Write-Host "1. Find 'SEB' in Start Menu" -ForegroundColor White
Write-Host "2. Run the application" -ForegroundColor White
Write-Host "3. No need to activate again!" -ForegroundColor Green

Write-Host "`nPress Enter to exit..." -ForegroundColor Gray
Read-Host