# ==================================================
# PATCH INSTALLER SEB v3.10.0.826
# Safe • Silent • Stable
# ==================================================

# ===== FIXED UTF-8 CONFIGURATION =====
try {
    [Console]::OutputEncoding = [System.Text.Encoding]::UTF8
} catch {
    # Jika gagal set encoding, lanjut saja
}

Clear-Host

# ===== ASCII ART LOGO =====
$AsciiLogo = @"
            _         _    _    ______     _____ _   _               _       
  _ __ ___ | |__   __| |  / \  |  _ \ \   / /_ _| \ | |_ __  _ __ __| |_ __  
 | '_ ` _ \| '_ \ / _` | / _ \ | |_) \ \ / / | ||  \| | '_ \| '__/ _` | '_ \ 
 | | | | | | | | | (_| |/ ___ \|  _ < \ V /  | || |\  | |_) | | | (_| | | | |
 |_| |_| |_|_| |_|\__,_/_/   \_\_| \_\ \_/  |___|_| \_| .__/|_|  \__,_|_| |_|
                                                      |_|                     
"@

# ===== DISPLAY ASCII LOGO =====
Write-Host $AsciiLogo -ForegroundColor Magenta

# ===== TITLE SECTION =====
Write-Host "`n" + ("=" * 70) -ForegroundColor Cyan
Write-Host "          PATCH INSTALLER SEB v3.10.0.826" -ForegroundColor Cyan
Write-Host "              Safe • Silent • Stable" -ForegroundColor Cyan
Write-Host "              Powered by ArvinPrdn" -ForegroundColor Cyan
Write-Host ("=" * 70) -ForegroundColor Cyan
Write-Host "`n"

# ===== CHECK ADMIN PRIVILEGES =====
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if ($isAdmin) {
    Write-Host "[✓] Running with administrator privileges" -ForegroundColor Green
} else {
    Write-Host "[⚠] Running without administrator privileges" -ForegroundColor Yellow
    Write-Host "    (Some features may require admin rights)" -ForegroundColor Yellow
}
Write-Host "`n"

# ===== DOWNLOAD CONFIGURATION =====
$Url = "https://github.com/ArvinPrdn/PATCH-INSTALLER-SEB-v3.10.0.826/releases/download/v3.10.0.826/patch-seb.1.exe"
$Out = "$env:TEMP\patch-seb.exe"

Write-Host "[1] Downloading Patch SEB..." -ForegroundColor Yellow

# ===== ANIMATED DOWNLOAD MESSAGE =====
Write-Host "   Source: $Url" -ForegroundColor Gray
Write-Host "   " -NoNewline

# ===== DOWNLOAD FILE =====
try {
    # Hapus file lama jika ada
    if (Test-Path $Out) {
        Remove-Item $Out -Force -ErrorAction SilentlyContinue
    }
    
    # Animasi loading sederhana
    $dots = @('.   ', '..  ', '... ', '....')
    $job = Start-Job -ScriptBlock {
        param($Url, $Out)
        if ($PSVersionTable.PSVersion.Major -ge 7) {
            Invoke-WebRequest -Uri $Url -OutFile $Out -UseBasicParsing -MaximumRedirection 10
        } else {
            Invoke-WebRequest -Uri $Url -OutFile $Out -UseBasicParsing -MaximumRedirection 10
        }
    } -ArgumentList $Url, $Out
    
    # Tampilkan animasi saat download
    $counter = 0
    while ($job.State -eq 'Running') {
        $counter = ($counter + 1) % 4
        Write-Host "`r   Downloading$($dots[$counter])" -NoNewline -ForegroundColor Gray
        Start-Sleep -Milliseconds 300
    }
    
    # Hapus animasi
    Write-Host "`r" + (" " * 50) -NoNewline
    Write-Host "`r" -NoNewline
    
    # Periksa hasil download
    if (Test-Path $Out) {
        $fileSize = (Get-Item $Out).Length / 1MB
        Write-Host "[✓] Download completed successfully" -ForegroundColor Green
        Write-Host "    File size: $($fileSize.ToString('0.00')) MB" -ForegroundColor Gray
    } else {
        Write-Host "[❌] ERROR: File not found after download" -ForegroundColor Red
        exit 1
    }
    
} catch {
    Write-Host "`r[❌] ERROR: Download failed!" -ForegroundColor Red
    Write-Host "    Error: $($_.Exception.Message)" -ForegroundColor DarkGray
    Write-Host "`n    Possible solutions:" -ForegroundColor Yellow
    Write-Host "    1. Check internet connection" -ForegroundColor White
    Write-Host "    2. Try running as administrator" -ForegroundColor White
    Write-Host "    3. Disable antivirus temporarily" -ForegroundColor White
    exit 1
}

Write-Host "`n"

# ===== VERIFY FILE =====
Write-Host "[2] Verifying downloaded file..." -ForegroundColor Yellow

if (!(Test-Path $Out)) {
    Write-Host "[❌] ERROR: File not found" -ForegroundColor Red
    exit 1
}

# Cek signature file (jika ada)
try {
    $signature = Get-AuthenticodeSignature -FilePath $Out -ErrorAction SilentlyContinue
    if ($signature -and $signature.Status -eq "Valid") {
        Write-Host "[✓] File is digitally signed" -ForegroundColor Green
    } elseif ($signature -and $signature.Status -eq "NotSigned") {
        Write-Host "[ℹ] File is not digitally signed" -ForegroundColor Yellow
    } else {
        Write-Host "[ℹ] Could not verify signature" -ForegroundColor Gray
    }
} catch {
    Write-Host "[ℹ] Could not check file signature" -ForegroundColor Gray
}

Write-Host "`n"

# ===== INSTALLATION =====
Write-Host "[3] Starting installation..." -ForegroundColor Yellow

try {
    # Tampilkan info file
    Write-Host "   File: $Out" -ForegroundColor Gray
    
    # Coba unblock file
    try {
        Unblock-File -Path $Out -ErrorAction SilentlyContinue
        Write-Host "   File unblocked" -ForegroundColor Gray
    } catch {
        Write-Host "   File unblock not required" -ForegroundColor Gray
    }
    
    # Tampilkan instruksi
    Write-Host "`n   [INFO] Installer will now open with graphical interface" -ForegroundColor Cyan
    Write-Host "   Please follow the installation wizard manually" -ForegroundColor Cyan
    Write-Host "`n   Opening installer in 3 seconds..." -ForegroundColor Yellow
    
    # Countdown
    for ($i = 3; $i -gt 0; $i--) {
        Write-Host "   $i..." -ForegroundColor Yellow
        Start-Sleep -Seconds 1
    }
    
    # Jalankan installer dengan GUI normal (TANPA silent mode)
    Write-Host "`n   [▶] Launching installer..." -ForegroundColor Green
    
    # Method 1: Gunakan Start-Process tanpa argumen silent
    $process = Start-Process -FilePath $Out -Wait -PassThru
    
    if ($process.HasExited) {
        $exitCode = $process.ExitCode
        Write-Host "`n   [✓] Installation process completed" -ForegroundColor Green
        Write-Host "   Exit code: $exitCode" -ForegroundColor Gray
        
        if ($exitCode -eq 0) {
            Write-Host "   Status: Success" -ForegroundColor Green
        } elseif ($exitCode -eq 3010) {
            Write-Host "   Status: Success, restart required" -ForegroundColor Yellow
        } else {
            Write-Host "   Status: Completed with code $exitCode" -ForegroundColor Yellow
        }
    }
    
} catch {
    Write-Host "`n   [❌] ERROR during installation!" -ForegroundColor Red
    Write-Host "   Error: $($_.Exception.Message)" -ForegroundColor DarkGray
    
    # Coba alternatif method
    Write-Host "`n   [🔄] Trying alternative method..." -ForegroundColor Yellow
    
    try {
        # Method alternatif: langsung execute
        Write-Host "   Running installer directly..." -ForegroundColor Gray
        & $Out
        Write-Host "   [✓] Alternative method completed" -ForegroundColor Green
    } catch {
        Write-Host "   [❌] All methods failed" -ForegroundColor Red
        Write-Host "`n   Please run the installer manually:" -ForegroundColor Yellow
        Write-Host "   1. Go to: $env:TEMP" -ForegroundColor White
        Write-Host "   2. Run: patch-seb.exe" -ForegroundColor White
        exit 1
    }
}

Write-Host "`n"

# ===== VERIFY INSTALLATION =====
Write-Host "[4] Verifying installation..." -ForegroundColor Yellow

# Tunggu sebentar untuk proses instalasi selesai
Start-Sleep -Seconds 2

# Cek beberapa lokasi umum
$checkPaths = @(
    "$env:ProgramFiles\SEB",
    "$env:ProgramFiles(x86)\SEB", 
    "$env:LOCALAPPDATA\SEB",
    "$env:APPDATA\SEB",
    "$env:ProgramData\SEB"
)

$installed = $false
foreach ($path in $checkPaths) {
    if (Test-Path $path) {
        Write-Host "[✓] Found installation at: $path" -ForegroundColor Green
        $installed = $true
        
        # Tampilkan file/folder yang ada
        try {
            $items = Get-ChildItem -Path $path -ErrorAction SilentlyContinue | Select-Object -First 3
            if ($items) {
                Write-Host "   Detected files:" -ForegroundColor Gray
                foreach ($item in $items) {
                    Write-Host "   • $($item.Name)" -ForegroundColor Gray
                }
            }
        } catch {}
        break
    }
}

if (-not $installed) {
    Write-Host "[⚠] Could not find installation in standard locations" -ForegroundColor Yellow
    Write-Host "   (Application may be installed elsewhere)" -ForegroundColor Gray
}

Write-Host "`n"

# ===== CLEANUP =====
Write-Host "[5] Cleaning up..." -ForegroundColor Yellow

try {
    if (Test-Path $Out) {
        Write-Host "   Removing temporary file..." -ForegroundColor Gray
        Remove-Item -Path $Out -Force -ErrorAction SilentlyContinue
        Write-Host "[✓] Temporary file removed" -ForegroundColor Green
    } else {
        Write-Host "[ℹ] No temporary file to remove" -ForegroundColor Gray
    }
} catch {
    Write-Host "[ℹ] Could not remove temporary file" -ForegroundColor Gray
    Write-Host "   You can manually delete: $Out" -ForegroundColor Gray
}

# ===== FINAL MESSAGE =====
Write-Host "`n" + ("=" * 70) -ForegroundColor Cyan
Write-Host "                 INSTALLATION COMPLETED                 " -ForegroundColor Green
Write-Host ("=" * 70) -ForegroundColor Cyan
Write-Host "`n"

Write-Host "[📋] Summary:" -ForegroundColor Cyan
Write-Host "• Patch SEB installer downloaded successfully" -ForegroundColor White
Write-Host "• Installer launched with graphical interface" -ForegroundColor White
Write-Host "• Temporary files cleaned up" -ForegroundColor White
Write-Host ""

Write-Host "[💡] Next steps:" -ForegroundColor Yellow
Write-Host "1. Check if installation completed in the wizard" -ForegroundColor White
Write-Host "2. Look for 'SEB' in Start Menu" -ForegroundColor White
Write-Host "3. Restart computer if prompted" -ForegroundColor White
Write-Host "4. Run the application to verify" -ForegroundColor White
Write-Host ""

Write-Host "[⚠] If installation was not completed:" -ForegroundColor Cyan
Write-Host "• Run the installer manually from: $env:TEMP" -ForegroundColor White
Write-Host "• Right-click and select 'Run as Administrator'" -ForegroundColor White
Write-Host ""

Write-Host "[⏱️] Script execution completed at: $(Get-Date -Format 'HH:mm:ss')" -ForegroundColor Gray
Write-Host ""

# ===== PAUSE BEFORE EXIT =====
if ($Host.Name -like "*ISE*") {
    # Jika di PowerShell ISE
    Write-Host "Press Enter to exit..." -ForegroundColor Gray -NoNewline
    Read-Host
} else {
    # Jika di PowerShell Console, tunggu 5 detik
    Write-Host "Auto-closing in 5 seconds..." -ForegroundColor Gray
    Start-Sleep -Seconds 5
}

exit 0
