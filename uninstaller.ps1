# ==================================================
# SEB UNINSTALLER WITH LICENSE CLEANUP (FIXED)
# ==================================================

Clear-Host

Write-Host @"
========================================================
          SEB APPLICATION UNINSTALLER                  
========================================================
"@ -ForegroundColor Cyan

Write-Host "`n[WARNING] This will remove SEB application and license." -ForegroundColor Yellow
Write-Host "`nAre you sure you want to uninstall?" -ForegroundColor White
Write-Host "[Y] Yes, uninstall" -ForegroundColor Red
Write-Host "[N] No, cancel" -ForegroundColor Green

$choice = Read-Host "`nChoice (Y/N)"

if ($choice -notin @('Y','y')) {
    Write-Host "`n[INFO] Uninstallation cancelled." -ForegroundColor Yellow
    exit 0
}

# ===== REMOVE LICENSE =====
Write-Host "`n[1] Removing license..." -ForegroundColor Yellow

# Remove from HKCU Registry
$licenseRegistryPathCU = "HKCU:\Software\SEB\License"
if (Test-Path $licenseRegistryPathCU) {
    try {
        Remove-Item -Path $licenseRegistryPathCU -Recurse -Force
        Write-Host "[OK] License removed from HKCU registry" -ForegroundColor Green
    } catch {
        Write-Host "[WARNING] Could not remove license from HKCU: $_" -ForegroundColor Yellow
    }
} else {
    Write-Host "[INFO] No license found in HKCU registry" -ForegroundColor Gray
}

# Remove from HKLM Registry (requires admin)
$licenseRegistryPathLM = "HKLM:\SOFTWARE\SEB\License"
if (Test-Path $licenseRegistryPathLM) {
    try {
        Remove-Item -Path $licenseRegistryPathLM -Recurse -Force
        Write-Host "[OK] License removed from HKLM registry" -ForegroundColor Green
    } catch {
        Write-Host "[WARNING] Could not remove license from HKLM: $_" -ForegroundColor Yellow
    }
} else {
    Write-Host "[INFO] No license found in HKLM registry" -ForegroundColor Gray
}

# Remove license JSON file
$licenseJsonPath = "$env:APPDATA\SEB\license.json"
if (Test-Path $licenseJsonPath) {
    try {
        Remove-Item -Path $licenseJsonPath -Force
        Write-Host "[OK] License JSON file removed" -ForegroundColor Green
    } catch {
        Write-Host "[WARNING] Could not remove license JSON file: $_" -ForegroundColor Yellow
    }
} else {
    Write-Host "[INFO] No license JSON file found" -ForegroundColor Gray
}

# Remove ProgramData license file
$licenseTxtPath = "C:\ProgramData\SEB\license.txt"
if (Test-Path $licenseTxtPath) {
    try {
        Remove-Item -Path $licenseTxtPath -Force
        Write-Host "[OK] ProgramData license file removed" -ForegroundColor Green
    } catch {
        Write-Host "[WARNING] Could not remove ProgramData license file: $_" -ForegroundColor Yellow
    }
} else {
    Write-Host "[INFO] No ProgramData license file found" -ForegroundColor Gray
}

# ===== REMOVE APPLICATION =====
Write-Host "`n[2] Removing application..." -ForegroundColor Yellow
$appPaths = @(
    "C:\Program Files\SEB",
    "C:\Program Files (x86)\SEB",
    "$env:LOCALAPPDATA\SEB",
    "$env:APPDATA\SEB"
)

foreach ($path in $appPaths) {
    if (Test-Path $path) {
        try {
            Remove-Item -Path $path -Recurse -Force -ErrorAction SilentlyContinue
            Write-Host "[OK] Removed: $path" -ForegroundColor Green
        } catch {
            Write-Host "[WARNING] Could not remove: $path" -ForegroundColor Yellow
        }
    }
}

# ===== REMOVE SHORTCUTS =====
Write-Host "`n[3] Removing shortcuts..." -ForegroundColor Yellow
$shortcutPaths = @(
    "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\SEB.lnk",
    "$env:PUBLIC\Desktop\SEB.lnk",
    "$env:USERPROFILE\Desktop\SEB.lnk"
)

foreach ($shortcut in $shortcutPaths) {
    if (Test-Path $shortcut) {
        Remove-Item -Path $shortcut -Force -ErrorAction SilentlyContinue
        Write-Host "[OK] Removed shortcut" -ForegroundColor Green
    }
}

# ===== FINAL MESSAGE =====
Write-Host "`n" + ("=" * 50) -ForegroundColor Cyan
Write-Host "        UNINSTALLATION COMPLETE        " -ForegroundColor Green
Write-Host ("=" * 50) -ForegroundColor Cyan

Write-Host "`n[SUCCESS] SEB has been uninstalled successfully!" -ForegroundColor Green
Write-Host "   License has been deactivated" -ForegroundColor White
Write-Host "   Application files removed" -ForegroundColor White
Write-Host "   Shortcuts removed" -ForegroundColor White

Write-Host "`n[INFO] To reinstall, run the installer again with a new license." -ForegroundColor Cyan

Write-Host "`nPress Enter to exit..." -ForegroundColor Gray
Read-Host