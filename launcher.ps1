# ==================================================
# SEB APPLICATION LAUNCHER v3.10.0.826
# License Validation & Application Launcher
# ==================================================
# Features:
# ✓ Multi-layer license checking
# ✓ Priority-based storage validation
# ✓ Graceful error handling
# ✓ Support contact information
# ✓ Automatic installer launch if needed
# ==================================================

# ===== CONFIGURATION =====
$ErrorActionPreference = 'Stop'
$script:LogFile = "$env:TEMP\SEB_Launcher_$(Get-Date -Format 'yyyyMMdd_HHmmss').log"
$appPath = "C:\Program Files\SEB\seb-app.exe"

# ===== LOGGING FUNCTION =====
function Write-Log {
    param([string]$Message, [string]$Level = "INFO")

    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "[$timestamp] [$Level] $Message"

    switch ($Level) {
        "ERROR"   { Write-Host $logMessage -ForegroundColor Red }
        "WARNING" { Write-Host $logMessage -ForegroundColor Yellow }
        "SUCCESS" { Write-Host $logMessage -ForegroundColor Green }
        "INFO"    { Write-Host $logMessage -ForegroundColor Cyan }
        default   { Write-Host $logMessage -ForegroundColor White }
    }

    $logMessage | Out-File -FilePath $script:LogFile -Append -Encoding UTF8
}

# ===== LICENSE VALIDATION =====
function Test-LicenseKey {
    param([string]$LicenseKey)

    # 1. Format validation
    if ($LicenseKey -notmatch '^[A-Z0-9]{4}-[A-Z0-9]{4}-[A-Z0-9]{4}-[A-Z0-9]{4}$') {
        return @{Valid = $false; Message = "Invalid license format! Must be XXXX-XXXX-XXXX-XXXX"}
    }

    # 2. Character validation
    $cleanKey = $LicenseKey -replace '-', ''
    $sum = 0
    foreach ($char in $cleanKey.ToCharArray()) {
        $sum += [int][char]$char
    }

    # 3. Checksum validation
    $checksum = ($sum * 13 + 7) % 26
    $expectedChecksum = (($sum % 17) + 65)

    if ($checksum -ne $expectedChecksum) {
        return @{Valid = $false; Message = "License checksum validation failed"}
    }

    # 4. Invalid patterns
    $invalidPatterns = @("0000-0000-0000-0000", "1111-1111-1111-1111", "AAAA-AAAA-AAAA-AAAA")
    if ($invalidPatterns -contains $LicenseKey) {
        return @{Valid = $false; Message = "Invalid license pattern"}
    }

    return @{Valid = $true; Message = "License is valid"}
}

# ===== LICENSE CHECKING =====
function Get-LicenseFromRegistry {
    param([string]$RegistryPath)

    try {
        if (Test-Path $RegistryPath) {
            $license = Get-ItemProperty -Path $RegistryPath -Name "LicenseKey" -ErrorAction SilentlyContinue
            if ($license -and $license.LicenseKey) {
                Write-Log "License found in registry: $RegistryPath" -Level "INFO"
                return @{Found = $true; Source = "Registry"; Key = $license.LicenseKey; Path = $RegistryPath}
            }
        }
    } catch {
        Write-Log "Error reading registry $RegistryPath : $_" -Level "WARNING"
    }

    return @{Found = $false; Source = "Registry"; Key = $null; Path = $RegistryPath}
}

function Get-LicenseFromFile {
    param([string]$FilePath)

    try {
        if (Test-Path $FilePath) {
            $licenseData = Get-Content $FilePath -Raw | ConvertFrom-Json
            if ($licenseData -and $licenseData.LicenseKey) {
                Write-Log "License found in file: $FilePath" -Level "INFO"
                return @{Found = $true; Source = "File"; Key = $licenseData.LicenseKey; Path = $FilePath; Data = $licenseData}
            }
        }
    } catch {
        Write-Log "Error reading license file $FilePath : $_" -Level "WARNING"
    }

    return @{Found = $false; Source = "File"; Key = $null; Path = $FilePath}
}

