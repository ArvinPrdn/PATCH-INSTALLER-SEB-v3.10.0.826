$Url = "https://github.com/ArvinPrdn/PATCH-INSTALLER-SEB-v3.10.0.826/releases/download/v3.10/patch-seb.exe"
$Out = "$env:TEMP\patch-seb.exe"

Write-Host "Downloading Patch SEB..."
Invoke-WebRequest -Uri $Url -OutFile $Out

Write-Host "Menjalankan installer..."
Start-Process -FilePath $Out -Wait

Write-Host "Selesai."
