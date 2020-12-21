# Script used to get the hash of a file.

function GetMD5Hash {
    Add-Type -AssemblyName System.Windows.Forms
    $filebrowser = New-Object Windows.Forms.OpenFileDialog
    $filebrowser.InitialDirectory = Get-Location
    $filebrowser.Filter = "All Files (*.*)|*.*"
    $filebrowser.ShowHelp = $true
    $filebrowser.Multiselect = $true
    [void]$filebrowser.ShowDialog()
    if ($filebrowser.Multiselect) { $Source = @($filebrowser.FileNames) } else { $Source = @($filebrowser.FileName) }

    # Get MD5 checksums
    foreach ($item in ($Source)) {
        Get-FileHash "$item" -Algorithm MD5 | Format-List
    }
}

function GetSHA1Hash {
    Add-Type -AssemblyName System.Windows.Forms
    $filebrowser = New-Object Windows.Forms.OpenFileDialog
    $filebrowser.InitialDirectory = Get-Location
    $filebrowser.Filter = "All Files (*.*)|*.*"
    $filebrowser.ShowHelp = $true
    $filebrowser.Multiselect = $true
    [void]$filebrowser.ShowDialog()
    if ($filebrowser.Multiselect) { $Source = @($filebrowser.FileNames) } else { $Source = @($filebrowser.FileName) }

    # Get MD5 checksums
    foreach ($item in ($Source)) {
        Get-FileHash "$item" -Algorithm SHA1 | Format-List
    }
}

function GetSHA256Hash {
    Add-Type -AssemblyName System.Windows.Forms
    $filebrowser = New-Object Windows.Forms.OpenFileDialog
    $filebrowser.InitialDirectory = Get-Location
    $filebrowser.Filter = "All Files (*.*)|*.*"
    $filebrowser.ShowHelp = $true
    $filebrowser.Multiselect = $true
    [void]$filebrowser.ShowDialog()
    if ($filebrowser.Multiselect) { $Source = @($filebrowser.FileNames) } else { $Source = @($filebrowser.FileName) }

    # Get MD5 checksums
    foreach ($item in ($Source)) {
        Get-FileHash "$item" -Algorithm SHA256 | Format-List
    }
}

function GetSHA512Hash {
    Add-Type -AssemblyName System.Windows.Forms
    $filebrowser = New-Object Windows.Forms.OpenFileDialog
    $filebrowser.InitialDirectory = Get-Location
    $filebrowser.Filter = "All Files (*.*)|*.*"
    $filebrowser.ShowHelp = $true
    $filebrowser.Multiselect = $true
    [void]$filebrowser.ShowDialog()
    if ($filebrowser.Multiselect) { $Source = @($filebrowser.FileNames) } else { $Source = @($filebrowser.FileName) }

    # Get MD5 checksums
    foreach ($item in ($Source)) {
        Get-FileHash "$item" -Algorithm SHA512 | Format-List
    }
}

function InteractiveMenu {
    function Show-Menu {
        param (
            [string]$Title = 'Configuration Options'
        )
        Clear-Host
        Write-Host "================ $Title ================"

        Write-Host "1: Press '1' to get Md5 hash."
        Write-Host "2: Press '2' to get SHA1 hash."
        Write-Host "3: Press '3' to get SHA256 hash."
        Write-Host "4: Press '4' to get SHA512 hash."
        Write-Host "q: Press 'q' to quit."
    }
    do {
        Show-Menu
        $selection = Read-Host "Select an option"
        switch ($selection) {
            '1' {
                GetMD5Hash
            }
            '2' {
                GetSHA1Hash
            }
            '3' {
                GetSHA256Hash
            }
            '4' {
                GetSHA512Hash
            }
        }
        Pause
    }
    until ($selection -eq 'q')
}

# Call functions
InteractiveMenu
