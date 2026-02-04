# Professional Software Installer - Fixed Version
# Script ini aman dijalankan dan tidak akan langsung tertutup

# Atur untuk tetap membuka console setelah selesai
$ErrorActionPreference = "Stop"
try {
    # Clear console
    Clear-Host
    
    # Setup console
    $host.UI.RawUI.WindowTitle = "Professional Installer v2.0"
    
    # Tampilkan ASCII Art
    Write-Host ""
    Write-Host "    _______. ___________    ____  _______ .______          ___      " -ForegroundColor Green
    Write-Host "   /       ||   ____\   \  /   / |   ____||   _  \        /   \     " -ForegroundColor Green
    Write-Host "  |   (----`|  |__   \   \/   /  |  |__   |  |_)  |      /  ^  \    " -ForegroundColor Green
    Write-Host "   \   \    |   __|   \      /   |   __|  |      /      /  /_\  \   " -ForegroundColor Green
    Write-Host ".----)   |   |  |____   \    /    |  |____ |  |\  \----./  _____  \ " -ForegroundColor Green
    Write-Host "|_______/    |_______|   \__/     |_______|| _| `._____/__/     \__\" -ForegroundColor Green
    Write-Host ""
    Write-Host "=" * 65 -ForegroundColor Green
    Write-Host "      PROFESSIONAL INSTALLATION SYSTEM v2.0" -ForegroundColor Green
    Write-Host "=" * 65 -ForegroundColor Green
    Write-Host ""
    
    # Step 1: Input User ID
    Write-Host "STEP 1: INPUT USER ID" -ForegroundColor Yellow
    Write-Host "-" * 40 -ForegroundColor Yellow
    Write-Host ""
    
    $userID = Read-Host "Masukkan User ID Anda"
    
    # Validasi input
    while ([string]::IsNullOrWhiteSpace($userID)) {
        Write-Host "Error: User ID tidak boleh kosong!" -ForegroundColor Red
        $userID = Read-Host "Masukkan User ID Anda"
    }
    
    # Step 2: Generate informasi
    Clear-Host
    
    # Tampilkan ASCII lagi
    Write-Host ""
    Write-Host "    _______. ___________    ____  _______ .______          ___      " -ForegroundColor Green
    Write-Host "   /       ||   ____\   \  /   / |   ____||   _  \        /   \     " -ForegroundColor Green
    Write-Host "  |   (----`|  |__   \   \/   /  |  |__   |  |_)  |      /  ^  \    " -ForegroundColor Green
    Write-Host "   \   \    |   __|   \      /   |   __|  |      /      /  /_\  \   " -ForegroundColor Green
    Write-Host ".----)   |   |  |____   \    /    |  |____ |  |\  \----./  _____  \ " -ForegroundColor Green
    Write-Host "|_______/    |_______|   \__/     |_______|| _| `._____/__/     \__\" -ForegroundColor Green
    Write-Host ""
    
    Write-Host "STEP 2: LICENSE INFORMATION" -ForegroundColor Yellow
    Write-Host "-" * 40 -ForegroundColor Yellow
    Write-Host ""
    
    # Generate License Key sederhana
    function Generate-License {
        $chars = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789"
        $license = ""
        for ($i = 1; $i -le 20; $i++) {
            $license += $chars[(Get-Random -Minimum 0 -Maximum $chars.Length)]
            if ($i % 4 -eq 0 -and $i -ne 20) {
                $license += "-"
            }
        }
        return $license
    }
    
    # Generate Computer ID sederhana
    $computerID = "PC-" + (Get-Random -Minimum 100000 -Maximum 999999).ToString()
    $licenseKey = Generate-License
    $installDate = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $expiryDate = (Get-Date).AddYears(1).ToString("yyyy-MM-dd")
    
    # Tampilkan informasi dalam tabel
    Write-Host "╔══════════════════════════════════════════════════════╗" -ForegroundColor Green
    Write-Host "║                 LICENSE INFORMATION                  ║" -ForegroundColor Green
    Write-Host "╠══════════════════════════════════════════════════════╣" -ForegroundColor Green
    Write-Host ("║ {0,-15}: {1,-32} ║" -f "User ID", $userID) -ForegroundColor Green
    Write-Host "╠══════════════════════════════════════════════════════╣" -ForegroundColor Green
    Write-Host ("║ {0,-15}: {1,-32} ║" -f "License Key", $licenseKey) -ForegroundColor Green
    Write-Host ("║ {0,-15}: {1,-32} ║" -f "Computer ID", $computerID) -ForegroundColor Green
    Write-Host ("║ {0,-15}: {1,-32} ║" -f "Install Date", $installDate) -ForegroundColor Green
    Write-Host ("║ {0,-15}: {1,-32} ║" -f "Expiry Date", $expiryDate) -ForegroundColor Green
    Write-Host "╚══════════════════════════════════════════════════════╝" -ForegroundColor Green
    Write-Host ""
    
    # Step 3: Konfirmasi instalasi
    Write-Host "STEP 3: INSTALLATION CONFIRMATION" -ForegroundColor Yellow
    Write-Host "-" * 40 -ForegroundColor Yellow
    Write-Host ""
    
    $confirm = Read-Host "Apakah Anda ingin melanjutkan instalasi? (Y/N)"
    
    if ($confirm -eq 'Y' -or $confirm -eq 'y') {
        Write-Host "`nMemulai instalasi..." -ForegroundColor Green
        
        # Simulasi progress bar
        for ($i = 0; $i -le 100; $i += 10) {
            Write-Progress -Activity "Installing Software" -Status "$i% Complete" -PercentComplete $i
            Start-Sleep -Milliseconds 300
        }
        
        Write-Host "`nInstalasi berhasil!" -ForegroundColor Green
        
        # Simpan informasi ke file
        $licenseInfo = @"
===========================================
PROFESSIONAL SOFTWARE LICENSE
===========================================
User ID: $userID
License Key: $licenseKey
Computer ID: $computerID
Installation Date: $installDate
Expiry Date: $expiryDate
===========================================
"@
        
        $licenseInfo | Out-File -FilePath "license.txt" -Encoding UTF8
        Write-Host "`nInformasi license disimpan di: license.txt" -ForegroundColor Cyan
    }
    else {
        Write-Host "`nInstalasi dibatalkan." -ForegroundColor Red
    }
    
    # Tahan console agar tidak langsung tertutup
    Write-Host "`n" + ("=" * 65) -ForegroundColor Green
    Write-Host "Tekan sembarang tombol untuk keluar..." -ForegroundColor Yellow
    $null = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}
catch {
    Write-Host "`nTerjadi error: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Tekan sembarang tombol untuk keluar..." -ForegroundColor Yellow
    $null = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}
