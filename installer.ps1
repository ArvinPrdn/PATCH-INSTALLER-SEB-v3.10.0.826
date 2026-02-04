<#
.SYNOPSIS
    Professional Software Installer - GitHub Safe Version
.DESCRIPTION
    Installer template yang aman diupload ke GitHub.
    Logika validasi license di-handle oleh server eksternal.
.NOTES
    GitHub Repository: https://github.com/yourusername/professional-installer
    Version: 4.0 (GitHub Safe)
    Security: No hardcoded keys, no validation logic in source
#>

# ============================================
# CONFIGURATION - SAFE FOR GITHUB
# ============================================
$Config = @{
    AppName = "Professional Suite"
    AppVersion = "2.0"
    CompanyName = "Your Company Name"
    SupportEmail = "support@yourcompany.com"
    Website = "https://yourwebsite.com"
    # ENDPOINTS WILL BE SET FROM SERVER RESPONSE
    LicenseServer = $null
    UpdateServer = $null
}

# ============================================
# UI FUNCTIONS - SAFE
# ============================================

function Show-Header {
    Clear-Host
    Write-Host ""
    Write-Host "    _______. ___________    ____  _______ .______          ___      " -ForegroundColor Green
    Write-Host "   /       ||   ____\   \  /   / |   ____||   _  \        /   \     " -ForegroundColor Green
    Write-Host "  |   (----|  |__   \   \/   /  |  |__   |  |_)  |      /  ^  \    " -ForegroundColor Green
    Write-Host "   \   \    |   __|   \      /   |   __|  |      /      /  /_\  \   " -ForegroundColor Green
    Write-Host ".----)   |   |  |____   \    /    |  |____ |  |\  \----./  _____  \ " -ForegroundColor Green
    Write-Host "|_______/    |_______|   \__/     |_______|| _| `._____/__/     \__\" -ForegroundColor Green
    Write-Host ""
    Write-Host "=" * 60 -ForegroundColor Green
    Write-Host "    PROFESSIONAL INSTALLER v$($Config.AppVersion)" -ForegroundColor Green
    Write-Host "=" * 60 -ForegroundColor Green
    Write-Host ""
}

function Get-InstallationConfig {
    <#
    .SYNOPSIS
        Get configuration from external server
        This ensures no hardcoded endpoints in GitHub
    #>
    try {
        # You can change this URL to your configuration server
        $configUrl = "https://raw.githubusercontent.com/yourusername/installer-config/main/config.json"
        
        # For development, use local fallback
        $localConfig = @{
            LicenseServer = "https://api.yourcompany.com/v1/validate"
            UpdateServer = "https://api.yourcompany.com/v1/update"
            Features = @("standard")
        }
        
        return $localConfig
        
    } catch {
        Write-Warning "Could not fetch config from server"
        return @{
            LicenseServer = "CHANGE_ME_IN_PRODUCTION"
            UpdateServer = "CHANGE_ME_IN_PRODUCTION"
            Features = @("local")
        }
    }
}

function Get-UserInput {
    Show-Header
    
    Write-Host "STEP 1: USER INFORMATION" -ForegroundColor Yellow
    Write-Host "-" * 40 -ForegroundColor Yellow
    Write-Host ""
    
    # User Information
    $userInfo = @{}
    
    $userInfo.Name = Read-Host "Enter your full name"
    $userInfo.Email = Read-Host "Enter your email address"
    $userInfo.Company = Read-Host "Enter your company name (optional)"
    $userInfo.LicenseKey = Read-Host "Enter your license key"
    
    # Validate basic input
    if ([string]::IsNullOrWhiteSpace($userInfo.Name)) {
        Write-Host "Name is required!" -ForegroundColor Red
        return $null
    }
    
    if ([string]::IsNullOrWhiteSpace($userInfo.Email) -or $userInfo.Email -notmatch '^[^@]+@[^@]+\.[^@]+$') {
        Write-Host "Valid email is required!" -ForegroundColor Red
        return $null
    }
    
    return $userInfo
}

