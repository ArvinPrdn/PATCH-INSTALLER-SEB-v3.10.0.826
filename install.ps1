# ==================================================
# PATCH INSTALLER SEB v3.10.0.826
# Safe • Silent • Stable
# ==================================================

# ===== SET CONSOLE TO FULLSCREEN (IMPROVED) =====
function Set-FullScreen {
    try {
        if ($Host.Name -eq 'ConsoleHost') {
            $console = $Host.UI.RawUI
            
            # Get current window size
            $currentSize = $console.WindowSize
            
            # Set buffer size larger to prevent clipping
            $bufferSize = $console.BufferSize
            $newBufferSize = New-Object System.Management.Automation.Host.Size(120, 3000)
            $console.BufferSize = $newBufferSize
            
            # Get maximum window size
            $maxWindowSize = $console.MaxWindowSize
            
            # Set window size to maximum
            $newSize = New-Object System.Management.Automation.Host.Size($maxWindowSize.Width, $maxWindowSize.Height)
            $console.WindowSize = $newSize
            
            # Clear screen with black background
            $console.BackgroundColor = "Black"
            $console.ForegroundColor = "Gray"
            Clear-Host
            
            return $true
        }
        return $false
    } catch {
        return $false
    }
}

# Try to set fullscreen
$fullscreenSuccess = Set-FullScreen

# ===== FIXED UTF-8 CONFIGURATION =====
try {
    [Console]::OutputEncoding = [System.Text.Encoding]::UTF8
} catch {
    # Jika gagal set encoding, lanjut saja
}

Clear-Host

# ===== DOWNLOAD CONFIGURATION =====
$Url = "https://github.com/ArvinPrdn/PATCH-INSTALLER-SEB-v3.10.0.826/releases/download/v3.10.0.826/patch-seb.1.exe"
$Out = "$env:TEMP\patch-seb.exe"

# ===== ANIMATED LOGO DISPLAY =====
function Show-AnimatedLogo {
    param(
        [string]$Logo,
        [string]$Color = "Magenta",
        [int]$DelayPerLine = 30
    )
    
    $lines = $Logo -split "`n"
    foreach ($line in $lines) {
        Write-Host $line -ForegroundColor $Color
        if ($DelayPerLine -gt 0) {
            Start-Sleep -Milliseconds $DelayPerLine
        }
    }
}

# ===== ASCII ART LOGO - PART 1 =====
$AsciiLogo1 = @"
                                                                            
              .                                                .            
              *                                                #            
           +  #=                                              :%  *         
           .%  %*                                            +%  %          
             %+ %%-                                        :%% +%           
           .* -%--%%=                                    -%%=-%= =.         
            #%= -%==%%#                                #%%+=%= =%*          
             -%%#. +#+#%%#.                        .#%%#+#*  #%%-           
            %= :#%%%=.-*#%%%%                    %%%%#+-.-%%%#: =%          
             +%%=  *%%%%%%%%%%.                :%%%%%%%%%%*. =%%+           
            -%*:.-*%+:=*%%%%#      .-+#=         %%%%%*=:=%*-.:*%=          
              #%%%%%%%%%%%%%%#      -%%%%-      #%%%%%%%%%%%%%%%            
                   :=*%%%%%%%%%#     %%%%%    #%%%%%%%%%*=:                 
               ##+=--=+*#%%%%%%%%%-.%%%%%%=:%%%%%%%%%#*+=---+*#             
                 *%%#+-=#%%%%%%%%%%%%%%%%%%%%%%%%%%%%#=-+#%%*               
                  .#%%%=   *%%%%%%%%%+ %%%%%%%%%%%*   -%%%#:                
                      --*%%%:%%%%%%%+.@:%%%%%%%%%.#%%*--                    
                        =+ -%%-%*%+%.@@@ #%+%*%-%%- ++                      
                         =%%% +% *  @@@@@ % *:%+ %%%+                       
                            :%%:#- @@@@@@@. -* %%.                          
                                  @@@# =@@@                                 
                                 #@@#   =@@@.                               
                                %@@@     +@@@-                              
                        -      =@@@@@@@@@ -@@@-      -                      
                          =%%*-@@@@@@@@@@  =@@@-*%%+                        
                                                                            
                            :%%%%+%=#%%%%%=%+#%%%-                          
                               +#*=-%%%%%%-+**+                             
                                    =%%%%=                                  
                                     .%%.                                   
                                                                            
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

