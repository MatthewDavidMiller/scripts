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

# Configure firewall
$WindowsFirewall = "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\WindowsFirewall"
$FirewallRules = "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\WindowsFirewall\FirewallRules"
$DomainProfile = "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\WindowsFirewall\DomainProfile"
$PrivateProfile = "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\WindowsFirewall\PrivateProfile"
$PublicProfile = "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\WindowsFirewall\PublicProfile"
$DomainProfileLogging = "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\WindowsFirewall\DomainProfile\Logging"
$PrivateProfileLogging = "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\WindowsFirewall\PrivateProfile\Logging"
$PublicProfileLogging = "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\WindowsFirewall\PublicProfile\Logging"
$FirewallStandardProfile = "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\WindowsFirewall\StandardProfile"
$FirewallAuthorizedApplications = "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\WindowsFirewall\StandardProfile\AuthorizedApplications"
$FirewallGloballyOpenPorts = "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\WindowsFirewall\StandardProfile\GloballyOpenPorts"

# Global settings

if (!(Test-Path $WindowsFirewall)) {
    New-Item -Path $WindowsFirewall -Force | Out-Null
    New-ItemProperty -Path $WindowsFirewall -Name DisableStatefulFTP -Value "0" -PropertyType DWORD -Force | Out-Null
    New-ItemProperty -Path $WindowsFirewall -Name DisableStatefulPPTP -Value "0" -PropertyType DWORD -Force | Out-Null
    New-ItemProperty -Path $WindowsFirewall -Name IPSecExempt -Value "9" -PropertyType DWORD -Force | Out-Null
    New-ItemProperty -Path $WindowsFirewall -Name PolicyVersion -Value "542" -PropertyType DWORD -Force | Out-Null
}
else {
    New-ItemProperty -Path $WindowsFirewall -Name DisableStatefulFTP -Value "0" -PropertyType DWORD -Force | Out-Null
    New-ItemProperty -Path $WindowsFirewall -Name DisableStatefulPPTP -Value "0" -PropertyType DWORD -Force | Out-Null
    New-ItemProperty -Path $WindowsFirewall -Name IPSecExempt -Value "9" -PropertyType DWORD -Force | Out-Null
    New-ItemProperty -Path $WindowsFirewall -Name PolicyVersion -Value "542" -PropertyType DWORD -Force | Out-Null
}

# Configure profiles

# Configure domain profile
if (!(Test-Path $DomainProfile)) {
    New-Item -Path $DomainProfile -Force | Out-Null
    New-ItemProperty -Path $DomainProfile -Name AllowLocalPolicyMerge -Value "0" -PropertyType DWORD -Force | Out-Null
    New-ItemProperty -Path $DomainProfile -Name AllowLocalIPsecPolicyMerge -Value "0" -PropertyType DWORD -Force | Out-Null
    New-ItemProperty -Path $DomainProfile -Name DefaultInboundAction -Value "1" -PropertyType DWORD -Force | Out-Null
    New-ItemProperty -Path $DomainProfile -Name DefaultOutboundAction -Value "0" -PropertyType DWORD -Force | Out-Null
    New-ItemProperty -Path $DomainProfile -Name DisableNotifications -Value "0" -PropertyType DWORD -Force | Out-Null
    New-ItemProperty -Path $DomainProfile -Name DisableUnicastResponsesToMulticastBroadcast -Value "0" -PropertyType DWORD -Force | Out-Null
    # Enable firewall
    New-ItemProperty -Path $DomainProfile -Name EnableFirewall -Value "1" -PropertyType DWORD -Force | Out-Null
}
else {
    New-ItemProperty -Path $DomainProfile -Name AllowLocalPolicyMerge -Value "0" -PropertyType DWORD -Force | Out-Null
    New-ItemProperty -Path $DomainProfile -Name AllowLocalIPsecPolicyMerge -Value "0" -PropertyType DWORD -Force | Out-Null
    New-ItemProperty -Path $DomainProfile -Name DefaultInboundAction -Value "1" -PropertyType DWORD -Force | Out-Null
    New-ItemProperty -Path $DomainProfile -Name DefaultOutboundAction -Value "0" -PropertyType DWORD -Force | Out-Null
    New-ItemProperty -Path $DomainProfile -Name DisableNotifications -Value "0" -PropertyType DWORD -Force | Out-Null
    New-ItemProperty -Path $DomainProfile -Name DisableUnicastResponsesToMulticastBroadcast -Value "0" -PropertyType DWORD -Force | Out-Null
    # Enable firewall
    New-ItemProperty -Path $DomainProfile -Name EnableFirewall -Value "1" -PropertyType DWORD -Force | Out-Null
}

