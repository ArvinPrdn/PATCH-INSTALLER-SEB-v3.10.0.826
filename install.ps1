$Url = "https://github.com/ArvinPrdn/PATCH-INSTALLER-SEB-v3.10.0.826/releases/download/v3.10.0.826/patch-seb.exe"
$Out = "$env:TEMP\patch-seb.exe"

Write-Host "Downloading Patch SEB..."

try {
    Invoke-WebRequest -Uri $Url -OutFile $Out -UseBasicParsing -ErrorAction Stop
} catch {
    Write-Host "❌ Gagal download file."
    Write-Host "Cek koneksi atau URL release."
    exit 1
}

if (!(Test-Path $Out)) {
    Write-Host "❌ File tidak ditemukan setelah download."
    exit 1
}

Write-Host "Menjalankan installer..."
Start-Process -FilePath $Out -Wait
Write-Host "✅ Installer selesai."
