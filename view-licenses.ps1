# ==================================================
# SEB LICENSE DATABASE VIEWER
# ==================================================

Clear-Host
Write-Host "================================================" -ForegroundColor Cyan
Write-Host "        SEB LICENSE DATABASE VIEWER" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan

$databaseFile = "licenses.csv"

if (-not (Test-Path $databaseFile)) {
    Write-Host "`n[ERROR] Database file not found!" -ForegroundColor Red
    Write-Host "File: $databaseFile" -ForegroundColor Yellow
    Write-Host "`nGenerate some licenses first." -ForegroundColor Gray
    Read-Host "`nPress Enter to exit..."
    exit 1
}

# Load data
$licenses = Import-Csv -Path $databaseFile

Write-Host "`n📊 DATABASE STATISTICS:" -ForegroundColor Yellow
Write-Host "Total Licenses : $($licenses.Count)" -ForegroundColor White

# Hitung yang aktif/expired
$today = Get-Date
$active = 0
$expired = 0

foreach ($license in $licenses) {
    $expiry = [datetime]::ParseExact($license.ExpiryDate, "yyyy-MM-dd", $null)
    if ($expiry -ge $today) {
        $active++
    } else {
        $expired++
    }
}

Write-Host "Active         : $active" -ForegroundColor Green
Write-Host "Expired        : $expired" -ForegroundColor Red

# Menu filter
function Show-FilterMenu {
    Write-Host "`n🔍 FILTER OPTIONS:" -ForegroundColor Yellow
    Write-Host "[1] Show all licenses" -ForegroundColor Gray
    Write-Host "[2] Show active licenses only" -ForegroundColor Gray
    Write-Host "[3] Show expired licenses" -ForegroundColor Gray
    Write-Host "[4] Search by customer name" -ForegroundColor Gray
    Write-Host "[5] Search by license key" -ForegroundColor Gray
    Write-Host "[6] Search by computer name" -ForegroundColor Gray
    Write-Host "[7] Export to Excel/HTML" -ForegroundColor Cyan
    Write-Host "[8] Exit" -ForegroundColor Red
    
    Write-Host "`n" + ("-" * 40) -ForegroundColor DarkGray
    $choice = Read-Host "Select option (1-8)"
    
    return $choice
}

# Function to display licenses
function Show-Licenses {
    param($LicenseList, $Title)
    
    Clear-Host
    Write-Host "================================================" -ForegroundColor Cyan
    Write-Host "   $Title" -ForegroundColor Cyan
    Write-Host "================================================" -ForegroundColor Cyan
    
    if ($LicenseList.Count -eq 0) {
        Write-Host "`n[INFO] No licenses found!" -ForegroundColor Yellow
        return
    }
    
    Write-Host "`nFound $($LicenseList.Count) license(s)" -ForegroundColor Gray
    
    # Tampilkan dalam tabel
    $counter = 1
    foreach ($license in $LicenseList) {
        Write-Host "`n───── LICENSE #$counter ─────" -ForegroundColor DarkGray
        
        # Cek status
        $expiry = [datetime]::ParseExact($license.ExpiryDate, "yyyy-MM-dd", $null)
        $isExpired = $expiry -lt $today
        
        Write-Host "Customer : $($license.CustomerName)" -ForegroundColor White
        Write-Host "License  : $($license.LicenseKey)" -ForegroundColor Cyan
        Write-Host "Computer : $($license.ComputerName)" -ForegroundColor Gray
        Write-Host "Generated: $($license.GeneratedDate)" -ForegroundColor Gray
        Write-Host "Expires  : $($license.ExpiryDate)" -ForegroundColor $(if($isExpired){'Red'}else{'Green'})
        Write-Host "Status   : $(if($isExpired){'EXPIRED'}else{'ACTIVE'})" -ForegroundColor $(if($isExpired){'Red'}else{'Green'})
        
        $counter++
    }
}