function Validate-LicenseExternal {
    param(
        [hashtable]$UserInfo,
        [string]$LicenseServer
    )
    
    <#
    .SYNOPSIS
        Validate license via external API
        NO VALIDATION LOGIC IN SOURCE CODE
    #>
    
    Write-Host "`nValidating license..." -ForegroundColor Yellow
    
    try {
        # This is a template - implement actual API call in production
        # For GitHub safety, we only show the structure
        
        $apiParams = @{
            Name = $UserInfo.Name
            Email = $UserInfo.Email
            Company = $UserInfo.Company
            LicenseKey = $UserInfo.LicenseKey
            Timestamp = (Get-Date -Format "yyyy-MM-ddTHH:mm:ss")
        }
        
        Write-Host "Contacting license server..." -ForegroundColor Cyan
        
        # SIMULATED RESPONSE - In production, make actual HTTP request
        Start-Sleep -Seconds 2
        
        # Example of what the server should return
        $simulatedResponse = @{
            valid = $true
            message = "License validated successfully"
            data = @{
                user_id = "USER-" + (Get-Random -Minimum 10000 -Maximum 99999)
                license_type = "Professional"
                expiry_date = (Get-Date).AddYears(1).ToString("yyyy-MM-dd")
                max_installs = 1
                features = @("advanced", "support", "updates")
            }
        }
        
        return $simulatedResponse
        
    } catch {
        Write-Host "License validation failed: $($_.Exception.Message)" -ForegroundColor Red
        return @{
            valid = $false
            message = "Connection error: $($_.Exception.Message)"
            data = $null
        }
    }
}

function Install-ApplicationSafe {
    param(
        [hashtable]$UserInfo,
        [hashtable]$LicenseData
    )
    
    Write-Host "`n" + ("=" * 60) -ForegroundColor Green
    Write-Host "INSTALLATION PROCESS" -ForegroundColor Green
    Write-Host ("=" * 60) -ForegroundColor Green
    Write-Host ""
    
    # Create installation directory
    $installDir = "$env:ProgramFiles\$($Config.CompanyName)\$($Config.AppName)"
    
    try {
        Write-Host "[1/6] Creating installation directory..." -ForegroundColor Yellow
        if (-not (Test-Path $installDir)) {
            New-Item -Path $installDir -ItemType Directory -Force | Out-Null
            Write-Host "   Directory created: $installDir" -ForegroundColor Green
        }
        
        Write-Host "[2/6] Creating application structure..." -ForegroundColor Yellow
        @("Bin", "Data", "Logs", "Docs") | ForEach-Object {
            $path = Join-Path $installDir $_
            if (-not (Test-Path $path)) {
                New-Item -Path $path -ItemType Directory -Force | Out-Null
            }
        }
        
        Write-Host "[3/6] Creating configuration files..." -ForegroundColor Yellow
        
        # Create app config (no sensitive data)
        $appConfig = @"
<?xml version="1.0" encoding="UTF-8"?>
<Application>
    <Name>$($Config.AppName)</Name>
    <Version>$($Config.AppVersion)</Version>
    <Company>$($Config.CompanyName)</Company>
    <InstallDate>$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')</InstallDate>
    <InstallPath>$installDir</InstallPath>
</Application>
"@
        
        $appConfig | Out-File -FilePath "$installDir\config.xml" -Encoding UTF8
        
        # Create README
        $readme = @"
$($Config.AppName) v$($Config.AppVersion)
=======================================

Thank you for installing $($Config.AppName)!

Installation Details:
- Version: $($Config.AppVersion)
- Installed on: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
- Installation ID: INST-$(Get-Date -Format 'yyyyMMddHHmmss')

Support Information:
- Email: $($Config.SupportEmail)
- Website: $($Config.Website)
- Documentation: $installDir\Docs\

For license management and updates, please visit our website.

© $((Get-Date).Year) $($Config.CompanyName). All rights reserved.
"@
        
        $readme | Out-File -FilePath "$installDir\README.txt" -Encoding UTF8
        
        Write-Host "[4/6] Creating desktop shortcut..." -ForegroundColor Yellow
        $desktopPath = [Environment]::GetFolderPath("Desktop")
        $shortcutPath = Join-Path $desktopPath "$($Config.AppName).lnk"
        
        $WScriptShell = New-Object -ComObject WScript.Shell
        $shortcut = $WScriptShell.CreateShortcut($shortcutPath)
        $shortcut.TargetPath = "https://$($Config.Website)/launch"
        $shortcut.WorkingDirectory = $installDir
        $shortcut.Description = "$($Config.AppName) v$($Config.AppVersion)"
        $shortcut.Save()
        
        Write-Host "[5/6] Registering application..." -ForegroundColor Yellow
        $regPath = "HKLM:\SOFTWARE\$($Config.CompanyName)\$($Config.AppName)"
        if (-not (Test-Path $regPath)) {
            New-Item -Path $regPath -Force | Out-Null
        }
        
        Set-ItemProperty -Path $regPath -Name "Version" -Value $Config.AppVersion
        Set-ItemProperty -Path $regPath -Name "InstallPath" -Value $installDir
        Set-ItemProperty -Path $regPath -Name "InstallDate" -Value (Get-Date -Format "yyyyMMdd")
        
        Write-Host "[6/6] Finalizing installation..." -ForegroundColor Yellow
        Start-Sleep -Seconds 1
        
        return @{
            Success = $true
            InstallPath = $installDir
            ShortcutPath = $shortcutPath
        }
        
    } catch {
        Write-Host "Installation failed: $($_.Exception.Message)" -ForegroundColor Red
        return @{
            Success = $false
            Error = $_.Exception.Message
        }
    }
}

