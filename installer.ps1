<#
.SYNOPSIS
    Professional Software Installer with License Validation
.DESCRIPTION
    Installer yang memvalidasi License Key yang telah Anda generate
.NOTES
    Author: Your Company
    Version: 3.0
    Security: License validation with pre-generated keys
#>

# ============================================
# KONFIGURASI LICENSE YANG TELAH DI-GENERATE
# ============================================
# License keys yang telah Anda generate untuk customers
# Tambahkan license keys valid Anda di sini
$ValidLicenses = @{
    # Format: "LICENSE_KEY" = @{UserID = "USER_ID", CustomerName = "Customer Name", ExpiryDate = "2024-12-31"}
    "ABCD-1234-EFGH-5678" = @{
        UserID = "CUST001"
        CustomerName = "PT. Customer Pertama"
        ExpiryDate = "2024-12-31"
        MaxInstalls = 1
        InstallCount = 0
    }
    "WXYZ-9876-PQRS-5432" = @{
        UserID = "CUST002"
        CustomerName = "CV. Customer Kedua"
        ExpiryDate = "2025-06-30"
        MaxInstalls = 2
        InstallCount = 0
    }
    "LMNO-2468-HIJK-1357" = @{
        UserID = "CUST003"
        CustomerName = "UD. Customer Ketiga"
        ExpiryDate = "2024-10-15"
        MaxInstalls = 1
        InstallCount = 0
    }
    # Tambahkan license keys lain yang telah Anda generate
}

# ============================================
# FUNGSI UTAMA
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
    Write-Host "       LICENSED SOFTWARE INSTALLER v3.0" -ForegroundColor Green
    Write-Host "=" * 60 -ForegroundColor Green
    Write-Host ""
}

function Get-ComputerID {
    # Generate unique Computer ID berdasarkan hardware
    try {
        $computerName = $env:COMPUTERNAME
        $cpuId = (Get-WmiObject Win32_Processor).ProcessorId
        if ([string]::IsNullOrEmpty($cpuId)) { $cpuId = "CPU-UNKNOWN" }
        
        $biosSerial = (Get-WmiObject Win32_BIOS).SerialNumber
        if ([string]::IsNullOrEmpty($biosSerial)) { $biosSerial = "BIOS-UNKNOWN" }
        
        $baseString = "$computerName-$cpuId-$biosSerial"
        $hash = [System.BitConverter]::ToString(
            [System.Security.Cryptography.MD5]::Create().ComputeHash(
                [System.Text.Encoding]::UTF8.GetBytes($baseString)
            )
        ).Replace("-", "").Substring(0, 8).ToUpper()
        
        return "COMP-$hash"
    } catch {
        return "COMP-" + (Get-Date -Format "yyyyMMddHHmmss")
    }
}

function Validate-License {
    param([string]$LicenseKey)
    
    Write-Host "`nMemvalidasi License Key..." -ForegroundColor Yellow
    
    # Cek apakah license key ada di database
    if ($ValidLicenses.ContainsKey($LicenseKey)) {
        $license = $ValidLicenses[$LicenseKey]
        
        # Cek expiry date
        $expiryDate = [DateTime]::Parse($license.ExpiryDate)
        if ((Get-Date) -gt $expiryDate) {
            return @{
                Valid = $false
                Message = "License telah expired pada $($license.ExpiryDate)"
                LicenseData = $null
            }
        }
        
        # Cek max installations
        if ($license.InstallCount -ge $license.MaxInstalls) {
            return @{
                Valid = $false
                Message = "License telah mencapai batas instalasi ($($license.MaxInstalls) komputer)"
                LicenseData = $null
            }
        }
        
        # License valid
        return @{
            Valid = $true
            Message = "License valid untuk $($license.CustomerName)"
            LicenseData = @{
                UserID = $license.UserID
                CustomerName = $license.CustomerName
                ExpiryDate = $license.ExpiryDate
                LicenseKey = $LicenseKey
                MaxInstalls = $license.MaxInstalls
                InstallCount = $license.InstallCount + 1
            }
        }
    } else {
        return @{
            Valid = $false
            Message = "License Key tidak valid"
            LicenseData = $null
        }
    }
}

