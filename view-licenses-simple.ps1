# ==================================================
# SIMPLE LICENSE VIEWER
# ==================================================

Clear-Host
Write-Host "================================================" -ForegroundColor Cyan
Write-Host "           SEB LICENSE DATABASE" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""

$dbFile = "licenses.csv"

# Check if database exists
if (-not (Test-Path $dbFile)) {
    Write-Host "[ERROR] Database file not found!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please generate licenses first using:" -ForegroundColor Yellow
    Write-Host ".\license-gen-simple-v2.ps1" -ForegroundColor Green
    Write-Host ""
    Read-Host "Press Enter to exit"
    exit
}

# Load database
try {
    $licenses = Import-Csv -Path $dbFile
    
    if ($licenses.Count -eq 0) {
        Write-Host "[INFO] No licenses in database" -ForegroundColor Yellow
        Read-Host "`nPress Enter to exit"
        exit
    }
    
    # Show statistics
    Write-Host "📊 DATABASE STATISTICS:" -ForegroundColor Yellow
    Write-Host "Total licenses: $($licenses.Count)" -ForegroundColor White
    
    # Count active/expired
    $today = Get-Date
    $active = 0
    $expired = 0
    
    foreach ($license in $licenses) {
        try {
            $expiryDate = [datetime]::ParseExact($license.ExpiryDate, "yyyy-MM-dd", $null)
            if ($expiryDate -ge $today) {
                $active++
            } else {
                $expired++
            }
        } catch {
            # Skip if date format is wrong
        }
    }
    
    Write-Host "Active        : $active" -ForegroundColor Green
    Write-Host "Expired       : $expired" -ForegroundColor Red
    Write-Host ""
    
    # Show all licenses
    Write-Host "📋 ALL LICENSES:" -ForegroundColor Yellow
    Write-Host ""
    
    $counter = 1
    foreach ($license in $licenses) {
        # Check status
        try {
            $expiryDate = [datetime]::ParseExact($license.ExpiryDate, "yyyy-MM-dd", $null)
            $isExpired = $expiryDate -lt $today
            $statusColor = if ($isExpired) { "Red" } else { "Green" }
            $statusText = if ($isExpired) { "EXPIRED" } else { "ACTIVE" }
        } catch {
            $statusColor = "Yellow"
            $statusText = "UNKNOWN"
        }
        
        Write-Host "────────────────────────────────────" -ForegroundColor DarkGray
        Write-Host "LICENSE #$counter" -ForegroundColor White
        Write-Host ""
        Write-Host "Customer : $($license.CustomerName)" -ForegroundColor White
        Write-Host "Key      : $($license.LicenseKey)" -ForegroundColor Cyan
        Write-Host "Computer : $($license.ComputerName)" -ForegroundColor Gray
        Write-Host "Generated: $($license.GeneratedDate)" -ForegroundColor Gray
        Write-Host "Expires  : $($license.ExpiryDate)" -ForegroundColor $statusColor
        Write-Host "Status   : $statusText" -ForegroundColor $statusColor
        Write-Host ""
        
        $counter++
    }
    
    # Export option
    Write-Host "────────────────────────────────────" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "[1] Export to Text File" -ForegroundColor Green
    Write-Host "[2] Exit" -ForegroundColor Red
    Write-Host ""
    
    $exportChoice = Read-Host "Select option (1-2)"
    
    if ($exportChoice -eq "1") {
        $exportFile = "licenses_export_$(Get-Date -Format 'yyyyMMdd_HHmmss').txt"
        
        $text = "SEB LICENSES EXPORT`n"
        $text += "Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')`n"
        $text += "Total: $($licenses.Count) licenses`n`n"
        
        foreach ($license in $licenses) {
            $text += "Customer: $($license.CustomerName)`n"
            $text += "License: $($license.LicenseKey)`n"
            $text += "Computer: $($license.ComputerName)`n"
            $text += "Generated: $($license.GeneratedDate)`n"
            $text += "Expires: $($license.ExpiryDate)`n"
            $text += "─" * 30 + "`n`n"
        }
        
        $text | Out-File -FilePath $exportFile -Encoding UTF8
        Write-Host "[EXPORT] Saved to: $exportFile" -ForegroundColor Green
        
        $open = Read-Host "`nOpen file? (Y/N)"
        if ($open -eq 'Y') {
            notepad $exportFile
        }
    }
    
} catch {
    Write-Host "[ERROR] Cannot read database: $_" -ForegroundColor Red
}

Write-Host ""
Read-Host "Press Enter to exit"