# ==================================================
# PATCH INSTALLER SEB v3.10.0.826
# Safe • Silent • Stable
# ==================================================

# ===== SAFE UTF-8 MODE =====
try {
    [Console]::OutputEncoding = [System.Text.Encoding]::UTF8
} catch {}

Clear-Host

# ===== DETECT UNICODE SUPPORT =====
$UnicodeOK = $true
try {
    Write-Host "█" -NoNewline
    Clear-Host
} catch {
    $UnicodeOK = $false
}

# ===== ASCII LOGO =====
$AsciiUnicode = @(
"███╗   ███╗ ██╗  ██╗ ██████╗  █████╗ ██████╗ ██╗   ██╗ ███╗   ██╗ ███╗   ██╗",
"████╗ ████║ ██║  ██║ ██╔══██╗██╔══██╗██╔══██╗██║   ██║ ████╗  ██║ ████╗  ██║",
"██╔████╔██║ ███████║ ██║  ██║███████║██████╔╝██║   ██║ ██╔██╗ ██║ ██╔██╗ ██║",
"██║╚██╔╝██║ ██╔══██║ ██║  ██║██╔══██║██╔══██╗╚██╗ ██╔╝ ██║╚██╗██║ ██║╚██╗██║",
"██║ ╚═╝ ██║ ██║  ██║ ██████╔╝██║  ██║██║  ██║ ╚████╔╝  ██║ ╚████║ ██║ ╚████║",
"╚═╝     ╚═╝ ╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝  ╚═══╝   ╚═╝  ╚═══╝ ╚═╝  ╚═══╝"
)

$AsciiSafe = @(
"###    ###  ##   ##  ######   #####  ######  ##    ##  ###    ##  ###    ##",
"####  ####  ##   ##  ##   ## ##   ## ##   ## ##    ## ####   ## ####   ##",
"## #### ##  #######  ##   ## ####### ######  ##    ## ## ##  ## ## ##  ##",
"##  ##  ##  ##   ##  ##   ## ##   ## ##   ##  ##  ##  ##  ## ## ##  ## ##",
"##      ##  ##   ##  ######  ##   ## ##   ##   ####   ##   #### ##   ####"
)

$Logo = if ($UnicodeOK) { $AsciiUnicode } else { $AsciiSafe }

# ===== ASCII ANIMATION (MAGENTA) =====
foreach ($line in $Logo) {
    Write-Host $line -ForegroundColor Magenta
    Start-Sleep -Milliseconds 60
}

Write-Host ""

# ===== TITLE (NEON BLUE) =====
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "   PATCH INSTALLER SEB v3.10.0.826   " -ForegroundColor Cyan
Write-Host "        Powered by ArvinPrdn        " -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""

# ===== DOWNLOAD CONFIG =====
$Url = "https://github.com/ArvinPrdn/PATCH-INSTALLER-SEB-v3.10.0.826/releases/download/v3.10.0.826/patch-seb.1.exe"
$Out = "$env:TEMP\patch-seb.exe"

Write-Host "📥 Downloading Patch SEB..." -ForegroundColor Yellow

try {
    Invoke-WebRequest -Uri $Url -OutFile $Out -UseBasicParsing -MaximumRedirection 10
} catch {
    Write-Host "❌ Download gagal. Cek koneksi / URL." -ForegroundColor Red
    exit 1
}

if (!(Test-Path $Out)) {
    Write-Host "❌ File installer tidak ditemukan." -ForegroundColor Red
    exit 1
}

# ===== FAKE PROGRESS =====
for ($i = 0; $i -le 100; $i += 5) {
    Write-Progress -Activity "Preparing Installer" -Status "$i% Complete" -PercentComplete $i
    Start-Sleep -Milliseconds 70
}
Write-Progress -Activity "Preparing Installer" -Completed

# ===== RUN SILENT INSTALL =====
Write-Host "⚙️ Menjalankan installer (silent)..." -ForegroundColor Yellow

Unblock-File $Out
Start-Process -FilePath $Out -ArgumentList "/S" -Wait

# ===== DONE =====
Write-Host ""
Write-Host "✅ INSTALL SELESAI" -ForegroundColor Green
Write-Host "Silakan restart jika diperlukan."
