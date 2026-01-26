$Url = "PASTE_URL_EXE_DARI_RELEASE_DI_SINI"
$Out = "$env:TEMP\patch-seb.exe"

Write-Host "Downloading Patch SEB..."

Invoke-WebRequest -Uri $Url -OutFile $Out -UseBasicParsing

Write-Host "Menjalankan installer..."
Unblock-File $Out
Start-Process $Out -Wait

Write-Host "✅ Selesai."
