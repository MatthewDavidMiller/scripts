# Script to confgure settings in Windows 10

# Prompts
$DisableCortana = Read-Host 'Disable Cortana? y/n '
$DisableTelemetry = Read-Host 'Disable Telemetry? y/n '
$ConfigureFirewall = Read-Host 'Configure Firewall? y/n '
$RemoveApplications = Read-Host 'Remove some of the default applications? y/n '
$ConfigureAppPrivacy = Read-Host 'Configure app privacy settings? y/n '
$ConfigureNTP = Read-Host 'Configure NTP? y/n '
$InstallApplications = Read-Host 'Install some applications? y/n '

# Disable Cortana
function DisableCortana {
    $CortanaKey = "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Windows Search"
    $CortanaKeyName = "AllowCortana"

    if (!(Test-Path $CortanaKey)) {
        New-Item -Path $CortanaKey -Force | Out-Null
        New-ItemProperty -Path $CortanaKey -Name $CortanaKeyName -Value "0" -PropertyType DWORD -Force | Out-Null
    }
    else {
        New-ItemProperty -Path $CortanaKey -Name $CortanaKeyName -Value "0" -PropertyType DWORD -Force | Out-Null
    }
}

# Disable telemetry
function DisableTelemetry {
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
}

# Configure firewall
function ConfigureFirewall {
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

    function FirewallGlobalSettings {
        New-ItemProperty -Path $WindowsFirewall -Name DisableStatefulFTP -Value "0" -PropertyType DWORD -Force | Out-Null
        New-ItemProperty -Path $WindowsFirewall -Name DisableStatefulPPTP -Value "0" -PropertyType DWORD -Force | Out-Null
        New-ItemProperty -Path $WindowsFirewall -Name IPSecExempt -Value "9" -PropertyType DWORD -Force | Out-Null
        New-ItemProperty -Path $WindowsFirewall -Name PolicyVersion -Value "542" -PropertyType DWORD -Force | Out-Null
    }

    # Global settings
    if (!(Test-Path $WindowsFirewall)) {
        New-Item -Path $WindowsFirewall -Force | Out-Null
        FirewallGlobalSettings
    }
    else {
        FirewallGlobalSettings
    }

    # Configure profiles
    function FirewallDomainProfile {
        New-ItemProperty -Path $DomainProfile -Name AllowLocalPolicyMerge -Value "0" -PropertyType DWORD -Force | Out-Null
        New-ItemProperty -Path $DomainProfile -Name AllowLocalIPsecPolicyMerge -Value "0" -PropertyType DWORD -Force | Out-Null
        New-ItemProperty -Path $DomainProfile -Name DefaultInboundAction -Value "1" -PropertyType DWORD -Force | Out-Null
        New-ItemProperty -Path $DomainProfile -Name DefaultOutboundAction -Value "0" -PropertyType DWORD -Force | Out-Null
        New-ItemProperty -Path $DomainProfile -Name DisableNotifications -Value "0" -PropertyType DWORD -Force | Out-Null
        New-ItemProperty -Path $DomainProfile -Name DisableUnicastResponsesToMulticastBroadcast -Value "0" -PropertyType DWORD -Force | Out-Null
        # Enable firewall
        New-ItemProperty -Path $DomainProfile -Name EnableFirewall -Value "1" -PropertyType DWORD -Force | Out-Null
    }

    # Configure domain profile
    if (!(Test-Path $DomainProfile)) {
        New-Item -Path $DomainProfile -Force | Out-Null
        FirewallDomainProfile
    }
    else {
        FirewallDomainProfile
    }

    function FirewallPrivateProfile {
        New-ItemProperty -Path $PrivateProfile -Name AllowLocalPolicyMerge -Value "0" -PropertyType DWORD -Force | Out-Null
        New-ItemProperty -Path $PrivateProfile -Name AllowLocalIPsecPolicyMerge -Value "0" -PropertyType DWORD -Force | Out-Null
        New-ItemProperty -Path $PrivateProfile -Name DefaultInboundAction -Value "1" -PropertyType DWORD -Force | Out-Null
        New-ItemProperty -Path $PrivateProfile -Name DefaultOutboundAction -Value "0" -PropertyType DWORD -Force | Out-Null
        New-ItemProperty -Path $PrivateProfile -Name DisableNotifications -Value "0" -PropertyType DWORD -Force | Out-Null
        New-ItemProperty -Path $PrivateProfile -Name DisableUnicastResponsesToMulticastBroadcast -Value "0" -PropertyType DWORD -Force | Out-Null
        # Enable firewall
        New-ItemProperty -Path $PrivateProfile -Name EnableFirewall -Value "1" -PropertyType DWORD -Force | Out-Null
    }

    # Configure private profile
    if (!(Test-Path $PrivateProfile)) {
        New-Item -Path $PrivateProfile -Force | Out-Null
        FirewallPrivateProfile
    }
    else {
        FirewallPrivateProfile
    }

    function FirewallPublicProfile {
        New-ItemProperty -Path $PublicProfile -Name AllowLocalPolicyMerge -Value "0" -PropertyType DWORD -Force | Out-Null
        New-ItemProperty -Path $PublicProfile -Name AllowLocalIPsecPolicyMerge -Value "0" -PropertyType DWORD -Force | Out-Null
        New-ItemProperty -Path $PublicProfile -Name DefaultInboundAction -Value "1" -PropertyType DWORD -Force | Out-Null
        New-ItemProperty -Path $PublicProfile -Name DefaultOutboundAction -Value "0" -PropertyType DWORD -Force | Out-Null
        New-ItemProperty -Path $PublicProfile -Name DisableNotifications -Value "0" -PropertyType DWORD -Force | Out-Null
        New-ItemProperty -Path $PublicProfile -Name DisableUnicastResponsesToMulticastBroadcast -Value "0" -PropertyType DWORD -Force | Out-Null
        # Enable firewall
        New-ItemProperty -Path $PublicProfile -Name EnableFirewall -Value "1" -PropertyType DWORD -Force | Out-Null
    }

    # Configure public profile
    if (!(Test-Path $PublicProfile)) {
        New-Item -Path $PublicProfile -Force | Out-Null
        FirewallPublicProfile
    }
    else {
        FirewallPublicProfile
    }

    function FirewallRulesCreation {
        # Allow delivery optimization inbound on local network.
        New-ItemProperty -Path $FirewallRules -Name "DeliveryOptimization-TCP-In" -Value "v2.30|Action=Allow|Active=TRUE|Dir=In|Protocol=6|Profile=Domain|Profile=Private|LPort=7680|RA4=LocalSubnet|RA6=LocalSubnet|App=%SystemRoot%\system32\svchost.exe|Svc=dosvc|Name=@%systemroot%\system32\dosvc.dll,-102|Desc=@%systemroot%\system32\dosvc.dll,-104|EmbedCtxt=@%systemroot%\system32\dosvc.dll,-100|Edge=TRUE|" -PropertyType String -Force | Out-Null
    }

    # Firewall Rules
    if (!(Test-Path $FirewallRules)) {
        New-Item -Path $FirewallRules -Force | Out-Null
        FirewallRulesCreation
    }
    else {
        Remove-Item -Path $FirewallRules -Force | Out-Null
        New-Item -Path $FirewallRules -Force | Out-Null
        FirewallRulesCreation
    }

    # Enable firewall logging
    function EnableDomainProfileLogging {
        # Enable logging of dropped packets
        New-ItemProperty -Path $DomainProfileLogging -Name LogDroppedPackets -Value "1" -PropertyType DWORD -Force | Out-Null
        # Set log file location
        New-ItemProperty -Path $DomainProfileLogging -Name LogFilePath -Value "%systemroot%\system32\LogFiles\Firewall\pfirewall.log" -PropertyType String -Force | Out-Null
        # Set log file size
        New-ItemProperty -Path $DomainProfileLogging -Name LogFileSize -Value "4096" -PropertyType DWORD -Force | Out-Null
        # Enable logging of successful connections
        New-ItemProperty -Path $DomainProfileLogging -Name LogSuccessfulConnections -Value "1" -PropertyType DWORD -Force | Out-Null
    }

    # Enable logging for domain profile
    if (!(Test-Path $DomainProfileLogging)) {
        New-Item -Path $DomainProfileLogging -Force | Out-Null
        EnableDomainProfileLogging
    }
    else {
        EnableDomainProfileLogging
    }

    function EnablePrivateProfileLogging {
        # Enable logging of dropped packets
        New-ItemProperty -Path $PrivateProfileLogging -Name LogDroppedPackets -Value "1" -PropertyType DWORD -Force | Out-Null
        # Set log file location
        New-ItemProperty -Path $PrivateProfileLogging -Name LogFilePath -Value "%systemroot%\system32\LogFiles\Firewall\pfirewall.log" -PropertyType String -Force | Out-Null
        # Set log file size
        New-ItemProperty -Path $PrivateProfileLogging -Name LogFileSize -Value "4096" -PropertyType DWORD -Force | Out-Null
        # Enable logging of successful connections
        New-ItemProperty -Path $PrivateProfileLogging -Name LogSuccessfulConnections -Value "1" -PropertyType DWORD -Force | Out-Null
    }

    # Enable logging for private profile
    if (!(Test-Path $PrivateProfileLogging)) {
        New-Item -Path $PrivateProfileLogging -Force | Out-Null
        EnablePrivateProfileLogging
    }
    else {
        EnablePrivateProfileLogging
    }

    function EnablePublicProfileLogging {
        # Enable logging of dropped packets
        New-ItemProperty -Path $PublicProfileLogging -Name LogDroppedPackets -Value "1" -PropertyType DWORD -Force | Out-Null
        # Set log file location
        New-ItemProperty -Path $PublicProfileLogging -Name LogFilePath -Value "%systemroot%\system32\LogFiles\Firewall\pfirewall.log" -PropertyType String -Force | Out-Null
        # Set log file size
        New-ItemProperty -Path $PublicProfileLogging -Name LogFileSize -Value "4096" -PropertyType DWORD -Force | Out-Null
        # Enable logging of successful connections
        New-ItemProperty -Path $PublicProfileLogging -Name LogSuccessfulConnections -Value "1" -PropertyType DWORD -Force | Out-Null
    }

    # Enable logging for public profile
    if (!(Test-Path $PublicProfileLogging)) {
        New-Item -Path $PublicProfileLogging -Force | Out-Null
        EnablePublicProfileLogging
    }
    else {
        EnablePublicProfileLogging
    }

    # Disable local creation of firewall rules
    if (!(Test-Path $FirewallStandardProfile)) {
        New-Item -Path $FirewallStandardProfile -Force | Out-Null
    }

    function DisableLocalApplicationRules {
        New-ItemProperty -Path $FirewallAuthorizedApplications -Name AllowUserPrefMerge -Value "0" -PropertyType DWORD -Force | Out-Null
    }

    # Disable creating local application rules
    if (!(Test-Path $FirewallAuthorizedApplications)) {
        New-Item -Path $FirewallAuthorizedApplications -Force | Out-Null
        DisableLocalApplicationRules
    }
    else {
        DisableLocalApplicationRules
    }

    function DisableLocalPortRules {
        New-ItemProperty -Path $FirewallGloballyOpenPorts -Name AllowUserPrefMerge -Value "0" -PropertyType DWORD -Force | Out-Null
    }

    # Disable creating local port rules
    if (!(Test-Path $FirewallGloballyOpenPorts)) {
        New-Item -Path $FirewallGloballyOpenPorts -Force | Out-Null
        DisableLocalPortRules
    }
    else {
        DisableLocalPortRules
    }
}

