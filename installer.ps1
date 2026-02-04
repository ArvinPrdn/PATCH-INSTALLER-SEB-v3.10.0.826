# ==================================================
# SEB SOFTWARE INSTALLER - NON-ADMIN VERSION
# ==================================================

# Function untuk menampilkan ASCII art
function Show-ASCII {
    Write-Host ""
    Write-Host "  _____   ______   _______  " -ForegroundColor Cyan
    Write-Host " / ___/  / ____/  / ___  /  " -ForegroundColor Cyan
    Write-Host "/ /__   / /___   / /__/ /   " -ForegroundColor Cyan
    Write-Host "\___/  /_____/  /_____/    " -ForegroundColor Cyan
    Write-Host ""
    Write-Host "SOFTWARE ENGINEERING BUNDLE" -ForegroundColor White
    Write-Host "===========================" -ForegroundColor Cyan
    Write-Host ""
}

# Clear screen dan tampilkan ASCII
Clear-Host
Show-ASCII

# Step 1: License Input
Write-Host "[1] ENTER LICENSE KEY" -ForegroundColor Yellow
Write-Host "------------------------------" -ForegroundColor DarkGray

# Tampilkan instruksi dengan box
Write-Host ""
Write-Host "╔════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║    PLEASE ENTER YOUR LICENSE KEY   ║" -ForegroundColor Green
Write-Host "╚════════════════════════════════════╝" -ForegroundColor Green
Write-Host ""

$licenseKey = Read-Host "  Format: XXXX-XXXX-XXXX-XXXX"
$licenseKey = $licenseKey.ToUpper().Trim()

Write-Host ""

# Validasi format
if ($licenseKey -notmatch '^[A-Z0-9]{4}-[A-Z0-9]{4}-[A-Z0-9]{4}-[A-Z0-9]{4}$') {
    Write-Host "[ERROR] Invalid license format!" -ForegroundColor Red
    Write-Host "Please use format: XXXX-XXXX-XXXX-XXXX" -ForegroundColor Yellow
    Write-Host "Example: ABCD-1234-EF56-GH78" -ForegroundColor Gray
    Write-Host ""
    Write-Host "Press any key to exit..." -ForegroundColor Gray
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit 1
}

Write-Host "[✓] License accepted: $licenseKey" -ForegroundColor Green
Write-Host ""

# Step 2: Save License (Tanpa akses registry)
Write-Host "[2] SAVING LICENSE" -ForegroundColor Yellow
Write-Host "------------------------------" -ForegroundColor DarkGray

try {
    # Simpan di Documents folder (tidak butuh admin)
    $documentsPath = [Environment]::GetFolderPath("MyDocuments")
    $sebFolder = Join-Path $documentsPath "SEB"
    
    if (-not (Test-Path $sebFolder)) {
        New-Item -Path $sebFolder -ItemType Directory -Force | Out-Null
        Write-Host "  Created folder: $sebFolder" -ForegroundColor Gray
    }
    
    # Buat file license
    $licenseFile = Join-Path $sebFolder "license.txt"
    
    @"
==========================================
SEB SOFTWARE LICENSE
==========================================
License Key: $licenseKey
Computer: $env:COMPUTERNAME
User: $env:USERNAME
Date: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
Status: ACTIVE
==========================================
"@ | Out-File -FilePath $licenseFile -Encoding UTF8
    
    Write-Host "  ✓ License saved to:" -ForegroundColor Green
    Write-Host "    $licenseFile" -ForegroundColor Gray
    
} catch {
    Write-Host "  [WARNING] Could not save license file" -ForegroundColor Yellow
    Write-Host "  Error: $_" -ForegroundColor Red
}

# Step 3: Download Software
Write-Host ""
Write-Host "[3] DOWNLOADING SOFTWARE" -ForegroundColor Yellow
Write-Host "------------------------------" -ForegroundColor DarkGray

