# ==================================================
# PATCH INSTALLER SEB v3.10.0.826
# Safe • Silent • Stable
# ==================================================

# ===== FIXED UTF-8 CONFIGURATION =====
try {
    $OutputEncoding = [System.Text.Encoding]::UTF8
    [Console]::OutputEncoding = [System.Text.Encoding]::UTF8
    [Console]::InputEncoding = [System.Text.Encoding]::UTF8
} catch {
    # Jika gagal set encoding, lanjut saja
}

Clear-Host

# ===== SIMPLE LOGO (NO UNICODE ISSUES) =====
Write-Host "==================================================" -ForegroundColor Magenta
Write-Host "    PATCH INSTALLER SEB v3.10.0.826" -ForegroundColor Magenta
Write-Host "        Safe • Silent • Stable" -ForegroundColor Magenta
Write-Host "==================================================" -ForegroundColor Magenta
Write-Host ""

# ===== CHECK ADMIN PRIVILEGES =====
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "[⚠] WARNING: Running without administrator privileges!" -ForegroundColor Yellow
    Write-Host "    Some features may not work properly." -ForegroundColor Yellow
    Write-Host ""
}

# ===== DOWNLOAD CONFIGURATION =====
$Url = "https://github.com/ArvinPrdn/PATCH-INSTALLER-SEB-v3.10.0.826/releases/download/v3.10.0.826/patch-seb.1.exe"
$Out = "$env:TEMP\patch-seb.exe"

Write-Host "[1] Downloading Patch SEB..." -ForegroundColor Yellow

# ===== DOWNLOAD FILE =====
try {
    # Hapus file lama jika ada
    if (Test-Path $Out) {
        Remove-Item $Out -Force -ErrorAction SilentlyContinue
    }
    
    # Download dengan progress
    Write-Host "   Downloading from: $Url" -ForegroundColor Gray
    
    $ProgressPreference = 'SilentlyContinue'
    if ($PSVersionTable.PSVersion.Major -ge 7) {
        Invoke-WebRequest -Uri $Url -OutFile $Out -UseBasicParsing -MaximumRedirection 10
    } else {
        Invoke-WebRequest -Uri $Url -OutFile $Out -UseBasicParsing -MaximumRedirection 10
    }
    $ProgressPreference = 'Continue'
    
    if (Test-Path $Out) {
        $fileSize = (Get-Item $Out).Length / 1MB
        Write-Host "[✓] Download completed ($($fileSize.ToString('0.0')) MB)" -ForegroundColor Green
    } else {
        Write-Host "[❌] ERROR: File not found after download" -ForegroundColor Red
        exit 1
    }
    
} catch {
    Write-Host ""
    Write-Host "[❌] ERROR: Download failed!" -ForegroundColor Red
    Write-Host "   Error: $($_.Exception.Message)" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "Possible solutions:" -ForegroundColor Yellow
    Write-Host "1. Check internet connection" -ForegroundColor White
    Write-Host "2. Try running as administrator" -ForegroundColor White
    Write-Host "3. Disable antivirus temporarily" -ForegroundColor White
    exit 1
}

# ===== VERIFY FILE =====
Write-Host ""
Write-Host "[2] Verifying downloaded file..." -ForegroundColor Yellow

if (!(Test-Path $Out)) {
    Write-Host "[❌] ERROR: File not found" -ForegroundColor Red
    exit 1
}

# Cek signature file (jika ada)
try {
    $signature = Get-AuthenticodeSignature -FilePath $Out
    if ($signature.Status -eq "Valid") {
        Write-Host "[✓] File is digitally signed" -ForegroundColor Green
    } elseif ($signature.Status -eq "NotSigned") {
        Write-Host "[⚠] File is not digitally signed" -ForegroundColor Yellow
    }
} catch {
    Write-Host "[ℹ] Could not verify signature" -ForegroundColor Gray
}

# ===== INSTALLATION =====
Write-Host ""
Write-Host "[3] Starting installation..." -ForegroundColor Yellow

