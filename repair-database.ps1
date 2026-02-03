# ==================================================
# REPAIR LICENSE DATABASE
# ==================================================

Clear-Host
Write-Host "================================================" -ForegroundColor Yellow
Write-Host "           REPAIR LICENSE DATABASE" -ForegroundColor Yellow
Write-Host "================================================" -ForegroundColor Yellow
Write-Host ""

$dbFile = "licenses.csv"

Write-Host "[1] Check if database exists..." -ForegroundColor Gray
if (Test-Path $dbFile) {
    $size = (Get-Item $dbFile).Length
    Write-Host "[OK] Database found: $dbFile ($size bytes)" -ForegroundColor Green
    
    # Show first few lines
    Write-Host "`nFirst 5 lines:" -ForegroundColor Yellow
    Get-Content $dbFile -First 5 | ForEach-Object { Write-Host "  $_" -ForegroundColor Gray }
    
    # Count lines
    $lineCount = (Get-Content $dbFile).Count
    Write-Host "`nTotal lines: $lineCount" -ForegroundColor White
    
} else {
    Write-Host "[WARNING] Database not found!" -ForegroundColor Red
    Write-Host "Creating new database..." -ForegroundColor Yellow
    
    # Create new database
    @"
LicenseKey,CustomerName,ComputerName,GeneratedDate,ExpiryDate,DaysValid
"@ | Out-File -FilePath $dbFile -Encoding UTF8
    
    Write-Host "[OK] New database created: $dbFile" -ForegroundColor Green
}

Write-Host ""
Write-Host "[2] Testing CSV format..." -ForegroundColor Gray
try {
    if (Test-Path $dbFile) {
        $testData = Import-Csv $dbFile -ErrorAction Stop
        Write-Host "[OK] CSV format is valid" -ForegroundColor Green
        Write-Host "Records found: $($testData.Count)" -ForegroundColor White
    }
} catch {
    Write-Host "[ERROR] Invalid CSV format: $_" -ForegroundColor Red
    Write-Host "Fixing format..." -ForegroundColor Yellow
    
    # Backup old file
    $backupFile = "$dbFile.backup_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
    Copy-Item $dbFile $backupFile -Force
    Write-Host "Backup created: $backupFile" -ForegroundColor Gray
    
    # Create fresh database
    @"
LicenseKey,CustomerName,ComputerName,GeneratedDate,ExpiryDate,DaysValid
"@ | Out-File -FilePath $dbFile -Encoding UTF8 -Force
    
    Write-Host "[OK] Database recreated" -ForegroundColor Green
}

Write-Host ""
Write-Host "[3] Ready to use!" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "1. Run: .\license-gen-simple-v2.ps1" -ForegroundColor White
Write-Host "2. Generate licenses" -ForegroundColor White
Write-Host "3. View with: .\view-licenses-simple.ps1" -ForegroundColor White
Write-Host ""

Read-Host "Press Enter to continue"