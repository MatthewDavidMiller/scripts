# Script to batch compress files with 7zip.

# Prompts
$CompressFiles = Read-Host 'Compress files? y/n '
$CompressFolders = Read-Host 'Compress folders? y/n '
$Source = Read-Host 'Specify source directory to batch compress '

# Compress folders
if ($CompressFolders -eq 'y') {
    foreach ($item in (Get-ChildItem -Directory -Name $Source)) {
        & "c:\Program Files\7-Zip\7z.exe" "-mx=9" "-ms=off" a "$Source\$item.7z" "$Source\$item"

    }
}

# Compress files
if ($CompressFiles -eq 'y') {
    foreach ($item in (Get-ChildItem -File -Name $Source)) {
        & "c:\Program Files\7-Zip\7z.exe" "-mx=9" "-ms=off" a "$Source\$item.7z" "$Source\$item"

    }
}
