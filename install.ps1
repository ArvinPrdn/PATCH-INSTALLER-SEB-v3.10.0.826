# ==================================================
# PATCH INSTALLER SEB v3.10.0.826
# Safe • Silent • Stable
# ==================================================

# ===== FIXED UTF-8 CONFIGURATION =====
$OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::InputEncoding = [System.Text.Encoding]::UTF8

Clear-Host

# ===== COMPATIBLE ASCII LOGO (100% WORKS) =====
$Logo = @"
================================================================================
            _         _          _______      _______ _   _               _       
           | |       | |   /\   |  __ \ \    / /_   _| \ | |             | |      
  _ __ ___ | |__   __| |  /  \  | |__) \ \  / /  | | |  \| |_ __  _ __ __| |_ __  
 | '_ ` _ \| '_ \ / _` | / /\ \ |  _  / \ \/ /   | | | . ` | '_ \| '__/ _` | '_ \ 
 | | | | | | | | | (_| |/ ____ \| | \ \  \  /   _| |_| |\  | |_) | | | (_| | | | |
 |_| |_| |_|_| |_|\__,_/_/    \_\_|  \_\  \/   |_____|_| \_| .__/|_|  \__,_|_| |_|
                                                           | |                    
                                                           |_|                    
================================================================================
"@

# ===== DISPLAY LOGO (MAGENTA COLOR) =====
Write-Host $Logo -ForegroundColor Magenta

# ===== TITLE SECTION (CYAN COLOR) =====
Write-Host "==============================================" -ForegroundColor Cyan
Write-Host "    PATCH INSTALLER SEB v3.10.0.826" -ForegroundColor Cyan
Write-Host "        Safe • Silent • Stable" -ForegroundColor Cyan
Write-Host "      Powered by ArvinPrdn" -ForegroundColor Cyan
Write-Host "==============================================" -ForegroundColor Cyan
Write-Host ""

# ===== DOWNLOAD CONFIGURATION =====
$Url = "https://github.com/ArvinPrdn/PATCH-INSTALLER-SEB-v3.10.0.826/releases/download/v3.10.0.826/patch-seb.1.exe"
$Out = "$env:TEMP\patch-seb.exe"

Write-Host "[📥] Downloading Patch SEB..." -ForegroundColor Yellow

# ===== DOWNLOAD FILE =====
try {
    # Coba menggunakan Invoke-WebRequest dengan error handling
    if ($PSVersionTable.PSVersion.Major -ge 7) {
        # PowerShell 7+ dengan -SkipCertificateCheck
        Invoke-WebRequest -Uri $Url -OutFile $Out -UseBasicParsing -MaximumRedirection 10 -SkipCertificateCheck
    } else {
        # PowerShell 5.1
        Invoke-WebRequest -Uri $Url -OutFile $Out -UseBasicParsing -MaximumRedirection 10
    }
    
    Write-Host "[✓] Download completed successfully" -ForegroundColor Green
} catch {
    Write-Host ""
    Write-Host "[❌] ERROR: Download failed!" -ForegroundColor Red
    Write-Host "Possible reasons:" -ForegroundColor Yellow
    Write-Host "1. No internet connection" -ForegroundColor Yellow
    Write-Host "2. URL not accessible" -ForegroundColor Yellow
    Write-Host "3. Antivirus blocking" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Error details: $_" -ForegroundColor DarkGray
    exit 1
}

# ===== VERIFY FILE =====
if (!(Test-Path $Out)) {
    Write-Host "[❌] ERROR: Downloaded file not found" -ForegroundColor Red
    exit 1
}

$fileSize = (Get-Item $Out).Length / 1MB
Write-Host "[ℹ] File size: $($fileSize.ToString('0.00')) MB" -ForegroundColor Cyan

# ===== PROGRESS ANIMATION =====
Write-Host ""
Write-Host "[⚙️] Preparing installation..." -ForegroundColor Yellow

# Animated progress bar
$frames = @('|', '/', '-', '\')
for ($i = 0; $i -lt 20; $i++) {
    $frame = $frames[$i % 4]
    Write-Host "`r[$frame] Processing... " -NoNewline -ForegroundColor Cyan
    Start-Sleep -Milliseconds 100
}
Write-Host "`r[✓] Processing completed!  " -ForegroundColor Green

