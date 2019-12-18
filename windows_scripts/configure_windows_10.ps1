# Script to confgure settings I use in Windows 10.

# Disable Cortana
$CortanaKey = "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Windows Search"
$CortanaKeyName = "AllowCortana"

if (!(Test-Path $CortanaKey)) {
    New-Item -Path $CortanaKey -Force | Out-Null
    New-ItemProperty -Path $CortanaKey -Name $CortanaKeyName -Value "0" -PropertyType DWORD -Force | Out-Null
}
else {
    New-ItemProperty -Path $CortanaKey -Name $CortanaKeyName -Value "0" -PropertyType DWORD -Force | Out-Null
}

# Disable telemetry
$TelemetryKey = "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\DataCollection"
$TelemetryKeyName = "AllowTelemetry"
$TelemetryService1 = "Connected User Experiences and Telemetry"

if (!(Test-Path $TelemetryKey)) {
    New-Item -Path $TelemetryKey -Force | Out-Null
    New-ItemProperty -Path $TelemetryKey -Name $TelemetryKeyName -Value "0" -PropertyType DWORD -Force | Out-Null
}
else {
    New-ItemProperty -Path $TelemetryKey -Name $TelemetryKeyName -Value "0" -PropertyType DWORD -Force | Out-Null
}

Get-Service -Name $TelemetryService1 | Set-Service -Status Stopped
Get-Service -Name $TelemetryService1 | Set-Service -StartupType Disabled