function Show-SuccessMessage {
    param(
        [hashtable]$UserInfo,
        [hashtable]$InstallResult,
        [hashtable]$LicenseData
    )
    
    Show-Header
    
    Write-Host "INSTALLATION COMPLETE!" -ForegroundColor Green
    Write-Host "=" * 60 -ForegroundColor Green
    Write-Host ""
    
    Write-Host "Thank you for installing $($Config.AppName)!" -ForegroundColor White
    Write-Host ""
    
    Write-Host "Installation Details:" -ForegroundColor Cyan
    Write-Host "  Application: $($Config.AppName) v$($Config.AppVersion)" -ForegroundColor White
    Write-Host "  Installed for: $($UserInfo.Name)" -ForegroundColor White
    Write-Host "  Email: $($UserInfo.Email)" -ForegroundColor White
    if ($UserInfo.Company) {
        Write-Host "  Company: $($UserInfo.Company)" -ForegroundColor White
    }
    Write-Host "  Install Location: $($InstallResult.InstallPath)" -ForegroundColor White
    Write-Host "  Desktop Shortcut: Created" -ForegroundColor White
    Write-Host ""
    
    if ($LicenseData -and $LicenseData.data) {
        Write-Host "License Information:" -ForegroundColor Cyan
        Write-Host "  License Type: $($LicenseData.data.license_type)" -ForegroundColor White
        Write-Host "  Expiry Date: $($LicenseData.data.expiry_date)" -ForegroundColor White
        Write-Host "  Features: $($LicenseData.data.features -join ', ')" -ForegroundColor White
        Write-Host ""
    }
    
    Write-Host "Next Steps:" -ForegroundColor Yellow
    Write-Host "  1. Launch the application from the desktop shortcut" -ForegroundColor White
    Write-Host "  2. Check your email for activation instructions" -ForegroundColor White
    Write-Host "  3. Visit $($Config.Website) for documentation" -ForegroundColor White
    Write-Host ""
    
    Write-Host "Need Help?" -ForegroundColor Cyan
    Write-Host "  Email: $($Config.SupportEmail)" -ForegroundColor White
    Write-Host "  Website: $($Config.Website)" -ForegroundColor White
    Write-Host ""
}

# ============================================
# MAIN INSTALLER FLOW - GITHUB SAFE
# ============================================

