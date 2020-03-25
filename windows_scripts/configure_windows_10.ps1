# Script to confgure settings in Windows 10

# Prompts
$ConfigureComputerNameVar = Read-Host 'Configure computer hostname? Requires running as admin. y/n '
if ($ConfigureComputerNameVar -eq 'y') {
    $ComputerName = Read-Host 'Enter computer hostname '
}
$ConfigurePowerOptionsVar = Read-Host 'Configure power options? Requires running as admin. y/n '
$DisableCortanaVar = Read-Host 'Disable Cortana? Requires running as admin. y/n '
$DisableTelemetryVar = Read-Host 'Disable Telemetry? Requires running as admin. y/n '
$ConfigureFirewallVar = Read-Host 'Configure Firewall? Requires running as admin. y/n '
$RemoveApplicationsVar = Read-Host 'Remove some of the default applications? Requires running as admin. y/n '
$ConfigureAppPrivacyVar = Read-Host 'Configure app privacy settings? Requires running as admin. y/n '
$ConfigureNTPVar = Read-Host 'Configure NTP? Requires running as admin. y/n '
$InstallFeaturesVar = Read-Host 'Install features? Requires running as admin. y/n '
$RemoveFeaturesVar = Read-Host 'Remove features? Requires running as admin. y/n '
$MapDrivesVar = Read-Host 'Map network drives? Requires running as a normal user. y/n '
$InstallApplicationsVar = Read-Host 'Install some applications? Requires running as admin. y/n '
if ($InstallApplicationsVar -eq 'y') {
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
    $InstallEdge = Read-Host 'Install Microsoft Edge? y/n '
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
    $InstallReolink = Read-Host 'Install reolink? y/n '
    $InstallUplay = Read-Host 'Install uplay? y/n '
    $InstallMicrosoftOffice = Read-Host 'Install Microsoft Office? y/n '
}

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

    Get-Service -Name $TelemetryService1 | Stop-Service -Force
    Get-Service -Name $TelemetryService1 | Set-Service -StartupType Disabled
}

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

    # Uninstall Onedrive
    if (Test-Path "$env:systemroot\System32\OneDriveSetup.exe") {
        Start-Process -FilePath "$env:systemroot\System32\OneDriveSetup.exe" /uninstall -Wait
    }
    if (Test-Path "$env:systemroot\SysWOW64\OneDriveSetup.exe") {
        Start-Process -FilePath "$env:systemroot\SysWOW64\OneDriveSetup.exe" /uninstall -Wait
    }
}

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

