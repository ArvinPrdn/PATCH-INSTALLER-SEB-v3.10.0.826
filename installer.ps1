Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Main Form
$form = New-Object System.Windows.Forms.Form
$form.Text = "Professional Software Installer v2.0"
$form.Size = New-Object System.Drawing.Size(900, 700)
$form.StartPosition = "CenterScreen"
$form.BackColor = [System.Drawing.Color]::FromArgb(30, 30, 30)
$form.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedSingle
$form.MaximizeBox = $false

# ASCII Art Label
$asciiArt = @"
_______. ___________    ____  _______ .______          ___      
   /       ||   ____\   \  /   / |   ____||   _  \        /   \     
  |   (----`|  |__   \   \/   /  |  |__   |  |_)  |      /  ^  \    
   \   \    |   __|   \      /   |   __|  |      /      /  /_\  \   
.----)   |   |  |____   \    /    |  |____ |  |\  \----./  _____  \  
|_______/    |_______|   \__/     |_______|| _| `._____/__/     \__\ 
"@

$asciiLabel = New-Object System.Windows.Forms.Label
$asciiLabel.Text = $asciiArt
$asciiLabel.Font = New-Object System.Drawing.Font("Consolas", 9, [System.Drawing.FontStyle]::Regular)
$asciiLabel.ForeColor = [System.Drawing.Color]::LightGreen
$asciiLabel.Location = New-Object System.Drawing.Point(50, 20)
$asciiLabel.Size = New-Object System.Drawing.Size(800, 100)
$asciiLabel.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
$form.Controls.Add($asciiLabel)

# Title Label
$titleLabel = New-Object System.Windows.Forms.Label
$titleLabel.Text = "PROFESSIONAL SOFTWARE INSTALLER v2.0"
$titleLabel.Font = New-Object System.Drawing.Font("Segoe UI", 16, [System.Drawing.FontStyle]::Bold)
$titleLabel.ForeColor = [System.Drawing.Color]::LightGreen
$titleLabel.Location = New-Object System.Drawing.Point(50, 120)
$titleLabel.Size = New-Object System.Drawing.Size(800, 30)
$titleLabel.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
$form.Controls.Add($titleLabel)

# Separator
$separator1 = New-Object System.Windows.Forms.Label
$separator1.Text = "=" * 80
$separator1.ForeColor = [System.Drawing.Color]::LightGreen
$separator1.Location = New-Object System.Drawing.Point(50, 160)
$separator1.Size = New-Object System.Drawing.Size(800, 20)
$form.Controls.Add($separator1)

# User ID Section
$userIDLabel = New-Object System.Windows.Forms.Label
$userIDLabel.Text = "STEP 1: ENTER USER ID"
$userIDLabel.Font = New-Object System.Drawing.Font("Segoe UI", 11, [System.Drawing.FontStyle]::Bold)
$userIDLabel.ForeColor = [System.Drawing.Color]::LightGreen
$userIDLabel.Location = New-Object System.Drawing.Point(50, 190)
$userIDLabel.Size = New-Object System.Drawing.Size(800, 25)
$form.Controls.Add($userIDLabel)

# User ID TextBox
$userIDTextBox = New-Object System.Windows.Forms.TextBox
$userIDTextBox.Location = New-Object System.Drawing.Point(50, 230)
$userIDTextBox.Size = New-Object System.Drawing.Size(600, 30)
$userIDTextBox.Font = New-Object System.Drawing.Font("Consolas", 10)
$userIDTextBox.BackColor = [System.Drawing.Color]::FromArgb(45, 45, 45)
$userIDTextBox.ForeColor = [System.Drawing.Color]::White
$form.Controls.Add($userIDTextBox)

# Paste Button
$pasteButton = New-Object System.Windows.Forms.Button
$pasteButton.Text = "📋 Paste"
$pasteButton.Location = New-Object System.Drawing.Point(660, 225)
$pasteButton.Size = New-Object System.Drawing.Size(90, 35)
$pasteButton.Font = New-Object System.Drawing.Font("Segoe UI", 9)
$pasteButton.BackColor = [System.Drawing.Color]::FromArgb(76, 175, 80)
$pasteButton.ForeColor = [System.Drawing.Color]::White
$pasteButton.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$pasteButton.Add_Click({
    $userIDTextBox.Text = [System.Windows.Forms.Clipboard]::GetText()
})
$form.Controls.Add($pasteButton)

# Generate Button
$generateButton = New-Object System.Windows.Forms.Button
$generateButton.Text = "🔄 Generate ID"
$generateButton.Location = New-Object System.Drawing.Point(760, 225)
$generateButton.Size = New-Object System.Drawing.Size(90, 35)
$generateButton.Font = New-Object System.Drawing.Font("Segoe UI", 9)
$generateButton.BackColor = [System.Drawing.Color]::FromArgb(76, 175, 80)
$generateButton.ForeColor = [System.Drawing.Color]::White
$generateButton.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$generateButton.Add_Click({
    $userIDTextBox.Text = "USER-" + (Get-Date -Format "yyyyMMddHHmmss")
})
$form.Controls.Add($generateButton)

# Continue Button
$continueButton = New-Object System.Windows.Forms.Button
$continueButton.Text = "▶ Continue to License Info"
$continueButton.Location = New-Object System.Drawing.Point(50, 280)
$continueButton.Size = New-Object System.Drawing.Size(800, 40)
$continueButton.Font = New-Object System.Drawing.Font("Segoe UI", 11, [System.Drawing.FontStyle]::Bold)
$continueButton.BackColor = [System.Drawing.Color]::FromArgb(76, 175, 80)
$continueButton.ForeColor = [System.Drawing.Color]::White
$continueButton.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$continueButton.Add_Click({
    if ([string]::IsNullOrWhiteSpace($userIDTextBox.Text)) {
        [System.Windows.Forms.MessageBox]::Show("Please enter User ID first!", "Error", 
            [System.Windows.Forms.MessageBoxButtons]::OK, 
            [System.Windows.Forms.MessageBoxIcon]::Warning)
        return
    }
    
    # Generate license info
    $computerID = "COMP-" + (-join ((65..90) | Get-Random -Count 8 | % {[char]$_}))
    $licenseKey = -join ((65..90) + (48..57) | Get-Random -Count 20 | % {[char]$_})
    $installationID = "INST-" + (Get-Date -Format "yyyyMMddHHmmss")
    
    # Show license info in new form
    Show-LicenseInfoForm $userIDTextBox.Text $licenseKey $computerID $installationID
})
$form.Controls.Add($continueButton)

function Show-LicenseInfoForm($userID, $licenseKey, $computerID, $installationID) {
    $licenseForm = New-Object System.Windows.Forms.Form
    $licenseForm.Text = "License Information"
    $licenseForm.Size = New-Object System.Drawing.Size(850, 600)
    $licenseForm.StartPosition = "CenterScreen"
    $licenseForm.BackColor = [System.Drawing.Color]::FromArgb(30, 30, 30)
    
    # Title
    $licenseTitle = New-Object System.Windows.Forms.Label
    $licenseTitle.Text = "LICENSE & SYSTEM INFORMATION"
    $licenseTitle.Font = New-Object System.Drawing.Font("Segoe UI", 14, [System.Drawing.FontStyle]::Bold)
    $licenseTitle.ForeColor = [System.Drawing.Color]::LightGreen
    $licenseTitle.Location = New-Object System.Drawing.Point(50, 20)
    $licenseTitle.Size = New-Object System.Drawing.Size(750, 30)
    $licenseTitle.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
    $licenseForm.Controls.Add($licenseTitle)
    
    # Info Panel
    $yPos = 70
    $infoFields = @(
        @{Label="User ID"; Value=$userID},
        @{Label="License Key"; Value=$licenseKey},
        @{Label="Computer ID"; Value=$computerID},
        @{Label="Installation ID"; Value=$installationID},
        @{Label="Installation Date"; Value=(Get-Date -Format "yyyy-MM-dd HH:mm:ss")},
        @{Label="Expiry Date"; Value=(Get-Date).AddYears(1).ToString("yyyy-MM-dd")}
    )
    
    foreach ($field in $infoFields) {
        $label = New-Object System.Windows.Forms.Label
        $label.Text = $field.Label + ":"
        $label.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
        $label.ForeColor = [System.Drawing.Color]::Cyan
        $label.Location = New-Object System.Drawing.Point(50, $yPos)
        $label.Size = New-Object System.Drawing.Size(150, 25)
        $licenseForm.Controls.Add($label)
        
        $valueBox = New-Object System.Windows.Forms.TextBox
        $valueBox.Text = $field.Value
        $valueBox.Font = New-Object System.Drawing.Font("Consolas", 10)
        $valueBox.BackColor = [System.Drawing.Color]::FromArgb(45, 45, 45)
        $valueBox.ForeColor = [System.Drawing.Color]::LightGreen
        $valueBox.BorderStyle = [System.Windows.Forms.BorderStyle]::FixedSingle
        $valueBox.Location = New-Object System.Drawing.Point(200, $yPos)
        $valueBox.Size = New-Object System.Drawing.Size(600, 25)
        $valueBox.ReadOnly = $true
        $licenseForm.Controls.Add($valueBox)
        
        $yPos += 40
    }
    
    # Copy All Button
    $copyButton = New-Object System.Windows.Forms.Button
    $copyButton.Text = "📋 Copy All Information"
    $copyButton.Location = New-Object System.Drawing.Point(50, $yPos + 20)
    $copyButton.Size = New-Object System.Drawing.Size(750, 40)
    $copyButton.Font = New-Object System.Drawing.Font("Segoe UI", 11, [System.Drawing.FontStyle]::Bold)
    $copyButton.BackColor = [System.Drawing.Color]::FromArgb(76, 175, 80)
    $copyButton.ForeColor = [System.Drawing.Color]::White
    $copyButton.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
    $copyButton.Add_Click({
        $allInfo = @()
        foreach ($field in $infoFields) {
            $allInfo += "$($field.Label): $($field.Value)"
        }
        [System.Windows.Forms.Clipboard]::SetText($allInfo -join "`r`n")
        [System.Windows.Forms.MessageBox]::Show("All information copied to clipboard!", "Success",
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Information)
    })
    $licenseForm.Controls.Add($copyButton)
    
    $licenseForm.ShowDialog()
}

# Show main form
[void]$form.ShowDialog()
