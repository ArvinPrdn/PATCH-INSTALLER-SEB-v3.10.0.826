# ==================================================
# MOVE FOLDER SCRIPT
# Untuk pindah folder ke lokasi yang lebih baik
# ==================================================

Clear-Host
Write-Host "MOVE SEB FOLDER" -ForegroundColor Cyan
Write-Host "================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Current location: $PWD" -ForegroundColor White
Write-Host ""

Write-Host "Choose new location:" -ForegroundColor Yellow
Write-Host "[1] C:\SEB-System" -ForegroundColor White
Write-Host "[2] Documents\SEB-System" -ForegroundColor White
Write-Host "[3] Desktop\SEB-System" -ForegroundColor White
Write-Host "[4] Cancel" -ForegroundColor Red
Write-Host ""

$choice = Read-Host "Select (1-4)"

switch ($choice) {
    "1" { $newPath = "C:\SEB-System" }
    "2" { $newPath = "$env:USERPROFILE\Documents\SEB-System" }
    "3" { $newPath = "$env:USERPROFILE\Desktop\SEB-System" }
    "4" { 
        Write-Host "Cancelled." -ForegroundColor Yellow
        exit
    }
    default {
        Write-Host "Invalid choice!" -ForegroundColor Red
        exit
    }
}

# Check if destination exists
if (Test-Path $newPath) {
    Write-Host "Folder already exists: $newPath" -ForegroundColor Yellow
    $overwrite = Read-Host "Overwrite? (Y/N)"
    if ($overwrite -ne 'Y') {
        Write-Host "Cancelled." -ForegroundColor Yellow
        exit
    }
}

# Move files
Write-Host "`nMoving files..." -ForegroundColor Yellow

try {
    # Create destination
    New-Item -Path $newPath -ItemType Directory -Force | Out-Null
    
    # Copy all files
    $files = Get-ChildItem -Path $PWD -File
    foreach ($file in $files) {
        Copy-Item -Path $file.FullName -Destination $newPath -Force
        Write-Host "Copied: $($file.Name)" -ForegroundColor Gray
    }
    
    Write-Host "`n[SUCCESS] Files moved to: $newPath" -ForegroundColor Green
    
    # Create shortcut
    $shortcutPath = "$env:USERPROFILE\Desktop\SEB System.lnk"
    $WshShell = New-Object -ComObject WScript.Shell
    $Shortcut = $WshShell.CreateShortcut($shortcutPath)
    $Shortcut.TargetPath = "powershell.exe"
    $Shortcut.Arguments = "-NoProfile -ExecutionPolicy Bypass -File `"$newPath\installer.ps1`""
    $Shortcut.WorkingDirectory = $newPath
    $Shortcut.Description = "SEB Licensing System"
    $Shortcut.Save()
    
    Write-Host "Shortcut created on Desktop" -ForegroundColor Green
    
    Write-Host "`nNext steps:" -ForegroundColor Cyan
    Write-Host "1. Open folder: $newPath" -ForegroundColor White
    Write-Host "2. Run installer.ps1 from there" -ForegroundColor White
    Write-Host "3. Or use Desktop shortcut" -ForegroundColor White
    
} catch {
    Write-Host "[ERROR] Failed to move files: $_" -ForegroundColor Red
}

Read-Host "`nPress Enter to exit"