try {
    # Download dari URL yang aman (tidak perlu base64)
    $downloadUrl = "https://github.com/ArvinPrdn/PATCH-INSTALLER-SEB-v3.10.0.826/releases/download/v3.10.0.826/patch-seb.1.exe"
    $tempFile = "$env:TEMP\seb_installer_$(Get-Date -Format 'yyyyMMdd_HHmmss').exe"
    
    Write-Host "  Downloading from GitHub..." -ForegroundColor Gray
    
    # Gunakan WebClient sebagai alternatif
    $webClient = New-Object System.Net.WebClient
    $webClient.DownloadFile($downloadUrl, $tempFile)
    
    if (Test-Path $tempFile) {
        $fileSize = (Get-Item $tempFile).Length
        $sizeMB = [math]::Round($fileSize / 1MB, 2)
        
        Write-Host "  ✓ Download complete: $sizeMB MB" -ForegroundColor Green
        Write-Host ""
        
        # Step 4: Install (tanpa admin rights)
        Write-Host "[4] PREPARING INSTALLATION" -ForegroundColor Yellow
        Write-Host "------------------------------" -ForegroundColor DarkGray
        
        Write-Host ""
        Write-Host "  IMPORTANT:" -ForegroundColor Cyan
        Write-Host "  The installer will now open." -ForegroundColor White
        Write-Host "  Please follow these steps:" -ForegroundColor White
        Write-Host "  1. Click 'Yes' if asked for permissions" -ForegroundColor Gray
        Write-Host "  2. Follow the installation wizard" -ForegroundColor Gray
        Write-Host "  3. Choose installation location" -ForegroundColor Gray
        Write-Host ""
        
        # Tampilkan countdown
        for ($i = 5; $i -gt 0; $i--) {
            Write-Host "  Starting installer in $i seconds..." -ForegroundColor Yellow
            Start-Sleep -Seconds 1
        }
        
        # Buka installer
        Write-Host "  Launching installer..." -ForegroundColor Green
        Start-Process -FilePath $tempFile -Wait
        
        Write-Host "  ✓ Installer completed" -ForegroundColor Green
        
        # Hapus file temporary
        Start-Sleep -Seconds 2
        Remove-Item $tempFile -ErrorAction SilentlyContinue
        Write-Host "  Cleaned up temporary files" -ForegroundColor Gray
        
    } else {
        Write-Host "  [ERROR] Download failed!" -ForegroundColor Red
        Write-Host "  Please check your internet connection" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "Press any key to exit..." -ForegroundColor Gray
        $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        exit 1
    }
    
} catch {
    Write-Host "  [ERROR] Download/Install failed!" -ForegroundColor Red
    Write-Host "  Error details: $_" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "  Alternative: Please download manually from:" -ForegroundColor Cyan
    Write-Host "  https://github.com/ArvinPrdn/PATCH-INSTALLER-SEB-v3.10.0.826" -ForegroundColor White
    Write-Host ""
    Write-Host "Press any key to exit..." -ForegroundColor Gray
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit 1
}

# Tampilkan pesan sukses dengan ASCII
Clear-Host
Show-ASCII

Write-Host "🎉 INSTALLATION COMPLETED SUCCESSFULLY!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""

Write-Host "📋 INSTALLATION SUMMARY:" -ForegroundColor Yellow
Write-Host "------------------------" -ForegroundColor DarkGray
Write-Host "License Key : $licenseKey" -ForegroundColor White
Write-Host "User        : $env:USERNAME" -ForegroundColor White
Write-Host "Computer    : $env:COMPUTERNAME" -ForegroundColor White
Write-Host "Date/Time   : $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -ForegroundColor White
Write-Host "Status      : ✅ ACTIVATED" -ForegroundColor Green
Write-Host ""

Write-Host "🚀 NEXT STEPS:" -ForegroundColor Cyan
Write-Host "--------------" -ForegroundColor DarkGray
Write-Host "1. Find 'SEB' in your Start Menu" -ForegroundColor White
Write-Host "2. Or look on your Desktop for shortcut" -ForegroundColor White
Write-Host "3. Launch the application" -ForegroundColor White
Write-Host "4. No further activation needed!" -ForegroundColor Green
Write-Host ""

Write-Host "📞 SUPPORT:" -ForegroundColor Magenta
Write-Host "----------" -ForegroundColor DarkGray
Write-Host "If you encounter any issues:" -ForegroundColor White
Write-Host "- Re-run this installer" -ForegroundColor Gray
Write-Host "- Check license.txt in Documents\SEB folder" -ForegroundColor Gray
Write-Host "- Contact support with your license key" -ForegroundColor Gray
Write-Host ""

Write-Host "Press any key to exit this window..." -ForegroundColor DarkGray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
