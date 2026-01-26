# Pastikan dijalankan sebagai Admin
if (-not ([Security.Principal.WindowsPrincipal]
    [Security.Principal.WindowsIdentity]::GetCurrent()
).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {

    Write-Host "Jalankan PowerShell sebagai Administrator."
    exit
}

# Alamat file installer
$Url = "https://github.com/ArvinPrdn/PATCH-INSTALLER-SEB-v3.10.0.826/releases/download/v3.10.0.826/patch-seb.1.exe"

# Lokasi simpan sementara
$File = "$env:TEMP\patch-seb.exe"

Write-Host "Mengunduh installer..."
Invoke-WebRequest -Uri $Url -OutFile $File -UseBasicParsing

Write-Host "Memasang aplikasi secara otomatis..."
Unblock-File $File
Start-Process $File -ArgumentList "/S" -Wait

Write-Host "✅ Aplikasi sudah terpasang."
