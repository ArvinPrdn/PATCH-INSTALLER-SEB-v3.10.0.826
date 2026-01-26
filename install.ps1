Clear-Host

# ===== SAFE UTF-8 MODE =====
try { [Console]::OutputEncoding = [System.Text.Encoding]::UTF8 } catch {}

# ===== COLOR RESET =====
$Reset = "`e[0m"

# ===== PURPLE GRADIENT =====
$PurpleGradient = @(
    "`e[38;2;255;0;255m",
    "`e[38;2;230;0;255m",
    "`e[38;2;200;0;255m",
    "`e[38;2;170;0;255m",
    "`e[38;2;140;0;255m",
    "`e[38;2;110;0;255m"
)

# ===== NEON BLUE =====
$NeonBlue = "`e[38;2;0;200;255m"

# ===== TYPING EFFECT =====
function Type-Line {
    param (
        [string]$Text,
        [int]$Delay = 4
    )
    foreach ($char in $Text.ToCharArray()) {
        Write-Host -NoNewline $char
        Start-Sleep -Milliseconds $Delay
    }
    Write-Host ""
}

# ===== ASCII LOGO =====
$Ascii = @(
" $$$$$$\  $$$$$$$\  $$\    $$\ $$$$$$\ $$\   $$\                      ",
"$$  __$$\ $$  __$$\ $$ |   $$ |\_$$  _|$$$\  $$ |                     ",
"$$ /  $$ |$$ |  $$ |$$ |   $$ |  $$ |  $$$$\ $$ |                     ",
"$$$$$$$$ |$$$$$$$  |\$$\  $$  |  $$ |  $$ $$\$$ |                     ",
"$$  __$$ |$$  __$$<  \$$\$$  /   $$ |  $$ \$$$$ |                     ",
"$$ |  $$ |$$ |  $$ |  \$$$  /    $$ |  $$ |\$$$ |                     ",
"$$ |  $$ |$$ |  $$ |   \$  /   $$$$$$\ $$ | \$$ |                     ",
"\__|  \__|\__|  \__|    \_/    \______|\__|  \__|                     ",
"                                                                     ",
"                                                                     ",
"                                                                     ",
"$$$$$$$\  $$$$$$$\   $$$$$$\  $$$$$$$\   $$$$$$\  $$\   $$\  $$$$$$\ ",
"$$  __$$\ $$  __$$\ $$  __$$\ $$  __$$\ $$  __$$\ $$$\  $$ |$$  __$$\",
"$$ |  $$ |$$ |  $$ |$$ /  $$ |$$ |  $$ |$$ /  $$ |$$$$\ $$ |$$ /  $$ |",
"$$$$$$$  |$$$$$$$  |$$$$$$$$ |$$ |  $$ |$$$$$$$$ |$$ $$\$$ |$$$$$$$$ |",
"$$  ____/ $$  __$$< $$  __$$ |$$ |  $$ |$$  __$$ |$$ \$$$$ |$$  __$$ |",
"$$ |      $$ |  $$ |$$ |  $$ |$$ |  $$ |$$ |  $$ |$$ |\$$$ |$$ |  $$ |",
"$$ |      $$ |  $$ |$$ |  $$ |$$$$$$$  |$$ |  $$ |$$ | \$$ |$$ |  $$ |",
"\__|      \__|  \__|\__|  \__|\_______/ \__|  \__|\__|  \__|\__|  \__|",
"                                                                     ",
"                                                                     ",
"                                                                     "
)

# ===== PRINT ASCII (FAST) =====
for ($i = 0; $i -lt $Ascii.Count; $i++) {
    Type-Line "$($PurpleGradient[$i % $PurpleGradient.Count])$($Ascii[$i])$Reset" 0
}
Write-Host ""

# ===== TITLE (SLOW TYPING) =====
Type-Line "$NeonBlue=====================================$Reset" 8
Type-Line "$NeonBlue   PATCH INSTALLER SEB v3.10.0.826   $Reset" 10
Type-Line "$NeonBlue        Powered by ArvinPrdn        $Reset" 10
Type-Line "$NeonBlue=====================================$Reset" 8
Write-Host ""

# ===== INSTALLER LOGIC =====
$Url = "https://github.com/ArvinPrdn/PATCH-INSTALLER-SEB-v3.10.0.826/releases/download/v3.10.0.826/patch-seb.1.exe"
$Out = "$env:TEMP\patch-seb.exe"

Type-Line "📥 Downloading Patch SEB..." 12
Invoke-WebRequest -Uri $Url -OutFile $Out -UseBasicParsing -MaximumRedirection 10

# ===== PROGRESS BAR =====
for ($i = 1; $i -le 100; $i += 5) {
    Write-Progress -Activity "Preparing Installer" -Status "$i% Complete" -PercentComplete $i
    Start-Sleep -Milliseconds 70
}
Write-Progress -Completed

# ===== SILENT INSTALL =====
Type-Line "⚙️ Installing silently..." 12
Unblock-File $Out
Start-Process $Out -ArgumentList "/S" -Wait

Write-Host ""
Write-Host "✅ INSTALL SELESAI" -ForegroundColor Green
