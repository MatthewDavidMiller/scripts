# Get the file hash of all files where the script is run from.

$CurrentDir = Split-Path $script:MyInvocation.MyCommand.Path
Get-FileHash "$CurrentDir\*" -Algorithm SHA256 | Format-List
Get-FileHash "$CurrentDir\*" -Algorithm SHA512 | Format-List
Get-FileHash "$CurrentDir\*" -Algorithm SHA1 | Format-List
Get-FileHash "$CurrentDir\*" -Algorithm MD5 | Format-List
Read-Host -Prompt "Script finished.  Press enter to exit."