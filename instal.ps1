# instal.ps1
# Script Instalasi Portable dengan GitHub Integration
# Simpan di flashdisk untuk instalasi di berbagai perangkat

# ============================================
# KONFIGURASI
# ============================================
$ScriptVersion = "1.0.0"
$GitHubRepo = "username/repository"  # Ganti dengan repo GitHub Anda
$DefaultInstallPath = "$env:ProgramData\MyApplication"
$LogFile = "installation_log_$(Get-Date -Format 'yyyyMMdd_HHmmss').log"

# ============================================
# FUNGSI LOGGING
# ============================================
function Write-Log {
    param(
        [string]$Message,
        [string]$Level = "INFO"
    )
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "[$timestamp] [$Level] $Message"
    
    # Tampilkan di console dengan warna berbeda
    switch ($Level) {
        "ERROR" { Write-Host $logEntry -ForegroundColor Red }
        "WARNING" { Write-Host $logEntry -ForegroundColor Yellow }
        "SUCCESS" { Write-Host $logEntry -ForegroundColor Green }
        default { Write-Host $logEntry -ForegroundColor Cyan }
    }
    
    # Simpan ke file log
    Add-Content -Path $LogFile -Value $logEntry -Force
}

# ============================================
# FUNGSI DETEKSI PERANGKAT
# ============================================
function Get-DeviceInfo {
    Write-Log "Mengumpulkan informasi perangkat..." "INFO"
    
    $deviceInfo = @{
        Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        ComputerName = $env:COMPUTERNAME
        Username = $env:USERNAME
        Domain = $env:USERDOMAIN
    }
    
    try {
        # Informasi Sistem Operasi
        $os = Get-CimInstance Win32_OperatingSystem
        $deviceInfo.OS = "$($os.Caption) $($os.Version)"
        $deviceInfo.Architecture = $os.OSArchitecture
        $deviceInfo.BuildNumber = $os.BuildNumber
        
        # Informasi Manufacturer
        $computerSystem = Get-CimInstance Win32_ComputerSystem
        $deviceInfo.Manufacturer = $computerSystem.Manufacturer
        $deviceInfo.Model = $computerSystem.Model
        $deviceInfo.TotalMemory = "$([math]::Round($computerSystem.TotalPhysicalMemory / 1GB, 2)) GB"
        
        # Informasi Processor
        $processor = Get-CimInstance Win32_Processor
        $deviceInfo.Processor = $processor.Name
        $deviceInfo.Cores = "$($processor.NumberOfCores) core"
        $deviceInfo.LogicalProcessors = "$($processor.NumberOfLogicalProcessors) thread"
        
        # Informasi Disk
        $disks = Get-CimInstance Win32_LogicalDisk -Filter "DriveType=3"
        $diskInfo = @()
        foreach ($disk in $disks) {
            $freeGB = [math]::Round($disk.FreeSpace / 1GB, 2)
            $totalGB = [math]::Round($disk.Size / 1GB, 2)
            $diskInfo += "$($disk.DeviceID) ($freeGB GB free / $totalGB GB total)"
        }
        $deviceInfo.Disks = $diskInfo -join ", "
        
        # Informasi Network
        $networkAdapters = Get-CimInstance Win32_NetworkAdapterConfiguration -Filter "IPEnabled=True"
        $ipAddresses = @()
        foreach ($adapter in $networkAdapters) {
            if ($adapter.IPAddress) {
                $ipAddresses += $adapter.IPAddress[0]
            }
        }
        $deviceInfo.IPAddress = $ipAddresses -join ", "
        
        # Informasi Battery (jika laptop)
        $battery = Get-CimInstance Win32_Battery
        if ($battery) {
            $deviceInfo.BatteryStatus = $battery.Status
            $deviceInfo.BatteryPercentage = if ($battery.EstimatedChargeRemaining) { "$($battery.EstimatedChargeRemaining)%" } else { "N/A" }
        }
        
        Write-Log "Informasi perangkat berhasil dikumpulkan" "SUCCESS"
        
    } catch {
        Write-Log "Gagal mengumpulkan beberapa informasi perangkat: $_" "WARNING"
    }
    
    return $deviceInfo
}

