$Source = 'C:\Users\matthew\Nextcloud\git'
$Destination = 'C:\Users\matthew\iCloudDrive\Matthew_Cloud\git_env'

foreach ( $item in ( Get-ChildItem -Name $Source ) ) {
    & robocopy "$Source\$item\env" "$Destination\$item\env" /s /copy:DAT /np /r:2 /w:5 /MT:40 /tee /mir
}