try {
    # Tampilkan info file
    Write-Host "   File: $Out" -ForegroundColor Gray
    
    # Coba unblock file
    try {
        Unblock-File -Path $Out -ErrorAction SilentlyContinue
        Write-Host "   File unblocked" -ForegroundColor Gray
    } catch {}
    
    # ===== PERBAIKAN UTAMA DISINI =====
    # Coba beberapa opsi argument untuk silent install
    
    $installArgs = @()
    
    # Coba dulu dengan /S (biasanya untuk InnoSetup)
    $installArgs += @("/S", "/VERYSILENT", "/SUPPRESSMSGBOXES", "/NORESTART")
    
    # Atau coba dengan /quiet (biasanya untuk MSI)
    # $installArgs += @("/quiet", "/norestart")
    
    Write-Host "   Arguments: $($installArgs -join ' ')" -ForegroundColor Gray
    
    # PROSES INSTALLASI YANG BENAR
    Write-Host "   Installing (please wait)..." -ForegroundColor Gray
    
    # Method 1: Gunakan Start-Process dengan redirect output
    $processInfo = New-Object System.Diagnostics.ProcessStartInfo
    $processInfo.FileName = $Out
    $processInfo.Arguments = "/S"  # Coba hanya /S dulu
    $processInfo.UseShellExecute = $false
    $processInfo.CreateNoWindow = $true
    $processInfo.RedirectStandardOutput = $true
    $processInfo.RedirectStandardError = $true
    
    $process = New-Object System.Diagnostics.Process
    $process.StartInfo = $processInfo
    
    # Mulai proses
    if ($process.Start()) {
        # Tunggu proses selesai (timeout 5 menit)
        $process.WaitForExit(300000)
        
        if ($process.HasExited) {
            $exitCode = $process.ExitCode
            Write-Host "[✓] Installation process completed" -ForegroundColor Green
            Write-Host "   Exit code: $exitCode" -ForegroundColor Gray
            
            if ($exitCode -eq 0) {
                Write-Host "   Status: Success" -ForegroundColor Green
            } else {
                Write-Host "   Status: Completed with code $exitCode" -ForegroundColor Yellow
            }
        } else {
            Write-Host "[⚠] Installation timeout, process still running" -ForegroundColor Yellow
            $process.Kill()
        }
    } else {
        Write-Host "[❌] Failed to start installer" -ForegroundColor Red
        exit 1
    }
    
} catch {
    Write-Host ""
    Write-Host "[❌] ERROR during installation!" -ForegroundColor Red
    Write-Host "   Error: $($_.Exception.Message)" -ForegroundColor DarkGray
    
    # Coba alternatif method
    Write-Host ""
    Write-Host "[🔄] Trying alternative installation method..." -ForegroundColor Yellow
    
    try {
        # Method alternatif: langsung execute
        Write-Host "   Running: $Out /SILENT" -ForegroundColor Gray
        & $Out /SILENT
        Write-Host "[✓] Alternative method completed" -ForegroundColor Green
    } catch {
        Write-Host "[❌] All installation methods failed" -ForegroundColor Red
        Write-Host "   Please run the installer manually:" -ForegroundColor Yellow
        Write-Host "   $Out" -ForegroundColor White
        exit 1
    }
}

# ===== VERIFY INSTALLATION =====
Write-Host ""
Write-Host "[4] Verifying installation..." -ForegroundColor Yellow

# Tunggu sebentar untuk proses instalasi selesai
Start-Sleep -Seconds 3

# Cek beberapa lokasi umum
$checkPaths = @(
    "$env:ProgramFiles\SEB",
    "$env:ProgramFiles(x86)\SEB", 
    "$env:LOCALAPPDATA\SEB",
    "$env:APPDATA\SEB"
)

$installed = $false
foreach ($path in $checkPaths) {
    if (Test-Path $path) {
        Write-Host "[✓] Found installation at: $path" -ForegroundColor Green
        $installed = $true
        
        # Tampilkan file/folder yang ada
        try {
            $items = Get-ChildItem -Path $path -ErrorAction SilentlyContinue | Select-Object -First 5
            if ($items) {
                Write-Host "   Contents:" -ForegroundColor Gray
                foreach ($item in $items) {
                    Write-Host "   - $($item.Name)" -ForegroundColor Gray
                }
            }
        } catch {}
        break
    }
}

if (-not $installed) {
    Write-Host "[⚠] Could not find installation in standard locations" -ForegroundColor Yellow
    Write-Host "   Application may be installed elsewhere" -ForegroundColor Gray
}

# ===== CLEANUP =====
Write-Host ""
Write-Host "[5] Cleaning up..." -ForegroundColor Yellow

try {
    if (Test-Path $Out) {
        Remove-Item -Path $Out -Force -ErrorAction SilentlyContinue
        Write-Host "[✓] Temporary file removed" -ForegroundColor Green
    }
} catch {
    Write-Host "[ℹ] Could not remove temporary file" -ForegroundColor Gray
}

# ===== FINAL MESSAGE =====
Write-Host ""
Write-Host "=" * 60 -ForegroundColor Cyan
Write-Host "              INSTALLATION COMPLETED              " -ForegroundColor Green
Write-Host "=" * 60 -ForegroundColor Cyan
Write-Host ""
Write-Host "[📋] Summary:" -ForegroundColor Cyan
Write-Host "• Patch SEB v3.10.0.826 installer downloaded" -ForegroundColor White
Write-Host "• Silent installation attempted" -ForegroundColor White
Write-Host "• Temporary files cleaned up" -ForegroundColor White
Write-Host ""
Write-Host "[💡] Next steps:" -ForegroundColor Yellow
Write-Host "1. Check Start Menu for 'SEB' application" -ForegroundColor White
Write-Host "2. Restart computer if required" -ForegroundColor White
Write-Host "3. Run the application to verify" -ForegroundColor White
Write-Host ""
Write-Host "[ℹ] Note: If installation failed, try running:" -ForegroundColor Cyan
Write-Host "    $Out" -ForegroundColor White
Write-Host "    manually with right-click → Run as Administrator" -ForegroundColor White
Write-Host ""

# ===== PAUSE =====
if ($Host.Name -notlike "*ISE*") {
    Write-Host "Press any key to continue..." -ForegroundColor Gray -NoNewline
    $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
}

exit 0
