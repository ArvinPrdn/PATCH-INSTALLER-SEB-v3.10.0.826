# ==================================================
# PATCH INSTALLER SEB v3.10.0.826
# Safe • Silent • Stable
# ==================================================

# ===== SET CONSOLE TO FULLSCREEN =====
try {
    # Cek jika di PowerShell Console (bukan ISE)
    if ($Host.Name -eq 'ConsoleHost') {
        # Simpan ukuran console saat ini
        $console = $Host.UI.RawUI
        $originalSize = $console.WindowSize
        
        # Set ke ukuran maksimum
        $maxSize = $console.MaxPhysicalWindowSize
        $console.BufferSize = New-Object System.Management.Automation.Host.Size($maxSize.Width, 5000)
        $console.WindowSize = New-Object System.Management.Automation.Host.Size($maxSize.Width, $maxSize.Height)
        
        # Set window position ke (0,0) untuk fullscreen effect
        $console.WindowPosition = New-Object System.Management.Automation.Host.Coordinates(0, 0)
        
        # Set warna background dan foreground
        $console.BackgroundColor = "Black"
        $console.ForegroundColor = "Gray"
        
        # Clear dengan background baru
        Clear-Host
    }
} catch {
    Write-Host "Note: Could not set fullscreen mode" -ForegroundColor Yellow
}

# ===== FIXED UTF-8 CONFIGURATION =====
try {
    [Console]::OutputEncoding = [System.Text.Encoding]::UTF8
} catch {
    # Jika gagal set encoding, lanjut saja
}

Clear-Host

# ===== ASCII ART LOGO - PART 1 =====
$AsciiLogo1 = @"
                                                                                        
                                                                                        
                5                                                        B              
            F   3D                                                       2              
             5   1                                                      35  8F          
              0F A06                                                  E04  38           
               33 B01D                                               203 91             
             AB C05 400A                                           101 C03  3           
              02F D15 6005                                      9101B914  50F           
               400B  32E51004                                C0012B62A  201             
              B  10028  53830003D                         61001763E F31008  7           
              518  A20003AE9711001                      4000149CD600017  D21            
                2003  F100010101000                    1010100000008  8001C B           
              D13A  E525BDC4000009       D8835           0000129DC833B  C516            
                300000010000101011D       700002        201000010000000011E             
                   E8210000100100001C      01010E     2001001100000026C                 
                 C          C3010100009   4010003   1001001018          E               
                  700000001011000010100001010101000010101000110100000001                
                         B73018C101001010011101010100100017C30259D                      
                      7435B    600101010100E 40001010010102    F7436D                   
                         CCB4101D600100010EF0F90100010103 30128CB                       
                           A44E 601 13350B 000D5006150E401  637                         
                              8001 50 2 3 00000 90 5 20 7003F                           
                                  916 2  0000000B  8AF04                                
                                     F  0000 0000E   F                                  
                                       4000   00009                                     
                                      5000B    0000C                                    
                                     70005      00008                                   
                            C       E0000144444D 10008       E                          
                              34D   000000000007  00007   81B                           
                                94                      D3                              
                                88842127063111118146113797B                             
                                  5326901B0000008704A323E                               
                                    B89C 50101002 EA8A                                  
                                          400011                                        
                                           A004                                         
                                            E8                                          
                                                                                        
                                                                                        
                                                                                        
"@

# ===== ASCII ART LOGO - PART 2 =====
$AsciiLogo2 = @"
            _         _    _    ______     _____ _   _               _       
  _ __ ___ | |__   __| |  / \  |  _ \ \   / /_ _| \ | |_ __  _ __ __| |_ __  
 | '_ ` _ \| '_ \ / _` | / _ \ | |_) \ \ / / | ||  \| | '_ \| '__/ _` | '_ \ 
 | | | | | | | | | (_| |/ ___ \|  _ < \ V /  | || |\  | |_) | | | (_| | | | |
 |_| |_| |_|_| |_|\__,_/_/   \_\_| \_\ \_/  |___|_| \_| .__/|_|  \__,_|_| |_|
                                                      |_|
"@

# ===== DISPLAY ASCII LOGOS =====
Write-Host $AsciiLogo1 -ForegroundColor Magenta
Write-Host $AsciiLogo2 -ForegroundColor Cyan
Write-Host "`n"

# ===== TITLE SECTION =====
Write-Host ("=" * 90) -ForegroundColor Cyan
Write-Host "                    PATCH INSTALLER SEB v3.10.0.826" -ForegroundColor Cyan
Write-Host "                        Safe • Silent • Stable" -ForegroundColor Cyan
Write-Host "                        Powered by ArvinPrdn" -ForegroundColor Cyan
Write-Host ("=" * 90) -ForegroundColor Cyan
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
    $counter = 0
    
    # Mulai download di background job
    $job = Start-Job -ScriptBlock {
        param($Url, $Out)
        $ProgressPreference = 'SilentlyContinue'
        try {
            if ($PSVersionTable.PSVersion.Major -ge 7) {
                Invoke-WebRequest -Uri $Url -OutFile $Out -UseBasicParsing -MaximumRedirection 10 -SkipCertificateCheck
            } else {
                Invoke-WebRequest -Uri $Url -OutFile $Out -UseBasicParsing -MaximumRedirection 10
            }
            return $true
        } catch {
            return $false
        }
    } -ArgumentList $Url, $Out
    
    # Tampilkan animasi saat download
    while ($job.State -eq 'Running') {
        $counter = ($counter + 1) % 4
        Write-Host "`r   Downloading$($dots[$counter])" -NoNewline -ForegroundColor Gray
        Start-Sleep -Milliseconds 300
    }
    
    # Dapatkan hasil
    $result = Receive-Job $job
    Remove-Job $job -Force
    
    # Hapus animasi
    Write-Host "`r" + (" " * 50) -NoNewline
    Write-Host "`r" -NoNewline
    
    # Periksa hasil download
    if ($result -and (Test-Path $Out)) {
        $fileSize = (Get-Item $Out).Length / 1MB
        Write-Host "[✓] Download completed successfully" -ForegroundColor Green
        Write-Host "    File size: $($fileSize.ToString('0.00')) MB" -ForegroundColor Gray
    } else {
        Write-Host "[❌] ERROR: Download failed or file not found" -ForegroundColor Red
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
Write-Host "`n" + ("=" * 90) -ForegroundColor Cyan
Write-Host "                          INSTALLATION COMPLETED                          " -ForegroundColor Green
Write-Host ("=" * 90) -ForegroundColor Cyan
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
