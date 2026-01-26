# Cek apakah PowerShell dijalankan sebagai Administrator
$IsAdmin = ([Security.Principal.WindowsPrincipal] `
    [Security.Principal.WindowsIdentity]::GetCurrent() `
).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $IsAdmin) {
    Write-Host "Jalankan PowerShell sebagai Administrator." -ForegroundColor Yellow
    exit
}

# Link installer
$Url = "https://github.com/ArvinPrdn/PATCH-INSTALLER-SEB-v3.10.0.826/releases/download/v3.10.0.826/patch-seb.1.exe"

# Lokasi simpan sementara
$File = "$env:TEMP\patch-seb.exe"

Write-Host "Mengunduh installer..."
Invoke-WebRequest -Uri $Url -OutFile $File -UseBasicParsing -MaximumRedirection 10

if (!(Test-Path $File)) {
    Write-Host "Download gagal." -ForegroundColor Red
    exit
}

Write-Host "Memasang aplikasi secara otomatis..."
Unblock-File $File
Start-Process -FilePath $File -ArgumentList "/S" -Wait

Write-Host "✅ Aplikasi sudah terpasang."