# Remove applications
function RemoveApplications {
    # Applications base name
    $AppBase = "Microsoft."
    # Applications to remove
    $AppBingWeather = "BingWeather"
    $AppStickyNotes = "MicrosoftStickyNotes"
    $AppZuneVideo = "ZuneVideo"
    $AppZuneMusic = "ZuneMusic"
    $AppMaps = "WindowsMaps"
    $AppFeedbackHub = "WindowsFeedbackHub"
    $AppCommunications = "windowscommunicationsapps"
    $AppCamera = "WindowsCamera"
    $AppAlarms = "WindowsAlarms"
    $AppSkype = "SkypeApp"
    $AppPrint3D = "Print3D"
    $AppPeople = "People"
    $AppOneConnect = "OneConnect"
    $AppOfficeSway = "Office.Sway"
    $AppNetworkSpeedTest = "NetworkSpeedTest"
    $AppSolitaire = "MicrosoftSolitaireCollection"
    $AppOfficeHub = "MicrosoftOfficeHub"
    $App3DViewer = "Microsoft3DViewer"
    $AppMessaging = "Messaging"
    $AppGetStarted = "Getstarted"
    $AppGetHelp = "GetHelp"
    $AppXboxOneSmartGlass = "XboxOneSmartGlass"
    $AppNews = "BingNews"
    $AppYourPhone = "YourPhone"
    $AppMixedReality = "MixedReality.Portal"
    $AppScreenSketch = "ScreenSketch"
    $AppOfficeOnenote = "Office.OneNote"
    $AppWallet = "Wallet"

    # Removes the applications
    Get-AppxPackage -name "$($AppBase)$($AppBingWeather)" | Remove-AppxPackage
    Get-AppxPackage -name "$($AppBase)$($AppStickyNotes)" | Remove-AppxPackage
    Get-AppxPackage -name "$($AppBase)$($AppZuneVideo)" | Remove-AppxPackage
    Get-AppxPackage -name "$($AppBase)$($AppZuneMusic)" | Remove-AppxPackage
    Get-AppxPackage -name "$($AppBase)$($AppMaps)" | Remove-AppxPackage
    Get-AppxPackage -name "$($AppBase)$($AppFeedbackHub)" | Remove-AppxPackage
    Get-AppxPackage -name "$($AppBase)$($AppCommunications)" | Remove-AppxPackage
    Get-AppxPackage -name "$($AppBase)$($AppCamera)" | Remove-AppxPackage
    Get-AppxPackage -name "$($AppBase)$($AppAlarms)" | Remove-AppxPackage
    Get-AppxPackage -name "$($AppBase)$($AppSkype)" | Remove-AppxPackage
    Get-AppxPackage -name "$($AppBase)$($AppPrint3D)" | Remove-AppxPackage
    Get-AppxPackage -name "$($AppBase)$($AppPeople)" | Remove-AppxPackage
    Get-AppxPackage -name "$($AppBase)$($AppOneConnect)" | Remove-AppxPackage
    Get-AppxPackage -name "$($AppBase)$($AppOfficeSway)" | Remove-AppxPackage
    Get-AppxPackage -name "$($AppBase)$($AppNetworkSpeedTest)" | Remove-AppxPackage
    Get-AppxPackage -name "$($AppBase)$($AppSolitaire)" | Remove-AppxPackage
    Get-AppxPackage -name "$($AppBase)$($AppOfficeHub)" | Remove-AppxPackage
    Get-AppxPackage -name "$($AppBase)$($App3DViewer)" | Remove-AppxPackage
    Get-AppxPackage -name "$($AppBase)$($AppMessaging)" | Remove-AppxPackage
    Get-AppxPackage -name "$($AppBase)$($AppGetStarted)" | Remove-AppxPackage
    Get-AppxPackage -name "$($AppBase)$($AppGetHelp)" | Remove-AppxPackage
    Get-AppxPackage -name "$($AppBase)$($AppXboxOneSmartGlass)" | Remove-AppxPackage
    Get-AppxPackage -name "$($AppBase)$($AppNews)" | Remove-AppxPackage
    Get-AppxPackage -name "$($AppBase)$($AppYourPhone)" | Remove-AppxPackage
    Get-AppxPackage -name "$($AppBase)$($AppMixedReality)" | Remove-AppxPackage
    Get-AppxPackage -name "$($AppBase)$($AppScreenSketch)" | Remove-AppxPackage
    Get-AppxPackage -name "$($AppBase)$($AppOfficeOnenote)" | Remove-AppxPackage
    Get-AppxPackage -name "$($AppBase)$($AppWallet)" | Remove-AppxPackage
}

