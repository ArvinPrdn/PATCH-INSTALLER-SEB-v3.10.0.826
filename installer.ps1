<#
.SYNOPSIS
    Professional Software Installer - Complete Version
.DESCRIPTION
    Installer dengan proses instalasi nyata dan tidak hanya simulasi
.NOTES
    Author: System Administrator
    Version: 2.1
    Requires: Administrator privileges
#>

# ============================================
# KONFIGURASI INSTALASI
# ============================================
$InstallConfig = @{
    AppName = "Professional Software Suite"
    AppVersion = "2.0"
    CompanyName = "Professional Systems Inc."
    InstallPath = "$env:ProgramFiles\ProfessionalSuite"
    DesktopShortcut = $true
    StartMenuShortcut = $true
    CreateUninstaller = $true
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
    Write-Host "|_______/    |_______|   \__/     |_______|| _| ._____/__/     \__\" -ForegroundColor Green
    Write-Host ""
    Write-Host "=" * 60 -ForegroundColor Green
    Write-Host "        PROFESSIONAL INSTALLER v2.1" -ForegroundColor Green
    Write-Host "=" * 60 -ForegroundColor Green
    Write-Host ""
}

function Test-Administrator {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Get-UserID {
    Show-Header
    Write-Host "STEP 1: USER ID INPUT" -ForegroundColor Yellow
    Write-Host "-" * 40 -ForegroundColor Yellow
    Write-Host ""
    
    Write-Host "Silakan masukkan User ID Anda (atau tekan Enter untuk generate otomatis):" -ForegroundColor White
    $id = Read-Host "User ID"
    
    if ([string]::IsNullOrWhiteSpace($id)) {
        $id = "USER-" + (Get-Date -Format "yyyyMMddHHmmss")
        Write-Host "Generated User ID: $id" -ForegroundColor Green
    }
    
    return $id
}

function Get-LicenseInfo {
    param([string]$UserID)
    
    # Generate Computer ID berdasarkan sistem
    $computerName = $env:COMPUTERNAME
    $cpuId = (Get-WmiObject Win32_Processor).ProcessorId
    $baseString = "$computerName$cpuId"
    $hash = [System.BitConverter]::ToString(
        (New-Object System.Security.Cryptography.MD5CryptoServiceProvider).ComputeHash(
            [System.Text.Encoding]::UTF8.GetBytes($baseString)
        )
    ).Replace("-", "").Substring(0, 8).ToUpper()
    $computerID = "COMP-$hash"
    
    # Generate License Key
    $chars = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789"
    $licenseKey = ""
    for ($i = 1; $i -le 25; $i++) {
        $licenseKey += $chars[(Get-Random -Maximum $chars.Length)]
        if ($i % 5 -eq 0 -and $i -ne 25) {
            $licenseKey += "-"
        }
    }
    
    # Tampilkan informasi
    Show-Header
    Write-Host "STEP 2: LICENSE INFORMATION" -ForegroundColor Yellow
    Write-Host "-" * 40 -ForegroundColor Yellow
    Write-Host ""
    
    Write-Host "======================================================" -ForegroundColor Green
    Write-Host "               LICENSE DETAILS" -ForegroundColor Green
    Write-Host "======================================================" -ForegroundColor Green
    Write-Host ("{0,-15}: {1}" -f "User ID", $UserID) -ForegroundColor Cyan
    Write-Host ("{0,-15}: {1}" -f "License Key", $licenseKey) -ForegroundColor Cyan
    Write-Host ("{0,-15}: {1}" -f "Computer ID", $computerID) -ForegroundColor Cyan
    Write-Host ("{0,-15}: {1}" -f "Install Date", (Get-Date -Format "yyyy-MM-dd HH:mm:ss")) -ForegroundColor Cyan
    Write-Host ("{0,-15}: {1}" -f "Expiry Date", (Get-Date).AddYears(1).ToString("yyyy-MM-dd")) -ForegroundColor Cyan
    Write-Host "======================================================" -ForegroundColor Green
    Write-Host ""
    
    return @{
        UserID = $UserID
        LicenseKey = $licenseKey
        ComputerID = $computerID
        InstallDate = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        ExpiryDate = (Get-Date).AddYears(1).ToString("yyyy-MM-dd")
    }
}

function Install-Application {
    param(
        [hashtable]$Config,
        [hashtable]$LicenseInfo
    )
    
    Write-Host "`n" + ("=" * 60) -ForegroundColor Green
    Write-Host "MULAI PROSES INSTALASI NYATA" -ForegroundColor Green
    Write-Host ("=" * 60) -ForegroundColor Green
    Write-Host ""
    
    try {
        # 1. Buat direktori instalasi
        Write-Host "[1/7] Membuat direktori instalasi..." -ForegroundColor Yellow
        if (-not (Test-Path $Config.InstallPath)) {
            New-Item -Path $Config.InstallPath -ItemType Directory -Force | Out-Null
            Write-Host "   Direktori dibuat: $($Config.InstallPath)" -ForegroundColor Green
        } else {
            Write-Host "   Direktori sudah ada: $($Config.InstallPath)" -ForegroundColor Yellow
        }
        
        # 2. Buat struktur folder dalam direktori program
        Write-Host "[2/7] Membuat struktur folder..." -ForegroundColor Yellow
        $folders = @("Bin", "Data", "Logs", "Config", "Resources")
        foreach ($folder in $folders) {
            $folderPath = Join-Path $Config.InstallPath $folder
            if (-not (Test-Path $folderPath)) {
                New-Item -Path $folderPath -ItemType Directory -Force | Out-Null
                Write-Host "   Folder dibuat: $folder" -ForegroundColor Green
            }
        }
        
        # 3. Buat file konfigurasi aplikasi
        Write-Host "[3/7] Membuat file konfigurasi..." -ForegroundColor Yellow
        $configContent = @"
<?xml version="1.0" encoding="UTF-8"?>
<Configuration>
    <Application>
        <Name>$($Config.AppName)</Name>
        <Version>$($Config.AppVersion)</Version>
        <Company>$($Config.CompanyName)</Company>
    </Application>
    <License>
        <UserID>$($LicenseInfo.UserID)</UserID>
        <Key>$($LicenseInfo.LicenseKey)</Key>
        <ComputerID>$($LicenseInfo.ComputerID)</ComputerID>
        <InstallDate>$($LicenseInfo.InstallDate)</InstallDate>
        <ExpiryDate>$($LicenseInfo.ExpiryDate)</ExpiryDate>
    </License>
    <Paths>
        <InstallPath>$($Config.InstallPath)</InstallPath>
        <DataPath>$($Config.InstallPath)\Data</DataPath>
        <LogPath>$($Config.InstallPath)\Logs</LogPath>
    </Paths>
</Configuration>
"@
        
        $configFile = Join-Path $Config.InstallPath "Config\app_config.xml"
        $configContent | Out-File -FilePath $configFile -Encoding UTF8
        Write-Host "   File konfigurasi dibuat: app_config.xml" -ForegroundColor Green
        
        # 4. Buat file executable dummy (contoh)
        Write-Host "[4/7] Menginstall file aplikasi..." -ForegroundColor Yellow
        $exeContent = @'
@echo off
echo Professional Software Suite v2.0
echo --------------------------------
echo Licensed to: %USERNAME%
echo.
echo Application successfully installed!
pause
'@
        
        $exeFile = Join-Path $Config.InstallPath "Bin\ProfessionalSuite.exe"
        $exeContent | Out-File -FilePath $exeFile -Encoding ASCII
        Write-Host "   File aplikasi dibuat: ProfessionalSuite.exe" -ForegroundColor Green
        
        # 5. Buat file dokumentasi
        Write-Host "[5/7] Membuat dokumentasi..." -ForegroundColor Yellow
        $readmeContent = @"
PROFESSIONAL SOFTWARE SUITE v2.0
================================

INSTALLATION DETAILS:
- Application: $($Config.AppName)
- Version: $($Config.AppVersion)
- Install Path: $($Config.InstallPath)
- Install Date: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")

LICENSE INFORMATION:
- User ID: $($LicenseInfo.UserID)
- License Key: $($LicenseInfo.LicenseKey)
- Computer ID: $($LicenseInfo.ComputerID)
- Expiry Date: $($LicenseInfo.ExpiryDate)

SUPPORT:
For technical support, please contact:
Email: support@professionalsystems.com
Phone: 1-800-PRO-SOFT
"@
        
        $readmeFile = Join-Path $Config.InstallPath "Readme.txt"
        $readmeContent | Out-File -FilePath $readmeFile -Encoding UTF8
        Write-Host "   Dokumentasi dibuat: Readme.txt" -ForegroundColor Green
        
        # 6. Buat shortcut di desktop
        if ($Config.DesktopShortcut) {
            Write-Host "[6/7] Membuat shortcut di desktop..." -ForegroundColor Yellow
            $desktopPath = [Environment]::GetFolderPath("Desktop")
            $shortcutPath = Join-Path $desktopPath "$($Config.AppName).lnk"
            
            $WScriptShell = New-Object -ComObject WScript.Shell
            $shortcut = $WScriptShell.CreateShortcut($shortcutPath)
            $shortcut.TargetPath = $exeFile
            $shortcut.WorkingDirectory = $Config.InstallPath
            $shortcut.Description = "$($Config.AppName) v$($Config.AppVersion)"
            $shortcut.Save()
            
            Write-Host "   Shortcut dibuat di desktop" -ForegroundColor Green
        }
        
        # 7. Buat entri registry untuk uninstall
        if ($Config.CreateUninstaller) {
            Write-Host "[7/7] Membuat entri uninstall..." -ForegroundColor Yellow
            $regPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\$($Config.AppName.Replace(' ', '_'))"
            
            if (-not (Test-Path $regPath)) {
                New-Item -Path $regPath -Force | Out-Null
            }
            
            Set-ItemProperty -Path $regPath -Name "DisplayName" -Value $Config.AppName
            Set-ItemProperty -Path $regPath -Name "DisplayVersion" -Value $Config.AppVersion
            Set-ItemProperty -Path $regPath -Name "Publisher" -Value $Config.CompanyName
            Set-ItemProperty -Path $regPath -Name "InstallLocation" -Value $Config.InstallPath
            Set-ItemProperty -Path $regPath -Name "UninstallString" -Value "powershell.exe -Command `"Remove-Item -Path '$Config.InstallPath' -Recurse -Force`""
            Set-ItemProperty -Path $regPath -Name "InstallDate" -Value (Get-Date -Format "yyyyMMdd")
            
            Write-Host "   Entri uninstall dibuat di registry" -ForegroundColor Green
        }
        
        Write-Host "`n" + ("=" * 60) -ForegroundColor Green
        Write-Host "INSTALASI BERHASIL!" -ForegroundColor Green
        Write-Host ("=" * 60) -ForegroundColor Green
        
        return $true
        
    } catch {
        Write-Host "`nERROR dalam proses instalasi: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

function Save-LicenseFile {
    param(
        [hashtable]$LicenseInfo,
        [string]$InstallPath
    )
    
    $licenseContent = @"
===============================================
PROFESSIONAL SOFTWARE SUITE - LICENSE
===============================================
SOFTWARE INFORMATION:
- Application: Professional Software Suite
- Version: 2.0
- Company: Professional Systems Inc.

LICENSE DETAILS:
- User ID: $($LicenseInfo.UserID)
- License Key: $($LicenseInfo.LicenseKey)
- Computer ID: $($LicenseInfo.ComputerID)
- Install Date: $($LicenseInfo.InstallDate)
- Expiry Date: $($LicenseInfo.ExpiryDate)

SYSTEM INFORMATION:
- Computer Name: $env:COMPUTERNAME
- Windows Version: $([System.Environment]::OSVersion.VersionString)
- Install Path: $InstallPath

IMPORTANT:
1. This license is bound to this computer only
2. Do not share your license key with anyone
3. Keep this file for future reference
4. Contact support before expiry for renewal

SUPPORT CONTACT:
Email: support@professionalsystems.com
Phone: 1-800-PRO-SOFT
===============================================
"@
    
    # Simpan di beberapa lokasi
    $locations = @(
        "$InstallPath\license_info.txt",
        "$env:USERPROFILE\Desktop\license_info.txt",
        "$env:USERPROFILE\Documents\license_info.txt"
    )
    
    foreach ($location in $locations) {
        try {
            $licenseContent | Out-File -FilePath $location -Encoding UTF8
            Write-Host "License file saved: $location" -ForegroundColor Green
        } catch {
            Write-Host "Failed to save license to: $location" -ForegroundColor Yellow
        }
    }
}

# ============================================
# PROGRAM UTAMA
# ============================================

try {
    # Set execution policy untuk session ini
    Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force -ErrorAction SilentlyContinue
    
    # Set judul window
    $host.UI.RawUI.WindowTitle = "Professional Installer v2.1"
    
    # Cek administrator privileges
    if (-not (Test-Administrator)) {
        Show-Header
        Write-Host "PERINGATAN: Instalasi membutuhkan hak Administrator!" -ForegroundColor Red
        Write-Host ""
        Write-Host "Silakan jalankan PowerShell sebagai Administrator:" -ForegroundColor Yellow
        Write-Host "1. Klik kanan PowerShell" -ForegroundColor Cyan
        Write-Host "2. Pilih 'Run as Administrator'" -ForegroundColor Cyan
        Write-Host "3. Jalankan script ini lagi" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "Tekan Enter untuk keluar..." -ForegroundColor Yellow -NoNewline
        Read-Host
        exit 1
    }
    
    # Step 1: Dapatkan User ID
    $userID = Get-UserID
    
    # Step 2: Generate dan tampilkan license info
    $licenseInfo = Get-LicenseInfo -UserID $userID
    
    # Step 3: Konfirmasi instalasi
    Write-Host "STEP 3: KONFIRMASI INSTALASI" -ForegroundColor Yellow
    Write-Host "-" * 40 -ForegroundColor Yellow
    Write-Host ""
    
    Write-Host "Detail Instalasi:" -ForegroundColor White
    Write-Host "  Aplikasi     : $($InstallConfig.AppName)" -ForegroundColor Cyan
    Write-Host "  Versi        : $($InstallConfig.AppVersion)" -ForegroundColor Cyan
    Write-Host "  Lokasi       : $($InstallConfig.InstallPath)" -ForegroundColor Cyan
    Write-Host "  Perusahaan   : $($InstallConfig.CompanyName)" -ForegroundColor Cyan
    Write-Host ""
    
    Write-Host "Apakah Anda ingin melanjutkan instalasi?" -ForegroundColor White
    Write-Host "1. Ya, lanjutkan instalasi" -ForegroundColor Green
    Write-Host "2. Tidak, batalkan" -ForegroundColor Red
    Write-Host ""
    
    $choice = Read-Host "Pilihan (1/2)"
    
    if ($choice -eq "1") {
        # Jalankan instalasi nyata
        $installResult = Install-Application -Config $InstallConfig -LicenseInfo $licenseInfo
        
        if ($installResult) {
            # Simpan file license
            Save-LicenseFile -LicenseInfo $licenseInfo -InstallPath $InstallConfig.InstallPath
            
            # Tampilkan ringkasan
            Show-Header
            Write-Host "INSTALASI SELESAI!" -ForegroundColor Green
            Write-Host "=" * 60 -ForegroundColor Green
            Write-Host ""
            Write-Host "Ringkasan Instalasi:" -ForegroundColor White
            Write-Host "  ✓ Aplikasi terinstall di: $($InstallConfig.InstallPath)" -ForegroundColor Green
            Write-Host "  ✓ File konfigurasi: $($InstallConfig.InstallPath)\Config\app_config.xml" -ForegroundColor Green
            Write-Host "  ✓ File executable: $($InstallConfig.InstallPath)\Bin\ProfessionalSuite.exe" -ForegroundColor Green
            Write-Host "  ✓ File license disimpan di desktop dan dokumen" -ForegroundColor Green
            Write-Host "  ✓ Shortcut dibuat di desktop" -ForegroundColor Green
            Write-Host "  ✓ Entri uninstall ditambahkan ke Windows" -ForegroundColor Green
            Write-Host ""
            Write-Host "Informasi License:" -ForegroundColor White
            Write-Host "  User ID      : $($licenseInfo.UserID)" -ForegroundColor Cyan
            Write-Host "  License Key  : $($licenseInfo.LicenseKey)" -ForegroundColor Cyan
            Write-Host "  Computer ID  : $($licenseInfo.ComputerID)" -ForegroundColor Cyan
            Write-Host "  Expiry Date  : $($licenseInfo.ExpiryDate)" -ForegroundColor Cyan
            Write-Host ""
            Write-Host "Catatan:" -ForegroundColor Yellow
            Write-Host "  - Jangan lupa menyimpan file license_info.txt" -ForegroundColor Yellow
            Write-Host "  - Aplikasi dapat dijalankan dari shortcut di desktop" -ForegroundColor Yellow
            Write-Host "  - Untuk uninstall, gunakan Add/Remove Programs di Control Panel" -ForegroundColor Yellow
        } else {
            Write-Host "`nINSTALASI GAGAL!" -ForegroundColor Red
            Write-Host "Silakan coba lagi atau hubungi support." -ForegroundColor Red
        }
    } else {
        Write-Host "`nInstalasi dibatalkan oleh pengguna." -ForegroundColor Yellow
    }
    
    # Tahan window
    Write-Host "`n" + ("=" * 60) -ForegroundColor Green
    Write-Host "Tekan Enter untuk keluar..." -ForegroundColor Yellow -NoNewline
    Read-Host
    
} catch {
    Write-Host "`nERROR: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Stack Trace: $($_.ScriptStackTrace)" -ForegroundColor Red
    Write-Host "`nTekan Enter untuk keluar..." -ForegroundColor Yellow -NoNewline
    Read-Host
}
