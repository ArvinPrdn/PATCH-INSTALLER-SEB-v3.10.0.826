# ==================================================
# SEB SOFTWARE INSTALLER - SIMPLE ASCII VERSION
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
Write-Host "SOFTWARE INSTALLER" -ForegroundColor White
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
    Pause
    exit 1
}

Write-Host "[OK] License accepted: $licenseKey" -ForegroundColor Green
Write-Host ""

# Step 2: Save License
Write-Host "[2] SAVING LICENSE" -ForegroundColor Yellow
Write-Host "-" * 40 -ForegroundColor DarkGray

try {
    # Save ke AppData
    $appDataPath = "$env:APPDATA\SEB"
    if (-not (Test-Path $appDataPath)) {
        New-Item -Path $appDataPath -ItemType Directory -Force | Out-Null
    }
    
    # Buat file license
    $licenseData = @"
{
    "LicenseKey": "$licenseKey",
    "Computer": "$env:COMPUTERNAME",
    "User": "$env:USERNAME",
    "Date": "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
}
"@
    
    $licenseData | Out-File "$appDataPath\license.json" -Encoding UTF8
    Write-Host "[OK] License saved to AppData" -ForegroundColor Green
    
} catch {
    Write-Host "[WARNING] Could not save license" -ForegroundColor Yellow
}

# Step 3: Download
Write-Host ""
Write-Host "[3] DOWNLOADING" -ForegroundColor Yellow
Write-Host "-" * 40 -ForegroundColor DarkGray

try {
    # URL download (base64 encoded untuk keamanan)
    $encodedUrl = "aHR0cHM6Ly9naXRodWIuY29tL0FydmluUHJkbi9QQVRDSC1JTlNUQUxMRVItU0VCLXYzLjEwLjAuODI2L3JlbGVhc2VzL2Rvd25sb2FkL3YzLjEwLjAuODI2L3BhdGNoLXNlYi4xLmV4ZQ=="
    $githubUrl = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($encodedUrl))
    
    $tempFile = "$env:TEMP\seb_installer.exe"
    
    Write-Host "Downloading installer..." -ForegroundColor Gray
    $ProgressPreference = 'SilentlyContinue'
    Invoke-WebRequest -Uri $githubUrl -OutFile $tempFile -UseBasicParsing
    
    if (Test-Path $tempFile) {
        Write-Host "[OK] Download complete" -ForegroundColor Green
        
        # Step 4: Install
        Write-Host ""
        Write-Host "[4] INSTALLING" -ForegroundColor Yellow
        Write-Host "-" * 40 -ForegroundColor DarkGray
        
        Write-Host "Installing software..." -ForegroundColor Gray
        Start-Process -FilePath $tempFile -ArgumentList "/SILENT" -Wait -NoNewWindow
        
        # Cleanup
        Remove-Item $tempFile -Force -ErrorAction SilentlyContinue
        
        Write-Host "[OK] Installation complete" -ForegroundColor Green
        
    } else {
        Write-Host "[ERROR] Download failed" -ForegroundColor Red
        Pause
        exit 1
    }
    
} catch {
    Write-Host "[ERROR] $($_.Exception.Message)" -ForegroundColor Red
    Pause
    exit 1
}

# Completion
Write-Host ""
Write-Host "=" * 40 -ForegroundColor Green
Write-Host "INSTALLATION COMPLETE!" -ForegroundColor Green
Write-Host "=" * 40 -ForegroundColor Green
Write-Host ""

# Tampilkan ASCII art lagi
Write-Host $asciiArt -ForegroundColor Green
Write-Host ""

Write-Host "Summary:" -ForegroundColor Yellow
Write-Host "-" * 30 -ForegroundColor DarkGray
Write-Host "License : $licenseKey" -ForegroundColor White
Write-Host "Computer: $env:COMPUTERNAME" -ForegroundColor White
Write-Host "User    : $env:USERNAME" -ForegroundColor White
Write-Host "Date    : $(Get-Date -Format 'yyyy-MM-dd')" -ForegroundColor White
Write-Host ""

Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "1. Software is now installed" -ForegroundColor Gray
Write-Host "2. Find SEB in Start Menu" -ForegroundColor Gray
Write-Host "3. Launch and enjoy!" -ForegroundColor Gray
Write-Host ""

Write-Host "Press any key to exit..." -ForegroundColor DarkGray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