# Configure private profile
if (!(Test-Path $PrivateProfile)) {
    New-Item -Path $PrivateProfile -Force | Out-Null
    New-ItemProperty -Path $PrivateProfile -Name AllowLocalPolicyMerge -Value "0" -PropertyType DWORD -Force | Out-Null
    New-ItemProperty -Path $PrivateProfile -Name AllowLocalIPsecPolicyMerge -Value "0" -PropertyType DWORD -Force | Out-Null
    New-ItemProperty -Path $PrivateProfile -Name DefaultInboundAction -Value "1" -PropertyType DWORD -Force | Out-Null
    New-ItemProperty -Path $PrivateProfile -Name DefaultOutboundAction -Value "0" -PropertyType DWORD -Force | Out-Null
    New-ItemProperty -Path $PrivateProfile -Name DisableNotifications -Value "0" -PropertyType DWORD -Force | Out-Null
    New-ItemProperty -Path $PrivateProfile -Name DisableUnicastResponsesToMulticastBroadcast -Value "0" -PropertyType DWORD -Force | Out-Null
    # Enable firewall
    New-ItemProperty -Path $PrivateProfile -Name EnableFirewall -Value "1" -PropertyType DWORD -Force | Out-Null
}
else {
    New-ItemProperty -Path $PrivateProfile -Name AllowLocalPolicyMerge -Value "0" -PropertyType DWORD -Force | Out-Null
    New-ItemProperty -Path $PrivateProfile -Name AllowLocalIPsecPolicyMerge -Value "0" -PropertyType DWORD -Force | Out-Null
    New-ItemProperty -Path $PrivateProfile -Name DefaultInboundAction -Value "1" -PropertyType DWORD -Force | Out-Null
    New-ItemProperty -Path $PrivateProfile -Name DefaultOutboundAction -Value "0" -PropertyType DWORD -Force | Out-Null
    New-ItemProperty -Path $PrivateProfile -Name DisableNotifications -Value "0" -PropertyType DWORD -Force | Out-Null
    New-ItemProperty -Path $PrivateProfile -Name DisableUnicastResponsesToMulticastBroadcast -Value "0" -PropertyType DWORD -Force | Out-Null
    # Enable firewall
    New-ItemProperty -Path $PrivateProfile -Name EnableFirewall -Value "1" -PropertyType DWORD -Force | Out-Null
}

# Configure public profile
if (!(Test-Path $PublicProfile)) {
    New-Item -Path $PublicProfile -Force | Out-Null
    New-ItemProperty -Path $PublicProfile -Name AllowLocalPolicyMerge -Value "0" -PropertyType DWORD -Force | Out-Null
    New-ItemProperty -Path $PublicProfile -Name AllowLocalIPsecPolicyMerge -Value "0" -PropertyType DWORD -Force | Out-Null
    New-ItemProperty -Path $PublicProfile -Name DefaultInboundAction -Value "1" -PropertyType DWORD -Force | Out-Null
    New-ItemProperty -Path $PublicProfile -Name DefaultOutboundAction -Value "0" -PropertyType DWORD -Force | Out-Null
    New-ItemProperty -Path $PublicProfile -Name DisableNotifications -Value "0" -PropertyType DWORD -Force | Out-Null
    New-ItemProperty -Path $PublicProfile -Name DisableUnicastResponsesToMulticastBroadcast -Value "0" -PropertyType DWORD -Force | Out-Null
    # Enable firewall
    New-ItemProperty -Path $PublicProfile -Name EnableFirewall -Value "1" -PropertyType DWORD -Force | Out-Null
}
else {
    New-ItemProperty -Path $PublicProfile -Name AllowLocalPolicyMerge -Value "0" -PropertyType DWORD -Force | Out-Null
    New-ItemProperty -Path $PublicProfile -Name AllowLocalIPsecPolicyMerge -Value "0" -PropertyType DWORD -Force | Out-Null
    New-ItemProperty -Path $PublicProfile -Name DefaultInboundAction -Value "1" -PropertyType DWORD -Force | Out-Null
    New-ItemProperty -Path $PublicProfile -Name DefaultOutboundAction -Value "0" -PropertyType DWORD -Force | Out-Null
    New-ItemProperty -Path $PublicProfile -Name DisableNotifications -Value "0" -PropertyType DWORD -Force | Out-Null
    New-ItemProperty -Path $PublicProfile -Name DisableUnicastResponsesToMulticastBroadcast -Value "0" -PropertyType DWORD -Force | Out-Null
    # Enable firewall
    New-ItemProperty -Path $PublicProfile -Name EnableFirewall -Value "1" -PropertyType DWORD -Force | Out-Null
}

