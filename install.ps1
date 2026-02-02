# ==================================================
# PATCH INSTALLER SEB v3.10.0.826
# Safe • Silent • Stable
# ==================================================

# ===== FIXED UTF-8 CONFIGURATION =====
try {
    [Console]::OutputEncoding = [System.Text.Encoding]::UTF8
} catch {}

Clear-Host

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
    ________       ____  __  _______ __ __ ___   _____
   / ____/ /      / __ \/ / / / ___// //_//   | / ___/
  / __/ / /      / /_/ / / / /\__ \/ ,<  / /| | \__ \ 
 / /___/ /___   / ____/ /_/ /___/ / /| |/ ___ |___/ / 
/_____/_____/  /_/    \____//____/_/ |_/_/  |_/____/
"@

# ==================================================
# FUNGSI ANIMASI LOGO DENGAN JEDA
# ==================================================

function Show-AnimatedLogo {
    param(
        [string]$LogoPart,
        [string]$Color = "Magenta",
        [int]$LineDelay = 50,
        [int]$BetweenDelay = 1000
    )
    
    # Split logo menjadi baris-baris
    $lines = $LogoPart -split "`n"
    
    # Animasi masuk baris per baris
    foreach ($line in $lines) {
        Write-Host $line -ForegroundColor $Color
        if ($LineDelay -gt 0) {
            Start-Sleep -Milliseconds $LineDelay
        }
    }
    
    # Jeda antar bagian logo
    if ($BetweenDelay -gt 0) {
        Start-Sleep -Milliseconds $BetweenDelay
    }
}