# Main loop
while ($true) {
    $choice = Show-FilterMenu
    
    switch ($choice) {
        "1" {
            Show-Licenses -LicenseList $licenses -Title "ALL LICENSES"
        }
        
        "2" {
            $activeLicenses = @()
            foreach ($license in $licenses) {
                $expiry = [datetime]::ParseExact($license.ExpiryDate, "yyyy-MM-dd", $null)
                if ($expiry -ge $today) {
                    $activeLicenses += $license
                }
            }
            Show-Licenses -LicenseList $activeLicenses -Title "ACTIVE LICENSES"
        }
        
        "3" {
            $expiredLicenses = @()
            foreach ($license in $licenses) {
                $expiry = [datetime]::ParseExact($license.ExpiryDate, "yyyy-MM-dd", $null)
                if ($expiry -lt $today) {
                    $expiredLicenses += $license
                }
            }
            Show-Licenses -LicenseList $expiredLicenses -Title "EXPIRED LICENSES"
        }
        
        "4" {
            $search = Read-Host "`nEnter customer name (or part of name)"
            $filtered = $licenses | Where-Object { $_.CustomerName -like "*$search*" }
            Show-Licenses -LicenseList $filtered -Title "SEARCH RESULTS - CUSTOMER: $search"
        }
        
        "5" {
            $search = Read-Host "`nEnter license key (or part of key)"
            $filtered = $licenses | Where-Object { $_.LicenseKey -like "*$search*" }
            Show-Licenses -LicenseList $filtered -Title "SEARCH RESULTS - LICENSE: $search"
        }
        
        "6" {
            $search = Read-Host "`nEnter computer name (or part of name)"
            $filtered = $licenses | Where-Object { $_.ComputerName -like "*$search*" }
            Show-Licenses -LicenseList $filtered -Title "SEARCH RESULTS - COMPUTER: $search"
        }
        
        "7" {
            # Export options
            Write-Host "`n📤 EXPORT OPTIONS:" -ForegroundColor Yellow
            Write-Host "[1] Export as CSV" -ForegroundColor Gray
            Write-Host "[2] Export as HTML Report" -ForegroundColor Gray
            Write-Host "[3] Export as Text File" -ForegroundColor Gray
            Write-Host "[4] Print to PDF (requires printer)" -ForegroundColor Gray
            
            $exportChoice = Read-Host "`nSelect format (1-4)"
            
            $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
            
            switch ($exportChoice) {
                "1" {
                    $exportFile = "licenses_export_$timestamp.csv"
                    $licenses | Export-Csv -Path $exportFile -NoTypeInformation
                    Write-Host "`n[EXPORT] Saved to: $exportFile" -ForegroundColor Green
                    
                    # Buka file
                    $open = Read-Host "Open file in Excel? (Y/N)"
                    if ($open -eq 'Y') {
                        Start-Process $exportFile
                    }
                }
                
                "2" {
                    $exportFile = "licenses_report_$timestamp.html"
                    
                    # Buat HTML report
                    $html = @"
<!DOCTYPE html>
<html>
<head>
    <title>SEB Licenses Report</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        h1 { color: #2c3e50; }
        .header { background: #3498db; color: white; padding: 10px; }
        table { border-collapse: collapse; width: 100%; margin-top: 20px; }
        th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
        th { background-color: #2c3e50; color: white; }
        tr:nth-child(even) { background-color: #f2f2f2; }
        .active { color: green; font-weight: bold; }
        .expired { color: red; font-weight: bold; }
        .stats { background: #ecf0f1; padding: 15px; border-radius: 5px; margin: 20px 0; }
    </style>
</head>
<body>
    <div class="header">
        <h1>SEB LICENSES REPORT</h1>
        <p>Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')</p>
    </div>
    
    <div class="stats">
        <h3>📊 STATISTICS</h3>
        <p>Total Licenses: $($licenses.Count)</p>
        <p>Active: $active</p>
        <p>Expired: $expired</p>
    </div>
    
    <table>
        <tr>
            <th>No</th>
            <th>Customer Name</th>
            <th>License Key</th>
            <th>Computer</th>
            <th>Generated Date</th>
            <th>Expiry Date</th>
            <th>Status</th>
        </tr>
"@
                    
                    $counter = 1
                    foreach ($license in $licenses) {
                        $expiry = [datetime]::ParseExact($license.ExpiryDate, "yyyy-MM-dd", $null)
                        $isExpired = $expiry -lt $today
                        $status = if ($isExpired) { "EXPIRED" } else { "ACTIVE" }
                        $statusClass = if ($isExpired) { "expired" } else { "active" }
                        
                        $html += @"
        <tr>
            <td>$counter</td>
            <td>$($license.CustomerName)</td>
            <td>$($license.LicenseKey)</td>
            <td>$($license.ComputerName)</td>
            <td>$($license.GeneratedDate)</td>
            <td>$($license.ExpiryDate)</td>
            <td class="$statusClass">$status</td>
        </tr>
"@
                        $counter++
                    }
                    
                    $html += @"
    </table>
    
    <div style="margin-top: 30px; padding: 10px; background: #f8f9fa; border-left: 4px solid #3498db;">
        <p><strong>Note:</strong> This report was automatically generated by SEB License System.</p>
        <p>© $(Get-Date -Format 'yyyy') SEB Software. All rights reserved.</p>
    </div>
</body>
</html>
"@
                    
                    $html | Out-File -FilePath $exportFile -Encoding UTF8
                    Write-Host "`n[EXPORT] HTML report saved to: $exportFile" -ForegroundColor Green
                    
                    # Buka di browser
                    $open = Read-Host "Open in browser? (Y/N)"
                    if ($open -eq 'Y') {
                        Start-Process $exportFile
                    }
                }
                
                "3" {
                    $exportFile = "licenses_list_$timestamp.txt"
                    
                    $text = @"
SEB LICENSES LIST
=================
Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
Total: $($licenses.Count) licenses

"@
                    
                    $counter = 1
                    foreach ($license in $licenses) {
                        $expiry = [datetime]::ParseExact($license.ExpiryDate, "yyyy-MM-dd", $null)
                        $isExpired = $expiry -lt $today
                        $status = if ($isExpired) { "EXPIRED" } else { "ACTIVE" }
                        
                        $text += @"
[$counter] $($license.CustomerName)
   License: $($license.LicenseKey)
   Computer: $($license.ComputerName)
   Generated: $($license.GeneratedDate)
   Expires: $($license.ExpiryDate) [$status]
   
"@
                        $counter++
                    }
                    
                    $text | Out-File -FilePath $exportFile -Encoding UTF8
                    Write-Host "`n[EXPORT] Text file saved to: $exportFile" -ForegroundColor Green
                    
                    # Buka file
                    $open = Read-Host "Open file? (Y/N)"
                    if ($open -eq 'Y') {
                        notepad $exportFile
                    }
                }
            }
        }
        
        "8" {
            Write-Host "`nExiting..." -ForegroundColor Gray
            exit 0
        }
        
        default {
            Write-Host "`nInvalid choice!" -ForegroundColor Red
            Start-Sleep -Seconds 1
        }
    }
    
    Read-Host "`nPress Enter to continue..."
}