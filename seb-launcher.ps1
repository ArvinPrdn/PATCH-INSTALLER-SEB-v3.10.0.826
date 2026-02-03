# ==================================================
# SEB APPLICATION LAUNCHER
# Checks license before launching main app
# ==================================================

# Hide PowerShell window
$windowStyle = 'Hidden'
if ($Host.Name -eq 'ConsoleHost') {
    $windowStyle = 'Minimized'
}

# ===== LICENSE CHECK =====
$licenseRegistryPath = "HKLM:\SOFTWARE\PATCH-INSTALLER-SEB"
$appPath = "C:\Program Files\SEB\seb-app.exe"

function Check-License {
    try {
        if (-not (Test-Path $licenseRegistryPath)) {
            return @{Valid = $false; Message = "Software not activated!"}
        }
        
        $license = Get-ItemProperty -Path $licenseRegistryPath -Name "LicenseKey" -ErrorAction SilentlyContinue
        if (-not $license.LicenseKey) {
            return @{Valid = $false; Message = "License key not found!"}
        }
        
        # Validasi format license
        if ($license.LicenseKey -notmatch '^[A-Z0-9]{4}-[A-Z0-9]{4}-[A-Z0-9]{4}-[A-Z0-9]{4}$') {
            return @{Valid = $false; Message = "Invalid license format!"}
        }
        
        return @{Valid = $true; LicenseKey = $license.LicenseKey}
        
    } catch {
        return @{Valid = $false; Message = "License check error: $_"}
    }
}

# ===== MAIN CHECK =====
$licenseResult = Check-License

if (-not $licenseResult.Valid) {
    # Show error message
    $wshell = New-Object -ComObject Wscript.Shell
    $wshell.Popup("License Error: $($licenseResult.Message)`n`nPlease re-activate the software.", 0, "SEB License Error", 0x0 + 0x10)
    exit 1
}

# ===== LAUNCH APPLICATION =====
try {
    if (Test-Path $appPath) {
        Start-Process -FilePath $appPath -WindowStyle $windowStyle
    } else {
        # App not found, show installation prompt
        $wshell = New-Object -ComObject Wscript.Shell
        $response = $wshell.Popup("Application not found. Would you like to install it?", 0, "SEB Installer", 4 + 32)
        
        if ($response -eq 6) { # Yes
            Start-Process "powershell" -ArgumentList "-File `"$PSScriptRoot\install-with-license.ps1`"" -Verb RunAs
        }
    }
} catch {
    $wshell = New-Object -ComObject Wscript.Shell
    $wshell.Popup("Error launching application: $_", 0, "SEB Error", 0x0 + 0x10)
}