# Configure app privacy settings
function ConfigureAppPrivacy {
    $AppPrivacy = "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\AppPrivacy"
    $ForceAllowBackgroundApps = @"
Microsoft.WindowsStore_8wekyb3d8bbwe
windows.immersivecontrolpanel_cw5n1h2txyewy
"@

    function ConfigureAppPrivacyRegistry {
        # Prevent apps from accessing account info
        New-ItemProperty -Path $AppPrivacy -Name LetAppsAccessAccountInfo -Value "2" -PropertyType DWORD -Force | Out-Null
        New-ItemProperty -Path $AppPrivacy -Name LetAppsAccessAccountInfo_ForceAllowTheseApps -PropertyType MultiString -Force | Out-Null
        New-ItemProperty -Path $AppPrivacy -Name LetAppsAccessAccountInfo_ForceDenyTheseApps -PropertyType MultiString -Force | Out-Null
        New-ItemProperty -Path $AppPrivacy -Name LetAppsAccessAccountInfo_UserInControlOfTheseApps -PropertyType MultiString -Force | Out-Null
        # Prevent apps from accessing calendar
        New-ItemProperty -Path $AppPrivacy -Name LetAppsAccessCalendar -Value "2" -PropertyType DWORD -Force | Out-Null
        New-ItemProperty -Path $AppPrivacy -Name LetAppsAccessCalendar_ForceAllowTheseApps -PropertyType MultiString -Force | Out-Null
        New-ItemProperty -Path $AppPrivacy -Name LetAppsAccessCalendar_ForceDenyTheseApps -PropertyType MultiString -Force | Out-Null
        New-ItemProperty -Path $AppPrivacy -Name LetAppsAccessCalendar_UserInControlOfTheseApps -PropertyType MultiString -Force | Out-Null
        # Prevent apps from accessing call history
        New-ItemProperty -Path $AppPrivacy -Name LetAppsAccessCallHistory -Value "2" -PropertyType DWORD -Force | Out-Null
        New-ItemProperty -Path $AppPrivacy -Name LetAppsAccessCallHistory_ForceAllowTheseApps -PropertyType MultiString -Force | Out-Null
        New-ItemProperty -Path $AppPrivacy -Name LetAppsAccessCallHistory_ForceDenyTheseApps -PropertyType MultiString -Force | Out-Null
        New-ItemProperty -Path $AppPrivacy -Name LetAppsAccessCallHistory_UserInControlOfTheseApps -PropertyType MultiString -Force | Out-Null
        # Prevent apps from accessing camera
        New-ItemProperty -Path $AppPrivacy -Name LetAppsAccessCamera -Value "2" -PropertyType DWORD -Force | Out-Null
        New-ItemProperty -Path $AppPrivacy -Name LetAppsAccessCamera_ForceAllowTheseApps -PropertyType MultiString -Force | Out-Null
        New-ItemProperty -Path $AppPrivacy -Name LetAppsAccessCamera_ForceDenyTheseApps -PropertyType MultiString -Force | Out-Null
        New-ItemProperty -Path $AppPrivacy -Name LetAppsAccessCamera_UserInControlOfTheseApps -PropertyType MultiString -Force | Out-Null
        # Prevent apps from accessing contacts
        New-ItemProperty -Path $AppPrivacy -Name LetAppsAccessContacts -Value "2" -PropertyType DWORD -Force | Out-Null
        New-ItemProperty -Path $AppPrivacy -Name LetAppsAccessContacts_ForceAllowTheseApps -PropertyType MultiString -Force | Out-Null
        New-ItemProperty -Path $AppPrivacy -Name LetAppsAccessContacts_ForceDenyTheseApps -PropertyType MultiString -Force | Out-Null
        New-ItemProperty -Path $AppPrivacy -Name LetAppsAccessContacts_UserInControlOfTheseApps -PropertyType MultiString -Force | Out-Null
        # Prevent apps from accessing email
        New-ItemProperty -Path $AppPrivacy -Name LetAppsAccessEmail -Value "2" -PropertyType DWORD -Force | Out-Null
        New-ItemProperty -Path $AppPrivacy -Name LetAppsAccessEmail_ForceAllowTheseApps -PropertyType MultiString -Force | Out-Null
        New-ItemProperty -Path $AppPrivacy -Name LetAppsAccessEmail_ForceDenyTheseApps -PropertyType MultiString -Force | Out-Null
        New-ItemProperty -Path $AppPrivacy -Name LetAppsAccessEmail_UserInControlOfTheseApps -PropertyType MultiString -Force | Out-Null
        # Prevent apps from accessing gaze input
        New-ItemProperty -Path $AppPrivacy -Name LetAppsAccessGazeInput -Value "2" -PropertyType DWORD -Force | Out-Null
        New-ItemProperty -Path $AppPrivacy -Name LetAppsAccessGazeInput_ForceAllowTheseApps -PropertyType MultiString -Force | Out-Null
        New-ItemProperty -Path $AppPrivacy -Name LetAppsAccessGazeInput_ForceDenyTheseApps -PropertyType MultiString -Force | Out-Null
        New-ItemProperty -Path $AppPrivacy -Name LetAppsAccessGazeInput_UserInControlOfTheseApps -PropertyType MultiString -Force | Out-Null
        # Prevent apps from accessing location
        New-ItemProperty -Path $AppPrivacy -Name LetAppsAccessLocation -Value "2" -PropertyType DWORD -Force | Out-Null
        New-ItemProperty -Path $AppPrivacy -Name LetAppsAccessLocation_ForceAllowTheseApps -PropertyType MultiString -Force | Out-Null
        New-ItemProperty -Path $AppPrivacy -Name LetAppsAccessLocation_ForceDenyTheseApps -PropertyType MultiString -Force | Out-Null
        New-ItemProperty -Path $AppPrivacy -Name LetAppsAccessLocation_UserInControlOfTheseApps -PropertyType MultiString -Force | Out-Null
        # Prevent apps from accessing messaging
        New-ItemProperty -Path $AppPrivacy -Name LetAppsAccessMessaging -Value "2" -PropertyType DWORD -Force | Out-Null
        New-ItemProperty -Path $AppPrivacy -Name LetAppsAccessMessaging_ForceAllowTheseApps -PropertyType MultiString -Force | Out-Null
        New-ItemProperty -Path $AppPrivacy -Name LetAppsAccessMessaging_ForceDenyTheseApps -PropertyType MultiString -Force | Out-Null
        New-ItemProperty -Path $AppPrivacy -Name LetAppsAccessMessaging_UserInControlOfTheseApps -PropertyType MultiString -Force | Out-Null
        # Prevent apps from accessing microphone
        New-ItemProperty -Path $AppPrivacy -Name LetAppsAccessMicrophone -Value "2" -PropertyType DWORD -Force | Out-Null
        New-ItemProperty -Path $AppPrivacy -Name LetAppsAccessMicrophone_ForceAllowTheseApps -PropertyType MultiString -Force | Out-Null
        New-ItemProperty -Path $AppPrivacy -Name LetAppsAccessMicrophone_ForceDenyTheseApps -PropertyType MultiString -Force | Out-Null
        New-ItemProperty -Path $AppPrivacy -Name LetAppsAccessMicrophone_UserInControlOfTheseApps -PropertyType MultiString -Force | Out-Null
        # Prevent apps from accessing motion
        New-ItemProperty -Path $AppPrivacy -Name LetAppsAccessMotion -Value "2" -PropertyType DWORD -Force | Out-Null
        New-ItemProperty -Path $AppPrivacy -Name LetAppsAccessMotion_ForceAllowTheseApps -PropertyType MultiString -Force | Out-Null
        New-ItemProperty -Path $AppPrivacy -Name LetAppsAccessMotion_ForceDenyTheseApps -PropertyType MultiString -Force | Out-Null
        New-ItemProperty -Path $AppPrivacy -Name LetAppsAccessMotion_UserInControlOfTheseApps -PropertyType MultiString -Force | Out-Null
        # Prevent apps from accessing notifications
        New-ItemProperty -Path $AppPrivacy -Name LetAppsAccessNotifications -Value "2" -PropertyType DWORD -Force | Out-Null
        New-ItemProperty -Path $AppPrivacy -Name LetAppsAccessNotifications_ForceAllowTheseApps -PropertyType MultiString -Force | Out-Null
        New-ItemProperty -Path $AppPrivacy -Name LetAppsAccessNotifications_ForceDenyTheseApps -PropertyType MultiString -Force | Out-Null
        New-ItemProperty -Path $AppPrivacy -Name LetAppsAccessNotifications_UserInControlOfTheseApps -PropertyType MultiString -Force | Out-Null
        # Prevent apps from accessing phone
        New-ItemProperty -Path $AppPrivacy -Name LetAppsAccessPhone -Value "2" -PropertyType DWORD -Force | Out-Null
        New-ItemProperty -Path $AppPrivacy -Name LetAppsAccessPhone_ForceAllowTheseApps -PropertyType MultiString -Force | Out-Null
        New-ItemProperty -Path $AppPrivacy -Name LetAppsAccessPhone_ForceDenyTheseApps -PropertyType MultiString -Force | Out-Null
        New-ItemProperty -Path $AppPrivacy -Name LetAppsAccessPhone_UserInControlOfTheseApps -PropertyType MultiString -Force | Out-Null
        # Prevent apps from accessing radios
        New-ItemProperty -Path $AppPrivacy -Name LetAppsAccessRadios -Value "2" -PropertyType DWORD -Force | Out-Null
        New-ItemProperty -Path $AppPrivacy -Name LetAppsAccessRadios_ForceAllowTheseApps -PropertyType MultiString -Force | Out-Null
        New-ItemProperty -Path $AppPrivacy -Name LetAppsAccessRadios_ForceDenyTheseApps -PropertyType MultiString -Force | Out-Null
        New-ItemProperty -Path $AppPrivacy -Name LetAppsAccessRadios_UserInControlOfTheseApps -PropertyType MultiString -Force | Out-Null
        # Prevent apps from accessing tasks
        New-ItemProperty -Path $AppPrivacy -Name LetAppsAccessTasks -Value "2" -PropertyType DWORD -Force | Out-Null
        New-ItemProperty -Path $AppPrivacy -Name LetAppsAccessTasks_ForceAllowTheseApps -PropertyType MultiString -Force | Out-Null
        New-ItemProperty -Path $AppPrivacy -Name LetAppsAccessTasks_ForceDenyTheseApps -PropertyType MultiString -Force | Out-Null
        New-ItemProperty -Path $AppPrivacy -Name LetAppsAccessTasks_UserInControlOfTheseApps -PropertyType MultiString -Force | Out-Null
        # Prevent apps from accessing trusted devices
        New-ItemProperty -Path $AppPrivacy -Name LetAppsAccessTrustedDevices -Value "2" -PropertyType DWORD -Force | Out-Null
        New-ItemProperty -Path $AppPrivacy -Name LetAppsAccessTrustedDevices_ForceAllowTheseApps -PropertyType MultiString -Force | Out-Null
        New-ItemProperty -Path $AppPrivacy -Name LetAppsAccessTrustedDevices_ForceDenyTheseApps -PropertyType MultiString -Force | Out-Null
        New-ItemProperty -Path $AppPrivacy -Name LetAppsAccessTrustedDevices_UserInControlOfTheseApps -PropertyType MultiString -Force | Out-Null
        # Prevent apps from activating with voice
        New-ItemProperty -Path $AppPrivacy -Name LetAppsActivateWithVoice -Value "2" -PropertyType DWORD -Force | Out-Null
        # Prevent apps from activating with voice while locked
        New-ItemProperty -Path $AppPrivacy -Name LetAppsActivateWithVoiceAboveLock -Value "2" -PropertyType DWORD -Force | Out-Null
        # Prevent apps from accessing diagnostic info
        New-ItemProperty -Path $AppPrivacy -Name LetAppsGetDiagnosticInfo -Value "2" -PropertyType DWORD -Force | Out-Null
        New-ItemProperty -Path $AppPrivacy -Name LetAppsGetDiagnosticInfo_ForceAllowTheseApps -PropertyType MultiString -Force | Out-Null
        New-ItemProperty -Path $AppPrivacy -Name LetAppsGetDiagnosticInfo_ForceDenyTheseApps -PropertyType MultiString -Force | Out-Null
        New-ItemProperty -Path $AppPrivacy -Name LetAppsGetDiagnosticInfo_UserInControlOfTheseApps -PropertyType MultiString -Force | Out-Null
        # Prevent apps from running in the background by default
        # Force allow some apps to run in the background
        New-ItemProperty -Path $AppPrivacy -Name LetAppsRunInBackground -Value "2" -PropertyType DWORD -Force | Out-Null
        New-ItemProperty -Path $AppPrivacy -Name LetAppsRunInBackground_ForceAllowTheseApps -Value "$ForceAllowBackgroundApps" -PropertyType MultiString -Force | Out-Null
        New-ItemProperty -Path $AppPrivacy -Name LetAppsRunInBackground_ForceDenyTheseApps -PropertyType MultiString -Force | Out-Null
        New-ItemProperty -Path $AppPrivacy -Name LetAppsRunInBackground_UserInControlOfTheseApps -PropertyType MultiString -Force | Out-Null
        # Prevent apps from syncing across devices
        New-ItemProperty -Path $AppPrivacy -Name LetAppsSyncWithDevices -Value "2" -PropertyType DWORD -Force | Out-Null
        New-ItemProperty -Path $AppPrivacy -Name LetAppsSyncWithDevices_ForceAllowTheseApps -PropertyType MultiString -Force | Out-Null
        New-ItemProperty -Path $AppPrivacy -Name LetAppsSyncWithDevices_ForceDenyTheseApps -PropertyType MultiString -Force | Out-Null
        New-ItemProperty -Path $AppPrivacy -Name LetAppsSyncWithDevices_UserInControlOfTheseApps -PropertyType MultiString -Force | Out-Null
    }

    if (!(Test-Path $AppPrivacy)) {
        New-Item -Path $AppPrivacy -Force | Out-Null
        ConfigureAppPrivacyRegistry
    }
    else {
        ConfigureAppPrivacyRegistry
    }
}

