# ==================================================
# SEB SOFTWARE INSTALLER - NO ADMIN REQUIRED
# ==================================================

Clear-Host

# ASCII Art yang kompatibel
$asciiArt = @"
 _______  _______  _______ 
|   _   ||       ||       |
|  |_|  ||    ___||    ___|
|       ||   |___ |   |___ 
|       ||    ___||    ___|
|   _   ||   |___ |   |___ 
|__| |__||_______||_______|
"@

# Tampilkan header dengan ASCII
Write-Host $asciiArt -ForegroundColor Cyan
Write-Host "=" * 40 -ForegroundColor Cyan
Write-Host "SOFTWARE INSTALLER (No Admin Needed)" -ForegroundColor White
Write-Host "=" * 40 -ForegroundColor Cyan
Write-Host ""

# Step 1: License Input
Write-Host "[1] LICENSE INPUT" -ForegroundColor Yellow
Write-Host "-" * 40 -ForegroundColor DarkGray

# Tampilkan pesan dengan box sederhana
Write-Host "+----------------------------------------+" -ForegroundColor Green
Write-Host "|  ENTER YOUR LICENSE KEY BELOW          |" -ForegroundColor Green
Write-Host "+----------------------------------------+" -ForegroundColor Green
Write-Host ""

$licenseKey = Read-Host "License (format: XXXX-XXXX-XXXX-XXXX) "
$licenseKey = $licenseKey.ToUpper().Trim()

Write-Host ""

# Validasi sederhana
if ($licenseKey -notmatch '^[A-Z0-9]{4}-[A-Z0-9]{4}-[A-Z0-9]{4}-[A-Z0-9]{4}$') {
    Write-Host "[ERROR] Invalid license format!" -ForegroundColor Red
    Write-Host "Example: ABCD-1234-EF56-GH78" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Press any key to exit..." -ForegroundColor Gray
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit 1
}

Write-Host "[OK] License accepted: $licenseKey" -ForegroundColor Green
Write-Host ""

# Step 2: Save License (ke Documents folder, tidak butuh admin)
Write-Host "[2] SAVING LICENSE" -ForegroundColor Yellow
Write-Host "-" * 40 -ForegroundColor DarkGray

try {
    # Save ke Documents folder (tidak butuh admin)
    $documentsPath = [Environment]::GetFolderPath("MyDocuments")
    $sebFolder = "$documentsPath\SEB"
    
    if (-not (Test-Path $sebFolder)) {
        New-Item -Path $sebFolder -ItemType Directory -Force | Out-Null
        Write-Host "Created folder: $sebFolder" -ForegroundColor Gray
    }
    
    # Buat file license sederhana
    $licenseInfo = @"
==========================================
SEB SOFTWARE LICENSE
==========================================
License: $licenseKey
User: $env:USERNAME
Computer: $env:COMPUTERNAME
Date: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
Status: ACTIVE
==========================================
"@
    
    $licenseInfo | Out-File "$sebFolder\license.txt" -Encoding UTF8
    Write-Host "[OK] License saved to Documents\SEB" -ForegroundColor Green
    
} catch {
    Write-Host "[WARNING] Could not save license: $_" -ForegroundColor Yellow
}

# Step 3: Download
Write-Host ""
Write-Host "[3] DOWNLOADING" -ForegroundColor Yellow
Write-Host "-" * 40 -ForegroundColor DarkGray