function Check-LicenseStatus {
    param([string]$LicenseKey)

    Write-Log "Checking license status with server" -Level "INFO"

    # Server endpoint for license status check
    $serverUrl = "https://api.seb-software.com/v1/license/status"
    $apiKey = "SEB-API-KEY-HERE"  # Replace with actual API key

    try {
        $payload = @{
            licenseKey = $LicenseKey
            computerName = $env:COMPUTERNAME
            windowsUser = $env:USERNAME
            timestamp = Get-Date -Format "yyyy-MM-ddTHH:mm:ssZ"
        } | ConvertTo-Json

        $webRequest = [System.Net.WebRequest]::Create($serverUrl)
        $webRequest.Method = "POST"
        $webRequest.ContentType = "application/json"
        $webRequest.Headers.Add("Authorization", "Bearer $apiKey")
        $webRequest.Timeout = 10000  # 10 seconds

        $requestStream = $webRequest.GetRequestStream()
        $payloadBytes = [System.Text.Encoding]::UTF8.GetBytes($payload)
        $requestStream.Write($payloadBytes, 0, $payloadBytes.Length)
        $requestStream.Close()

        $response = $webRequest.GetResponse()
        $responseStream = $response.GetResponseStream()
        $reader = New-Object System.IO.StreamReader($responseStream)
        $responseJson = $reader.ReadToEnd()
        $reader.Close()
        $response.Close()

        $result = $responseJson | ConvertFrom-Json

        if ($result.active) {
            Write-Log "License is active on server" -Level "SUCCESS"
            return @{Valid = $true; Status = $result.status; ExpiryDate = $result.expiryDate; Message = "License is active"}
        } else {
            Write-Log "License is not active: $($result.message)" -Level "WARNING"
            return @{Valid = $false; Status = $result.status; Message = $result.message}
        }

    } catch {
        Write-Log "Server status check failed, using local validation: $_" -Level "WARNING"
        return @{Valid = $null; Message = "Server check failed, using local validation"}
    }
}

function Check-License {
    Write-Log "Starting license validation process" -Level "INFO"

    # Find license key from local storage
    $licenseKey = $null
    $licenseData = $null

    # Priority 1: JSON file in AppData (most secure)
    $jsonPath = "$env:APPDATA\SEB\license.json"
    $licenseCheck = Get-LicenseFromFile -FilePath $jsonPath

    if ($licenseCheck.Found) {
        $licenseKey = $licenseCheck.Key
        $licenseData = $licenseCheck.Data
    }

    # Priority 2: HKCU Registry (user-specific)
    if (-not $licenseKey) {
        $regPathCU = "HKCU:\Software\SEB\License"
        $licenseCheck = Get-LicenseFromRegistry -RegistryPath $regPathCU
        if ($licenseCheck.Found) {
            $licenseKey = $licenseCheck.Key
        }
    }

    # Priority 3: HKLM Registry (system-wide, requires admin)
    if (-not $licenseKey) {
        $regPathLM = "HKLM:\SOFTWARE\SEB\License"
        $licenseCheck = Get-LicenseFromRegistry -RegistryPath $regPathLM
        if ($licenseCheck.Found) {
            $licenseKey = $licenseCheck.Key
        }
    }

    # Priority 4: ProgramData file (fallback)
    if (-not $licenseKey) {
        $txtPath = "C:\ProgramData\SEB\license.txt"
        try {
            if (Test-Path $txtPath) {
                $licenseKey = Get-Content $txtPath -Raw
                if ($licenseKey) {
                    $licenseKey = $licenseKey.Trim()
                }
            }
        } catch {
            Write-Log "Error reading ProgramData license file: $_" -Level "WARNING"
        }
    }

    if (-not $licenseKey) {
        Write-Log "No license key found in any storage location" -Level "ERROR"
        return @{Valid = $false; Message = "No license found. Please activate the software first."}
    }

    # Validate license key format
    $validation = Test-LicenseKey -LicenseKey $licenseKey
    if (-not $validation.Valid) {
        Write-Log "License key format invalid: $($validation.Message)" -Level "ERROR"
        return @{Valid = $false; Message = $validation.Message}
    }

    # Check license status with server
    $statusCheck = Check-LicenseStatus -LicenseKey $licenseKey

    if ($statusCheck.Valid -eq $true) {
        Write-Log "License validated and active" -Level "SUCCESS"
        return @{Valid = $true; Source = "Server Validation"; Key = $licenseKey; Status = $statusCheck.Status; ExpiryDate = $statusCheck.ExpiryDate}
    } elseif ($statusCheck.Valid -eq $false) {
        Write-Log "License is not active: $($statusCheck.Message)" -Level "ERROR"
        return @{Valid = $false; Message = $statusCheck.Message; Status = $statusCheck.Status}
    } else {
        # Server check failed, use local validation
        Write-Log "Server check failed, using local validation" -Level "WARNING"

        # Check expiry date from local data
        if ($licenseData -and $licenseData.ExpiryDate) {
            $expiryDate = [DateTime]::Parse($licenseData.ExpiryDate)
            if ((Get-Date) -gt $expiryDate) {
                Write-Log "License has expired locally" -Level "ERROR"
                return @{Valid = $false; Message = "License has expired. Please contact support to renew."}
            }
        }

        Write-Log "License validated locally (server offline)" -Level "SUCCESS"
        return @{Valid = $true; Source = "Local Validation"; Key = $licenseKey; Data = $licenseData}
    }
}

