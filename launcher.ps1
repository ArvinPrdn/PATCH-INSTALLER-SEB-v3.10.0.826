# ==================================================
# SEB SOFTWARE LAUNCHER - SIMPLE VERSION
# ==================================================

Clear-Host
Write-Host "SEB LAUNCHER" -ForegroundColor Cyan
Write-Host "============" -ForegroundColor Cyan
Write-Host ""

# Function to get license from storage
function Get-License {
    # Try AppData first
    $licenseFile = "$env:APPDATA\SEB\license.json"
    if (Test-Path $licenseFile) {
        try {
            $license = Get-Content $licenseFile -Raw | ConvertFrom-Json
            return $license.LicenseKey
        } catch {
            Write-Host "[WARNING] Could not read license file" -ForegroundColor Yellow
        }
    }
    
    # Try Registry
    try {
        $regPath = "HKCU:\Software\SEB"
        if (Test-Path $regPath) {
            $regLicense = Get-ItemProperty -Path $regPath -Name "License" -ErrorAction SilentlyContinue
            if ($regLicense.License) {
                return $regLicense.License
            }
        }
    } catch {
        # Continue to next method
    }
    
    return $null
}

# Check license
Write-Host "Checking license..." -ForegroundColor Yellow
$license = Get-License

if (-not $license) {
    Write-Host "[ERROR] No valid license found!" -ForegroundColor Red
    Write-Host "Please run installer.ps1 first." -ForegroundColor Yellow
    Read-Host "`nPress Enter to exit"
    exit 1
}

# Validate license format
if ($license -match '^[A-Z0-9]{4}-[A-Z0-9]{4}-[A-Z0-9]{4}-[A-Z0-9]{4}$') {
    Write-Host "[OK] License valid: $license" -ForegroundColor Green
} else {
    Write-Host "[ERROR] Invalid license format!" -ForegroundColor Red
    Write-Host "Please reinstall with valid license." -ForegroundColor Yellow
    Read-Host "`nPress Enter to exit"
    exit 1
}

# Launch application
Write-Host "`nLaunching SEB application..." -ForegroundColor Yellow

$appPaths = @(
    "C:\Program Files\SEB\seb-app.exe",
    "C:\Program Files (x86)\SEB\seb-app.exe",
    "$env:PROGRAMFILES\SEB\seb-app.exe"
)

$appFound = $false
foreach ($path in $appPaths) {
    if (Test-Path $path) {
        try {
            Start-Process -FilePath $path
            Write-Host "[SUCCESS] Application launched!" -ForegroundColor Green
            $appFound = $true
            break
        } catch {
            Write-Host "[ERROR] Could not launch: $path" -ForegroundColor Red
        }
    }
}

if (-not $appFound) {
    Write-Host "`n[ERROR] Application not found!" -ForegroundColor Red
    Write-Host "Possible causes:" -ForegroundColor Yellow
    Write-Host "  1. Software not installed" -ForegroundColor White
    Write-Host "  2. Installation incomplete" -ForegroundColor White
    Write-Host "  3. Files moved or deleted" -ForegroundColor White
    
    Write-Host "`nSolutions:" -ForegroundColor Cyan
    Write-Host "  1. Run installer.ps1 again" -ForegroundColor White
    Write-Host "  2. Contact support" -ForegroundColor White
    
    $choice = Read-Host "`nRun installer now? (Y/N)"
    if ($choice -eq 'Y') {
        Start-Process powershell -ArgumentList "-File `"installer.ps1`""
    }
}

Write-Host "`nPress Enter to exit..." -ForegroundColor Gray
Read-Host