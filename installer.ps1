<#
.SYNOPSIS
    Professional Software Installer - Simple Version
.DESCRIPTION
    Installer dengan tampilan yang sederhana dan tidak error
.NOTES
    Author: System Administrator
    Version: 2.0
#>

# Function untuk menampilkan header
function Show-Header {
    Clear-Host
    Write-Host ""
    Write-Host "    _______. ___________    ____  _______ .______          ___      " -ForegroundColor Green
    Write-Host "   /       ||   ____\   \  /   / |   ____||   _  \        /   \     " -ForegroundColor Green
    Write-Host "  |   (----`|  |__   \   \/   /  |  |__   |  |_)  |      /  ^  \    " -ForegroundColor Green
    Write-Host "   \   \    |   __|   \      /   |   __|  |      /      /  /_\  \   " -ForegroundColor Green
    Write-Host ".----)   |   |  |____   \    /    |  |____ |  |\  \----./  _____  \ " -ForegroundColor Green
    Write-Host "|_______/    |_______|   \__/     |_______|| _| `._____/__/     \__\" -ForegroundColor Green
    Write-Host ""
    Write-Host "*" * 60 -ForegroundColor Green
    Write-Host "        PROFESSIONAL INSTALLER v2.0" -ForegroundColor Green
    Write-Host "*" * 60 -ForegroundColor Green
    Write-Host ""
}

# Function untuk input User ID
function Get-UserID {
    Show-Header
    Write-Host "STEP 1: USER ID INPUT" -ForegroundColor Yellow
    Write-Host "-" * 40 -ForegroundColor Yellow
    Write-Host ""
    
    $id = Read-Host "Silakan masukkan User ID Anda"
    
    # Jika kosong, beri default
    if ([string]::IsNullOrWhiteSpace($id)) {
        Write-Host "Menggunakan ID default..." -ForegroundColor Yellow
        $id = "USER-" + (Get-Date -Format "yyyyMMdd")
    }
    
    return $id
}

# Function untuk generate license
function Get-LicenseInfo {
    param([string]$UserID)
    
    Show-Header
    Write-Host "STEP 2: LICENSE INFORMATION" -ForegroundColor Yellow
    Write-Host "-" * 40 -ForegroundColor Yellow
    Write-Host ""
    
    # Generate sederhana
    $random = Get-Random -Minimum 100000 -Maximum 999999
    $computerID = "COMP-" + $random.ToString()
    
    # License Key format: XXXX-XXXX-XXXX-XXXX
    $key = ""
    for ($i = 0; $i -lt 16; $i++) {
        $key += (48..57 + 65..70 | Get-Random | % {[char]$_})
        if (($i + 1) % 4 -eq 0 -and $i -lt 15) {
            $key += "-"
        }
    }
    
    # Tampilkan informasi
    Write-Host "┌──────────────────────────────────────────────────────┐" -ForegroundColor Green
    Write-Host "│               LICENSE DETAILS                        │" -ForegroundColor Green
    Write-Host "├──────────────────────────────────────────────────────┤" -ForegroundColor Green
    Write-Host ("│ {0,-12}: {1,-35} │" -f "User ID", $UserID) -ForegroundColor Green
    Write-Host ("│ {0,-12}: {1,-35} │" -f "License", $key) -ForegroundColor Green
    Write-Host ("│ {0,-12}: {1,-35} │" -f "Computer ID", $computerID) -ForegroundColor Green
    Write-Host ("│ {0,-12}: {1,-35} │" -f "Date", (Get-Date -Format "yyyy-MM-dd")) -ForegroundColor Green
    Write-Host "└──────────────────────────────────────────────────────┘" -ForegroundColor Green
    Write-Host ""
    
    return @{
        UserID = $UserID
        LicenseKey = $key
        ComputerID = $computerID
        Date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    }
}

# Function utama
function Start-Installer {
    try {
        # Dapatkan User ID
        $userID = Get-UserID
        
        # Tampilkan license info
        $licenseInfo = Get-LicenseInfo -UserID $userID
        
        # Konfirmasi instalasi
        Write-Host "STEP 3: CONFIRMATION" -ForegroundColor Yellow
        Write-Host "-" * 40 -ForegroundColor Yellow
        Write-Host ""
        
        Write-Host "Apakah Anda ingin melanjutkan instalasi?" -ForegroundColor White
        Write-Host "1. Ya, lanjutkan instalasi" -ForegroundColor Cyan
        Write-Host "2. Tidak, batalkan" -ForegroundColor Cyan
        Write-Host ""
        
        $choice = Read-Host "Pilihan (1/2)"
        
        if ($choice -eq "1") {
            # Proses instalasi
            Write-Host "`nMemulai instalasi..." -ForegroundColor Green
            
            # Progress sederhana
            $steps = @("Initializing...", "Copying files...", "Registering components...", "Finalizing...")
            $i = 1
            foreach ($step in $steps) {
                Write-Host "  [$i/4] $step" -ForegroundColor Yellow
                Start-Sleep -Seconds 1
                $i++
            }
            
            Write-Host "`nInstalasi selesai!" -ForegroundColor Green
            
            # Simpan ke file
            $infoText = @"
=======================================
SOFTWARE LICENSE INFORMATION
=======================================
User ID      : $($licenseInfo.UserID)
License Key  : $($licenseInfo.LicenseKey)
Computer ID  : $($licenseInfo.ComputerID)
Install Date : $($licenseInfo.Date)
=======================================
"@
            
            $infoText | Out-File -FilePath "C:\temp\license_info.txt" -Force -ErrorAction SilentlyContinue
            if (Test-Path "C:\temp\license_info.txt") {
                Write-Host "License disimpan di: C:\temp\license_info.txt" -ForegroundColor Cyan
            } else {
                $infoText | Out-File -FilePath ".\license_info.txt" -Force
                Write-Host "License disimpan di: license_info.txt" -ForegroundColor Cyan
            }
        }
        else {
            Write-Host "`nInstalasi dibatalkan." -ForegroundColor Red
        }
        
        # Tahan window
        Write-Host "`n" + ("=" * 60) -ForegroundColor Green
        Write-Host "Tekan ENTER untuk keluar..." -ForegroundColor Yellow -NoNewline
        Read-Host
    }
    catch {
        Write-Host "`nError: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host "Tekan ENTER untuk keluar..." -ForegroundColor Yellow -NoNewline
        Read-Host
    }
}

# Jalankan installer
Start-Installer