function Start-ProfessionalInstaller {
    # Set window title
    $host.UI.RawUI.WindowTitle = "$($Config.AppName) Installer v$($Config.AppVersion)"
    
    try {
        # Get configuration from external source
        $serverConfig = Get-InstallationConfig
        if ($serverConfig.LicenseServer -eq "CHANGE_ME_IN_PRODUCTION") {
            Write-Host "Warning: Using development configuration." -ForegroundColor Yellow
            Write-Host "Please set up proper license server in production." -ForegroundColor Yellow
        }
        
        # Get user information
        $userInfo = Get-UserInput
        if (-not $userInfo) {
            Write-Host "`nInstallation cancelled." -ForegroundColor Red
            Read-Host "Press Enter to exit"
            return
        }
        
        # Validate license via external API
        $licenseResult = Validate-LicenseExternal -UserInfo $userInfo -LicenseServer $serverConfig.LicenseServer
        
        if (-not $licenseResult.valid) {
            Write-Host "`nLicense validation failed: $($licenseResult.message)" -ForegroundColor Red
            Write-Host ""
            Write-Host "Please ensure you have a valid license key." -ForegroundColor Yellow
            Write-Host "Contact $($Config.SupportEmail) for assistance." -ForegroundColor Yellow
            Read-Host "`nPress Enter to exit"
            return
        }
        
        Write-Host "`n✓ License validated successfully!" -ForegroundColor Green
        
        # Confirm installation
        Write-Host "`n" + ("=" * 60) -ForegroundColor Yellow
        Write-Host "INSTALLATION CONFIRMATION" -ForegroundColor Yellow
        Write-Host ("=" * 60) -ForegroundColor Yellow
        Write-Host ""
        
        Write-Host "Ready to install $($Config.AppName) v$($Config.AppVersion)" -ForegroundColor White
        Write-Host ""
        Write-Host "Installation will:" -ForegroundColor Cyan
        Write-Host "  • Install to: Program Files\$($Config.CompanyName)\$($Config.AppName)" -ForegroundColor White
        Write-Host "  • Create desktop shortcut" -ForegroundColor White
        Write-Host "  • Register with Windows" -ForegroundColor White
        Write-Host ""
        
        $confirm = Read-Host "Proceed with installation? (Y/N)"
        
        if ($confirm -ne 'Y' -and $confirm -ne 'y') {
            Write-Host "`nInstallation cancelled." -ForegroundColor Yellow
            Read-Host "Press Enter to exit"
            return
        }
        
        # Perform installation
        $installResult = Install-ApplicationSafe -UserInfo $userInfo -LicenseData $licenseResult
        
        if ($installResult.Success) {
            # Show success message
            Show-SuccessMessage -UserInfo $userInfo -InstallResult $installResult -LicenseData $licenseResult
            
            # Create installation log (no sensitive data)
            $installLog = @"
Installation Log - $($Config.AppName) v$($Config.AppVersion)
==========================================================
Timestamp: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
User: $($userInfo.Name)
Email: $($userInfo.Email)
Company: $($userInfo.Company)
Install Path: $($installResult.InstallPath)
Status: Success
"@
            
            $installLog | Out-File -FilePath "$($installResult.InstallPath)\install.log" -Encoding UTF8
            
        } else {
            Write-Host "`nInstallation failed: $($installResult.Error)" -ForegroundColor Red
            Write-Host "Please try again or contact support." -ForegroundColor Yellow
        }
        
    } catch {
        Write-Host "`nAn unexpected error occurred: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host "Please contact $($Config.SupportEmail) for assistance." -ForegroundColor Yellow
    }
    
    # Keep window open
    Write-Host "`n" + ("=" * 60) -ForegroundColor Green
    Write-Host "Installation process completed." -ForegroundColor Green
    Write-Host "This window will close in 15 seconds..." -ForegroundColor Yellow
    
    Start-Sleep -Seconds 15
}

# ============================================
# ENTRY POINT WITH ERROR HANDLING
# ============================================

# Check for administrative privileges
function Test-AdminPrivileges {
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($identity)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

# Main execution block
try {
    # Display welcome message
    Show-Header
    
    Write-Host "Welcome to $($Config.AppName) Installer!" -ForegroundColor White
    Write-Host ""
    Write-Host "This installer will guide you through the installation process." -ForegroundColor Cyan
    Write-Host ""
    
    # Check for admin rights (recommended but not required)
    if (-not (Test-AdminPrivileges)) {
        Write-Host "Note: Administrative privileges are recommended for full installation." -ForegroundColor Yellow
        Write-Host "Some features may require manual configuration." -ForegroundColor Yellow
        Write-Host ""
        
        $continue = Read-Host "Continue without admin rights? (Y/N)"
        if ($continue -ne 'Y' -and $continue -ne 'y') {
            Write-Host "`nPlease run this installer as Administrator." -ForegroundColor Yellow
            Write-Host "Right-click on PowerShell and select 'Run as Administrator'." -ForegroundColor Cyan
            Read-Host "`nPress Enter to exit"
            exit 1
        }
    }
    
    # Start the installer
    Start-ProfessionalInstaller
    
} catch {
    Write-Host "`nFatal Error: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Line: $($_.InvocationInfo.ScriptLineNumber)" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please report this issue to: $($Config.SupportEmail)" -ForegroundColor Yellow
    Write-Host "Include the error message above and your system information." -ForegroundColor Yellow
    
    Read-Host "`nPress Enter to exit"
}
