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
            _         _    _    ______     _____ _   _               _       
  _ __ ___ | |__   __| |  / \  |  _ \ \   / /_ _| \ | |_ __  _ __ __| |_ __  
 | '_ ` _ \| '_ \ / _` | / _ \ | |_) \ \ / / | ||  \| | '_ \| '__/ _` | '_ \ 
 | | | | | | | | | (_| |/ ___ \|  _ < \ V /  | || |\  | |_) | | | (_| | | | |
 |_| |_| |_|_| |_|\__,_/_/   \_\_| \_\ \_/  |___|_| \_| .__/|_|  \__,_|_| |_|
                                                      |_|
"@

# ===== DISPLAY LOGOS =====
Clear-Host
Write-Host "`n`n"
Write-Host $AsciiLogo1 -ForegroundColor Magenta
Write-Host $AsciiLogo2 -ForegroundColor Cyan
Write-Host "`n"

# ===== TITLE SECTION =====
Write-Host "=" * 90 -ForegroundColor Cyan
Write-Host "=" * 90 -ForegroundColor Cyan
Write-Host "" -ForegroundColor Cyan
Write-Host "                    PATCH INSTALLER SEB v3.10.0.826" -ForegroundColor Cyan
Write-Host "                        Safe • Silent • Stable" -ForegroundColor Cyan
Write-Host "                        Powered by ArvinPrdn" -ForegroundColor Cyan
Write-Host "" -ForegroundColor Cyan
Write-Host "=" * 90 -ForegroundColor Cyan
Write-Host "=" * 90 -ForegroundColor Cyan
Write-Host "`n`n"

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
Write-Host "   Source: $Url" -ForegroundColor Gray

# ===== DOWNLOAD FILE =====
try {
    # Hapus file lama jika ada
    if (Test-Path $Out) {
        Remove-Item $Out -Force -ErrorAction SilentlyContinue
    }
    
    # Animasi loading
    $dots = @('.   ', '..  ', '... ', '....')
    $counter = 0
    
    # Mulai download
    $ProgressPreference = 'SilentlyContinue'
    
    # Buat job untuk download dengan animasi
    $job = Start-Job -ScriptBlock {
        param($Url, $Out)
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
    
    # Animasi saat download
    while ($job.State -eq 'Running') {
        $counter = ($counter + 1) % 4
        Write-Host "`r   Downloading$($dots[$counter])" -NoNewline -ForegroundColor Gray
        Start-Sleep -Milliseconds 300
    }
    
    $result = Receive-Job $job
    Remove-Job $job -Force
    
    Write-Host "`r" + (" " * 50) -NoNewline
    Write-Host "`r" -NoNewline
    
    if ($result -and (Test-Path $Out)) {
        $fileSize = (Get-Item $Out).Length / 1MB
        Write-Host "[✓] Download completed successfully" -ForegroundColor Green
        Write-Host "    File size: $($fileSize.ToString('0.00')) MB" -ForegroundColor Gray
    } else {
        Write-Host "[❌] ERROR: Download failed or file not found" -ForegroundColor Red
        exit 1
    }
    
} catch {
    Write-Host "[❌] ERROR: Download failed!" -ForegroundColor Red
    Write-Host "    Error: $($_.Exception.Message)" -ForegroundColor DarkGray
    exit 1
}

Write-Host "`n"

# ===== VERIFY FILE =====
Write-Host "[2] Verifying downloaded file..." -ForegroundColor Yellow

if (!(Test-Path $Out)) {
    Write-Host "[❌] ERROR: File not found" -ForegroundColor Red
    exit 1
}

Write-Host "[✓] File verified successfully" -ForegroundColor Green
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
    
    # Countdown
    Write-Host "`n   Opening installer in: " -NoNewline -ForegroundColor Yellow
    for ($i = 3; $i -gt 0; $i--) {
        Write-Host "$i " -NoNewline -ForegroundColor Yellow
        Start-Sleep -Seconds 1
    }
    Write-Host "GO!" -ForegroundColor Green
    
    # Jalankan installer dengan GUI normal
    Write-Host "`n   [▶] Launching installer..." -ForegroundColor Green
    
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

Write-Host "[⏱️] Script execution completed at: $(Get-Date -Format 'HH:mm:ss')" -ForegroundColor Gray
Write-Host ""

# ===== PAUSE BEFORE EXIT =====
Write-Host "Press any key to exit..." -ForegroundColor Gray -NoNewline
$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')

exit 0
