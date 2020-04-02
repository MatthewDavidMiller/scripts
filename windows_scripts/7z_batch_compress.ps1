# Script to batch compress files with 7zip.

# Prompts
$CompressFilesVar = Read-Host 'Compress files? y/n '
$CompressFoldersVar = Read-Host 'Compress folders? y/n '

function CompressFolders {
    $Source = Read-Host 'Specify source directory to batch compress '
    $Destination = Read-Host 'Specify destination directory '
    foreach ($item in (Get-ChildItem -Directory -Name $Source)) {
        $7zJob = Start-Job -ScriptBlock { & "c:\Program Files\7-Zip\7z.exe" "-mx=9" "-ms=on" a "$using:Destination\$using:item.7z" "$using:Source\$using:item" }
        Start-Sleep -s 12
        $7zProcess = Get-Process -Name "7z"
        $7zProcess.PriorityClass = 'Idle'
        Get-Job | Wait-Job
        Receive-Job -Job $7zJob
    }
    $AnotherTask = Read-Host 'Compress more folders? y/n '
    DO {
        $Source = Read-Host 'Specify source directory to batch compress '
        $Destination = Read-Host 'Specify destination directory '
        foreach ($item in (Get-ChildItem -Directory -Name $Source)) {
            $7zJob = Start-Job -ScriptBlock { & "c:\Program Files\7-Zip\7z.exe" "-mx=9" "-ms=on" a "$using:Destination\$using:item.7z" "$using:Source\$using:item" }
            Start-Sleep -s 12
            $7zProcess = Get-Process -Name "7z"
            $7zProcess.PriorityClass = 'Idle'
            Get-Job | Wait-Job
            Receive-Job -Job $7zJob
        }
        $AnotherTask = Read-Host 'Compress more folders? y/n '
    } while ($AnotherTask -eq 'y')
}

function CompressFiles {
    $Source = Read-Host 'Specify source directory to batch compress '
    $Destination = Read-Host 'Specify destination directory '
    foreach ($item in (Get-ChildItem -File -Name $Source)) {
        $7zJob = Start-Job -ScriptBlock { & "c:\Program Files\7-Zip\7z.exe" "-mx=9" "-ms=on" a "$using:Destination\$using:item.7z" "$using:Source\$using:item" }
        Start-Sleep -s 12
        $7zProcess = Get-Process -Name "7z"
        $7zProcess.PriorityClass = 'Idle'
        Get-Job | Wait-Job
        Receive-Job -Job $7zJob
    }
    $AnotherTask = Read-Host 'Compress more files? y/n '
    DO {
        $Source = Read-Host 'Specify source directory to batch compress '
        $Destination = Read-Host 'Specify destination directory '
        foreach ($item in (Get-ChildItem -File -Name $Source)) {
            $7zJob = Start-Job -ScriptBlock { & "c:\Program Files\7-Zip\7z.exe" "-mx=9" "-ms=on" a "$using:Destination\$using:item.7z" "$using:Source\$using:item" }
            Start-Sleep -s 12
            $7zProcess = Get-Process -Name "7z"
            $7zProcess.PriorityClass = 'Idle'
            Get-Job | Wait-Job
            Receive-Job -Job $7zJob
        }
        $AnotherTask = Read-Host 'Compress more files? y/n '
    } while ($AnotherTask -eq 'y')
}

# Call functions
if ($CompressFoldersVar -eq 'y') {
    CompressFolders
}

if ($CompressFilesVar -eq 'y') {
    CompressFiles
}

Read-Host -Prompt "Script finished.  Press enter to exit."