# Install applications
function InstallApplications {
    # Prompts
    $InstallChocolatey = Read-Host 'Install Chocolatey? y/n '
    $InstallShellCheck = Read-Host 'Install ShellCheck? y/n '
    $InstallNotepadPlusPlus = Read-Host 'Install Notepad++? y/n '
    $Install7Zip = Read-Host 'Install 7Zip? y/n '
    $InstallNMap = Read-Host 'Install Nmap? y/n '
    $InstallQBittorent = Read-Host 'Install QBittorent? y/n '
    $InstallRufus = Read-Host 'Install Rufus? y/n '
    $InstallEtcher = Read-Host 'Install Etcher? y/n '
    $InstallGimp = Read-Host 'Install Gimp? y/n '
    $InstallGit = Read-Host 'Install Git? y/n '
    $InstallVlc = Read-Host 'Install Vlc? Enter n if you want to install the windows store version. y/n '
    $InstallBlender = Read-Host 'Install Blender? Enter n if you want to install the windows store version. y/n '
    $InstallBitwarden = Read-Host 'Install Bitwarden? Enter n if you want to install the windows store version. y/n '
    $InstallWinSCP = Read-Host 'Install WinSCP? y/n '
    $InstallPutty = Read-Host 'Install Putty? y/n '
    $InstallPython = Read-Host 'Install Python? Enter n if you want to install the windows store version. y/n '
    $InstallLibreoffice = Read-Host 'Install Libreoffice? y/n '
    $InstallJava = Read-Host 'Install Java? y/n '
    $InstallSysinternals = Read-Host 'Install Sysinternals? y/n '
    $InstallVSCode = Read-Host 'Install VsCode? y/n '
    $InstallWireshark = Read-Host 'Install Wireshark? y/n '
    $InstallOpenJDK = Read-Host 'Install OpenJDK? y/n '
    $InstallTinyNvidiaUpdater = Read-Host 'Install TinyNvidiaUpdater? y/n '
    $InstallFirefox = Read-Host 'Install Firefox? y/n '
    $InstallChrome = Read-Host 'Install Chrome? y/n '
    $InstallFreeFileSync = Read-Host 'Install FreeFileSync? y/n '
    $InstallVmwarePlayer = Read-Host 'Install VmwarePlayer? y/n '
    $InstallNvidiaProfileInspector = Read-Host 'Install NvidiaProfileInspector? y/n '
    $InstallSteam = Read-Host 'Install Steam? y/n '
    $InstallOrigin = Read-Host 'Install Origin? y/n '
    $InstallGOG = Read-Host 'Install GOG? y/n '
    $InstallEpicStore = Read-Host 'Install EpicStore? y/n '
    $InstallBethesdaLauncher = Read-Host 'Install BethesdaLauncher? y/n '
    $InstallBorderlessGaming = Read-Host 'Install BorderlessGaming? y/n '
    $InstallDiscord = Read-Host 'Install Discord? y/n '
    $InstallFedoraMediaWriter = Read-Host 'Install FedoraMediaWriter? y/n '
    $InstallVisualStudioCommunity = Read-Host 'Install VisualStudioCommunity? y/n '
    $InstallOpenVPN = Read-Host 'Install OpenVPN? y/n '
    $InstallTwitch = Read-Host 'Install Twitch? y/n '
    $InstallVortex = Read-Host 'Install Vortex? y/n '
    $InstallVisualRedistributables = Read-Host 'Install Visual C++ Redistributables? y/n '
    $InstallRockstarLauncher = Read-Host 'Install RockstarLauncher? y/n '
    $InstallRPGMakerRTPs = Read-Host 'Install RPGMaker RTPs? y/n '
    $InstallGolang = Read-Host 'Install Go programming language? y/n '

    # Install chocolatey
    if ($InstallChocolatey -eq 'y') {
        Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
    }

    # Install shellcheck
    if ($InstallShellCheck -eq 'y') {
        choco install shellcheck
    }

    # Install notepad++
    if ($InstallNotepadPlusPlus -eq 'y') {
        Read-Host 'A web browser will be opened.  Download notepad++ into the downloads folder. Press enter to begin '
        Start-Process 'https://notepad-plus-plus.org/downloads/' -PassThru -Wait
        Read-Host 'Press enter when downloads are complete '
        Start-Process -FilePath "$HOME\Downloads\npp*.exe" -PassThru -Wait
    }

    # Install 7zip
    if ($Install7Zip -eq 'y') {
        Read-Host 'A web browser will be opened.  Download 7zip 32 bit and 64 bit into the downloads folder. Press enter to begin '
        Start-Process 'https://www.7-zip.org/download.html' -PassThru -Wait
        Read-Host 'Press enter when downloads are complete '
        New-Item -ItemType Directory -Force -Path "$HOME\Downloads\7zip_64_bit"
        Move-Item -Path "$HOME\Downloads\7z*x64.exe" -Destination "$HOME\Downloads\7zip_64_bit\7zip_x64.exe"
        Start-Process -FilePath "$HOME\Downloads\7z*.exe" -PassThru -Wait
        Start-Process -FilePath "$HOME\Downloads\7zip_64_bit\7z*x64.exe" -PassThru -Wait
    }

    # Install nmap
    if ($InstallNMap -eq 'y') {
        Read-Host 'A web browser will be opened.  Download nmap into the downloads folder. Press enter to begin '
        Start-Process 'https://nmap.org/download.html' -PassThru -Wait
        Read-Host 'Press enter when downloads are complete '
        Start-Process -FilePath "$HOME\Downloads\nmap*.exe" -PassThru -Wait
    }

    # Install qbittorrent
    if ($InstallQBittorent -eq 'y') {
        Read-Host 'A web browser will be opened.  Download qbittorrent into the downloads folder. Press enter to begin '
        Start-Process 'https://www.qbittorrent.org/download.php' -PassThru -Wait
        Read-Host 'Press enter when downloads are complete '
        Start-Process -FilePath "$HOME\Downloads\qbittorrent*.exe" -PassThru -Wait
    }

    # Install rufus
    if ($InstallRufus -eq 'y') {
        Read-Host 'A web browser will be opened.  Download rufus into the downloads folder. Press enter to begin '
        Start-Process 'https://rufus.ie/' -PassThru -Wait
        Read-Host 'Press enter when downloads are complete '
        Rename-Item -Path "$HOME\Downloads\rufus*.exe" -NewName 'rufus.exe'
        New-Item -ItemType Directory -Force -Path 'C:\Program Files\Rufus'
        Move-Item -Path "$HOME\Downloads\rufus.exe" -Destination 'C:\Program Files\Rufus\rufus.exe'
        # Create shortcut
        $WScriptShell = New-Object -ComObject WScript.Shell
        $Shortcut = $WScriptShell.CreateShortcut('C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Rufus.lnk')
        $Shortcut.WorkingDirectory = 'C:\Program Files\Rufus'
        $Shortcut.TargetPath = 'C:\Program Files\Rufus\rufus.exe'
        $Shortcut.Save()
    }

    # Install etcher
    if ($InstallEtcher -eq 'y') {
        Read-Host 'A web browser will be opened.  Download etcher into the downloads folder. Press enter to begin '
        Start-Process 'https://www.balena.io/etcher/' -PassThru -Wait
        Read-Host 'Press enter when downloads are complete '
        Start-Process -FilePath "$HOME\Downloads\balenaetcher*.exe" -PassThru -Wait
    }

    # Install gimp
    if ($InstallGimp -eq 'y') {
        Read-Host 'A web browser will be opened.  Download gimp into the downloads folder. Press enter to begin '
        Start-Process 'https://www.gimp.org/downloads/' -PassThru -Wait
        Read-Host 'Press enter when downloads are complete '
        Start-Process -FilePath "$HOME\Downloads\gimp*.exe" -PassThru -Wait
    }

    # Install git
    if ($InstallGit -eq 'y') {
        Read-Host 'A web browser will be opened.  Download git into the downloads folder. Press enter to begin '
        Start-Process 'https://git-scm.com/downloads' -PassThru -Wait
        Read-Host 'Press enter when downloads are complete '
        Start-Process -FilePath "$HOME\Downloads\git*.exe" -PassThru -Wait
    }

    # Install vlc
    if ($InstallVlc -eq 'y') {
        Read-Host 'A web browser will be opened.  Download vlc into the downloads folder. Press enter to begin '
        Start-Process 'https://www.videolan.org/vlc/download-windows.html' -PassThru -Wait
        Read-Host 'Press enter when downloads are complete '
        Start-Process -FilePath "$HOME\Downloads\vlc*.exe" -PassThru -Wait
    }

    # Install blender
    if ($InstallBlender -eq 'y') {
        Read-Host 'A web browser will be opened.  Download blender into the downloads folder. Press enter to begin '
        Start-Process 'https://www.blender.org/download/' -PassThru -Wait
        Read-Host 'Press enter when downloads are complete '
        Start-Process -FilePath "$HOME\Downloads\blender*.msi" -PassThru -Wait
    }

    # Install bitwarden
    if ($InstallBitwarden -eq 'y') {
        Invoke-WebRequest 'https://vault.bitwarden.com/download/?app=desktop&platform=windows' -OutFile "$HOME\Downloads\bitwarden_installer.exe"
        Start-Process -FilePath "$HOME\Downloads\bitwarden_installer.exe" -PassThru -Wait
    }

    # Install winscp
    if ($InstallWinSCP -eq 'y') {
        Read-Host 'A web browser will be opened.  Download winscp into the downloads folder. Press enter to begin '
        Start-Process 'https://winscp.net/eng/download.php' -PassThru -Wait
        Read-Host 'Press enter when downloads are complete '
        Start-Process -FilePath "$HOME\Downloads\winscp*.exe" -PassThru -Wait
    }

    # Install putty
    if ($InstallPutty -eq 'y') {
        Read-Host 'A web browser will be opened.  Download putty into the downloads folder. Press enter to begin '
        Start-Process 'https://www.chiark.greenend.org.uk/~sgtatham/putty/latest.html' -PassThru -Wait
        Read-Host 'Press enter when downloads are complete '
        Start-Process -FilePath "$HOME\Downloads\putty*.msi" -PassThru -Wait
    }

    # Install python
    if ($InstallPython -eq 'y') {
        Read-Host 'A web browser will be opened.  Download python into the downloads folder. Press enter to begin '
        Start-Process 'https://www.python.org/downloads/windows/' -PassThru -Wait
        Read-Host 'Press enter when downloads are complete '
        Start-Process -FilePath "$HOME\Downloads\python*.exe" -PassThru -Wait
        # Reload PATH
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")

        # Configure Python
        # Update pip
        python -m pip install -U pip
        # Install pylint
        pip install pylint
    }

    # Install libreoffice
    if ($InstallLibreoffice -eq 'y') {
        Read-Host 'A web browser will be opened.  Download libreoffice fresh into the downloads folder. Press enter to begin '
        Start-Process 'https://www.libreoffice.org/download/download/' -PassThru -Wait
        Read-Host 'Press enter when downloads are complete '
        Start-Process -FilePath "$HOME\Downloads\libreoffice*.msi" -PassThru -Wait
    }

    # Install java
    if ($InstallJava -eq 'y') {
        Read-Host 'A web browser will be opened.  Download java 64 bit into the downloads folder. Press enter to begin '
        Start-Process 'https://www.java.com/en/download/manual.jsp' -PassThru -Wait
        Read-Host 'Press enter when downloads are complete '
        Start-Process -FilePath "$HOME\Downloads\jre*.exe" -PassThru -Wait
    }

    # Install sysinternals
    if ($InstallSysinternals -eq 'y') {
        Invoke-WebRequest 'https://download.sysinternals.com/files/SysinternalsSuite.zip' -OutFile "$HOME\Downloads\SysinternalsSuite.zip"
        # Extract zip folder
        Expand-Archive -LiteralPath "$HOME\Downloads\SysinternalsSuite.zip" -DestinationPath 'C:\Program Files\SysinternalsSuite'
        # Create shortcut
        $WScriptShell = New-Object -ComObject WScript.Shell
        $Shortcut = $WScriptShell.CreateShortcut('C:\ProgramData\Microsoft\Windows\Start Menu\Programs\SysinternalsSuite.lnk')
        $Shortcut.WorkingDirectory = 'C:\Program Files\SysinternalsSuite'
        $Shortcut.TargetPath = 'C:\Program Files\SysinternalsSuite'
        $Shortcut.Save()
    }

    # Install vscode
    if ($InstallVSCode -eq 'y') {
        Invoke-WebRequest 'https://aka.ms/win32-x64-user-stable' -OutFile "$HOME\Downloads\vscode_installer.exe"
        Start-Process -FilePath "$HOME\Downloads\vscode_installer.exe" -PassThru -Wait -Verb
    }

    # Install wireshark
    if ($InstallWireshark -eq 'y') {
        Read-Host 'A web browser will be opened.  Download wireshark into the downloads folder. Press enter to begin '
        Start-Process 'https://www.wireshark.org/#download' -PassThru -Wait
        Read-Host 'Press enter when downloads are complete '
        Start-Process -FilePath "$HOME\Downloads\wireshark*.exe" -PassThru -Wait
    }

    # Install openjdk
    if ($InstallOpenJDK -eq 'y') {
        Read-Host 'A web browser will be opened.  Download openjdk into the downloads folder. Press enter to begin '
        Start-Process 'https://adoptopenjdk.net/' -PassThru -Wait
        Read-Host 'Press enter when downloads are complete '
        Start-Process -FilePath "$HOME\Downloads\openjdk*.msi" -PassThru -Wait
    }

    # Install tinynvidiaupdater
    if ($InstallTinyNvidiaUpdater -eq 'y') {
        Read-Host 'A web browser will be opened.  Download tinynvidiaupdater into the downloads folder. Press enter to begin '
        Start-Process 'https://github.com/ElPumpo/TinyNvidiaUpdateChecker/releases' -PassThru -Wait
        Read-Host 'Press enter when downloads are complete '
        Rename-Item -Path "$HOME\Downloads\TinyNvidiaUpdateChecker*.exe" -NewName 'TinyNvidiaUpdateChecker.exe'
        New-Item -ItemType Directory -Force -Path 'C:\Program Files\TinyNvidiaUpdateChecker'
        Move-Item -Path "$HOME\Downloads\TinyNvidiaUpdateChecker.exe" -Destination 'C:\Program Files\TinyNvidiaUpdateChecker\TinyNvidiaUpdateChecker.exe'
        # Create shortcut
        $WScriptShell = New-Object -ComObject WScript.Shell
        $Shortcut = $WScriptShell.CreateShortcut('C:\ProgramData\Microsoft\Windows\Start Menu\Programs\TinyNvidiaUpdateChecker.lnk')
        $Shortcut.WorkingDirectory = 'C:\Program Files\TinyNvidiaUpdateChecker'
        $Shortcut.TargetPath = 'C:\Program Files\TinyNvidiaUpdateChecker\TinyNvidiaUpdateChecker.exe'
        $Shortcut.Save()
    }

    # Install firefox
    if ($InstallFirefox -eq 'y') {
        Invoke-WebRequest 'https://download.mozilla.org/?product=firefox-msi-latest-ssl&os=win64&lang=en-US' -OutFile "$HOME\Downloads\firefox.msi"
        Start-Process -FilePath "$HOME\Downloads\firefox.msi" -PassThru -Wait
    }

    # Install chrome
    if ($InstallChrome -eq 'y') {
        Invoke-WebRequest 'https://dl.google.com/chrome/install/latest/chrome_installer.exe' -OutFile "$HOME\Downloads\chrome_installer.exe"
        Start-Process -FilePath "$HOME\Downloads\chrome_installer.exe" -PassThru -Wait
    }

    # Install freefilesync
    if ($InstallFreeFileSync -eq 'y') {
        Read-Host 'A web browser will be opened.  Download freefilesync into the downloads folder. Press enter to begin '
        Start-Process 'https://freefilesync.org/download.php' -PassThru -Wait
        Read-Host 'Press enter when downloads are complete '
        Start-Process -FilePath "$HOME\Downloads\FreeFileSync*.exe" -PassThru -Wait
    }

    # Install vmware player
    if ($InstallVmwarePlayer -eq 'y') {
        Invoke-WebRequest 'https://www.vmware.com/go/getplayer-win' -OutFile "$HOME\Downloads\vmware_player_setup.exe"
        Start-Process -FilePath "$HOME\Downloads\vmware_player_setup.exe" -PassThru -Wait
    }

    # Install nvidiaprofileinspector
    if ($InstallNvidiaProfileInspector -eq 'y') {
        Read-Host 'A web browser will be opened.  Download nvidiaprofileinspector into the downloads folder. Press enter to begin '
        Start-Process 'https://github.com/Orbmu2k/nvidiaProfileInspector/releases' -PassThru -Wait
        Read-Host 'Press enter when downloads are complete '
        # Extract zip folder
        Expand-Archive -LiteralPath "$HOME\Downloads\nvidiaProfileInspector.zip" -DestinationPath 'C:\Program Files\NvidiaProfileInspector'
        # Create shortcut
        $WScriptShell = New-Object -ComObject WScript.Shell
        $Shortcut = $WScriptShell.CreateShortcut('C:\ProgramData\Microsoft\Windows\Start Menu\Programs\NvidiaProfileInspector.lnk')
        $Shortcut.WorkingDirectory = 'C:\Program Files\NvidiaProfileInspector'
        $Shortcut.TargetPath = 'C:\Program Files\NvidiaProfileInspector\nvidiaProfileInspector.exe'
        $Shortcut.Save()
    }

    # Install steam
    if ($InstallSteam -eq 'y') {
        Invoke-WebRequest 'https://steamcdn-a.akamaihd.net/client/installer/SteamSetup.exe' -OutFile "$HOME\Downloads\steam_setup.exe"
        Start-Process -FilePath "$HOME\Downloads\steam_setup.exe" -PassThru -Wait
    }

    # Install origin
    if ($InstallOrigin -eq 'y') {
        Invoke-WebRequest 'https://www.dm.origin.com/download' -OutFile "$HOME\Downloads\origin_setup.exe"
        Start-Process -FilePath "$HOME\Downloads\origin_setup.exe" -PassThru -Wait
    }

    # Install gog
    if ($InstallGOG -eq 'y') {
        Read-Host 'A web browser will be opened.  Download gog into the downloads folder. Press enter to begin '
        Start-Process 'https://www.gog.com/galaxy' -PassThru -Wait
        Read-Host 'Press enter when downloads are complete '
        Start-Process -FilePath "$HOME\Downloads\gog_galaxy*.exe" -PassThru -Wait
    }

    # Install epicstore
    if ($InstallEpicStore -eq 'y') {
        Invoke-WebRequest 'https://launcher-public-service-prod06.ol.epicgames.com/launcher/api/installer/download/EpicGamesLauncherInstaller.msi' -OutFile "$HOME\Downloads\epic_setup.exe"
        Start-Process -FilePath "$HOME\Downloads\epic_setup.exe" -PassThru -Wait
    }

    # Install bethesdalauncher
    if ($InstallBethesdaLauncher -eq 'y') {
        Invoke-WebRequest 'https://download.cdp.bethesda.net/BethesdaNetLauncher_Setup.exe' -OutFile "$HOME\Downloads\bethesda_setup.exe"
        Start-Process -FilePath "$HOME\Downloads\bethesda_setup.exe" -PassThru -Wait
    }

    # Install BorderlessGaming
    if ($InstallBorderlessGaming -eq 'y') {
        Read-Host 'A web browser will be opened.  Download borderlessgaming into the downloads folder. Press enter to begin '
        Start-Process 'https://github.com/Codeusa/Borderless-Gaming/releases' -PassThru -Wait
        Read-Host 'Press enter when downloads are complete '
        Start-Process -FilePath "$HOME\Downloads\borderlessgaming*.exe" -PassThru -Wait
    }

    # Install Discord
    if ($InstallDiscord -eq 'y') {
        Invoke-WebRequest 'https://discordapp.com/api/download?platform=win' -OutFile "$HOME\Downloads\discord_setup.exe"
        Start-Process -FilePath "$HOME\Downloads\discord_setup.exe" -PassThru -Wait
    }

    # Install FedoraMediaWriter
    if ($InstallFedoraMediaWriter -eq 'y') {
        Read-Host 'A web browser will be opened.  Download fedoramediawriter into the downloads folder. Press enter to begin '
        Start-Process 'https://getfedora.org/en/workstation/download/' -PassThru -Wait
        Read-Host 'Press enter when downloads are complete '
        Start-Process -FilePath "$HOME\Downloads\fedoramedia*.exe" -PassThru -Wait
    }

    # Install Visual Studio Community
    if ($InstallVisualStudioCommunity -eq 'y') {
        Read-Host 'A web browser will be opened.  Download visual studio community into downloads folder. Press enter to begin '
        Start-Process 'https://visualstudio.microsoft.com/vs/community/' -PassThru -Wait
        Read-Host 'Press enter when download is complete '
        Start-Process -FilePath "$HOME\Downloads\vs_community*.exe" -PassThru -Wait
    }

    # Install OpenVPN
    if ($InstallOpenVPN -eq 'y') {
        Read-Host 'A web browser will be opened.  Download openvpn into the downloads folder. Press enter to begin '
        Start-Process 'https://openvpn.net/community-downloads/' -PassThru -Wait
        Read-Host 'Press enter when downloads are complete '
        Start-Process -FilePath "$HOME\Downloads\openvpn*.exe" -PassThru -Wait
    }

    # Install Twitch
    if ($InstallTwitch -eq 'y') {
        Invoke-WebRequest 'https://desktop.twitchsvc.net/installer/windows/TwitchSetup.exe' -OutFile "$HOME\Downloads\twitch_setup.exe"
        Start-Process -FilePath "$HOME\Downloads\twitch_setup.exe" -PassThru -Wait
    }

    # Install Vortex
    if ($InstallVortex -eq 'y') {
        Read-Host 'A web browser will be opened.  Download vortex into the downloads folder. Press enter to begin '
        Start-Process 'https://github.com/Nexus-Mods/Vortex/releases' -PassThru -Wait
        Read-Host 'Press enter when downloads are complete '
        Start-Process -FilePath "$HOME\Downloads\Vortex*.exe" -PassThru -Wait
    }

    # Install Visual C++ Redistributables
    if ($InstallVisualRedistributables -eq 'y') {
        Read-Host 'A web browser will be opened.  Download and install the Visual C++ Redistributables. Press enter to begin '
        Start-Process 'https://support.microsoft.com/en-us/help/2977003/the-latest-supported-visual-c-downloads' -PassThru -Wait
        Read-Host 'Press enter when finished installing '
    }

    # Install RockstarLauncher
    if ($InstallRockstarLauncher -eq 'y') {
        Read-Host 'A web browser will be opened.  Download the rockstar game launcher into the downloads folder. Press enter to begin '
        Start-Process 'https://socialclub.rockstargames.com/rockstar-games-launcher' -PassThru -Wait
        Read-Host 'Press enter when downloads are complete '
        Start-Process -FilePath "$HOME\Downloads\Rockstar*.exe" -PassThru -Wait
    }

    # Install rpgmaker rtps
    if ($InstallRPGMakerRTPs -eq 'y') {
        Read-Host 'A web browser will be opened.  Download all of the RPGMaker RTPs into the downloads folder. Press enter to begin '
        Start-Process 'https://www.rpgmakerweb.com/download/additional/run-time-packages' -PassThru -Wait
        Read-Host 'Press enter when downloads are complete '
        Start-Process -FilePath "$HOME\Downloads\RPGVXAce*.exe" -PassThru -Wait
    }

    # Install Golang
    if ($InstallGolang -eq 'y') {
        Read-Host 'A web browser will be opened.  Download the Golang binary into the downloads folder. Press enter to begin '
        Start-Process 'https://golang.org/dl/' -PassThru -Wait
        Read-Host 'Press enter when downloads are complete '
        Start-Process -FilePath "$HOME\Downloads\go*.windows-amd64.msi" -PassThru -Wait
    }

    # Install windows store apps
    Read-Host 'Windows store will be opened.  Install any windows store apps used. Press enter to begin '
    Start-Process 'ms-windows-store://pdp'
    Read-Host 'Press enter when finished installing windows store apps '
}

