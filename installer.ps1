<#
.SYNOPSIS
    Professional Software Installer - Fixed Version
.DESCRIPTION
    Installer dengan tampilan yang sederhana dan tidak error
.NOTES
    Author: System Administrator
    Version: 2.0
#>

# Atur execution policy untuk session ini saja
try {
    Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force -ErrorAction SilentlyContinue
} catch {
    # Jika gagal, tidak apa-apa, lanjutkan saja
}

# Clear error log
$Error.Clear()

# Function untuk menampilkan header
function Show-Header {
    try {
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
    } catch {
        Write-Host "Error displaying header" -ForegroundColor Red
    }
}

# Function untuk input User ID
function Get-UserID {
    try {
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
    } catch {
        Write-Host "Error in Get-UserID: $_" -ForegroundColor Red
        return "USER-DEFAULT"
    }
}

# Function untuk generate license
function Get-LicenseInfo {
    param([string]$UserID)
    
    try {
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
            # Generate random character (0-9, A-F)
            $charCode = Get-Random -Minimum 48 -Maximum 71
            if ($charCode -gt 57) {
                $charCode += 7  # Skip to A-F
            }
            $key += [char]$charCode
            
            if (($i + 1) % 4 -eq 0 -and $i -lt 15) {
                $key += "-"
            }
        }
        
        # Tampilkan informasi
        Write-Host "======================================================" -ForegroundColor Green
        Write-Host "               LICENSE DETAILS" -ForegroundColor Green
        Write-Host "======================================================" -ForegroundColor Green
        Write-Host ("{0,-12}: {1}" -f "User ID", $UserID) -ForegroundColor Cyan
        Write-Host ("{0,-12}: {1}" -f "License", $key) -ForegroundColor Cyan
        Write-Host ("{0,-12}: {1}" -f "Computer ID", $computerID) -ForegroundColor Cyan
        Write-Host ("{0,-12}: {1}" -f "Date", (Get-Date -Format "yyyy-MM-dd")) -ForegroundColor Cyan
        Write-Host "======================================================" -ForegroundColor Green
        Write-Host ""
        
        return @{
            UserID = $UserID
            LicenseKey = $key
            ComputerID = $computerID
            Date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        }
    } catch {
        Write-Host "Error in Get-LicenseInfo: $_" -ForegroundColor Red
        return @{
            UserID = $UserID
            LicenseKey = "LIC-ERROR-GENERATED"
            ComputerID = "COMP-ERROR"
            Date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        }
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
                # Sleep yang lebih pendek
                Start-Sleep -Milliseconds 500
                $i++
            }
            
            Write-Host "`nInstalasi selesai!" -ForegroundColor Green
            
            # Simpan ke file - coba beberapa lokasi
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
            
            # Coba simpan ke current directory dulu
            $currentDir = Get-Location
            $filePath = Join-Path $currentDir "license_info.txt"
            
            try {
                $infoText | Out-File -FilePath $filePath -Encoding UTF8 -Force
                Write-Host "License disimpan di: $filePath" -ForegroundColor Cyan
            } catch {
                Write-Host "Gagal menyimpan ke $filePath" -ForegroundColor Yellow
                
                # Coba simpan ke desktop
                $desktopPath = [Environment]::GetFolderPath("Desktop")
                $desktopFile = Join-Path $desktopPath "license_info.txt"
                try {
                    $infoText | Out-File -FilePath $desktopFile -Encoding UTF8 -Force
                    Write-Host "License disimpan di: $desktopFile" -ForegroundColor Cyan
                } catch {
                    Write-Host "Gagal menyimpan license file" -ForegroundColor Red
                }
            }
        }
        else {
            Write-Host "`nInstalasi dibatalkan." -ForegroundColor Red
        }
        
    }
    catch {
        Write-Host "`nTerjadi error dalam proses: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host "Error details:" -ForegroundColor Red
        Write-Host "  $($_.InvocationInfo.PositionMessage)" -ForegroundColor Red
    }
    finally {
        # Tahan window - gunakan cara yang lebih reliable
        Write-Host "`n" + ("=" * 60) -ForegroundColor Green
        Write-Host "Program selesai. Jendela akan tertutup dalam 30 detik..." -ForegroundColor Yellow
        Write-Host "Atau tekan Ctrl+C untuk keluar sekarang." -ForegroundColor Yellow
        
        # Countdown
        for ($i = 30; $i -gt 0; $i--) {
            Write-Host "`rTertutup dalam: $i detik " -NoNewline -ForegroundColor Yellow
            Start-Sleep -Seconds 1
        }
    }
}

# Main execution dengan error handling global
try {
    # Set window title
    $host.UI.RawUI.WindowTitle = "Professional Installer v2.0"
    
    # Jalankan installer
    Start-Installer
    
} catch {
    Write-Host "`nFATAL ERROR: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Script tidak dapat dijalankan." -ForegroundColor Red
    Write-Host ""
    Write-Host "Kemungkinan penyebab:" -ForegroundColor Yellow
    Write-Host "1. PowerShell Execution Policy diblock" -ForegroundColor Yellow
    Write-Host "2. Script dijalankan tanpa hak administrator" -ForegroundColor Yellow
    Write-Host "3. Ada karakter khusus dalam script" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Solusi:" -ForegroundColor Cyan
    Write-Host "1. Jalankan PowerShell sebagai Administrator" -ForegroundColor Cyan
    Write-Host "2. Ketik: Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned" -ForegroundColor Cyan
    Write-Host "3. Atau jalankan dengan: powershell -ExecutionPolicy Bypass -File nama_script.ps1" -ForegroundColor Cyan
    
    Write-Host "`nTekan ENTER untuk keluar..." -ForegroundColor Yellow -NoNewline
    $null = Read-Host
}