# ===== INSTALLATION PROCESS =====
Write-Host ""
Write-Host "[🔄] Running silent installation..." -ForegroundColor Yellow

try {
    # Unblock file jika diblokir
    try {
        Unblock-File -Path $Out -ErrorAction SilentlyContinue
        Write-Host "[🔓] File unblocked successfully" -ForegroundColor Cyan
    } catch {
        Write-Host "[ℹ] File unblock not required" -ForegroundColor Gray
    }
    
    # Jalankan installer secara silent
    Write-Host "[⚙️] Starting installer with /S flag..." -ForegroundColor Cyan
    
    $process = Start-Process -FilePath $Out -ArgumentList "/S" -Wait -PassThru -NoNewWindow
    
    if ($process.ExitCode -eq 0) {
        Write-Host "[✅] Installation completed successfully!" -ForegroundColor Green
        Write-Host "[ℹ] Exit code: 0 (Success)" -ForegroundColor Cyan
    } else {
        Write-Host "[⚠️] Installation completed with warning" -ForegroundColor Yellow
        Write-Host "[ℹ] Exit code: $($process.ExitCode)" -ForegroundColor Cyan
    }
    
} catch {
    Write-Host ""
    Write-Host "[❌] ERROR: Installation failed!" -ForegroundColor Red
    Write-Host "Possible reasons:" -ForegroundColor Yellow
    Write-Host "1. User cancelled the installation" -ForegroundColor Yellow
    Write-Host "2. Insufficient permissions" -ForegroundColor Yellow
    Write-Host "3. Antivirus blocked the installation" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Error details: $_" -ForegroundColor DarkGray
    exit 1
}

# ===== CLEANUP =====
Write-Host ""
Write-Host "[🧹] Cleaning up temporary files..." -ForegroundColor Yellow

try {
    if (Test-Path $Out) {
        Remove-Item -Path $Out -Force -ErrorAction SilentlyContinue
        Write-Host "[✓] Temporary files cleaned up" -ForegroundColor Green
    }
} catch {
    Write-Host "[ℹ] Could not clean up temporary files" -ForegroundColor Gray
}

# ===== FINAL MESSAGE =====
Write-Host ""
Write-Host "=" * 50 -ForegroundColor Cyan
Write-Host "       INSTALLATION COMPLETED SUCCESSFULLY      " -ForegroundColor Green
Write-Host "=" * 50 -ForegroundColor Cyan
Write-Host ""
Write-Host "[📋] Summary:" -ForegroundColor Cyan
Write-Host "• Patch SEB v3.10.0.826 has been installed" -ForegroundColor White
Write-Host "• Installation mode: Silent (/S)" -ForegroundColor White
Write-Host "• Powered by ArvinPrdn" -ForegroundColor White
Write-Host ""
Write-Host "[💡] Recommendations:" -ForegroundColor Yellow
Write-Host "1. Restart your computer if prompted" -ForegroundColor White
Write-Host "2. Check program in Start Menu" -ForegroundColor White
Write-Host "3. Run the application to verify installation" -ForegroundColor White
Write-Host ""
Write-Host "[⏱️] Script execution time: $((Get-Date).ToString('HH:mm:ss'))" -ForegroundColor Cyan
Write-Host ""

# ===== PAUSE BEFORE EXIT (OPTIONAL) =====
if ($Host.Name -match "ISE") {
    # Jika di PowerShell ISE, tunggu enter
    Write-Host "Press Enter to exit..." -ForegroundColor Gray -NoNewline
    Read-Host
} else {
    # Jika di PowerShell Console, tunggu 3 detik
    Start-Sleep -Seconds 3
}

exit 0
