# ==================================================
# SEB APPLICATION LAUNCHER (FIXED)
# Checks license before launching main app
# ==================================================

# ===== LICENSE CHECK =====
$licenseRegistryPath = "HKLM:\SOFTWARE\PATCH-INSTALLER-SEB"
$appPath = "C:\Program Files\SEB\seb-app.exe"

function Check-License {
    try {
        if (-not (Test-Path $licenseRegistryPath)) {
            return @{Valid = $false; Message = "Software not activated!"}
        }
        
        $license = Get-ItemProperty -Path $licenseRegistryPath -Name "LicenseKey" -ErrorAction SilentlyContinue
        if (-not $license.LicenseKey) {
            return @{Valid = $false; Message = "License key not found!"}
        }
        
        # Validasi format license
        if ($license.LicenseKey -notmatch '^[A-Z0-9]{4}-[A-Z0-9]{4}-[A-Z0-9]{4}-[A-Z0-9]{4}$') {
            return @{Valid = $false; Message = "Invalid license format!"}
        }
        
        return @{Valid = $true; LicenseKey = $license.LicenseKey}
        
    } catch {
        return @{Valid = $false; Message = "License check error: $_"}
    }
}

# ===== MAIN CHECK =====
$licenseResult = Check-License

if (-not $licenseResult.Valid) {
    # Show error message
    Write-Host "================================================" -ForegroundColor Red
    Write-Host "            LICENSE ERROR" -ForegroundColor Red
    Write-Host "================================================" -ForegroundColor Red
    Write-Host "`n$($licenseResult.Message)" -ForegroundColor Yellow
    Write-Host "`nPlease re-activate the software." -ForegroundColor White
    Write-Host "`nPress any key to exit..." -ForegroundColor Gray
    $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
    exit 1
}

# ===== LAUNCH APPLICATION =====
try {
    if (Test-Path $appPath) {
        Write-Host "[INFO] Launching SEB application..." -ForegroundColor Green
        Start-Process -FilePath $appPath
    } else {
        Write-Host "================================================" -ForegroundColor Yellow
        Write-Host "        APPLICATION NOT FOUND" -ForegroundColor Yellow
        Write-Host "================================================" -ForegroundColor Yellow
        
        Write-Host "`nThe SEB application was not found." -ForegroundColor White
        Write-Host "`nWould you like to install it now?" -ForegroundColor White
        Write-Host "[Y] Yes, install" -ForegroundColor Green
        Write-Host "[N] No, exit" -ForegroundColor Red
        
        $choice = Read-Host "`nChoice (Y/N)"
        
        if ($choice -in @('Y','y')) {
            Write-Host "`n[INFO] Starting installer..." -ForegroundColor Green
            Start-Process "powershell" -ArgumentList "-File `"$PSScriptRoot\install-with-license-fixed.ps1`"" -Verb RunAs
        }
    }
} catch {
    Write-Host "================================================" -ForegroundColor Red
    Write-Host "            LAUNCH ERROR" -ForegroundColor Red
    Write-Host "================================================" -ForegroundColor Red
    Write-Host "`nError launching application: $_" -ForegroundColor Yellow
    Write-Host "`nPress any key to exit..." -ForegroundColor Gray
    $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
}
