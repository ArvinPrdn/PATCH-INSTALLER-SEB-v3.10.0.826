Clear-Host

# ===== AUTO FULLSCREEN TERMINAL =====
Add-Type -AssemblyName System.Windows.Forms
[System.Windows.Forms.SendKeys]::SendWait("%{ENTER}")
Start-Sleep -Milliseconds 300

# ===== FUNCTION ANIMASI KETIK =====
function Type-Text {
    param (
        [string]$Text,
        [string]$Color = "White",
        [int]$Delay = 8
    )
    foreach ($char in $Text.ToCharArray()) {
        Write-Host -NoNewline $char -ForegroundColor $Color
        Start-Sleep -Milliseconds $Delay
    }
    Write-Host ""
}

# ===== GLITCH EFFECT =====
function Glitch-Line {
    param ([string]$Text)
    $glitchChars = "!@#$%^&*()_+=-[]{}<>"
    for ($i=0; $i -lt 2; $i++) {
        $rand = -join ($Text.ToCharArray() | ForEach-Object {
            if ((Get-Random -Max 5) -eq 1) {
                $glitchChars[(Get-Random -Max $glitchChars.Length)]
            } else { $_ }
        })
        Write-Host $rand -ForegroundColor DarkMagenta
        Start-Sleep -Milliseconds 40
        Clear-Host
    }
}

# ===== ASCII UNGU (CYBERPUNK) =====
$ascii = @(
"███╗   ███╗ ██╗  ██╗ ██████╗  █████╗ ██████╗ ██╗   ██╗ ███╗   ██╗ ███╗   ██╗",
"████╗ ████║ ██║  ██║ ██╔══██╗██╔══██╗██╔══██╗██║   ██║ ████╗  ██║ ████╗  ██║",
"██╔████╔██║ ███████║ ██║  ██║███████║██████╔╝██║   ██║ ██╔██╗ ██║ ██╔██╗ ██║",
"██║╚██╔╝██║ ██╔══██║ ██║  ██║██╔══██║██╔══██╗╚██╗ ██╔╝ ██║╚██╗██║ ██║╚██╗██║",
"██║ ╚═╝ ██║ ██║  ██║ ██████╔╝██║  ██║██║  ██║ ╚████╔╝  ██║ ╚████║ ██║ ╚████║",
"╚═╝     ╚═╝ ╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝  ╚═══╝   ╚═╝  ╚═══╝ ╚═╝  ╚═══╝"
)

foreach ($line in $ascii) {
    Glitch-Line $line
    Type-Text $line "Magenta" 3
}

Write-Host ""

# ===== LOGO BIRU NEON =====
Type-Text "=====================================" "Cyan" 4
Type-Text "   PATCH INSTALLER SEB v3.10.0.826   " "Cyan" 4
Type-Text "        Powered by ArvinPrdn        " "Cyan" 4
Type-Text "=====================================" "Cyan" 4
Write-Host ""

# ===== CONFIG =====
$Url = "https://github.com/ArvinPrdn/PATCH-INSTALLER-SEB-v3.10.0.826/releases/download/v3.10.0.826/patch-seb.1.exe"
$Out = "$env:TEMP\patch-seb.exe"

# ===== DOWNLOAD =====
Type-Text "📥 Downloading Patch SEB..." "Cyan"

try {
    Invoke-WebRequest -Uri $Url -OutFile $Out -UseBasicParsing
}
catch {
    Type-Text "❌ Download gagal." "Red"
    exit 1
}

# ===== FAKE PROGRESS =====
for ($i = 0; $i -le 100; $i += 4) {
    Write-Progress -Activity "Injecting Patch" -Status "$i% Complete" -PercentComplete $i
    Start-Sleep -Milliseconds 60
}
Write-Progress -Activity "Injecting Patch" -Completed

# ===== SILENT INSTALL =====
Type-Text "⚙️ Installing silently..." "Magenta"
Unblock-File $Out
Start-Process -FilePath $Out -ArgumentList "/S" -Wait

Write-Host ""
Type-Text "✅ INSTALLATION COMPLETE" "Green"
Type-Text "System ready. No user interaction required." "DarkGreen"