function Show-DeviceSummary {
    param($deviceInfo)
    
    Write-Host "`n" -NoNewline
    Write-Host "="*60 -ForegroundColor Magenta
    Write-Host "DETEKSI PERANGKAT" -ForegroundColor Magenta
    Write-Host "="*60 -ForegroundColor Magenta
    
    $deviceInfo.GetEnumerator() | ForEach-Object {
        Write-Host ("{0,-25}: {1}" -f $_.Key, $_.Value) -ForegroundColor White
    }
    
    Write-Host "="*60 -ForegroundColor Magenta
    Write-Host "`n" -NoNewline
}

# ============================================
# FUNGSI VALIDASI DAN PERSIAPAN
# ============================================
function Test-Administrator {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Test-InternetConnection {
    Write-Log "Memeriksa koneksi internet..." "INFO"
    
    try {
        $test = Test-NetConnection -ComputerName "github.com" -Port 443 -InformationLevel Quiet
        if ($test) {
            Write-Log "Koneksi internet tersedia" "SUCCESS"
            return $true
        } else {
            Write-Log "Koneksi internet tidak tersedia" "WARNING"
            return $false
        }
    } catch {
        Write-Log "Gagal memeriksa koneksi internet: $_" "WARNING"
        return $false
    }
}

function Get-InstallationPath {
    Write-Host "`nPilih lokasi instalasi:" -ForegroundColor Yellow
    Write-Host "1. Lokasi default ($DefaultInstallPath)" -ForegroundColor Cyan
    Write-Host "2. Custom location" -ForegroundColor Cyan
    Write-Host "3. Folder portable di flashdisk" -ForegroundColor Cyan
    
    $choice = Read-Host "`nMasukkan pilihan (1-3)"
    
    switch ($choice) {
        "1" {
            $path = $DefaultInstallPath
            Write-Log "Menggunakan lokasi default: $path" "INFO"
        }
        "2" {
            $path = Read-Host "Masukkan path custom"
            if (-not (Test-Path $path)) {
                try {
                    New-Item -ItemType Directory -Path $path -Force | Out-Null
                    Write-Log "Membuat folder: $path" "INFO"
                } catch {
                    Write-Log "Gagal membuat folder: $_" "ERROR"
                    $path = $DefaultInstallPath
                }
            }
        }
        "3" {
            $scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
            $path = Join-Path $scriptPath "PortableInstall"
            Write-Log "Menggunakan folder portable: $path" "INFO"
        }
        default {
            Write-Log "Pilihan tidak valid, menggunakan lokasi default" "WARNING"
            $path = $DefaultInstallPath
        }
    }
    
    return $path
}

# ============================================
# FUNGSI GITHUB INTEGRATION
# ============================================
function Get-GitHubReleases {
    param(
        [string]$Repo,
        [string]$AccessToken = $null
    )
    
    Write-Log "Mengecek update dari GitHub..." "INFO"
    
    $url = "https://api.github.com/repos/$Repo/releases/latest"
    
    $headers = @{
        "Accept" = "application/vnd.github.v3+json"
        "User-Agent" = "PowerShellInstallScript"
    }
    
    if ($AccessToken) {
        $headers["Authorization"] = "token $AccessToken"
    }
    
    try {
        $response = Invoke-RestMethod -Uri $url -Headers $headers -Method Get
        Write-Log "Berhasil mendapatkan informasi dari GitHub" "SUCCESS"
        
        return @{
            Version = $response.tag_name
            ReleaseNotes = $response.body
            DownloadUrl = $response.assets[0].browser_download_url
            PublishedDate = $response.published_at
        }
    } catch {
        Write-Log "Gagal mendapatkan informasi dari GitHub: $_" "WARNING"
        return $null
    }
}

function Update-FromGitHub {
    param(
        [string]$Repo,
        [string]$InstallPath,
        [string]$AccessToken = $null
    )
    
    $releaseInfo = Get-GitHubReleases -Repo $Repo -AccessToken $AccessToken
    
    if ($releaseInfo -and $releaseInfo.Version -ne $ScriptVersion) {
        Write-Host "`n" -NoNewline
        Write-Host "="*60 -ForegroundColor Green
        Write-Host "UPDATE TERSEDIA!" -ForegroundColor Green
        Write-Host "="*60 -ForegroundColor Green
        Write-Host "Versi saat ini: $ScriptVersion" -ForegroundColor Yellow
        Write-Host "Versi terbaru : $($releaseInfo.Version)" -ForegroundColor Green
        Write-Host "Tanggal rilis : $($releaseInfo.PublishedDate)" -ForegroundColor Cyan
        Write-Host "`nRelease Notes:" -ForegroundColor White
        Write-Host $releaseInfo.ReleaseNotes -ForegroundColor Gray
        Write-Host "="*60 -ForegroundColor Green
        
        $confirm = Read-Host "`nUpdate ke versi terbaru? (Y/N)"
        if ($confirm -eq 'Y' -or $confirm -eq 'y') {
            Write-Log "Mengunduh update dari GitHub..." "INFO"
            
            $tempFile = Join-Path $env:TEMP "update_$($releaseInfo.Version).zip"
            
            try {
                Invoke-WebRequest -Uri $releaseInfo.DownloadUrl -OutFile $tempFile
                Write-Log "Update berhasil diunduh" "SUCCESS"
                
                # Ekstrak update
                Expand-Archive -Path $tempFile -DestinationPath $InstallPath -Force
                Write-Log "Update berhasil diekstrak" "SUCCESS"
                
                # Update versi
                $ScriptVersion = $releaseInfo.Version
                
            } catch {
                Write-Log "Gagal mengunduh update: $_" "ERROR"
            }
        }
    } else {
        Write-Log "Aplikasi sudah versi terbaru" "INFO"
    }
}

# ============================================
# FUNGSI INSTALASI UTAMA
# ============================================
function Start-Installation {
    param(
        [string]$InstallPath
    )
    
    Write-Host "`n" -NoNewline
    Write-Host "="*60 -ForegroundColor Blue
    Write-Host "PROSES INSTALASI" -ForegroundColor Blue
    Write-Host "="*60 -ForegroundColor Blue
    
    # 1. Buat folder instalasi
    Write-Log "Membuat folder instalasi..." "INFO"
    try {
        if (-not (Test-Path $InstallPath)) {
            New-Item -ItemType Directory -Path $InstallPath -Force | Out-Null
            Write-Log "Folder instalasi dibuat: $InstallPath" "SUCCESS"
        } else {
            Write-Log "Folder instalasi sudah ada: $InstallPath" "INFO"
        }
    } catch {
        Write-Log "Gagal membuat folder instalasi: $_" "ERROR"
        return $false
    }
    
    # 2. Salin file dari flashdisk
    Write-Log "Menyalin file dari flashdisk..." "INFO"
    $scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
    
    try {
        # Contoh: Salin semua file .exe dan .dll
        $filesToCopy = Get-ChildItem -Path $scriptDir -Include "*.exe", "*.dll", "*.config" -Recurse
        
        foreach ($file in $filesToCopy) {
            $relativePath = $file.FullName.Substring($scriptDir.Length + 1)
            $destPath = Join-Path $InstallPath $relativePath
            $destDir = Split-Path -Parent $destPath
            
            if (-not (Test-Path $destDir)) {
                New-Item -ItemType Directory -Path $destDir -Force | Out-Null
            }
            
            Copy-Item -Path $file.FullName -Destination $destPath -Force
            Write-Log "File disalin: $relativePath" "INFO"
        }
        
        Write-Log "File berhasil disalin" "SUCCESS"
        
    } catch {
        Write-Log "Gagal menyalin file: $_" "ERROR"
        return $false
    }
    
    # 3. Buat shortcut (opsional)
    $createShortcut = Read-Host "`nBuat shortcut di desktop? (Y/N)"
    if ($createShortcut -eq 'Y' -or $createShortcut -eq 'y') {
        try {
            $shortcutPath = Join-Path ([Environment]::GetFolderPath("Desktop")) "MyApplication.lnk"
            $targetPath = Join-Path $InstallPath "MyApp.exe"  # Ganti dengan executable utama
            
            $WshShell = New-Object -ComObject WScript.Shell
            $Shortcut = $WshShell.CreateShortcut($shortcutPath)
            $Shortcut.TargetPath = $targetPath
            $Shortcut.WorkingDirectory = $InstallPath
            $Shortcut.Save()
            
            Write-Log "Shortcut berhasil dibuat di desktop" "SUCCESS"
        } catch {
            Write-Log "Gagal membuat shortcut: $_" "WARNING"
        }
    }
    
    return $true
}

# ============================================
# FUNGSI PEMBERSIHAN
# ============================================
function Complete-Installation {
    param(
        [string]$InstallPath,
        [hashtable]$DeviceInfo
    )
    
    # Simpan informasi instalasi
    $installInfo = @{
        InstallationDate = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        InstallationPath = $InstallPath
        ScriptVersion = $ScriptVersion
        DeviceInfo = $DeviceInfo
    }
    
    $installInfoPath = Join-Path $InstallPath "installation_info.json"
    $installInfo | ConvertTo-Json -Depth 10 | Out-File -FilePath $installInfoPath -Encoding UTF8
    
    Write-Host "`n" -NoNewline
    Write-Host "="*60 -ForegroundColor Green
    Write-Host "INSTALASI SELESAI" -ForegroundColor Green
    Write-Host "="*60 -ForegroundColor Green
    Write-Host "Lokasi instalasi : $InstallPath" -ForegroundColor White
    Write-Host "Versi aplikasi   : $ScriptVersion" -ForegroundColor White
    Write-Host "Log file         : $LogFile" -ForegroundColor White
    Write-Host "="*60 -ForegroundColor Green
    
    # Buka folder instalasi
    $openFolder = Read-Host "`nBuka folder instalasi? (Y/N)"
    if ($openFolder -eq 'Y' -or $openFolder -eq 'y') {
        explorer $InstallPath
    }
}

# ============================================
# MAIN EXECUTION
# ============================================
Clear-Host

# Header
Write-Host @"
╔══════════════════════════════════════════════════════════╗
║          INSTALASI APLIKASI - VERSI PORTABLE             ║
║                   Version: $ScriptVersion                 ║
╚══════════════════════════════════════════════════════════╝
"@ -ForegroundColor Cyan

# 1. Validasi administrator
Write-Log "Memeriksa hak akses administrator..." "INFO"
if (-not (Test-Administrator)) {
    Write-Log "Script perlu dijalankan sebagai Administrator!" "ERROR"
    Write-Host "`nSilakan jalankan PowerShell sebagai Administrator dan coba lagi." -ForegroundColor Red
    Write-Host "Tekan Enter untuk keluar..." -ForegroundColor Yellow
    Read-Host
    exit 1
}
Write-Log "Berjalan sebagai Administrator" "SUCCESS"

# 2. Deteksi perangkat
$deviceInfo = Get-DeviceInfo
Show-DeviceSummary $deviceInfo

# 3. Pilih lokasi instalasi
$installPath = Get-InstallationPath

# 4. Cek koneksi internet dan update dari GitHub
$hasInternet = Test-InternetConnection
if ($hasInternet) {
    $useGitHub = Read-Host "`nCek update dari GitHub? (Y/N)"
    if ($useGitHub -eq 'Y' -or $useGitHub -eq 'y') {
        $accessToken = Read-Host "Masukkan GitHub token (optional, tekan Enter untuk skip)"
        Update-FromGitHub -Repo $GitHubRepo -InstallPath $installPath -AccessToken $accessToken
    }
}

# 5. Konfirmasi instalasi
Write-Host "`n" -NoNewline
Write-Host "RINGKASAN INSTALASI" -ForegroundColor Yellow
Write-Host "Perangkat     : $($deviceInfo.ComputerName)" -ForegroundColor White
Write-Host "User          : $($deviceInfo.Username)" -ForegroundColor White
Write-Host "Sistem Operasi: $($deviceInfo.OS)" -ForegroundColor White
Write-Host "Lokasi        : $installPath" -ForegroundColor White
Write-Host "`n" -NoNewline

$confirm = Read-Host "Lanjutkan instalasi? (Y/N)"
if ($confirm -ne 'Y' -and $confirm -ne 'y') {
    Write-Log "Instalasi dibatalkan oleh pengguna" "WARNING"
    exit 0
}

# 6. Proses instalasi
$installationResult = Start-Installation -InstallPath $installPath

# 7. Selesaikan instalasi
if ($installationResult) {
    Complete-Installation -InstallPath $installPath -DeviceInfo $deviceInfo
} else {
    Write-Log "Instalasi gagal!" "ERROR"
    Write-Host "`nInstalasi gagal. Periksa log file: $LogFile" -ForegroundColor Red
}

# 8. Tutup script
Write-Host "`nTekan Enter untuk keluar..." -ForegroundColor Yellow
Read-Host