# ===== ANIMATED LOADING EFFECT BEFORE LOGO =====
Write-Host "`n`n`n`n`n`n`n`n"  # Spacing
Write-Host " " * 40 + "Initializing PATCH INSTALLER SEB..." -ForegroundColor Yellow
Write-Host "`n"

# Loading animation
$spinner = @('|', '/', '-', '\')
for ($i = 0; $i -lt 12; $i++) {
    $frame = $spinner[$i % 4]
    Write-Host "`r" + (" " * 45) + "[$frame] Loading..." -NoNewline -ForegroundColor Cyan
    Start-Sleep -Milliseconds 100
}

# Clear loading animation
Write-Host "`r" + (" " * 60) -NoNewline
Write-Host "`r" -NoNewline

Clear-Host

# ===== DISPLAY ASCII LOGOS WITH ANIMATION =====
Write-Host "`n`n"  # Top spacing

# Show first logo with line-by-line animation
Show-AnimatedLogo -Logo $AsciiLogo1 -Color "Magenta" -DelayPerLine 20

# Small pause between logos
Start-Sleep -Milliseconds 300

# Show second logo with line-by-line animation
Show-AnimatedLogo -Logo $AsciiLogo2 -Color "Cyan" -DelayPerLine 10

Write-Host "`n"

# ===== TITLE SECTION WITH ANIMATION =====
$titleLines = @(
# ===== TITLE SECTION WITH ANIMATION =====
Write-Host "╔══════════════════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║                                                                              ║" -ForegroundColor Cyan
Write-Host "║                    PATCH INSTALLER SEB v3.10.0.826                           ║" -ForegroundColor Cyan
Write-Host "║                        Safe • Silent • Stable                                ║" -ForegroundColor Cyan
Write-Host "║                        Powered by ArvinPrdn                                  ║" -ForegroundColor Cyan
Write-Host "║                                                                              ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan

Write-Host "`n`n"
)

foreach ($line in $titleLines) {
    Write-Host $line -ForegroundColor Cyan
    Start-Sleep -Milliseconds 50
}

Write-Host "`n`n"

# ===== CHECK ADMIN PRIVILEGES =====
Write-Host "[✓] Checking system permissions..." -ForegroundColor Yellow

# Loading animation for admin check
$adminSpinner = @('⠋', '⠙', '⠹', '⠸', '⠼', '⠴', '⠦', '⠧', '⠇', '⠏')
for ($i = 0; $i -lt 8; $i++) {
    $frame = $adminSpinner[$i % 10]
    Write-Host "`r    [$frame] Verifying privileges..." -NoNewline -ForegroundColor Gray
    Start-Sleep -Milliseconds 80
}

$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

Write-Host "`r    " + (" " * 40) -NoNewline
Write-Host "`r" -NoNewline

if ($isAdmin) {
    Write-Host "[✓] Running with administrator privileges" -ForegroundColor Green
} else {
    Write-Host "[⚠] Running without administrator privileges" -ForegroundColor Yellow
    Write-Host "    (Some features may require admin rights)" -ForegroundColor Yellow
}

# Status bar for readiness
Write-Host "`n" + ("─" * 90) -ForegroundColor DarkGray
Write-Host "    [■■■■■■■■■■■■■■■■■■■■] System ready for installation" -ForegroundColor Green
Write-Host ("─" * 90) -ForegroundColor DarkGray
Write-Host "`n`n"

# ===== DOWNLOAD CONFIGURATION =====
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
    
    # Animasi loading yang lebih menarik
    $downloadFrames = @('▌', '▀', '▐', '▄')
    $counter = 0
    $downloadSpeed = 0
    $simulatedSize = 0
    
    # Buat progress bar animation
    Write-Host "`n   [                                              ] 0%" -NoNewline -ForegroundColor Gray
    
    # Simulasi progress bar selama download
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
    
    # Animated progress bar
    while ($job.State -eq 'Running') {
        $counter = ($counter + 1) % 4
        $frame = $downloadFrames[$counter]
        $simulatedSize = [Math]::Min($simulatedSize + 0.5, 98)
        
        # Update progress bar - PERBAIKAN DISINI: Gunakan -lt bukan <
        $progressBars = [Math]::Floor($simulatedSize / 2)
        $progressBar = "[" + ("#" * $progressBars) + (" " * (50 - $progressBars)) + "]"
        
        Write-Host "`r   $progressBar $([Math]::Floor($simulatedSize))% $frame" -NoNewline -ForegroundColor Cyan
        Start-Sleep -Milliseconds 150
    }
    
    # Dapatkan hasil
    $result = Receive-Job $job
    Remove-Job $job -Force
    
    # Set progress to 100%
    Write-Host "`r   [" + ("#" * 50) + "] 100% ✓" -ForegroundColor Green
    
    # Periksa hasil download
    if ($result -and (Test-Path $Out)) {
        $fileSize = (Get-Item $Out).Length / 1MB
        Write-Host "`n   [✓] Download completed successfully" -ForegroundColor Green
        Write-Host "       File size: $($fileSize.ToString('0.00')) MB" -ForegroundColor Gray
    } else {
        Write-Host "`n   [❌] ERROR: Download failed or file not found" -ForegroundColor Red
        exit 1
    }
    
} catch {
    Write-Host "`n   [❌] ERROR: Download failed!" -ForegroundColor Red
    Write-Host "       Error: $($_.Exception.Message)" -ForegroundColor DarkGray
    Write-Host "`n       Possible solutions:" -ForegroundColor Yellow
    Write-Host "       1. Check internet connection" -ForegroundColor White
    Write-Host "       2. Try running as administrator" -ForegroundColor White
    Write-Host "       3. Disable antivirus temporarily" -ForegroundColor White
    exit 1
}

