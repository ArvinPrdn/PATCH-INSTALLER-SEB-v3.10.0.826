$Url = "https://github.com/ArvinPrdn/PATCH-INSTALLER-SEB-v3.10.0.826/raw/main/patch-seb.exe"
$Out = "$env:TEMP\patch-seb.exe"

Write-Host "Downloading Patch SEB..."
try {
    Invoke-WebRequest -Uri $Url -OutFile $Out -UseBasicParsing -ErrorAction Stop
} catch {
    Write-Host "❌ Download gagal. Jalankan manual dari GitHub."
    exit
}

if (!(Test-Path $Out)) {
    Write-Host "❌ File tidak ditemukan."
    exit
}

Write-Host "Menjalankan installer..."
Start-Process -FilePath $Out -Wait
Write-Host "Selesai."
