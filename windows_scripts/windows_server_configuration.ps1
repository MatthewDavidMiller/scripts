# Copyright (c) Matthew David Miller. All rights reserved.
# Licensed under the MIT License.
# Run the script as admin.

# Get neeeded files
Invoke-WebRequest 'https://raw.githubusercontent.com/MatthewDavidMiller/scripts/stable/windows_scripts/windows_scripts.ps1' -OutFile "$PSScriptRoot\windows_scripts.ps1"

# Source Functions
. "$PSScriptRoot\windows_scripts.ps1"

# Prompts
$ConfigureTimeVar = Read-Host "Configure time? y/n "
$ConfigureNetworkVar = Read-Host "Configure network? y/n "
$ICMPRequestVar = Read-Host "Block ICMP requests? y/n "
$ConfigureComputerNameVar = Read-Host "Configure server name? y/n "
$AddLocalUserVar = Read-Host "Add a local user? y/n "
$ConfigureSSHVar = Read-Host "Configure SSH? y/n "

# Call functions
if ($ConfigureTimeVar -eq 'y') {
    ConfigureTime
}

if ($ConfigureNetworkVar -eq 'y') {
    ConfigureNetwork
}

if ($ICMPRequestVar -eq 'y') {
    BlockICMPRequests
}

if ($ConfigureComputerNameVar -eq 'y') {
    ConfigureComputerName
}

if ($AddLocalUserVar -eq 'y') {
    AddLocalUser
}

if ($ConfigureSSHVar -eq 'y') {
    ConfigureSSH
}
