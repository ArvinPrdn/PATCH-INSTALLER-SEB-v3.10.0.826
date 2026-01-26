# Paksa TLS 1.2 (WAJIB untuk GitHub)
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$Url = "https://github.com/ArvinPrdn/PATCH-INSTALLER-SEB-v3.10.0.826/releases/download/v3.10/patch-seb.exe"
$Out = "$env:TEMP\patch-seb.exe"

Write-Host "Downloading Patch SEB..."
Invoke-WebRequest -Uri $Url -OutFile $Out -UseBasicParsing

if (!(Test-Path $Out)) {
    Write-Host "Download gagal. Installer tidak ditemukan."
    exit 1
}

Write-Host "Menjalankan installer..."
Start-Process -FilePath $Out -Wait

Write-Host "Selesai."