# To Update all installed choclatey packages use command:
# choco upgrade all

function ConfigureNTP {
    # NTP client registry folder
    $NTPClient = "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\W32time\TimeProviders\NtpClient"
    # NTP parameters registry folder
    $NTPParameters = "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\W32time\Parameters"

    function ConfigureNTPClient {
        # Enable NTP client
        New-ItemProperty -Path $NTPClient -Name Enabled -Value "1" -PropertyType DWORD -Force | Out-Null
    }

    # Configure NTP client
    if (!(Test-Path $NTPClient)) {
        New-Item -Path $NTPClient -Force | Out-Null
        ConfigureNTPClient
    }
    else {
        ConfigureNTPClient
    }

    function ConfigureNTPParameters {
        # Set NTP server domain
        New-ItemProperty -Path $NTPParameters -Name NtpServer -Value 'time.windows.com,0x9' -PropertyType String -Force | Out-Null
        # Set NTP protocol type
        New-ItemProperty -Path $NTPParameters -Name 'Type' -Value 'NTP' -PropertyType String -Force | Out-Null
    }

    # Configure NTP parameters
    if (!(Test-Path $NTPParameters)) {
        New-Item -Path $NTPParameters -Force | Out-Null
        ConfigureNTPParameters
    }
    else {
        ConfigureNTPParameters
    }

}

# Calling Functions
if ($DisableCortana -eq 'y') {
    DisableCortana
}
if ($DisableTelemetry -eq 'y') {
    DisableTelemetry
}
if ($ConfigureFirewall -eq 'y') {
    ConfigureFirewall
}
if ($RemoveApplications -eq 'y') {
    RemoveApplications
}
if ($ConfigureAppPrivacy -eq 'y') {
    ConfigureAppPrivacy
}
if ($ConfigureNTP -eq 'y') {
    ConfigureNTP
}
if ($InstallApplications -eq 'y') {
    InstallApplications
}