# Firewall Rules
if (!(Test-Path $FirewallRules)) {
    New-Item -Path $FirewallRules -Force | Out-Null
    # Allow delivery optimization inbound on local network.
    New-ItemProperty -Path $FirewallRules -Name "DeliveryOptimization-TCP-In" -Value "v2.30|Action=Allow|Active=TRUE|Dir=In|Protocol=6|Profile=Domain|Profile=Private|LPort=7680|RA4=LocalSubnet|RA6=LocalSubnet|App=%SystemRoot%\system32\svchost.exe|Svc=dosvc|Name=@%systemroot%\system32\dosvc.dll,-102|Desc=@%systemroot%\system32\dosvc.dll,-104|EmbedCtxt=@%systemroot%\system32\dosvc.dll,-100|Edge=TRUE|" -PropertyType String -Force | Out-Null
}
else {
    Remove-Item -Path $FirewallRules -Force | Out-Null
    New-Item -Path $FirewallRules -Force | Out-Null
    # Allow delivery optimization inbound on local network.
    New-ItemProperty -Path $FirewallRules -Name "DeliveryOptimization-TCP-In" -Value "v2.30|Action=Allow|Active=TRUE|Dir=In|Protocol=6|Profile=Domain|Profile=Private|LPort=7680|RA4=LocalSubnet|RA6=LocalSubnet|App=%SystemRoot%\system32\svchost.exe|Svc=dosvc|Name=@%systemroot%\system32\dosvc.dll,-102|Desc=@%systemroot%\system32\dosvc.dll,-104|EmbedCtxt=@%systemroot%\system32\dosvc.dll,-100|Edge=TRUE|" -PropertyType String -Force | Out-Null
}

# Enable firewall logging

# Enable logging for domain profile
if (!(Test-Path $DomainProfileLogging)) {
    New-Item -Path $DomainProfileLogging -Force | Out-Null
    # Enable logging of dropped packets
    New-ItemProperty -Path $DomainProfileLogging -Name LogDroppedPackets -Value "1" -PropertyType DWORD -Force | Out-Null
    # Set log file location
    New-ItemProperty -Path $DomainProfileLogging -Name LogFilePath -Value "%systemroot%\system32\LogFiles\Firewall\pfirewall.log" -PropertyType String -Force | Out-Null
    # Set log file size
    New-ItemProperty -Path $DomainProfileLogging -Name LogFileSize -Value "4096" -PropertyType DWORD -Force | Out-Null
    # Enable logging of successful connections
    New-ItemProperty -Path $DomainProfileLogging -Name LogSuccessfulConnections -Value "1" -PropertyType DWORD -Force | Out-Null
}
else {
    # Enable logging of dropped packets
    New-ItemProperty -Path $DomainProfileLogging -Name LogDroppedPackets -Value "1" -PropertyType DWORD -Force | Out-Null
    # Set log file location
    New-ItemProperty -Path $DomainProfileLogging -Name LogFilePath -Value "%systemroot%\system32\LogFiles\Firewall\pfirewall.log" -PropertyType String -Force | Out-Null
    # Set log file size
    New-ItemProperty -Path $DomainProfileLogging -Name LogFileSize -Value "4096" -PropertyType DWORD -Force | Out-Null
    # Enable logging of successful connections
    New-ItemProperty -Path $DomainProfileLogging -Name LogSuccessfulConnections -Value "1" -PropertyType DWORD -Force | Out-Null
}

