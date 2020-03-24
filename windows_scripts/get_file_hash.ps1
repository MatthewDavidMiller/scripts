# Get the file hash of all files in a directory.

# Prompts
$MD5 = Read-Host 'Get MD5 checksums? y/n '
$SHA1 = Read-Host 'Get SHA1 checksums? y/n '
$SHA256 = Read-Host 'Get SHA256 checksums? y/n '
$SHA512 = Read-Host 'Get SHA512 checksums? y/n '
$Source = Read-Host 'Specify source directory to get file hashes '

# Get MD5 checksums
if ($MD5 -eq 'y') {
    Get-FileHash "$Source\*" -Algorithm MD5 | Format-List
}

# Get SHA1 checksums
if ($SHA1 -eq 'y') {
    Get-FileHash "$Source\*" -Algorithm SHA1 | Format-List
}

# Get SHA256 checksums
if ($SHA256 -eq 'y') {
    Get-FileHash "$Source\*" -Algorithm SHA256 | Format-List
}

# Get SHA512 checksums
if ($SHA512 -eq 'y') {
    Get-FileHash "$Source\*" -Algorithm SHA512 | Format-List
}

Read-Host -Prompt "Script finished.  Press enter to exit."