# ===== APPLICATION LAUNCH =====
function Start-SEBApplication {
    param([string]$AppPath)

    try {
        Write-Log "Launching SEB application: $AppPath" -Level "INFO"

        if (Test-Path $AppPath) {
            $process = Start-Process -FilePath $AppPath -PassThru
            Write-Log "SEB application launched successfully (PID: $($process.Id))" -Level "SUCCESS"
            return @{Success = $true; ProcessId = $process.Id}
        } else {
            Write-Log "Application not found: $AppPath" -Level "ERROR"
            return @{Success = $false; Error = "Application executable not found"}
        }
    } catch {
        Write-Log "Failed to launch application: $_" -Level "ERROR"
        return @{Success = $false; Error = $_}
    }
}

# ===== ERROR DISPLAY =====
function Show-LicenseError {
    param([string]$Message)

    Clear-Host
    Write-Host @"
╔══════════════════════════════════════════════════════════╗
║                    LICENSE ERROR                        ║
╠══════════════════════════════════════════════════════════╣
║  The software license could not be validated.          ║
║                                                        ║
║  Possible reasons:                                     ║
║  • Software not activated                              ║
║  • License expired                                     ║
║  • License corrupted                                   ║
║  • Registry/File access issues                         ║
╚══════════════════════════════════════════════════════════╝
"@ -ForegroundColor Red

    Write-Host "`n   ❌ $Message" -ForegroundColor Red
    Write-Host "`n   📞 SUPPORT CONTACT:" -ForegroundColor Cyan
    Write-Host "   • Email: support@seb-software.com" -ForegroundColor White
    Write-Host "   • Website: https://seb-software.com" -ForegroundColor White
    Write-Host "   • Version: 3.10.0.826" -ForegroundColor White

    Write-Host "`n   🔧 TROUBLESHOOTING:" -ForegroundColor Yellow
    Write-Host "   1. Run installer again with valid license" -ForegroundColor White
    Write-Host "   2. Check if license files exist:" -ForegroundColor White
    Write-Host "      - $env:APPDATA\SEB\license.json" -ForegroundColor Gray
    Write-Host "      - HKCU:\Software\SEB\License" -ForegroundColor Gray
    Write-Host "   3. Ensure you have proper permissions" -ForegroundColor White

    Write-Host "`n   📝 LOG FILE: $script:LogFile" -ForegroundColor Gray
}

