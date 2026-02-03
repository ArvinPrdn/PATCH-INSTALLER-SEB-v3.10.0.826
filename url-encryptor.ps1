# ==================================================
# URL ENCRYPTION TOOL FOR GITHUB LINKS
# ==================================================

function Encrypt-GitHubUrl {
    param(
        [string]$GitHubUrl,
        [string]$OutputFile = "installer-secure.ps1"
    )
    
    Write-Host "Encrypting GitHub URL..." -ForegroundColor Yellow
    Write-Host "Original URL: $GitHubUrl" -ForegroundColor Gray
    
    # 1. Simple XOR encryption dengan key random
    $key = -join ((65..90) + (97..122) | Get-Random -Count 16 | ForEach-Object {[char]$_})
    
    # 2. Enkripsi URL
    $urlBytes = [System.Text.Encoding]::UTF8.GetBytes($GitHubUrl)
    $keyBytes = [System.Text.Encoding]::UTF8.GetBytes($key)
    
    $encryptedBytes = @()
    for ($i = 0; $i -lt $urlBytes.Length; $i++) {
        $keyIndex = $i % $keyBytes.Length
        $encryptedBytes += $urlBytes[$i] -bxor $keyBytes[$keyIndex]
    }
    
    # 3. Convert ke Base64
    $base64Encoded = [System.Text.Encoding]::UTF8.GetString($encryptedBytes)
    $finalEncoded = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($base64Encoded))
    
    # 4. Split menjadi beberapa bagian (untuk hindari detection)
    $partSize = 32
    $parts = @()
    for ($i = 0; $i -lt $finalEncoded.Length; $i += $partSize) {
        $part = $finalEncoded.Substring($i, [math]::Min($partSize, $finalEncoded.Length - $i))
        $parts += $part
    }
    
    # 5. Generate PowerShell code
    $template = @'
# ===== URL DECRYPTION =====
function Get-SecureDownloadUrl {
    param([string]`$LicenseKey)
    
    # ENCRYPTED GITHUB URL
    `$encryptedParts = @(
        "{0}"
    )
    
    # 1. Gabungkan bagian
    `$fullEncoded = -join `$encryptedParts
    
    # 2. Decode Base64 pertama
    `$base64Decoded = [System.Text.Encoding]::UTF8.GetString(
        [System.Convert]::FromBase64String(`$fullEncoded)
    )
    
    # 3. XOR decryption dengan license key
    `$keyBytes = [System.Text.Encoding]::UTF8.GetBytes(`$LicenseKey)
    `$dataBytes = [System.Text.Encoding]::UTF8.GetBytes(`$base64Decoded)
    
    `$decryptedBytes = @()
    for (`$i = 0; `$i -lt `$dataBytes.Length; `$i++) {
        `$keyIndex = `$i % `$keyBytes.Length
        `$decryptedBytes += `$dataBytes[`$i] -bxor `$keyBytes[`$keyIndex]
    }
    
    `$decryptedUrl = [System.Text.Encoding]::UTF8.GetString(`$decryptedBytes)
    
    return `$decryptedUrl
}
'@
    
    # Format parts sebagai PowerShell array
    $partsFormatted = $parts -join "`",`n        `""
    $finalCode = $template -f $partsFormatted
    
    # 6. Save to file
    $finalCode | Out-File -FilePath $OutputFile -Encoding UTF8
    Write-Host "`n[SUCCESS] Encrypted URL saved to: $OutputFile" -ForegroundColor Green
    Write-Host "Encryption Key: $key" -ForegroundColor Cyan
    Write-Host "`nAdd this function to your installer script." -ForegroundColor Yellow
    
    return @{
        EncryptedCode = $finalCode
        Key = $key
        Parts = $parts
    }
}

# Contoh penggunaan
Clear-Host
Write-Host @"
========================================
   GITHUB URL ENCRYPTION TOOL
========================================
"@ -ForegroundColor Cyan

$githubUrl = "https://github.com/ArvinPrdn/PATCH-INSTALLER-SEB-v3.10.0.826/releases/download/v3.10.0.826/patch-seb.1.exe"

Write-Host "`nGitHub URL to encrypt:" -ForegroundColor Yellow
Write-Host $githubUrl -ForegroundColor Gray

$choice = Read-Host "`nEncrypt this URL? (Y/N)"
if ($choice -eq 'Y') {
    $result = Encrypt-GitHubUrl -GitHubUrl $githubUrl -OutputFile "encrypted-url-template.ps1"
    
    Write-Host "`n" + ("="*50) -ForegroundColor Green
    Write-Host "   ENCRYPTION COMPLETE!" -ForegroundColor Green
    Write-Host ("="*50) -ForegroundColor Green
    
    Write-Host "`nCopy the function into your installer script." -ForegroundColor Yellow
    Write-Host "Make sure to update the license validation logic." -ForegroundColor Yellow
}