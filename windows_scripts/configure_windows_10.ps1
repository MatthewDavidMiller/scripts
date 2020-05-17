# Copyright (c) Matthew David Miller. All rights reserved.
# Licensed under the MIT License.
# Script to confgure settings in Windows 10

# Prompts
$ConfigureComputerNameVar = Read-Host 'Configure computer hostname? Requires running as admin. y/n '
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

# Source Functions
. windows_scripts.ps1

# Call Functions
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