function InstallApplications {
    # Install chocolatey
    if ($InstallChocolatey -eq 'y') {
        Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
        # Reload PATH
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
    }

    # Install shellcheck
    if ($InstallShellCheck -eq 'y') {
        choco 'install' 'shellcheck' '-y'
    }

    # Install notepad++
    if ($InstallNotepadPlusPlus -eq 'y') {
        Read-Host 'A web browser will be opened.  Download notepad++ into the downloads folder. Press enter to begin '
        Start-Process 'https://notepad-plus-plus.org/downloads/' 
        Read-Host 'Press enter when downloads are complete '
        if (Get-AuthenticodeSignature -FilePath "$HOME\Downloads\npp*.exe" | Where-Object { $_.Status -eq "Valid" }) {
            Start-Process -FilePath "$HOME\Downloads\npp*.exe" -Wait
        }
        else {
            Read-Host "Signature is not valid, application will not be installed"
        }
    }

    # Install 7zip
    if ($Install7Zip -eq 'y') {
        Read-Host 'A web browser will be opened.  Download 7zip 32 bit and 64 bit into the downloads folder. Press enter to begin '
        Start-Process 'https://www.7-zip.org/download.html' 
        Read-Host 'Press enter when downloads are complete '
        New-Item -ItemType Directory -Force -Path "$HOME\Downloads\7zip_64_bit"
        Move-Item -Path "$HOME\Downloads\7z*x64.exe" -Destination "$HOME\Downloads\7zip_64_bit\7zip_x64.exe"
        Start-Process -FilePath "$HOME\Downloads\7z*.exe" -Wait
        Start-Process -FilePath "$HOME\Downloads\7zip_64_bit\7z*x64.exe" -Wait
    }

    # Install nmap
    if ($InstallNMap -eq 'y') {
        Read-Host 'A web browser will be opened.  Download nmap into the downloads folder. Press enter to begin '
        Start-Process 'https://nmap.org/download.html' 
        Read-Host 'Press enter when downloads are complete '
        if (Get-AuthenticodeSignature -FilePath "$HOME\Downloads\nmap*.exe" | Where-Object { $_.Status -eq "Valid" }) {
            Start-Process -FilePath "$HOME\Downloads\nmap*.exe" -Wait
        }
        else {
            Read-Host "Signature is not valid, application will not be installed"
        }
    }

    # Install qbittorrent
    if ($InstallQBittorent -eq 'y') {
        Read-Host 'A web browser will be opened.  Download qbittorrent into the downloads folder. Press enter to begin '
        Start-Process 'https://www.qbittorrent.org/download.php' 
        Read-Host 'Press enter when downloads are complete '
        Start-Process -FilePath "$HOME\Downloads\qbittorrent*.exe" -Wait
    }

    # Install rufus
    if ($InstallRufus -eq 'y') {
        Read-Host 'A web browser will be opened.  Download rufus into the downloads folder. Press enter to begin '
        Start-Process 'https://rufus.ie/' 
        Read-Host 'Press enter when downloads are complete '
        Get-ChildItem "$HOME\Downloads\rufus*.exe" | Rename-Item -NewName 'rufus.exe'
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
        Start-Process 'https://www.balena.io/etcher/' 
        Read-Host 'Press enter when downloads are complete '
        if (Get-AuthenticodeSignature -FilePath "$HOME\Downloads\balenaetcher*.exe" | Where-Object { $_.Status -eq "Valid" }) {
            Start-Process -FilePath "$HOME\Downloads\balenaetcher*.exe" -Wait
        }
        else {
            Read-Host "Signature is not valid, application will not be installed"
        }
    }

    # Install gimp
    if ($InstallGimp -eq 'y') {
        Read-Host 'A web browser will be opened.  Download gimp into the downloads folder. Press enter to begin '
        Start-Process 'https://www.gimp.org/downloads/' 
        Read-Host 'Press enter when downloads are complete '
        if (Get-AuthenticodeSignature -FilePath "$HOME\Downloads\gimp*.exe" | Where-Object { $_.Status -eq "Valid" }) {
            Start-Process -FilePath "$HOME\Downloads\gimp*.exe" -Wait
        }
        else {
            Read-Host "Signature is not valid, application will not be installed"
        }
    }

    # Install git
    if ($InstallGit -eq 'y') {
        Read-Host 'A web browser will be opened.  Download git into the downloads folder. Press enter to begin '
        Start-Process 'https://git-scm.com/downloads' 
        Read-Host 'Press enter when downloads are complete '
        if (Get-AuthenticodeSignature -FilePath "$HOME\Downloads\git*.exe" | Where-Object { $_.Status -eq "Valid" }) {
            Start-Process -FilePath "$HOME\Downloads\git*.exe" -Wait
        }
        else {
            Read-Host "Signature is not valid, application will not be installed"
        }
        # Add ssh key
        Copy-Item 'N:\SSHConfigs\github\github_ssh' -Destination "$HOME\.ssh\id_rsa"
    }

    # Install vlc
    if ($InstallVlc -eq 'y') {
        Read-Host 'A web browser will be opened.  Download vlc into the downloads folder. Press enter to begin '
        Start-Process 'https://www.videolan.org/vlc/download-windows.html' 
        Read-Host 'Press enter when downloads are complete '
        if (Get-AuthenticodeSignature -FilePath "$HOME\Downloads\vlc*.exe" | Where-Object { $_.Status -eq "Valid" }) {
            Start-Process -FilePath "$HOME\Downloads\vlc*.exe" -Wait
        }
        else {
            Read-Host "Signature is not valid, application will not be installed"
        }
    }

    # Install blender
    if ($InstallBlender -eq 'y') {
        Read-Host 'A web browser will be opened.  Download blender into the downloads folder. Press enter to begin '
        Start-Process 'https://www.blender.org/download/' 
        Read-Host 'Press enter when downloads are complete '
        if (Get-AuthenticodeSignature -FilePath "$HOME\Downloads\blender*.msi" | Where-Object { $_.Status -eq "Valid" }) {
            Start-Process -FilePath "$HOME\Downloads\blender*.msi" -Wait
        }
        else {
            Read-Host "Signature is not valid, application will not be installed"
        }
    }

    # Install bitwarden
    if ($InstallBitwarden -eq 'y') {
        Invoke-WebRequest 'https://vault.bitwarden.com/download/?app=desktop&platform=windows' -OutFile "$HOME\Downloads\bitwarden_installer.exe"
        if (Get-AuthenticodeSignature -FilePath "$HOME\Downloads\bitwarden_installer.exe" | Where-Object { $_.Status -eq "Valid" }) {
            Start-Process -FilePath "$HOME\Downloads\bitwarden_installer.exe" -Wait
        }
        else {
            Read-Host "Signature is not valid, application will not be installed"
        }
    }

    # Install winscp
    if ($InstallWinSCP -eq 'y') {
        Read-Host 'A web browser will be opened.  Download winscp into the downloads folder. Press enter to begin '
        Start-Process 'https://winscp.net/eng/download.php' 
        Read-Host 'Press enter when downloads are complete '
        if (Get-AuthenticodeSignature -FilePath "$HOME\Downloads\winscp*.exe" | Where-Object { $_.Status -eq "Valid" }) {
            Start-Process -FilePath "$HOME\Downloads\winscp*.exe" -Wait
        }
        else {
            Read-Host "Signature is not valid, application will not be installed"
        }
    }

    # Install putty
    if ($InstallPutty -eq 'y') {
        Read-Host 'A web browser will be opened.  Download putty into the downloads folder. Press enter to begin '
        Start-Process 'https://www.chiark.greenend.org.uk/~sgtatham/putty/latest.html' 
        Read-Host 'Press enter when downloads are complete '
        if (Get-AuthenticodeSignature -FilePath "$HOME\Downloads\putty*.msi" | Where-Object { $_.Status -eq "Valid" }) {
            Start-Process -FilePath "$HOME\Downloads\putty*.msi" -Wait
        }
        else {
            Read-Host "Signature is not valid, application will not be installed"
        }
    }

    # Install python
    if ($InstallPython -eq 'y') {
        Read-Host 'A web browser will be opened.  Download python into the downloads folder. Press enter to begin '
        Start-Process 'https://www.python.org/downloads/windows/' 
        Read-Host 'Press enter when downloads are complete '
        if (Get-AuthenticodeSignature -FilePath "$HOME\Downloads\python*.exe" | Where-Object { $_.Status -eq "Valid" }) {
            Start-Process -FilePath "$HOME\Downloads\python*.exe" -Wait
            # Reload PATH
            $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")

            # Configure Python
            # Update pip
            python -m pip install -U pip
            # Install pylint
            pip install pylint
        }
        else {
            Read-Host "Signature is not valid, application will not be installed"
        }
    }

    # Install libreoffice
    if ($InstallLibreoffice -eq 'y') {
        Read-Host 'A web browser will be opened.  Download libreoffice fresh into the downloads folder. Press enter to begin '
        Start-Process 'https://www.libreoffice.org/download/download/' 
        Read-Host 'Press enter when downloads are complete '
        if (Get-AuthenticodeSignature -FilePath "$HOME\Downloads\libreoffice*.msi" | Where-Object { $_.Status -eq "Valid" }) {
            Start-Process -FilePath "$HOME\Downloads\libreoffice*.msi" -Wait
        }
        else {
            Read-Host "Signature is not valid, application will not be installed"
        }
    }

    # Install java
    if ($InstallJava -eq 'y') {
        Read-Host 'A web browser will be opened.  Download java 64 bit into the downloads folder. Press enter to begin '
        Start-Process 'https://www.java.com/en/download/manual.jsp' 
        Read-Host 'Press enter when downloads are complete '
        if (Get-AuthenticodeSignature -FilePath "$HOME\Downloads\jre*.exe" | Where-Object { $_.Status -eq "Valid" }) {
            Start-Process -FilePath "$HOME\Downloads\jre*.exe" -Wait
        }
        else {
            Read-Host "Signature is not valid, application will not be installed"
        }
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
        if (Get-AuthenticodeSignature -FilePath "$HOME\Downloads\vscode_installer.exe" | Where-Object { $_.Status -eq "Valid" }) {
            Start-Process -FilePath "$HOME\Downloads\vscode_installer.exe" -Wait
        }
        else {
            Read-Host "Signature is not valid, application will not be installed"
        }
    }

    # Install wireshark
    if ($InstallWireshark -eq 'y') {
        Read-Host 'A web browser will be opened.  Download wireshark into the downloads folder. Press enter to begin '
        Start-Process 'https://www.wireshark.org/#download' 
        Read-Host 'Press enter when downloads are complete '
        if (Get-AuthenticodeSignature -FilePath "$HOME\Downloads\wireshark*.exe" | Where-Object { $_.Status -eq "Valid" }) {
            Start-Process -FilePath "$HOME\Downloads\wireshark*.exe" -Wait
        }
        else {
            Read-Host "Signature is not valid, application will not be installed"
        }
    }

    # Install openjdk
    if ($InstallOpenJDK -eq 'y') {
        Read-Host 'A web browser will be opened.  Download openjdk into the downloads folder. Press enter to begin '
        Start-Process 'https://adoptopenjdk.net/' 
        Read-Host 'Press enter when downloads are complete '
        if (Get-AuthenticodeSignature -FilePath "$HOME\Downloads\openjdk*.msi" | Where-Object { $_.Status -eq "Valid" }) {
            Start-Process -FilePath "$HOME\Downloads\openjdk*.msi" -Wait
        }
        else {
            Read-Host "Signature is not valid, application will not be installed"
        }
    }

    # Install tinynvidiaupdater
    if ($InstallTinyNvidiaUpdater -eq 'y') {
        Read-Host 'A web browser will be opened.  Download tinynvidiaupdater and the dll file into the downloads folder. Press enter to begin '
        Start-Process 'https://github.com/ElPumpo/TinyNvidiaUpdateChecker/releases' 
        Read-Host 'Press enter when downloads are complete '
        Get-ChildItem "$HOME\Downloads\TinyNvidiaUpdateChecker*.exe" | Rename-Item -NewName 'TinyNvidiaUpdateChecker.exe'
        New-Item -ItemType Directory -Force -Path 'C:\Program Files\TinyNvidiaUpdateChecker'
        Move-Item -Path "$HOME\Downloads\TinyNvidiaUpdateChecker.exe" -Destination 'C:\Program Files\TinyNvidiaUpdateChecker\TinyNvidiaUpdateChecker.exe'
        Move-Item -Path "$HOME\Downloads\HtmlAgilityPack.dll" -Destination 'C:\Program Files\TinyNvidiaUpdateChecker\HtmlAgilityPack.dll'
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
        if (Get-AuthenticodeSignature -FilePath "$HOME\Downloads\firefox.msi" | Where-Object { $_.Status -eq "Valid" }) {
            Start-Process -FilePath "$HOME\Downloads\firefox.msi" -Wait
        }
        else {
            Read-Host "Signature is not valid, application will not be installed"
        }
    }

    # Install chrome
    if ($InstallChrome -eq 'y') {
        Invoke-WebRequest 'https://dl.google.com/chrome/install/latest/chrome_installer.exe' -OutFile "$HOME\Downloads\chrome_installer.exe"
        if (Get-AuthenticodeSignature -FilePath "$HOME\Downloads\chrome_installer.exe" | Where-Object { $_.Status -eq "Valid" }) {
            Start-Process -FilePath "$HOME\Downloads\chrome_installer.exe" -Wait
        }
        else {
            Read-Host "Signature is not valid, application will not be installed"
        }
    }

    # Install freefilesync
    if ($InstallFreeFileSync -eq 'y') {
        Read-Host 'A web browser will be opened.  Download freefilesync into the downloads folder. Press enter to begin '
        Start-Process 'https://freefilesync.org/download.php' 
        Read-Host 'Press enter when downloads are complete '
        if (Get-AuthenticodeSignature -FilePath "$HOME\Downloads\FreeFileSync*.exe" | Where-Object { $_.Status -eq "Valid" }) {
            Start-Process -FilePath "$HOME\Downloads\FreeFileSync*.exe" -Wait
        }
        else {
            Read-Host "Signature is not valid, application will not be installed"
        }
    }

    # Install vmware player
    if ($InstallVmwarePlayer -eq 'y') {
        Invoke-WebRequest 'https://www.vmware.com/go/getplayer-win' -OutFile "$HOME\Downloads\vmware_player_setup.exe"
        if (Get-AuthenticodeSignature -FilePath "$HOME\Downloads\vmware_player_setup.exe" | Where-Object { $_.Status -eq "Valid" }) {
            Start-Process -FilePath "$HOME\Downloads\vmware_player_setup.exe" -Wait
        }
        else {
            Read-Host "Signature is not valid, application will not be installed"
        }
    }

    # Install nvidiaprofileinspector
    if ($InstallNvidiaProfileInspector -eq 'y') {
        Read-Host 'A web browser will be opened.  Download nvidiaprofileinspector into the downloads folder. Press enter to begin '
        Start-Process 'https://github.com/Orbmu2k/nvidiaProfileInspector/releases' 
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
        if (Get-AuthenticodeSignature -FilePath "$HOME\Downloads\steam_setup.exe" | Where-Object { $_.Status -eq "Valid" }) {
            Start-Process -FilePath "$HOME\Downloads\steam_setup.exe" -Wait
        }
        else {
            Read-Host "Signature is not valid, application will not be installed"
        }
    }

    # Install origin
    if ($InstallOrigin -eq 'y') {
        Invoke-WebRequest 'https://www.dm.origin.com/download' -OutFile "$HOME\Downloads\origin_setup.exe"
        if (Get-AuthenticodeSignature -FilePath "$HOME\Downloads\origin_setup.exe" | Where-Object { $_.Status -eq "Valid" }) {
            Start-Process -FilePath "$HOME\Downloads\origin_setup.exe" -Wait
        }
        else {
            Read-Host "Signature is not valid, application will not be installed"
        }
    }

    # Install gog
    if ($InstallGOG -eq 'y') {
        Read-Host 'A web browser will be opened.  Download gog into the downloads folder. Press enter to begin '
        Start-Process 'https://www.gog.com/galaxy' 
        Read-Host 'Press enter when downloads are complete '
        if (Get-AuthenticodeSignature -FilePath "$HOME\Downloads\gog_galaxy*.exe" | Where-Object { $_.Status -eq "Valid" }) {
            Start-Process -FilePath "$HOME\Downloads\gog_galaxy*.exe" -Wait
        }
        else {
            Read-Host "Signature is not valid, application will not be installed"
        }
    }

    # Install epicstore
    if ($InstallEpicStore -eq 'y') {
        Read-Host 'A web browser will be opened.  Download epic launcher into the downloads folder. Press enter to begin '
        Start-Process 'https://www.epicgames.com/store/en-US/' 
        Read-Host 'Press enter when downloads are complete '
        if (Get-AuthenticodeSignature -FilePath "$HOME\Downloads\EpicInstaller*.msi" | Where-Object { $_.Status -eq "Valid" }) {
            Start-Process -FilePath "$HOME\Downloads\EpicInstaller*.msi" -Wait
        }
        else {
            Read-Host "Signature is not valid, application will not be installed"
        }
    }

    # Install bethesdalauncher
    if ($InstallBethesdaLauncher -eq 'y') {
        Invoke-WebRequest 'https://download.cdp.bethesda.net/BethesdaNetLauncher_Setup.exe' -OutFile "$HOME\Downloads\bethesda_setup.exe"
        if (Get-AuthenticodeSignature -FilePath "$HOME\Downloads\bethesda_setup.exe" | Where-Object { $_.Status -eq "Valid" }) {
            Start-Process -FilePath "$HOME\Downloads\bethesda_setup.exe" -Wait
        }
        else {
            Read-Host "Signature is not valid, application will not be installed"
        }
    }

    # Install BorderlessGaming
    if ($InstallBorderlessGaming -eq 'y') {
        Read-Host 'A web browser will be opened.  Download borderlessgaming into the downloads folder. Press enter to begin '
        Start-Process 'https://github.com/Codeusa/Borderless-Gaming/releases' 
        Read-Host 'Press enter when downloads are complete '
        if (Get-AuthenticodeSignature -FilePath "$HOME\Downloads\borderlessgaming*.exe" | Where-Object { $_.Status -eq "Valid" }) {
            Start-Process -FilePath "$HOME\Downloads\borderlessgaming*.exe" -Wait
        }
        else {
            Read-Host "Signature is not valid, application will not be installed"
        }
    }

    # Install Discord
    if ($InstallDiscord -eq 'y') {
        Invoke-WebRequest 'https://discordapp.com/api/download?platform=win' -OutFile "$HOME\Downloads\discord_setup.exe"
        if (Get-AuthenticodeSignature -FilePath "$HOME\Downloads\discord_setup.exe" | Where-Object { $_.Status -eq "Valid" }) {
            Start-Process -FilePath "$HOME\Downloads\discord_setup.exe" -Wait
        }
        else {
            Read-Host "Signature is not valid, application will not be installed"
        }
    }

    # Install FedoraMediaWriter
    if ($InstallFedoraMediaWriter -eq 'y') {
        Read-Host 'A web browser will be opened.  Download fedoramediawriter into the downloads folder. Press enter to begin '
        Start-Process 'https://getfedora.org/en/workstation/download/' 
        Read-Host 'Press enter when downloads are complete '
        if (Get-AuthenticodeSignature -FilePath "$HOME\Downloads\fedoramedia*.exe" | Where-Object { $_.Status -eq "Valid" }) {
            Start-Process -FilePath "$HOME\Downloads\fedoramedia*.exe" -Wait
        }
        else {
            Read-Host "Signature is not valid, application will not be installed"
        }
    }

    # Install Visual Studio Community
    if ($InstallVisualStudioCommunity -eq 'y') {
        Read-Host 'A web browser will be opened.  Download visual studio community into downloads folder. Press enter to begin '
        Start-Process 'https://visualstudio.microsoft.com/vs/community/' 
        Read-Host 'Press enter when download is complete '
        if (Get-AuthenticodeSignature -FilePath "$HOME\Downloads\vs_community*.exe" | Where-Object { $_.Status -eq "Valid" }) {
            Start-Process -FilePath "$HOME\Downloads\vs_community*.exe" -Wait
        }
        else {
            Read-Host "Signature is not valid, application will not be installed"
        }
    }

    # Install OpenVPN
    if ($InstallOpenVPN -eq 'y') {
        Read-Host 'A web browser will be opened.  Download openvpn into the downloads folder. Press enter to begin '
        Start-Process 'https://openvpn.net/community-downloads/' 
        Read-Host 'Press enter when downloads are complete '
        if (Get-AuthenticodeSignature -FilePath "$HOME\Downloads\openvpn*.exe" | Where-Object { $_.Status -eq "Valid" }) {
            Start-Process -FilePath "$HOME\Downloads\openvpn*.exe" -Wait
        }
        else {
            Read-Host "Signature is not valid, application will not be installed"
        }
    }

    # Install Twitch
    if ($InstallTwitch -eq 'y') {
        Invoke-WebRequest 'https://desktop.twitchsvc.net/installer/windows/TwitchSetup.exe' -OutFile "$HOME\Downloads\twitch_setup.exe"
        if (Get-AuthenticodeSignature -FilePath "$HOME\Downloads\twitch_setup.exe" | Where-Object { $_.Status -eq "Valid" }) {
            Start-Process -FilePath "$HOME\Downloads\twitch_setup.exe" -Wait
        }
        else {
            Read-Host "Signature is not valid, application will not be installed"
        }
    }

    # Install Vortex
    if ($InstallVortex -eq 'y') {
        Read-Host 'A web browser will be opened.  Download vortex into the downloads folder. Press enter to begin '
        Start-Process 'https://github.com/Nexus-Mods/Vortex/releases' 
        Read-Host 'Press enter when downloads are complete '
        if (Get-AuthenticodeSignature -FilePath "$HOME\Downloads\Vortex*.exe" | Where-Object { $_.Status -eq "Valid" }) {
            Start-Process -FilePath "$HOME\Downloads\Vortex*.exe" -Wait
        }
        else {
            Read-Host "Signature is not valid, application will not be installed"
        }
    }

    # Install Visual C++ Redistributables
    if ($InstallVisualRedistributables -eq 'y') {
        Read-Host 'A web browser will be opened.  Download and install the Visual C++ Redistributables. Press enter to begin '
        Start-Process 'https://support.microsoft.com/en-us/help/2977003/the-latest-supported-visual-c-downloads' 
        Read-Host 'Press enter when finished installing '
    }

    # Install RockstarLauncher
    if ($InstallRockstarLauncher -eq 'y') {
        Read-Host 'A web browser will be opened.  Download the rockstar game launcher into the downloads folder. Press enter to begin '
        Start-Process 'https://socialclub.rockstargames.com/rockstar-games-launcher' 
        Read-Host 'Press enter when downloads are complete '
        if (Get-AuthenticodeSignature -FilePath "$HOME\Downloads\Rockstar*.exe" | Where-Object { $_.Status -eq "Valid" }) {
            Start-Process -FilePath "$HOME\Downloads\Rockstar*.exe" -Wait
        }
        else {
            Read-Host "Signature is not valid, application will not be installed"
        }
    }

    # Install rpgmaker rtps
    if ($InstallRPGMakerRTPs -eq 'y') {
        Read-Host 'A web browser will be opened.  Download and install all of the RPGMaker RTPs into the downloads folder. Press enter to begin '
        Start-Process 'https://www.rpgmakerweb.com/download/additional/run-time-packages'
        Read-Host 'Press enter when finished installing '
    }

    # Install Golang
    if ($InstallGolang -eq 'y') {
        Read-Host 'A web browser will be opened.  Download the Golang binary into the downloads folder. Press enter to begin '
        Start-Process 'https://golang.org/dl/'
        Read-Host 'Press enter when downloads are complete '
        if (Get-AuthenticodeSignature -FilePath "$HOME\Downloads\go*.windows-amd64.msi" | Where-Object { $_.Status -eq "Valid" }) {
            Start-Process -FilePath "$HOME\Downloads\go*.windows-amd64.msi" -Wait
        }
        else {
            Read-Host "Signature is not valid, application will not be installed"
        }
    }

    # Install Microsoft Edge
    if ($InstallEdge -eq 'y') {
        Read-Host 'A web browser will be opened.  Download the edge binary into the downloads folder. Press enter to begin '
        Start-Process 'https://www.microsoft.com/en-us/edge'
        Read-Host 'Press enter when downloads are complete '
        if (Get-AuthenticodeSignature -FilePath "$HOME\Downloads\MicrosoftEdgeSetup.exe" | Where-Object { $_.Status -eq "Valid" }) {
            Start-Process -FilePath "$HOME\Downloads\MicrosoftEdgeSetup.exe" -Wait
        }
        else {
            Read-Host "Signature is not valid, application will not be installed"
        }
    }

    # Install Reolink
    if ($InstallReolink -eq 'y') {
        Read-Host 'A web browser will be opened.  Download the reolink binary into the downloads folder. Press enter to begin '
        Start-Process 'https://reolink.com/software-and-manual/'
        Read-Host 'Press enter when downloads are complete '
        # Extract zip folder
        Get-ChildItem "$HOME\Downloads\Reolink*.zip" | Expand-Archive -DestinationPath "$HOME\Downloads\Reolink"
        if (Get-AuthenticodeSignature -FilePath "$HOME\Downloads\Reolink\Reolink*.exe" | Where-Object { $_.Status -eq "Valid" }) {
            Start-Process -FilePath "$HOME\Downloads\Reolink\Reolink*.exe" -Wait
        }
        else {
            Read-Host "Signature is not valid, application will not be installed"
        }
    }

    # Install Uplay
    if ($InstallUplay -eq 'y') {
        Read-Host 'A web browser will be opened.  Download the uplay binary into the downloads folder. Press enter to begin '
        Start-Process 'https://uplay.ubisoft.com/'
        Read-Host 'Press enter when downloads are complete '
        if (Get-AuthenticodeSignature -FilePath "$HOME\Downloads\UplayInstaller.exe" | Where-Object { $_.Status -eq "Valid" }) {
            Start-Process -FilePath "$HOME\Downloads\UplayInstaller.exe" -Wait
        }
        else {
            Read-Host "Signature is not valid, application will not be installed"
        }
    }

    # Install Microsoft Office
    if ($InstallMicrosoftOffice -eq 'y') {
        Read-Host 'A web browser will be opened.  Download the office binary into the downloads folder. Press enter to begin '
        Start-Process 'https://portal.office.com/account/'
        Read-Host 'Press enter when downloads are complete '
        if (Get-AuthenticodeSignature -FilePath "$HOME\Downloads\*O365ProPlusRetail*.exe" | Where-Object { $_.Status -eq "Valid" }) {
            Start-Process -FilePath "$HOME\Downloads\*O365ProPlusRetail*.exe" -Wait
        }
        else {
            Read-Host "Signature is not valid, application will not be installed"
        }
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

function ConfigureComputerName {
    Rename-Computer -NewName "$ComputerName"
}

function ConfigurePowerOptions {
    # Disable hibernate
    powercfg /hibernate off
    powercfg /change -hibernate-timeout-ac 0
    powercfg /change -hibernate-timeout-dc 0
    # Set disk poweroff to 20 minutes
    powercfg /change -disk-timeout-ac 20
    powercfg /change -disk-timeout-dc 20
    # Set display turnoff to 5 minutes
    powercfg /change -monitor-timeout-ac 5
    powercfg /change -monitor-timeout-dc 5
    # Set standby timeout
    powercfg /change -standby-timeout-ac 0
    powercfg /change -standby-timeout-dc 0
}

function InstallFeatures {
    # Enable Hyper-V
    Enable-WindowsOptionalFeature -Online -FeatureName 'Microsoft-Hyper-V' -All
    # Enable WSL
    Enable-WindowsOptionalFeature -Online -FeatureName 'Microsoft-Windows-Subsystem-Linux'
}

function RemoveFeatures {
    # Disable internet explorer
    Disable-WindowsOptionalFeature -Online -FeatureName 'Internet-Explorer-Optional-amd64'
    # Disable powershell 2.0
    Disable-WindowsOptionalFeature -Online -FeatureName 'MicrosoftWindowsPowerShellV2Root'
}

function MapDrives {
    # Network Share locations
    $Share1 = '\\matt-nas.miller.lan\matt_files'
    $Share2 = '\\matt-nas.miller.lan\matthew_versions'
    $Share3 = '\\matt-nas.miller.lan\vm_backup'
    # Mount Network Shares
    New-PSDrive -Name "N" -PSProvider "FileSystem" -Root "$Share1" -Persist -Scope "Global"
    New-PSDrive -Name "O" -PSProvider "FileSystem" -Root "$Share2" -Persist -Scope "Global"
    New-PSDrive -Name "P" -PSProvider "FileSystem" -Root "$Share3" -Persist -Scope "Global"
}

# Calling Functions
if ($ConfigureComputerNameVar -eq 'y') {
    ConfigureComputerName
}
if ($ConfigurePowerOptionsVar -eq 'y') {
    ConfigurePowerOptions
}
if ($DisableCortanaVar -eq 'y') {
    DisableCortana
}
if ($DisableTelemetryVar -eq 'y') {
    DisableTelemetry
}
if ($ConfigureFirewallVar -eq 'y') {
    ConfigureFirewall
}
if ($RemoveApplicationsVar -eq 'y') {
    RemoveApplications
}
if ($ConfigureAppPrivacyVar -eq 'y') {
    ConfigureAppPrivacy
}
if ($ConfigureNTPVar -eq 'y') {
    ConfigureNTP
}
if ($InstallFeaturesVar -eq 'y') {
    InstallFeatures
}
if ($RemoveFeaturesVar -eq 'y') {
    RemoveFeatures
}
if ($MapDrivesVar -eq 'y') {
    MapDrives
}
if ($InstallApplicationsVar -eq 'y') {
    InstallApplications
}