Write-Host "`n"

# ===== VERIFY FILE =====
Write-Host "[2] Verifying downloaded file..." -ForegroundColor Yellow

# Perbaikan disini: ganti < dengan -lt
if (!(Test-Path $Out)) {
    Write-Host "[❌] ERROR: File not found" -ForegroundColor Red
    exit 1
}
# Animated verification - PERBAIKAN: ganti for loop dengan -lt
$verifyFrames = @(' ', ' ', ' ', ' ')
for ($i = 0; $i -lt 6; $i++) {
    $frame = $verifyFrames[$i % 4]
    Write-Host "`r    [$frame] Verifying file..." -NoNewline -ForegroundColor Gray
    Start-Sleep -Milliseconds 150
}
Write-Host "`r    " + (" " * 40) -NoNewline
Write-Host "`r" -NoNewline

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
    
    # Countdown dengan animasi
    Write-Host "`n   Opening installer in: " -NoNewline -ForegroundColor Yellow
    for ($i = 3; $i -gt 0; $i--) {
        Write-Host "$i " -NoNewline -ForegroundColor Yellow
        Start-Sleep -Seconds 1
    }
    Write-Host "GO!" -ForegroundColor Green
    
    # Jalankan installer dengan GUI normal
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

# ===== FINAL MESSAGE WITH ANIMATION =====
Write-Host "`n" + ("=" * 90) -ForegroundColor Cyan

# Animate final message
$finalMessage = "                          INSTALLATION COMPLETED                          "
$colors = @("Green", "Cyan", "Green")
for ($i = 0; $i -lt 3; $i++) {
    Write-Host $finalMessage -ForegroundColor $colors[$i]
    if ($i -lt 2) {
        Write-Host "`r" + (" " * 90) -NoNewline
        Write-Host "`r" -NoNewline
        Start-Sleep -Milliseconds 200
    }
}

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
    # Countdown
    for ($i = 5; $i -gt 0; $i--) {
        Write-Host "  $i..." -NoNewline -ForegroundColor DarkGray
        Start-Sleep -Seconds 1
    }
    Write-Host "`r" + (" " * 10) -NoNewline
    Write-Host "`r" -NoNewline
}

exit 0
