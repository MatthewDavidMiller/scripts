# Script to batch compress files with 7zip.

# Prompts
$CompressFilesVar = Read-Host 'Compress files? y/n '
$CompressFoldersVar = Read-Host 'Compress folders? y/n '
$Source = Read-Host 'Specify source directory to batch compress '
$Destination = Read-Host 'Specify destination directory '

function CompressFolders {
    foreach ($item in (Get-ChildItem -Directory -Name $Source)) {
        $7zJob = Start-Job -ScriptBlock { & "c:\Program Files\7-Zip\7z.exe" "-mx=9" "-ms=on" a "$using:Destination\$using:item.7z" "$using:Source\$using:item" }
        $7zProcess = Get-Process -Name "7z"
        $7zProcess.PriorityClass = 'Idle'
        Get-Job | Wait-Job
        Receive-Job -Job $7zJob
    }
}

function CompressFiles {
    foreach ($item in (Get-ChildItem -File -Name $Source)) {
        $7zJob = Start-Job -ScriptBlock { & "c:\Program Files\7-Zip\7z.exe" "-mx=9" "-ms=on" a "$using:Destination\$using:item.7z" "$using:Source\$using:item" }
        $7zProcess = Get-Process -Name "7z"
        $7zProcess.PriorityClass = 'Idle'
        Get-Job | Wait-Job
        Receive-Job -Job $7zJob
    }
}

# Call functions
if ($CompressFoldersVar -eq 'y') {
    CompressFolders
}

if ($CompressFilesVar -eq 'y') {
    CompressFiles
}

Read-Host -Prompt "Script finished.  Press enter to exit."
