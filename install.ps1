$Url = "https://github.com/ArvinPrdn/PATCH-INSTALLER-SEB-v3.10.0.826/releases/download/v3.10.0.826/patch-seb.1.exe"
$Out = "$env:TEMP\patch-seb.exe"

Write-Host "Downloading Patch SEB..."

try {
    Invoke-WebRequest `
        -Uri $Url `
        -OutFile $Out `
        -UseBasicParsing `
        -MaximumRedirection 10
}
catch {
    Write-Error "❌ Gagal download file."
    exit 1
}

if (!(Test-Path $Out)) {
    Write-Error "❌ File tidak ditemukan setelah download."
    exit 1
}

Write-Host "Menjalankan installer..."
Unblock-File $Out
Start-Process -FilePath $Out -Wait

Write-Host "✅ Install selesai."
