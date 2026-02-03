# ==================================================
# SEB LICENSE GENERATOR v2.0 - SIMPLE & STABLE
# ==================================================

# Clear screen
Clear-Host

# Show header
Write-Host "================================================" -ForegroundColor Cyan
Write-Host "           SEB LICENSE GENERATOR" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""

# Database file
$dbFile = "licenses.csv"

# Create database if not exists
if (-not (Test-Path $dbFile)) {
    Write-Host "[INFO] Creating new database..." -ForegroundColor Yellow
    "LicenseKey,CustomerName,ComputerName,GeneratedDate,ExpiryDate,DaysValid" | Out-File $dbFile -Encoding UTF8
    Write-Host "[OK] Database created: $dbFile" -ForegroundColor Green
    Write-Host ""
}

# Function to generate license
function New-License {
    # Valid characters only
    $chars = "ACDEFGHJKLMNPQRTUVWXYZ234679"
    $key = ""
    
    # Generate 16 characters
    for ($i = 0; $i -lt 16; $i++) {
        $key += $chars[(Get-Random -Maximum $chars.Length)]
    }
    
    # Format: XXXX-XXXX-XXXX-XXXX
    $formatted = $key.Insert(4, '-').Insert(9, '-').Insert(14, '-')
    
    # Ensure checksum mod 13 = 7
    $clean = $formatted -replace '-', ''
    $checksum = 0
    foreach ($c in $clean.ToCharArray()) { $checksum += [int][char]$c }
    
    # Adjust if needed
    if (($checksum % 13) -ne 7) {
        $lastChar = $clean[15]
        $lastIndex = $chars.IndexOf($lastChar)
        
        for ($i = 0; $i -lt $chars.Length; $i++) {
            $testChar = $chars[$i]
            $testSum = $checksum - [int][char]$lastChar + [int][char]$testChar
            
            if (($testSum % 13) -eq 7) {
                $newKey = $clean.Substring(0, 15) + $testChar
                $formatted = $newKey.Insert(4, '-').Insert(9, '-').Insert(14, '-')
                break
            }
        }
    }
    
    return $formatted
}