try {
    # URL download langsung (tidak perlu base64)
    $githubUrl = "https://github.com/ArvinPrdn/PATCH-INSTALLER-SEB-v3.10.0.826/releases/download/v3.10.0.826/patch-seb.1.exe"
    
    # Simpan di TEMP folder (tidak butuh admin)
    $tempFile = "$env:TEMP\seb_installer.exe"
    
    Write-Host "Downloading installer..." -ForegroundColor Gray
    Write-Host "From: $githubUrl" -ForegroundColor DarkGray
    
    # Gunakan WebClient sebagai alternatif yang lebih stabil
    $webClient = New-Object System.Net.WebClient
    $webClient.DownloadFile($githubUrl, $tempFile)
    
    if (Test-Path $tempFile) {
        $fileSize = (Get-Item $tempFile).Length
        $sizeMB = [math]::Round($fileSize / 1MB, 2)
        Write-Host "[OK] Download complete: $sizeMB MB" -ForegroundColor Green
        
        # Step 4: Install (tanpa switch /SILENT yang butuh admin)
        Write-Host ""
        Write-Host "[4] INSTALLATION" -ForegroundColor Yellow
        Write-Host "-" * 40 -ForegroundColor DarkGray
        
        Write-Host "IMPORTANT: The installer will now open." -ForegroundColor Cyan
        Write-Host "Please follow these steps:" -ForegroundColor White
        Write-Host "1. If asked for admin, click 'Yes'" -ForegroundColor Gray
        Write-Host "2. Follow the installation wizard" -ForegroundColor Gray
        Write-Host "3. Choose installation location" -ForegroundColor Gray
        Write-Host ""
        
        # Tunggu sebentar
        Write-Host "Starting installer in 5 seconds..." -ForegroundColor Yellow
        Start-Sleep -Seconds 5
        
        # Jalankan installer TANPA /SILENT (biarkan user ikuti wizard)
        Write-Host "Launching installer..." -ForegroundColor Green
        Start-Process -FilePath $tempFile -Wait
        
        # Tunggu sampai installer selesai
        Write-Host "Waiting for installer to complete..." -ForegroundColor Gray
        Start-Sleep -Seconds 2
        
        # Hapus file installer sementara
        Remove-Item $tempFile -Force -ErrorAction SilentlyContinue
        Write-Host "[OK] Temporary files cleaned up" -ForegroundColor Green
        
    } else {
        Write-Host "[ERROR] Download failed!" -ForegroundColor Red
        Write-Host ""
        Write-Host "Please try:" -ForegroundColor Yellow
        Write-Host "1. Check your internet connection" -ForegroundColor Gray
        Write-Host "2. Download manually from:" -ForegroundColor Gray
        Write-Host "   https://github.com/ArvinPrdn/PATCH-INSTALLER-SEB" -ForegroundColor White
        Write-Host ""
        Write-Host "Press any key to exit..." -ForegroundColor Gray
        $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        exit 1
    }
    
} catch {
    Write-Host "[ERROR] Installation failed: $_" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please download manually from GitHub:" -ForegroundColor Yellow
    Write-Host "https://github.com/ArvinPrdn/PATCH-INSTALLER-SEB" -ForegroundColor White
    Write-Host ""
    Write-Host "Press any key to exit..." -ForegroundColor Gray
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit 1
}

# Completion
Write-Host ""
Write-Host "=" * 50 -ForegroundColor Green
Write-Host "       INSTALLATION COMPLETE!" -ForegroundColor Green
Write-Host "=" * 50 -ForegroundColor Green
Write-Host ""

# Tampilkan ASCII art lagi
Write-Host $asciiArt -ForegroundColor Green
Write-Host ""

Write-Host "✅ SEB Software has been installed successfully!" -ForegroundColor Cyan
Write-Host ""

Write-Host "📋 Summary:" -ForegroundColor Yellow
Write-Host "-" * 30 -ForegroundColor DarkGray
Write-Host "License : $licenseKey" -ForegroundColor White
Write-Host "User    : $env:USERNAME" -ForegroundColor White
Write-Host "Computer: $env:COMPUTERNAME" -ForegroundColor White
Write-Host "Date    : $(Get-Date -Format 'yyyy-MM-dd HH:mm')" -ForegroundColor White
Write-Host "Status  : ✅ ACTIVATED" -ForegroundColor Green
Write-Host ""

Write-Host "🚀 Next steps:" -ForegroundColor Cyan
Write-Host "1. Find 'SEB' in Start Menu" -ForegroundColor White
Write-Host "2. Or look for shortcut on Desktop" -ForegroundColor White
Write-Host "3. Launch and enjoy!" -ForegroundColor White
Write-Host ""

Write-Host "📁 License saved to: $sebFolder\license.txt" -ForegroundColor Gray
Write-Host ""

Write-Host "Press any key to exit..." -ForegroundColor DarkGray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