function Show-License-Info {
    param(
        [hashtable]$LicenseData,
        [string]$ComputerID
    )
    
    Show-Header
    Write-Host "LICENSE VALIDATION SUCCESSFUL" -ForegroundColor Green
    Write-Host "-" * 40 -ForegroundColor Green
    Write-Host ""
    
    Write-Host "┌────────────────────────────────────────────────────┐" -ForegroundColor Green
    Write-Host "│              LICENSE INFORMATION                   │" -ForegroundColor Green
    Write-Host "├────────────────────────────────────────────────────┤" -ForegroundColor Green
    Write-Host ("│ {0,-15}: {1,-30} │" -f "Customer", $LicenseData.CustomerName) -ForegroundColor Cyan
    Write-Host ("│ {0,-15}: {1,-30} │" -f "User ID", $LicenseData.UserID) -ForegroundColor Cyan
    Write-Host ("│ {0,-15}: {1,-30} │" -f "License Key", $LicenseData.LicenseKey) -ForegroundColor Cyan
    Write-Host ("│ {0,-15}: {1,-30} │" -f "Computer ID", $ComputerID) -ForegroundColor Cyan
    Write-Host ("│ {0,-15}: {1,-30} │" -f "Expiry Date", $LicenseData.ExpiryDate) -ForegroundColor Cyan
    Write-Host ("│ {0,-15}: {1,-30} │" -f "Installations", "$($LicenseData.InstallCount)/$($LicenseData.MaxInstalls)") -ForegroundColor Cyan
    Write-Host ("│ {0,-15}: {1,-30} │" -f "Install Date", (Get-Date -Format "yyyy-MM-dd HH:mm:ss")) -ForegroundColor Cyan
    Write-Host "└────────────────────────────────────────────────────┘" -ForegroundColor Green
    Write-Host ""
}

function Install-Software {
    param(
        [hashtable]$LicenseData,
        [string]$ComputerID
    )
    
    Write-Host "`nMemulai instalasi software..." -ForegroundColor Green
    
    # 1. Buat direktori instalasi
    $installPath = "$env:ProgramFiles\YourSoftware"
    Write-Host "[1/5] Membuat direktori instalasi..." -ForegroundColor Yellow
    if (-not (Test-Path $installPath)) {
        New-Item -Path $installPath -ItemType Directory -Force | Out-Null
    }
    
    # 2. Buat file konfigurasi
    Write-Host "[2/5] Membuat file konfigurasi..." -ForegroundColor Yellow
    $configContent = @"
<?xml version="1.0" encoding="UTF-8"?>
<Configuration>
    <Software>
        <Name>Your Professional Software</Name>
        <Version>3.0</Version>
        <License>
            <Customer>$($LicenseData.CustomerName)</Customer>
            <UserID>$($LicenseData.UserID)</UserID>
            <Key>$($LicenseData.LicenseKey)</Key>
            <ComputerID>$ComputerID</ComputerID>
            <InstallDate>$(Get-Date -Format "yyyy-MM-dd HH:mm:ss")</InstallDate>
            <ExpiryDate>$($LicenseData.ExpiryDate)</ExpiryDate>
        </License>
    </Software>
</Configuration>
"@
    
    $configContent | Out-File -FilePath "$installPath\config.xml" -Encoding UTF8
    
    # 3. Buat file executable contoh
    Write-Host "[3/5] Mengcopy file aplikasi..." -ForegroundColor Yellow
    $exeContent = @'
@echo off
echo ========================================
echo    YOUR PROFESSIONAL SOFTWARE
echo ========================================
echo.
echo License: VALID
echo Customer: %1
echo.
echo Software is ready to use!
echo.
pause
'@
    
    $exeContent | Out-File -FilePath "$installPath\YourSoftware.bat" -Encoding ASCII
    
    # 4. Buat shortcut di desktop
    Write-Host "[4/5] Membuat shortcut..." -ForegroundColor Yellow
    $desktopPath = [Environment]::GetFolderPath("Desktop")
    $shortcutPath = "$desktopPath\Your Software.lnk"
    
    $WScriptShell = New-Object -ComObject WScript.Shell
    $shortcut = $WScriptShell.CreateShortcut($shortcutPath)
    $shortcut.TargetPath = "$installPath\YourSoftware.bat"
    $shortcut.Arguments = """$($LicenseData.CustomerName)"""
    $shortcut.WorkingDirectory = $installPath
    $shortcut.Description = "Your Professional Software"
    $shortcut.Save()
    
    # 5. Buat file license untuk customer
    Write-Host "[5/5] Membuat file license..." -ForegroundColor Yellow
    $licenseContent = @"
===========================================
YOUR SOFTWARE - LICENSE CERTIFICATE
===========================================
CUSTOMER INFORMATION:
Customer Name: $($LicenseData.CustomerName)
User ID: $($LicenseData.UserID)

LICENSE INFORMATION:
License Key: $($LicenseData.LicenseKey)
Computer ID: $ComputerID
Install Date: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
Expiry Date: $($LicenseData.ExpiryDate)
Max Installations: $($LicenseData.MaxInstalls)

SOFTWARE INFORMATION:
Software Name: Your Professional Software
Version: 3.0
Install Path: $installPath

TERMS AND CONDITIONS:
1. This license is valid for $($LicenseData.MaxInstalls) computer(s)
2. License expires on: $($LicenseData.ExpiryDate)
3. Do not share your License Key with others
4. Contact support for license renewal

SUPPORT:
Email: support@yourcompany.com
Website: www.yourcompany.com
Phone: +62-21-12345678
===========================================
"@
    
    $licenseContent | Out-File -FilePath "$installPath\License_Certificate.txt" -Encoding UTF8
    Copy-Item -Path "$installPath\License_Certificate.txt" -Destination "$desktopPath\YourSoftware_License.txt" -Force
    
    Write-Host "`nInstalasi selesai!" -ForegroundColor Green
    
    return @{
        InstallPath = $installPath
        LicenseFile = "$desktopPath\YourSoftware_License.txt"
        Shortcut = $shortcutPath
    }
}