# Main menu
while ($true) {
    Clear-Host
    Write-Host "================================================" -ForegroundColor Cyan
    Write-Host "           SEB LICENSE GENERATOR" -ForegroundColor Cyan
    Write-Host "================================================" -ForegroundColor Cyan
    Write-Host ""
    
    Write-Host "[1] Generate New License" -ForegroundColor Green
    Write-Host "[2] View All Licenses" -ForegroundColor Yellow
    Write-Host "[3] Search License" -ForegroundColor Cyan
    Write-Host "[4] Exit" -ForegroundColor Red
    Write-Host ""
    Write-Host "-" * 40 -ForegroundColor DarkGray
    
    $choice = Read-Host "Select option (1-4)"
    
    switch ($choice) {
        "1" {
            # Generate new license
            Clear-Host
            Write-Host "=== GENERATE NEW LICENSE ===" -ForegroundColor Green
            Write-Host ""
            
            $customer = Read-Host "Customer Name"
            if ([string]::IsNullOrWhiteSpace($customer)) {
                Write-Host "Customer name is required!" -ForegroundColor Red
                Read-Host "Press Enter to continue..."
                continue
            }
            
            $computer = Read-Host "Computer Name [optional]"
            $days = Read-Host "Valid for (days) [default: 365]"
            
            if ([string]::IsNullOrWhiteSpace($computer)) { $computer = "ANY-PC" }
            if ([string]::IsNullOrWhiteSpace($days) -or $days -eq "") { $days = 365 }
            
            Write-Host ""
            Write-Host "Generating license..." -ForegroundColor Yellow
            
            # Generate
            $license = New-License
            $generated = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            $expiry = (Get-Date).AddDays([int]$days).ToString("yyyy-MM-dd")
            
            # Show result
            Write-Host ""
            Write-Host "=" * 40 -ForegroundColor Green
            Write-Host "LICENSE GENERATED SUCCESSFULLY!" -ForegroundColor Green
            Write-Host "=" * 40 -ForegroundColor Green
            Write-Host ""
            
            Write-Host "Customer    : $customer" -ForegroundColor White
            Write-Host "Computer    : $computer" -ForegroundColor White
            Write-Host "License Key : " -NoNewline
            Write-Host $license -ForegroundColor Cyan -BackgroundColor Black
            Write-Host "Generated   : $generated" -ForegroundColor Gray
            Write-Host "Expires     : $expiry" -ForegroundColor White
            Write-Host "Valid Days  : $days" -ForegroundColor White
            
            # Calculate checksum
            $clean = $license -replace '-', ''
            $sum = 0
            foreach ($c in $clean.ToCharArray()) { $sum += [int][char]$c }
            Write-Host "Checksum    : $sum (mod 13 = $($sum % 13))" -ForegroundColor Gray
            
            # Save to database
            $csvLine = "`"$license`",`"$customer`",`"$computer`",`"$generated`",`"$expiry`",`"$days`""
            $csvLine | Out-File -FilePath $dbFile -Append -Encoding UTF8
            
            Write-Host ""
            Write-Host "[SAVED] Added to database: $dbFile" -ForegroundColor Green
            
            # Save individual file
            $textFile = "License_$($customer)_$(Get-Date -Format 'yyyyMMdd').txt"
            $textContent = @"
================================
SEB SOFTWARE LICENSE
================================
Customer: $customer
Computer: $computer

LICENSE KEY:
$license

VALIDITY:
Generated: $generated
Expires: $expiry
Days: $days

CHECKSUM: $sum (mod 13 = $($sum % 13))

INSTALLATION:
1. Run installer-secure.ps1
2. Enter license key when prompted
================================
"@
            $textContent | Out-File -FilePath $textFile -Encoding UTF8
            Write-Host "[EXPORT] Text file: $textFile" -ForegroundColor Cyan
            
            # Copy to clipboard
            $copy = Read-Host "`nCopy to clipboard? (Y/N)"
            if ($copy -eq 'Y' -or $copy -eq 'y') {
                $license | Set-Clipboard
                Write-Host "[COPIED] License copied to clipboard!" -ForegroundColor Green
            }
            
            Read-Host "`nPress Enter to continue..."
        }
        
        "2" {
            # View all licenses
            Clear-Host
            Write-Host "=== VIEW ALL LICENSES ===" -ForegroundColor Yellow
            
            if (-not (Test-Path $dbFile)) {
                Write-Host ""
                Write-Host "[ERROR] Database not found!" -ForegroundColor Red
                Read-Host "`nPress Enter to continue..."
                continue
            }
            
            $licenses = Import-Csv $dbFile
            
            if ($licenses.Count -eq 0) {
                Write-Host ""
                Write-Host "[INFO] No licenses in database" -ForegroundColor Yellow
                Write-Host "Generate some licenses first!" -ForegroundColor Gray
                Read-Host "`nPress Enter to continue..."
                continue
            }
            
            Write-Host ""
            Write-Host "Total licenses: $($licenses.Count)" -ForegroundColor White
            Write-Host ""
            
            $counter = 1
            foreach ($item in $licenses) {
                Write-Host "$counter. $($item.CustomerName)" -ForegroundColor White
                Write-Host "   Key: $($item.LicenseKey)" -ForegroundColor Cyan
                Write-Host "   PC : $($item.ComputerName)" -ForegroundColor Gray
                Write-Host "   Exp: $($item.ExpiryDate)" -ForegroundColor Gray
                Write-Host ""
                $counter++
            }
            
            Read-Host "Press Enter to continue..."
        }
        
        "3" {
            # Search license
            Clear-Host
            Write-Host "=== SEARCH LICENSE ===" -ForegroundColor Cyan
            
            if (-not (Test-Path $dbFile)) {
                Write-Host ""
                Write-Host "[ERROR] Database not found!" -ForegroundColor Red
                Read-Host "`nPress Enter to continue..."
                continue
            }
            
            $licenses = Import-Csv $dbFile
            
            if ($licenses.Count -eq 0) {
                Write-Host ""
                Write-Host "[INFO] No licenses to search" -ForegroundColor Yellow
                Read-Host "`nPress Enter to continue..."
                continue
            }
            
            Write-Host ""
            $search = Read-Host "Search (customer name or license key)"
            
            if ([string]::IsNullOrWhiteSpace($search)) {
                Write-Host "[ERROR] Search term required!" -ForegroundColor Red
                Read-Host "`nPress Enter to continue..."
                continue
            }
            
            $results = $licenses | Where-Object {
                $_.CustomerName -like "*$search*" -or 
                $_.LicenseKey -like "*$search*"
            }
            
            Write-Host ""
            if ($results.Count -eq 0) {
                Write-Host "[INFO] No results found for '$search'" -ForegroundColor Yellow
            } else {
                Write-Host "Found $($results.Count) result(s):" -ForegroundColor Green
                Write-Host ""
                
                foreach ($item in $results) {
                    Write-Host "• $($item.CustomerName)" -ForegroundColor White
                    Write-Host "  Key: $($item.LicenseKey)" -ForegroundColor Cyan
                    Write-Host "  PC : $($item.ComputerName)" -ForegroundColor Gray
                    Write-Host "  Exp: $($item.ExpiryDate)" -ForegroundColor Gray
                    Write-Host ""
                }
            }
            
            Read-Host "Press Enter to continue..."
        }
        
        "4" {
            # Exit
            Clear-Host
            Write-Host "Thank you for using SEB License Generator!" -ForegroundColor Cyan
            Write-Host "Goodbye!" -ForegroundColor Gray
            Start-Sleep -Seconds 2
            exit
        }
        
        default {
            Write-Host "Invalid option! Please select 1-4." -ForegroundColor Red
            Start-Sleep -Seconds 1
        }
    }
}