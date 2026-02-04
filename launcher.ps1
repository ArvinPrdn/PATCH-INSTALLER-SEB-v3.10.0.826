# ==================================================
# SEB SOFTWARE INSTALLER - WITH ASCII ART
# ==================================================

Clear-Host
Write-Host "SEB SOFTWARE INSTALLER" -ForegroundColor Cyan
Write-Host "======================" -ForegroundColor Cyan
Write-Host ""

# ASCII Art untuk ditampilkan saat input
$asciiArt = @"
     _______. ___________    ____  _______ .______          ___      
    /       ||   ____\   \  /   / |   ____||   _  \        /   \     
   |   (----`|  |__   \   \/   /  |  |__   |  |_)  |      /  ^  \    
    \   \    |   __|   \      /   |   __|  |      /      /  /_\  \   
.----)   |   |  |____   \    /    |  |____ |  |\  \----./  _____  \  
|_______/    |_______|   \__/     |_______|| _| `._____/__/     \__\
"@

# Step 1: License Input dengan ASCII Art
Write-Host "[1] Enter License Key" -ForegroundColor Yellow
Write-Host "-" * 40 -ForegroundColor DarkGray
Write-Host ""

# Tampilkan ASCII Art
Write-Host $asciiArt -ForegroundColor Magenta
Write-Host ""

# Input license dengan prompt yang menarik
Write-Host "╔══════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║   Enter Your License Key (20 characters) ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

$licenseKey = Read-Host "   License (XXXX-XXXX-XXXX-XXXX) "
$licenseKey = $licenseKey.ToUpper().Trim()

Write-Host ""

# Simple Validation
if ($licenseKey -notmatch '^[A-Z0-9]{4}-[A-Z0-9]{4}-[A-Z0-9]{4}-[A-Z0-9]{4}$') {
    Write-Host "[ERROR] Invalid license format!" -ForegroundColor Red
    Write-Host "Format: XXXX-XXXX-XXXX-XXXX" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Example: ABCD-EFGH-IJKL-MNOP" -ForegroundColor Gray
    Write-Host ""
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host "[✓] License accepted" -ForegroundColor Green
Write-Host ""

# Tampilkan lagi ASCII kecil sebagai konfirmasi
Write-Host "   ✅ Validating..." -ForegroundColor Yellow
Write-Host "   ┌─────────────────────────────────┐" -ForegroundColor DarkGray
Write-Host "   │  LICENSI DITERIMA               │" -ForegroundColor Green
Write-Host "   │  ID: $licenseKey  │" -ForegroundColor White
Write-Host "   └─────────────────────────────────┘" -ForegroundColor DarkGray
Write-Host ""

# Step 2: Save License
Write-Host "[2] Saving License..." -ForegroundColor Yellow
Write-Host "-" * 40 -ForegroundColor DarkGray
Write-Host ""

try {
    # Save to AppData (Primary)
    $appDataPath = "$env:APPDATA\SEB"
    if (-not (Test-Path $appDataPath)) {
        New-Item -Path $appDataPath -ItemType Directory -Force | Out-Null
        Write-Host "   📁 Created directory: $appDataPath" -ForegroundColor Gray
    }
    
    $licenseInfo = @{
        LicenseKey = $licenseKey
        Computer = $env:COMPUTERNAME
        User = $env:USERNAME
        Date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        Status = "ACTIVE"
    }
    
    $licenseInfo | ConvertTo-Json | Out-File "$appDataPath\license.json" -Encoding UTF8
    Write-Host "   💾 License saved to: $appDataPath\license.json" -ForegroundColor Green
    
    # Try Registry as backup
    try {
        $regPath = "HKCU:\Software\SEB"
        if (-not (Test-Path $regPath)) {
            New-Item -Path $regPath -Force | Out-Null
        }
        Set-ItemProperty -Path $regPath -Name "License" -Value $licenseKey -Force | Out-Null
        Set-ItemProperty -Path $regPath -Name "InstallDate" -Value (Get-Date -Format "yyyy-MM-dd") -Force | Out-Null
        Write-Host "   🔧 Registry entry created" -ForegroundColor Green
    } catch {
        Write-Host "   ℹ️  Skipping registry (optional)" -ForegroundColor Gray
    }
    
} catch {
    Write-Host "[WARNING] Could not save license: $_" -ForegroundColor Yellow
    Write-Host "Continuing installation anyway..." -ForegroundColor Gray
}

# Step 3: Download & Install
Write-Host ""
Write-Host "[3] Downloading Software..." -ForegroundColor Yellow
Write-Host "-" * 40 -ForegroundColor DarkGray
Write-Host ""

try {
    # GitHub URL (Base64 encoded)
    $base64Url = "aHR0cHM6Ly9naXRodWIuY29tL0FydmluUHJkbi9QQVRDSC1JTlNUQUxMRVItU0VCLXYzLjEwLjAuODI2L3JlbGVhc2VzL2Rvd25sb2FkL3YzLjEwLjAuODI2L3BhdGNoLXNlYi4xLmV4ZQ=="
    
    # Decode URL
    $githubUrl = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($base64Url))
    
    # Add timestamp
    $timestamp = Get-Date -Format "yyyyMMddHHmmss"
    $downloadUrl = $githubUrl + "?t=" + $timestamp
    
    # Download file
    $tempFile = "$env:TEMP\seb-installer-$timestamp.exe"
    
    Write-Host "   🌐 Downloading from secure server..." -ForegroundColor Gray
    Write-Host "   📥 URL: $githubUrl" -ForegroundColor DarkGray
    
    $ProgressPreference = 'SilentlyContinue'
    Invoke-WebRequest -Uri $downloadUrl -OutFile $tempFile -UseBasicParsing
    
    if (Test-Path $tempFile) {
        $sizeMB = [math]::Round((Get-Item $tempFile).Length / 1MB, 2)
        Write-Host "   ✅ Downloaded: $sizeMB MB" -ForegroundColor Green
        
        # Install
        Write-Host ""
        Write-Host "[4] Installing..." -ForegroundColor Yellow
        Write-Host "-" * 40 -ForegroundColor DarkGray
        Write-Host ""
        Write-Host "   ⚙️  Running installer in silent mode..." -ForegroundColor Gray
        Write-Host "   ⏳ Please wait, this may take a moment..." -ForegroundColor Gray
        
        $process = Start-Process -FilePath $tempFile -ArgumentList "/SILENT" -Wait -PassThru
        
        if ($process.ExitCode -eq 0) {
            Write-Host "   🎉 Installation successful!" -ForegroundColor Green
        } else {
            Write-Host "   ⚠️  Installer completed with code: $($process.ExitCode)" -ForegroundColor Yellow
        }
        
        # Cleanup
        Start-Sleep -Seconds 2
        Remove-Item $tempFile -Force -ErrorAction SilentlyContinue
        Write-Host "   🧹 Temporary files cleaned up" -ForegroundColor Gray
        
    } else {
        Write-Host "[ERROR] Download failed!" -ForegroundColor Red
        Read-Host "Press Enter to exit"
        exit 1
    }
    
} catch {
    Write-Host "[ERROR] Installation failed: $_" -ForegroundColor Red
    Write-Host "Check internet connection and try again." -ForegroundColor Yellow
    Read-Host "Press Enter to exit"
    exit 1
}

# Final Message dengan ASCII Art
Write-Host ""
Write-Host "=" * 50 -ForegroundColor Green
Write-Host "            INSTALLATION COMPLETE!" -ForegroundColor Green
Write-Host "=" * 50 -ForegroundColor Green
Write-Host ""

# Tampilkan ASCII Art lagi di akhir
Write-Host $asciiArt -ForegroundColor Cyan
Write-Host ""

Write-Host "🎉 SEB Software installed successfully!" -ForegroundColor Cyan
Write-Host ""

Write-Host "📋 Next Steps:" -ForegroundColor Yellow
Write-Host "   1. Find 'SEB' in Start Menu" -ForegroundColor White
Write-Host "   2. Or run launcher.ps1" -ForegroundColor White
Write-Host "   3. No activation needed!" -ForegroundColor Green

Write-Host ""
Write-Host "🔑 Your License: $licenseKey" -ForegroundColor White
Write-Host "💻 Computer: $env:COMPUTERNAME" -ForegroundColor White
Write-Host "👤 User: $env:USERNAME" -ForegroundColor White
Write-Host "📅 Date: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -ForegroundColor White

Write-Host ""
Write-Host "━" * 50 -ForegroundColor DarkGray

Read-Host "`nPress Enter to exit"

# Optional: Create desktop shortcut
try {
    $desktopPath = [Environment]::GetFolderPath("Desktop")
    $shortcutPath = "$desktopPath\SEB.lnk"
    $WScriptShell = New-Object -ComObject WScript.Shell
    $Shortcut = $WScriptShell.CreateShortcut($shortcutPath)
    $Shortcut.TargetPath = "C:\Program Files\SEB\SEB.exe"
    $Shortcut.Save()
    Write-Host "   🚀 Desktop shortcut created" -ForegroundColor Green
} catch {
    # Ignore error if shortcut creation fails
}
