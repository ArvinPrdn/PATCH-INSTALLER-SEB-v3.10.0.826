# ==================================================
# SEB UNINSTALLER WITH LICENSE CLEANUP
# ==================================================

Clear-Host

Write-Host @"
╔══════════════════════════════════════════════════════════╗
║              SEB APPLICATION UNINSTALLER                ║
╚══════════════════════════════════════════════════════════╝
"@ -ForegroundColor Cyan

Write-Host "`n[⚠️] WARNING: This will remove SEB application and license." -ForegroundColor Yellow
Write-Host "`nAre you sure you want to uninstall?" -ForegroundColor White
Write-Host "[Y] Yes, uninstall" -ForegroundColor Red
Write-Host "[N] No, cancel" -ForegroundColor Green

$choice = Read-Host "`nChoice (Y/N)"

if ($choice -notin @('Y','y')) {
    Write-Host "`nUninstallation cancelled." -ForegroundColor Yellow
    exit 0
}

# ===== REMOVE LICENSE =====
Write-Host "`n[1] Removing license..." -ForegroundColor Yellow
$licenseRegistryPath = "HKLM:\SOFTWARE\PATCH-INSTALLER-SEB"

if (Test-Path $licenseRegistryPath) {
    try {
        Remove-Item -Path $licenseRegistryPath -Recurse -Force
        Write-Host "[✓] License removed" -ForegroundColor Green
    } catch {
        Write-Host "[⚠️] Could not remove license: $_" -ForegroundColor Yellow
    }
} else {
    Write-Host "[ℹ️] No license found" -ForegroundColor Gray
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
            Write-Host "[✓] Removed: $path" -ForegroundColor Green
        } catch {
            Write-Host "[⚠️] Could not remove: $path" -ForegroundColor Yellow
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
        Write-Host "[✓] Removed shortcut" -ForegroundColor Green
    }
}

# ===== FINAL MESSAGE =====
Write-Host "`n" + ("=" * 50) -ForegroundColor Cyan
Write-Host "        UNINSTALLATION COMPLETE        " -ForegroundColor Green
Write-Host ("=" * 50) -ForegroundColor Cyan

Write-Host "`n[✅] SEB has been uninstalled successfully!" -ForegroundColor Green
Write-Host "   License has been deactivated" -ForegroundColor White
Write-Host "   Application files removed" -ForegroundColor White
Write-Host "   Shortcuts removed" -ForegroundColor White

Write-Host "`n[💡] To reinstall, run the installer again with a new license." -ForegroundColor Cyan

Write-Host "`nPress Enter to exit..." -ForegroundColor Gray
Read-Host
