Clear-Host

# ===== ASCII LOGO =====
$Logo = @(
"  ___   ______   _   _   _____   _   _ ",
" / _ \  | ___ \ | | | | |_   _| | \ | |",
"/ /_\ \ | |_/ / | | | |   | |   |  \| |",
"|  _  | |    /  | | | |   | |   | . ` |",
"| | | | | |\ \  \ \_/ /  _| |_  | |\  |",
"\_| |_/ \_| \_|  \___/   \___/  \_| \_/",
"                                       ",
"                                       ",
"               _       _ _ _           ",
"              | |     | | | |          ",
" _ __  _ __ __| |_ __ | | | |          ",
"| '_ \| '__/ _` | '_ \| | | |          ",
"| |_) | | | (_| | | | |_|_|_|          ",
"| .__/|_|  \__,_|_| |_(_|_|_)          ",
"| |                                    ",
"|_|                                    "
)

# Warna neon untuk vibe cyberpunk
$Colors = @("Cyan", "Magenta", "Yellow", "Green", "Blue")

# Fungsi untuk animasi ketik per karakter
function Write-CyberText($text) {
    foreach ($char in $text.ToCharArray()) {
        $color = $Colors | Get-Random
        Write-Host -NoNewline $char -ForegroundColor $color
        Start-Sleep -Milliseconds (20 + (Get-Random -Minimum 0 -Maximum 40))
    }
    Write-Host ""
}

# Menampilkan logo dengan animasi
foreach ($line in $Logo) {
    Write-CyberText $line
}

Write-Host ""

# ===== TITLE =====
Write-CyberText "====================================="
Write-CyberText "   PATCH INSTALLER SEB v3.10.0.826   "
Write-CyberText "        Powered by ArvinPrdn        "
Write-CyberText "====================================="
Write-Host ""

# ===== DOWNLOAD CONFIG =====
$Url = "https://github.com/ArvinPrdn/PATCH-INSTALLER-SEB-v3.10.0.826/releases/download/v3.10.0.826/patch-seb.1.exe"
$Out = "$env:TEMP\patch-seb.exe"

Write-CyberText "📥 Downloading Patch SEB..."

try {
    Invoke-WebRequest -Uri $Url -OutFile $Out -UseBasicParsing
} catch {
    Write-CyberText "❌ Download gagal. Cek koneksi / URL."
    exit 1
}

if (!(Test-Path $Out)) {
    Write-CyberText "❌ File installer tidak ditemukan."
    exit 1
}

# ===== FAKE PROGRESS =====
for ($i = 0; $i -le 100; $i += 5) {
    Write-Progress -Activity "Preparing Installer" -Status "$i% Complete" -PercentComplete $i
    Start-Sleep -Milliseconds 70
}
Write-Progress -Activity "Preparing Installer" -Completed

# ===== RUN SILENT INSTALL =====
Write-CyberText "⚙️ Menjalankan installer (silent)..."

Unblock-File $Out
Start-Process -FilePath $Out -ArgumentList "/S" -Wait

# ===== DONE =====
Write-Host ""
Write-CyberText "✅ INSTALL SELESAI"
Write-CyberText "Silakan restart jika diperlukan."