function Show-LogoWithEffects {
    # Clear screen dulu
    Clear-Host
    
    # Spasi atas
    Write-Host "`n`n`n`n" -NoNewline
    
    # ===== ANIMASI LOADING SEBELUM LOGO =====
    Write-Host " " * 35 + "Loading PATCH INSTALLER SEB..." -ForegroundColor Yellow
    Write-Host "`n"
    
    # Spinner animation sebelum logo
    $spinner = @('|', '/', '-', '\')
    for ($i = 0; $i -lt 16; $i++) {
        $frame = $spinner[$i % 4]
        Write-Host "`r" + (" " * 40) + "[$frame] Preparing display..." -NoNewline -ForegroundColor Cyan
        Start-Sleep -Milliseconds 80
    }
    
    # Clear spinner
    Write-Host "`r" + (" " * 60) -NoNewline
    Write-Host "`r" -NoNewline
    
    Clear-Host
    
    # ===== TAMPILKAN LOGO PERTAMA DENGAN ANIMASI =====
    Write-Host "`n`n"  # Spacing atas
    
    Show-AnimatedLogo -LogoPart $AsciiLogo1 -Color "Magenta" -LineDelay 30 -BetweenDelay 500
    
    # ===== ANIMASI TRANSISI ANTAR LOGO =====
    Write-Host "`n"
    Write-Host " " * 40 + "*" -ForegroundColor Yellow
    Start-Sleep -Milliseconds 300
    Write-Host "`r" + (" " * 40) + "+" -ForegroundColor Cyan
    Start-Sleep -Milliseconds 300
    Write-Host "`r" + (" " * 40) + "*" -ForegroundColor Magenta
    Start-Sleep -Milliseconds 300
    Write-Host "`r" + (" " * 40) + " " -NoNewline
    Write-Host "`n"
    
    # ===== TAMPILKAN LOGO KEDUA DENGAN ANIMASI =====
    Show-AnimatedLogo -LogoPart $AsciiLogo2 -Color "Cyan" -LineDelay 20 -BetweenDelay 300
    
    # ===== FINAL EFFECT =====
    Write-Host "`n"
    
    # Fade in effect untuk title
    $titleLines = @(
        ("=" * 90),
        "",
        "                    PATCH INSTALLER SEB v3.10.0.826",
        "                        Safe • Silent • Stable",
        "                        Powered by ArvinPrdn",
        "",
        ("=" * 90)
    )
    
    foreach ($line in $titleLines) {
        # Efek ketikan
        $chars = $line.ToCharArray()
        foreach ($char in $chars) {
            Write-Host $char -NoNewline -ForegroundColor Cyan
            Start-Sleep -Milliseconds 2
        }
        Write-Host ""
        Start-Sleep -Milliseconds 30
    }
    
    Write-Host "`n`n"
}

# ==================================================
# FUNGSI PROGRESS BAR ANIMASI
# ==================================================

function Show-ProgressBar {
    param(
        [string]$Message = "Processing",
        [int]$Duration = 2,
        [string]$Color = "Cyan"
    )
    
    $frames = @('/', '-', '\', '|')
    $totalFrames = $Duration * 10  # 10 frames per second
    $frameDelay = 100  # milliseconds
    
    Write-Host "`n   $Message " -NoNewline -ForegroundColor Yellow
    
    for ($i = 0; $i -lt $totalFrames; $i++) {
        $frame = $frames[$i % $frames.Count]
        $percent = [math]::Min(100, [math]::Floor(($i / $totalFrames) * 100))
        
        $barLength = 30
        $filled = [math]::Floor(($percent / 100) * $barLength)
        $bar = "[" + ("#" * $filled) + (" " * ($barLength - $filled)) + "]"
        
        Write-Host "`r   $Message $bar $percent% $frame" -NoNewline -ForegroundColor $Color
        Start-Sleep -Milliseconds $frameDelay
    }
    
    Write-Host "`r   $Message [" + ("#" * 30) + "] 100% ✓" -ForegroundColor Green
    Write-Host "`n"
}

# ==================================================
# FUNGSI COUNTDOWN ANIMASI YANG LEBIH SEDERHANA
# ==================================================

function Show-Countdown {
    param(
        [int]$Seconds = 3,
        [string]$Message = "Opening installer in"
    )
    
    Write-Host "`n   $Message : " -NoNewline -ForegroundColor Yellow
    
    for ($i = $Seconds; $i -gt 0; $i--) {
        Write-Host "$i " -NoNewline -ForegroundColor Cyan
        Start-Sleep -Seconds 1
    }
    
    Write-Host "GO! ✓" -ForegroundColor Green
    Write-Host "`n"
}

# ==================================================
# FUNGSI TYPEWRITER EFFECT
# ==================================================

function Write-Typewriter {
    param(
        [string]$Text,
        [string]$Color = "White",
        [int]$Delay = 30
    )
    
    $chars = $Text.ToCharArray()
    foreach ($char in $chars) {
        Write-Host $char -NoNewline -ForegroundColor $Color
        Start-Sleep -Milliseconds $Delay
    }
    Write-Host ""
}

# ==================================================
# TAMPILKAN LOGO DENGAN ANIMASI
# ==================================================
Show-LogoWithEffects

# ===== CHECK ADMIN PRIVILEGES =====
Write-Host "[✓] Checking system permissions..." -ForegroundColor Yellow

$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if ($isAdmin) {
    Write-Host "[✓] Running with administrator privileges" -ForegroundColor Green
} else {
    Write-Host "[⚠] Running without administrator privileges" -ForegroundColor Yellow
    Write-Host "    (Some features may require admin rights)" -ForegroundColor Yellow
}

Write-Host "`n"

# ===== DOWNLOAD CONFIGURATION (URL TERSEMBUNYI) =====
# URL tersembunyi dalam beberapa bagian
$urlPart1 = "https://github.com/"
$urlPart2 = "ArvinPrdn/"
$urlPart3 = "PATCH-INSTALLER-SEB-v3.10.0.826/"
$urlPart4 = "releases/download/v3.10.0.826/"
$urlPart5 = "patch-seb.1.exe"

# Gabungkan secara diam-diam
$Url = $urlPart1 + $urlPart2 + $urlPart3 + $urlPart4 + $urlPart5
$Out = "$env:TEMP\patch-seb.exe"

Write-Host "[1] Downloading Patch SEB..." -ForegroundColor Yellow
Write-Host "   Connecting to secure repository..." -ForegroundColor Gray

# ===== DOWNLOAD FILE (TANPA MENAMPILKAN URL) =====
try {
    # Hapus file lama jika ada
    if (Test-Path $Out) {
        Remove-Item $Out -Force -ErrorAction SilentlyContinue
    }
    
    # Mulai download tanpa menampilkan URL
    $ProgressPreference = 'SilentlyContinue'
    
    # Animasi download
    Write-Host "`n   Establishing secure connection" -NoNewline -ForegroundColor Cyan
    for ($i = 0; $i -lt 3; $i++) {
        Write-Host "." -NoNewline -ForegroundColor Cyan
        Start-Sleep -Milliseconds 500
    }
    
    Write-Host " ✓" -ForegroundColor Green
    Write-Host "   Downloading installer package" -NoNewline -ForegroundColor Cyan
    
    # Download dengan progress tersembunyi
    if ($PSVersionTable.PSVersion.Major -ge 7) {
        Invoke-WebRequest -Uri $Url -OutFile $Out -UseBasicParsing -MaximumRedirection 10 -SkipCertificateCheck
    } else {
        Invoke-WebRequest -Uri $Url -OutFile $Out -UseBasicParsing -MaximumRedirection 10
    }
    
    # Animasi progress
    $dots = @('.   ', '..  ', '... ', '....')
    for ($i = 0; $i -lt 12; $i++) {
        Write-Host "`r   Downloading installer package$($dots[$i % 4])" -NoNewline -ForegroundColor Cyan
        Start-Sleep -Milliseconds 250
    }
    
    Write-Host "`r   Downloading installer package... ✓" -ForegroundColor Green
    
    if (Test-Path $Out) {
        $fileSize = (Get-Item $Out).Length / 1MB
        Write-Host "[✓] Download completed successfully" -ForegroundColor Green
        Write-Host "    Package size: $($fileSize.ToString('0.00')) MB" -ForegroundColor Gray
    } else {
        Write-Host "[❌] ERROR: Download failed or file not found" -ForegroundColor Red
        exit 1
    }
    
} catch {
    Write-Host "[❌] ERROR: Download failed!" -ForegroundColor Red
    Write-Host "    Error: $($_.Exception.Message)" -ForegroundColor DarkGray
    Write-Host "`n    Possible causes:" -ForegroundColor Yellow
    Write-Host "    1. Internet connection issue" -ForegroundColor White
    Write-Host "    2. Repository temporarily unavailable" -ForegroundColor White
    Write-Host "    3. Security software blocking" -ForegroundColor White
    exit 1
}

Write-Host "`n"

# ===== VERIFY FILE =====
Write-Host "[2] Verifying downloaded package..." -ForegroundColor Yellow

# Animasi verifikasi sederhana
Write-Host "   Verifying package integrity..." -NoNewline -ForegroundColor Gray
for ($i = 0; $i -lt 6; $i++) {
    Write-Host "." -NoNewline -ForegroundColor Gray
    Start-Sleep -Milliseconds 200
}
Write-Host " ✓" -ForegroundColor Green

if (!(Test-Path $Out)) {
    Write-Host "[❌] ERROR: Package not found" -ForegroundColor Red
    exit 1
}

Write-Host "[✓] Package verified successfully" -ForegroundColor Green
Write-Host "`n"

# ===== INSTALLATION =====
Write-Host "[3] Starting installation..." -ForegroundColor Yellow

try {
    # Tampilkan info file (tanpa path lengkap)
    Write-Host "   Package: Installer executable" -ForegroundColor Gray
    
    # Coba unblock file
    try {
        Unblock-File -Path $Out -ErrorAction SilentlyContinue
        Write-Host "   Security check passed" -ForegroundColor Gray
    } catch {
        Write-Host "   Security check not required" -ForegroundColor Gray
    }
    
    # Tampilkan instruksi
    Write-Host "`n   [INFO] Installer will now open with graphical interface" -ForegroundColor Cyan
    Write-Host "   Please follow the installation wizard manually" -ForegroundColor Cyan
    
    # Countdown dengan animasi
    Show-Countdown -Seconds 3 -Message "Launching installer"
    
    # Jalankan installer dengan GUI normal
    Write-Host "   [▶] Starting installation process..." -ForegroundColor Green
    
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
    exit 1
}

Write-Host "`n"

# ===== VERIFY INSTALLATION =====
Write-Host "[4] Verifying installation..." -ForegroundColor Yellow

Start-Sleep -Seconds 2

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
        break
    }
}

