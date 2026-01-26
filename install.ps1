Clear-Host

# ===== SAFE UTF-8 MODE =====
try { [Console]::OutputEncoding = [System.Text.Encoding]::UTF8 } catch {}

# ===== RESET =====
$Reset = "`e[0m"

# ===== COLORS =====
$PurpleGradient = @(
    "`e[38;2;255;0;255m",
    "`e[38;2;230;0;255m",
    "`e[38;2;200;0;255m",
    "`e[38;2;170;0;255m",
    "`e[38;2;140;0;255m",
    "`e[38;2;110;0;255m"
)
$NeonBlue = "`e[38;2;0;200;255m"

# ===== TYPING EFFECT (TEXT ONLY) =====
function Type-Line {
    param ([string]$Text, [int]$Delay = 10)
    foreach ($c in $Text.ToCharArray()) {
        Write-Host -NoNewline $c
        Start-Sleep -Milliseconds $Delay
    }
    Write-Host ""
}

# ===== ASCII LOGO (SAFE & NARROW) =====
$Ascii = @'
                                                                                               
                                                                                                                           
               AAA               RRRRRRRRRRRRRRRRR   VVVVVVVV           VVVVVVVV     IIIIIIIIII     NNNNNNNN        NNNNNNNN
              A:::A              R::::::::::::::::R  V::::::V           V::::::V     I::::::::I     N:::::::N       N::::::N
             A:::::A             R::::::RRRRRR:::::R V::::::V           V::::::V     I::::::::I     N::::::::N      N::::::N
            A:::::::A            RR:::::R     R:::::RV::::::V           V::::::V     II::::::II     N:::::::::N     N::::::N
           A:::::::::A             R::::R     R:::::R V:::::V           V:::::V        I::::I       N::::::::::N    N::::::N
          A:::::A:::::A            R::::R     R:::::R  V:::::V         V:::::V         I::::I       N:::::::::::N   N::::::N
         A:::::A A:::::A           R::::RRRRRR:::::R    V:::::V       V:::::V          I::::I       N:::::::N::::N  N::::::N
        A:::::A   A:::::A          R:::::::::::::RR      V:::::V     V:::::V           I::::I       N::::::N N::::N N::::::N
       A:::::A     A:::::A         R::::RRRRRR:::::R      V:::::V   V:::::V            I::::I       N::::::N  N::::N:::::::N
      A:::::AAAAAAAAA:::::A        R::::R     R:::::R      V:::::V V:::::V             I::::I       N::::::N   N:::::::::::N
     A:::::::::::::::::::::A       R::::R     R:::::R       V:::::V:::::V              I::::I       N::::::N    N::::::::::N
    A:::::AAAAAAAAAAAAA:::::A      R::::R     R:::::R        V:::::::::V               I::::I       N::::::N     N:::::::::N
   A:::::A             A:::::A   RR:::::R     R:::::R         V:::::::V              II::::::II     N::::::N      N::::::::N
  A:::::A               A:::::A  R::::::R     R:::::R          V:::::V               I::::::::I     N::::::N       N:::::::N
 A:::::A                 A:::::A R::::::R     R:::::R           V:::V                I::::::::I     N::::::N        N::::::N
AAAAAAA                   AAAAAAARRRRRRRR     RRRRRRR            VVV                 IIIIIIIIII     NNNNNNNN         NNNNNNN
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   
                                                    dddddddd                                                                
                                                    d::::::d                  !!!  !!!  !!!                                 
                                                    d::::::d                 !!:!!!!:!!!!:!!                                
                                                    d::::::d                 !:::!!:::!!:::!                                
                                                    d:::::d                  !:::!!:::!!:::!                                
ppppp   ppppppppp   rrrrr   rrrrrrrrr       ddddddddd:::::dnnnn  nnnnnnnn    !:::!!:::!!:::!                                
p::::ppp:::::::::p  r::::rrr:::::::::r    dd::::::::::::::dn:::nn::::::::nn  !:::!!:::!!:::!                                
p:::::::::::::::::p r:::::::::::::::::r  d::::::::::::::::dn::::::::::::::nn !:::!!:::!!:::!                                
pp::::::ppppp::::::prr::::::rrrrr::::::rd:::::::ddddd:::::dnn:::::::::::::::n!:::!!:::!!:::!                                
 p:::::p     p:::::p r:::::r     r:::::rd::::::d    d:::::d  n:::::nnnn:::::n!:::!!:::!!:::!                                
 p:::::p     p:::::p r:::::r     rrrrrrrd:::::d     d:::::d  n::::n    n::::n!:::!!:::!!:::!                                
 p:::::p     p:::::p r:::::r            d:::::d     d:::::d  n::::n    n::::n!!:!!!!:!!!!:!!                                
 p:::::p    p::::::p r:::::r            d:::::d     d:::::d  n::::n    n::::n !!!  !!!  !!!                                 
 p:::::ppppp:::::::p r:::::r            d::::::ddddd::::::dd n::::n    n::::n                                               
 p::::::::::::::::p  r:::::r             d:::::::::::::::::d n::::n    n::::n !!!  !!!  !!!                                 
 p::::::::::::::pp   r:::::r              d:::::::::ddd::::d n::::n    n::::n!!:!!!!:!!!!:!!                                
 p::::::pppppppp     rrrrrrr               ddddddddd   ddddd nnnnnn    nnnnnn !!!  !!!  !!!                                 
 p:::::p                                                                                                                    
 p:::::p                                                                                                                    
p:::::::p                                                                                                                   
p:::::::p                                                                                                                   
p:::::::p                                                                                                                   
ppppppppp                                                                                                                   
'@ -split "`n"

# ===== PRINT ASCII (NO TYPING, SAFE) =====
for ($i = 0; $i -lt $Ascii.Count; $i++) {
    Write-Host "$($PurpleGradient[$i % $PurpleGradient.Count])$($Ascii[$i])$Reset"
}
Write-Host ""

# ===== TITLE (SLOW TYPING) =====
Type-Line "$NeonBlue=====================================$Reset" 8
Type-Line "$NeonBlue   PATCH INSTALLER SEB v3.10.0.826   $Reset" 10
Type-Line "$NeonBlue        Powered by ArvinPrdn        $Reset" 10
Type-Line "$NeonBlue=====================================$Reset" 8
Write-Host ""

# ===== INSTALLER =====
$Url = "https://github.com/ArvinPrdn/PATCH-INSTALLER-SEB-v3.10.0.826/releases/download/v3.10.0.826/patch-seb.1.exe"
$Out = "$env:TEMP\patch-seb.exe"

Type-Line "📥 Downloading Patch SEB..." 12
Invoke-WebRequest -Uri $Url -OutFile $Out -UseBasicParsing -MaximumRedirection 10

# ===== PROGRESS =====
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