# Enable logging for private profile
if (!(Test-Path $PrivateProfileLogging)) {
    New-Item -Path $PrivateProfileLogging -Force | Out-Null
    # Enable logging of dropped packets
    New-ItemProperty -Path $PrivateProfileLogging -Name LogDroppedPackets -Value "1" -PropertyType DWORD -Force | Out-Null
    # Set log file location
    New-ItemProperty -Path $PrivateProfileLogging -Name LogFilePath -Value "%systemroot%\system32\LogFiles\Firewall\pfirewall.log" -PropertyType String -Force | Out-Null
    # Set log file size
    New-ItemProperty -Path $PrivateProfileLogging -Name LogFileSize -Value "4096" -PropertyType DWORD -Force | Out-Null
    # Enable logging of successful connections
    New-ItemProperty -Path $PrivateProfileLogging -Name LogSuccessfulConnections -Value "1" -PropertyType DWORD -Force | Out-Null
}
else {
    # Enable logging of dropped packets
    New-ItemProperty -Path $PrivateProfileLogging -Name LogDroppedPackets -Value "1" -PropertyType DWORD -Force | Out-Null
    # Set log file location
    New-ItemProperty -Path $PrivateProfileLogging -Name LogFilePath -Value "%systemroot%\system32\LogFiles\Firewall\pfirewall.log" -PropertyType String -Force | Out-Null
    # Set log file size
    New-ItemProperty -Path $PrivateProfileLogging -Name LogFileSize -Value "4096" -PropertyType DWORD -Force | Out-Null
    # Enable logging of successful connections
    New-ItemProperty -Path $PrivateProfileLogging -Name LogSuccessfulConnections -Value "1" -PropertyType DWORD -Force | Out-Null
}

# Enable logging for public profile
if (!(Test-Path $PublicProfileLogging)) {
    New-Item -Path $PublicProfileLogging -Force | Out-Null
    # Enable logging of dropped packets
    New-ItemProperty -Path $PublicProfileLogging -Name LogDroppedPackets -Value "1" -PropertyType DWORD -Force | Out-Null
    # Set log file location
    New-ItemProperty -Path $PublicProfileLogging -Name LogFilePath -Value "%systemroot%\system32\LogFiles\Firewall\pfirewall.log" -PropertyType String -Force | Out-Null
    # Set log file size
    New-ItemProperty -Path $PublicProfileLogging -Name LogFileSize -Value "4096" -PropertyType DWORD -Force | Out-Null
    # Enable logging of successful connections
    New-ItemProperty -Path $PublicProfileLogging -Name LogSuccessfulConnections -Value "1" -PropertyType DWORD -Force | Out-Null
}
else {
    # Enable logging of dropped packets
    New-ItemProperty -Path $PublicProfileLogging -Name LogDroppedPackets -Value "1" -PropertyType DWORD -Force | Out-Null
    # Set log file location
    New-ItemProperty -Path $PublicProfileLogging -Name LogFilePath -Value "%systemroot%\system32\LogFiles\Firewall\pfirewall.log" -PropertyType String -Force | Out-Null
    # Set log file size
    New-ItemProperty -Path $PublicProfileLogging -Name LogFileSize -Value "4096" -PropertyType DWORD -Force | Out-Null
    # Enable logging of successful connections
    New-ItemProperty -Path $PublicProfileLogging -Name LogSuccessfulConnections -Value "1" -PropertyType DWORD -Force | Out-Null
}

# Disable local creation of firewall rules

if (!(Test-Path $FirewallStandardProfile)) {
    New-Item -Path $FirewallStandardProfile -Force | Out-Null
}

# Disable creating local application rules
if (!(Test-Path $FirewallAuthorizedApplications)) {
    New-Item -Path $FirewallAuthorizedApplications -Force | Out-Null
    New-ItemProperty -Path $FirewallAuthorizedApplications -Name AllowUserPrefMerge -Value "0" -PropertyType DWORD -Force | Out-Null
}
else {
    New-ItemProperty -Path $FirewallAuthorizedApplications -Name AllowUserPrefMerge -Value "0" -PropertyType DWORD -Force | Out-Null
}

# Disable creating of local port rules

if (!(Test-Path $FirewallGloballyOpenPorts)) {
    New-Item -Path $FirewallGloballyOpenPorts -Force | Out-Null
    New-ItemProperty -Path $FirewallGloballyOpenPorts -Name AllowUserPrefMerge -Value "0" -PropertyType DWORD -Force | Out-Null
}
else {
    New-ItemProperty -Path $FirewallGloballyOpenPorts -Name AllowUserPrefMerge -Value "0" -PropertyType DWORD -Force | Out-Null
}