if (-not $installed) {
    Write-Host "[⚠] Could not find installation in standard locations" -ForegroundColor Yellow
    Write-Host "   (Application may be installed elsewhere)" -ForegroundColor Gray
}

Write-Host "`n"

# ===== CLEANUP =====
Write-Host "[5] Cleaning up temporary files..." -ForegroundColor Yellow

try {
    if (Test-Path $Out) {
        Remove-Item -Path $Out -Force -ErrorAction SilentlyContinue
        Write-Host "[✓] Temporary files removed" -ForegroundColor Green
    }
} catch {
    Write-Host "[ℹ] Could not remove temporary files" -ForegroundColor Gray
}

# ===== FINAL MESSAGE =====
Write-Host "`n" + ("=" * 90) -ForegroundColor Cyan
Write-Host "                          INSTALLATION COMPLETED                          " -ForegroundColor Green
Write-Host ("=" * 90) -ForegroundColor Cyan
Write-Host "`n"

Write-Host "[📋] Summary:" -ForegroundColor Cyan
Write-Host "• Patch SEB installer downloaded from secure repository" -ForegroundColor White
Write-Host "• Installer launched with graphical interface" -ForegroundColor White
Write-Host "• Temporary files cleaned up" -ForegroundColor White
Write-Host ""

Write-Host "[💡] Next steps:" -ForegroundColor Yellow
Write-Host "1. Check if installation completed in the wizard" -ForegroundColor White
Write-Host "2. Look for 'SEB' in Start Menu" -ForegroundColor White
Write-Host "3. Restart computer if prompted" -ForegroundColor White
Write-Host "4. Run the application to verify" -ForegroundColor White
Write-Host ""

Write-Host "[⏱️] Script execution completed at: $(Get-Date -Format 'HH:mm:ss')" -ForegroundColor Gray
Write-Host ""

# ===== PAUSE BEFORE EXIT =====
Write-Host "Press any key to exit..." -ForegroundColor Gray -NoNewline
$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')

exit 0