# ============================================
# ALUR UTAMA INSTALLER
# ============================================

function Start-MainInstaller {
    try {
        # Tampilkan header
        Show-Header
        
        # Step 1: Input License Key
        Write-Host "STEP 1: LICENSE KEY INPUT" -ForegroundColor Yellow
        Write-Host "-" * 40 -ForegroundColor Yellow
        Write-Host ""
        
        Write-Host "Masukkan License Key yang diberikan:" -ForegroundColor White
        Write-Host "(Format: XXXX-XXXX-XXXX-XXXX)" -ForegroundColor Gray
        Write-Host ""
        
        $licenseKey = Read-Host "License Key"
        
        # Format validation
        $licenseKey = $licenseKey.Trim().ToUpper()
        if ($licenseKey -notmatch '^[A-Z0-9]{4}-[A-Z0-9]{4}-[A-Z0-9]{4}-[A-Z0-9]{4}$') {
            Write-Host "`nError: Format License Key tidak valid!" -ForegroundColor Red
            Write-Host "Format yang benar: XXXX-XXXX-XXXX-XXXX" -ForegroundColor Yellow
            Write-Host "Contoh: ABCD-1234-EFGH-5678" -ForegroundColor Cyan
            Write-Host ""
            Write-Host "Tekan Enter untuk keluar..." -ForegroundColor Yellow -NoNewline
            Read-Host
            exit 1
        }
        
        # Step 2: Validasi License
        $validation = Validate-License -LicenseKey $licenseKey
        
        if (-not $validation.Valid) {
            Write-Host "`nVALIDASI GAGAL!" -ForegroundColor Red
            Write-Host "$($validation.Message)" -ForegroundColor Red
            Write-Host ""
            Write-Host "Silakan hubungi support untuk mendapatkan License Key yang valid." -ForegroundColor Yellow
            Write-Host ""
            Write-Host "Tekan Enter untuk keluar..." -ForegroundColor Yellow -NoNewline
            Read-Host
            exit 1
        }
        
        # Step 3: Tampilkan informasi license
        $computerID = Get-ComputerID
        Show-License-Info -LicenseData $validation.LicenseData -ComputerID $computerID
        
        # Step 4: Konfirmasi instalasi
        Write-Host "STEP 2: INSTALLATION CONFIRMATION" -ForegroundColor Yellow
        Write-Host "-" * 40 -ForegroundColor Yellow
        Write-Host ""
        
        Write-Host "Detail Instalasi:" -ForegroundColor White
        Write-Host "  Software     : Your Professional Software v3.0" -ForegroundColor Cyan
        Write-Host "  Customer     : $($validation.LicenseData.CustomerName)" -ForegroundColor Cyan
        Write-Host "  Lokasi       : Program Files\YourSoftware\" -ForegroundColor Cyan
        Write-Host "  License      : $($validation.LicenseData.InstallCount)/$($validation.LicenseData.MaxInstalls) instalasi" -ForegroundColor Cyan
        Write-Host ""
        
        Write-Host "Apakah Anda ingin melanjutkan instalasi?" -ForegroundColor White
        Write-Host "1. Ya, lanjutkan instalasi" -ForegroundColor Green
        Write-Host "2. Tidak, batalkan" -ForegroundColor Red
        Write-Host ""
        
        $choice = Read-Host "Pilihan (1/2)"
        
        if ($choice -eq "1") {
            # Jalankan instalasi
            $installResult = Install-Software -LicenseData $validation.LicenseData -ComputerID $computerID
            
            # Tampilkan ringkasan
            Show-Header
            Write-Host "INSTALLATION COMPLETE!" -ForegroundColor Green
            Write-Host "=" * 60 -ForegroundColor Green
            Write-Host ""
            
            Write-Host "Software berhasil diinstall!" -ForegroundColor White
            Write-Host ""
            Write-Host "Ringkasan Instalasi:" -ForegroundColor Cyan
            Write-Host "  ✓ Software terinstall di: $($installResult.InstallPath)" -ForegroundColor Green
            Write-Host "  ✓ Shortcut dibuat di: Desktop" -ForegroundColor Green
            Write-Host "  ✓ File license disimpan di: $($installResult.LicenseFile)" -ForegroundColor Green
            Write-Host ""
            Write-Host "Informasi License:" -ForegroundColor Cyan
            Write-Host "  Customer     : $($validation.LicenseData.CustomerName)" -ForegroundColor White
            Write-Host "  User ID      : $($validation.LicenseData.UserID)" -ForegroundColor White
            Write-Host "  License Key  : $($validation.LicenseData.LicenseKey)" -ForegroundColor White
            Write-Host "  Computer ID  : $computerID" -ForegroundColor White
            Write-Host "  Expiry Date  : $($validation.LicenseData.ExpiryDate)" -ForegroundColor White
            Write-Host ""
            Write-Host "Cara Menjalankan Software:" -ForegroundColor Yellow
            Write-Host "  1. Klik shortcut 'Your Software' di Desktop" -ForegroundColor White
            Write-Host "  2. Atau buka folder: $($installResult.InstallPath)" -ForegroundColor White
            Write-Host ""
            Write-Host "Catatan Penting:" -ForegroundColor Red
            Write-Host "  • Simpan file license di Desktop untuk referensi" -ForegroundColor Yellow
            Write-Host "  • Jangan bagikan License Key ke orang lain" -ForegroundColor Yellow
            Write-Host "  • Hubungi support sebelum license expired" -ForegroundColor Yellow
        } else {
            Write-Host "`nInstalasi dibatalkan." -ForegroundColor Red
        }
        
        # Tahan window
        Write-Host ""
        Write-Host "=" * 60 -ForegroundColor Green
        Write-Host "Tekan Enter untuk keluar..." -ForegroundColor Yellow -NoNewline
        Read-Host
        
    } catch {
        Write-Host ""
        Write-Host "ERROR: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host "Tekan Enter untuk keluar..." -ForegroundColor Yellow -NoNewline
        Read-Host
    }
}

# ============================================
# JALANKAN INSTALLER
# ============================================

# Clear screen dan set judul
Clear-Host
$host.UI.RawUI.WindowTitle = "Your Software Installer v3.0"

# Cek jika running sebagai administrator (optional)
function Test-Admin {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

if (-not (Test-Admin)) {
    Write-Host "PERINGATAN: Disarankan menjalankan installer sebagai Administrator!" -ForegroundColor Yellow
    Write-Host "Beberapa fitur mungkin memerlukan hak administrator." -ForegroundColor Yellow
    Write-Host ""
    
    $continue = Read-Host "Lanjutkan tanpa hak admin? (Y/N)"
    if ($continue -ne 'Y' -and $continue -ne 'y') {
        exit
    }
}

# Jalankan installer utama
Start-MainInstaller