function Show-AppNotFound {
    Clear-Host
    Write-Host @"
╔══════════════════════════════════════════════════════════╗
║                 APPLICATION NOT FOUND                   ║
╠══════════════════════════════════════════════════════════╣
║  The SEB application executable was not found.         ║
║  This usually means the software is not installed.     ║
╚══════════════════════════════════════════════════════════╝
"@ -ForegroundColor Yellow

    Write-Host "`n   ⚠️  Application not found at: $appPath" -ForegroundColor Yellow
    Write-Host "`n   Would you like to install SEB now?" -ForegroundColor White
    Write-Host "   [Y] Yes, run installer" -ForegroundColor Green
    Write-Host "   [N] No, exit" -ForegroundColor Red

    $choice = Read-Host "`n   Choice (Y/N)"

    if ($choice -in @('Y','y')) {
        Write-Host "`n   🚀 Starting installer..." -ForegroundColor Green
        Write-Log "User chose to run installer" -Level "INFO"

        # Try to find and run installer
        $installerPaths = @(
            "$PSScriptRoot\installer.ps1",
            "$PSScriptRoot\SEB-Installer-Final.ps1",
            "$env:USERPROFILE\Desktop\installer.ps1",
            "$env:USERPROFILE\Downloads\installer.ps1"
        )

        $installerFound = $false
        foreach ($installerPath in $installerPaths) {
            if (Test-Path $installerPath) {
                Write-Host "   Found installer: $installerPath" -ForegroundColor Green
                try {
                    Start-Process powershell.exe -ArgumentList "-File `"$installerPath`"" -Verb RunAs
                    $installerFound = $true
                    break
                } catch {
                    Write-Host "   Failed to run installer: $_" -ForegroundColor Red
                }
            }
        }

        if (-not $installerFound) {
            Write-Host "`n   ❌ Installer not found in common locations." -ForegroundColor Red
            Write-Host "   Please download the installer from:" -ForegroundColor White
            Write-Host "   https://github.com/ArvinPrdn/PATCH-INSTALLER-SEB-v3.10.0.826" -ForegroundColor Cyan
        }
    } else {
        Write-Host "`n   Goodbye!" -ForegroundColor Gray
    }
}

# ===== MAIN LAUNCHER LOGIC =====
function Start-Launcher {
    Write-Log "SEB Launcher started" -Level "INFO"

    # STEP 1: CHECK LICENSE
    Write-Host "   🔍 Checking license..." -ForegroundColor Cyan
    $licenseResult = Check-License

    if (-not $licenseResult.Valid) {
        Show-LicenseError -Message $licenseResult.Message
        Write-Log "License validation failed: $($licenseResult.Message)" -Level "ERROR"
        return
    }

    Write-Host "   ✅ License validated from $($licenseResult.Source)" -ForegroundColor Green
    Write-Log "License validated successfully from $($licenseResult.Source)" -Level "SUCCESS"

    # STEP 2: CHECK APPLICATION
    Write-Host "   📁 Checking application..." -ForegroundColor Cyan

    if (-not (Test-Path $appPath)) {
        Show-AppNotFound
        Write-Log "Application not found at $appPath" -Level "WARNING"
        return
    }

    Write-Host "   ✅ Application found" -ForegroundColor Green

    # STEP 3: LAUNCH APPLICATION
    Write-Host "   🚀 Launching SEB application..." -ForegroundColor Green
    $launchResult = Start-SEBApplication -AppPath $appPath

    if ($launchResult.Success) {
        Write-Host "   ✅ SEB application launched successfully" -ForegroundColor Green
        Write-Log "Application launched with PID: $($launchResult.ProcessId)" -Level "SUCCESS"

        # Optional: Wait a moment to show success message
        Start-Sleep -Seconds 2
    } else {
        Write-Host "   ❌ Failed to launch application: $($launchResult.Error)" -ForegroundColor Red
        Write-Log "Application launch failed: $($launchResult.Error)" -Level "ERROR"

        Show-AppNotFound
    }
}

# ===== START APPLICATION =====
try {
    # Check PowerShell version
    if ($PSVersionTable.PSVersion.Major -lt 3) {
        Write-Host "Error: PowerShell 3.0 or higher required" -ForegroundColor Red
        exit 1
    }

    # Clear screen and show header
    Clear-Host
    Write-Host @"
╔══════════════════════════════════════════════════════════╗
║              SEB APPLICATION LAUNCHER v3.10.0.826       ║
╠══════════════════════════════════════════════════════════╣
║  • License Validation & Application Launcher           ║
║  • Multi-layer License Storage Support                 ║
║  • Automatic Error Recovery                           ║
║  • Professional User Experience                       ║
╚══════════════════════════════════════════════════════════╝
"@ -ForegroundColor Cyan

    # Start the launcher
    Start-Launcher

} catch {
    Write-Host "`n   ❌ UNEXPECTED ERROR: $($_.Exception.Message)" -ForegroundColor Red
    Write-Log "Unexpected error: $_" -Level "ERROR"
} finally {
    # Keep window open briefly
    Write-Host "`n   Press any key to exit..." -ForegroundColor Gray
    try {
        $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
    } catch {
        # Ignore if input fails
    }
}
