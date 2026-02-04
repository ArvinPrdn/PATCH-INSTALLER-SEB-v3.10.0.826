# ==================================================
# SEB UNINSTALLER - SIMPLE VERSION
# ==================================================

Clear-Host
Write-Host "SEB UNINSTALLER" -ForegroundColor Cyan
Write-Host "================" -ForegroundColor Cyan
Write-Host ""

Write-Host "This will remove:" -ForegroundColor Yellow
Write-Host "• SEB application files" -ForegroundColor White
Write-Host "• License data" -ForegroundColor White
Write-Host "• Registry entries" -ForegroundColor White
Write-Host "• Shortcuts" -ForegroundColor White
Write-Host ""

$confirm = Read-Host "Are you sure? (Type 'YES' to continue)"

if ($confirm -ne "YES") {
    Write-Host "Uninstallation cancelled." -ForegroundColor Yellow
    Read-Host "Press Enter to exit"
    exit
}

Write-Host "`nUninstalling..." -ForegroundColor Yellow

# Remove application files
$appPaths = @(
    "C:\Program Files\SEB",
    "C:\Program Files (x86)\SEB"
)

foreach ($path in $appPaths) {
    if (Test-Path $path) {
        try {
            Remove-Item -Path $path -Recurse -Force -ErrorAction SilentlyContinue
            Write-Host "Removed: $path" -ForegroundColor Green
        } catch {
            Write-Host "Could not remove: $path" -ForegroundColor Yellow
        }
    }
}

# Remove license data
$dataPaths = @(
    "$env:APPDATA\SEB",
    "$env:LOCALAPPDATA\SEB",
    "$env:PROGRAMDATA\SEB"
)

foreach ($path in $dataPaths) {
    if (Test-Path $path) {
        try {
            Remove-Item -Path $path -Recurse -Force -ErrorAction SilentlyContinue
            Write-Host "Removed data: $path" -ForegroundColor Green
        } catch {
            Write-Host "Could not remove data: $path" -ForegroundColor Yellow
        }
    }
}

# Remove registry entries
$regPaths = @(
    "HKCU:\Software\SEB",
    "HKCU:\Software\PATCH-INSTALLER-SEB"
)

foreach ($regPath in $regPaths) {
    if (Test-Path $regPath) {
        try {
            Remove-Item -Path $regPath -Recurse -Force -ErrorAction SilentlyContinue
            Write-Host "Removed registry: $regPath" -ForegroundColor Green
        } catch {
            Write-Host "Could not remove registry: $regPath" -ForegroundColor Yellow
        }
    }
}

# Remove shortcuts
$shortcuts = @(
    "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\SEB.lnk",
    "$env:PUBLIC\Desktop\SEB.lnk",
    "$env:USERPROFILE\Desktop\SEB.lnk"
)

foreach ($shortcut in $shortcuts) {
    if (Test-Path $shortcut) {
        Remove-Item -Path $shortcut -Force -ErrorAction SilentlyContinue
        Write-Host "Removed shortcut" -ForegroundColor Green
    }
}

Write-Host "`n" + "=" * 40 -ForegroundColor Green
Write-Host "   UNINSTALLATION COMPLETE!" -ForegroundColor Green
Write-Host "=" * 40 -ForegroundColor Green

Write-Host "`n✅ SEB Software has been uninstalled." -ForegroundColor Cyan
Write-Host "All files, data, and settings have been removed." -ForegroundColor White

Write-Host "`nTo reinstall, run installer.ps1 with a new license." -ForegroundColor Yellow

Read-Host "`nPress Enter to exit"