Clear-Host

# ===== LOGO =====
Write-Host ""
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "   PATCH INSTALLER SEB v3.10.0.826   " -ForegroundColor Cyan
Write-Host "        Powered by ArvinPrdn        " -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""

$Url = "https://github.com/ArvinPrdn/PATCH-INSTALLER-SEB-v3.10.0.826/releases/download/v3.10.0.826/patch-seb.1.exe"
$Out = "$env:TEMP\patch-seb.exe"

# ===== DOWNLOAD =====
Write-Host "📥 Downloading Patch SEB..."

try {
    Invoke-WebRequest `
        -Uri $Url `
        -OutFile $Out `
        -UseBasicParsing `
        -MaximumRedirection 10 `
        -Verbose:$false
}
catch {
    Write-Host "❌ Download gagal. Cek koneksi / URL." -ForegroundColor Red
    exit 1
}

if (!(Test-Path $Out)) {
    Write-Host "❌ File tidak ditemukan." -ForegroundColor Red
    exit 1
}

# ===== PROGRESS BAR FAKE (BIAR KELIATAN PRO 😎) =====
for ($i = 1; $i -le 100; $i += 5) {
    Write-Progress -Activity "Preparing Installer" -Status "$i% Complete" -PercentComplete $i
    Start-Sleep -Milliseconds 80
}
Write-Progress -Activity "Preparing Installer" -Completed

# ===== RUN SILENT =====
Write-Host "⚙️ Menjalankan installer (silent)..."

Unblock-File $Out
Start-Process -FilePath $Out -ArgumentList "/S" -Wait

Write-Host ""
Write-Host "✅ INSTALL SELESAI" -ForegroundColor Green
Write-Host "Silakan restart jika diperlukan."
