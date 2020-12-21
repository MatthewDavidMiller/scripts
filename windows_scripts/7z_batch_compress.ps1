# Script to batch compress files with 7zip.
# Credits to Spc_555, https://stackoverflow.com/questions/25690038/how-do-i-properly-use-the-folderbrowserdialog-in-powershell
# Credits to Microsoft, https://docs.microsoft.com/en-us/dotnet/api/system.windows.forms.folderbrowserdialog?view=net-5.0

function CompressFolders {

    function GetFolderBrowser {
        Add-Type -AssemblyName System.Windows.Forms
        $FolderBrowser = New-Object Windows.Forms.FolderBrowserDialog
        $FolderBrowser.RootFolder = "MyComputer"
        $FolderBrowser.Description = "Select folder to compress"
        [void]$FolderBrowser.ShowDialog()
        $SelectedFolder = $FolderBrowser.SelectedPath
        return $SelectedFolder
    }
    $Source = GetFolderBrowser

    foreach ($item in ($Source)) {
        $7zJob = Start-Job -ScriptBlock { & "c:\Program Files\7-Zip\7z.exe" "-mx=9" "-ms=on" a "$using:item.7z" "$using:item" }
        Start-Sleep -s 12
        $7zProcess = Get-Process -Name "7z"
        $7zProcess.PriorityClass = 'Idle'
        Get-Job | Wait-Job
        Receive-Job -Job $7zJob
    }
}

function CompressFiles {
    function GetFileBrowser {
        Add-Type -AssemblyName System.Windows.Forms
        $FileBrowser = New-Object Windows.Forms.OpenFileDialog
        $FileBrowser.InitialDirectory = Get-Location
        $FileBrowser.Filter = "All Files (*.*)|*.*"
        $FileBrowser.ShowHelp = $true
        $FileBrowser.Multiselect = $true
        [void]$FileBrowser.ShowDialog()
        if ($FileBrowser.Multiselect) { $SelectedFiles = @($FileBrowser.FileNames) } else { $SelectedFiles = ($FileBrowser.FileName) }
        return $SelectedFiles
    }
    $Source = GetFileBrowser

    foreach ($item in ($Source)) {
        $7zJob = Start-Job -ScriptBlock { & "c:\Program Files\7-Zip\7z.exe" "-mx=9" "-ms=on" a "$using:item.7z" "$using:item" }
        Start-Sleep -s 12
        $7zProcess = Get-Process -Name "7z"
        $7zProcess.PriorityClass = 'Idle'
        Get-Job | Wait-Job
        Receive-Job -Job $7zJob
    }
}

function InteractiveMenu {
    function Show-Menu {
        param (
            [string]$Title = 'Configuration Options'
        )
        Clear-Host
        Write-Host "================ $Title ================"

        Write-Host "1: Press '1' to compress files."
        Write-Host "2: Press '2' to compress folders."
        Write-Host "q: Press 'q' to quit."
    }
    do {
        Show-Menu
        $selection = Read-Host "Select an option"
        switch ($selection) {
            '1' {
                CompressFiles
            }
            '2' {
                CompressFolders
            }
        }
        Pause
    }
    until ($selection -eq 'q')
}

# Call functions
InteractiveMenu
