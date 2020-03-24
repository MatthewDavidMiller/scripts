# Copyright (c) 2019 Matthew David Miller. All rights reserved.
# Licensed under the MIT License.
# Run the script as admin.

# Prompts
$DomainCredential = Read-Host -AsSecureString "Enter domain credential."

$ConfigureTime = Read-Host "Configure time? y/n "
if ($ConfigureTime -eq 'y') {
    $Date = Read-Host "Enter date in format xx/xx/xxxx"
    $Time = Read-Host "Enter time in format xx:xxpm"
    $Timezone = Read-Host "Enter timezone. A formatting example is: US Eastern Standard Time"
}

$ConfigureNetwork = Read-Host "Configure network? y/n "
if ($ConfigureNetwork -eq 'y') {
    $IPAddress = Read-Host "Enter IP address"
    $PrefixLength = Read-Host "Enter prefix length"
    $DefaultGateway = Read-Host "Enter default gateway"
    $InterfaceAlias = Read-Host "Enter interface alias"
    $DNSServerAddress = Read-Host "Enter DNS servers"
}

$ICMPRequest = Read-Host "Block ICMP requests? y/n "

$ConfigureServerName = Read-Host "Configure server name? y/n "
if ($ConfigureServerName -eq 'y') {
    $NewName = Read-Host "Enter the name for the server."
}

$AddLocalUser = Read-Host "Add a local user? y/n "
if ($AddLocalUser -eq 'y') {
    $LocalUserUsername = Read-Host -AsSecureString "Enter username for new user."
    $LocalUserPassword = Read-Host -AsSecureString "Enter password for new user."
    $LocalUserFullName = Read-Host -AsSecureString "Enter full name for new user."
    $LocalUserDescription = Read-Host -AsSecureString "Enter description for new user."
}

$ConfigureSSH = Read-Host "Configure SSH? y/n "

function ConfigureTime {
    Set-Date "$Date $Time"
    Set-TimeZone "$Timezone"
}

function ConfigureNetwork {
    New-NetIPAddress $IPAddress -PrefixLength $PrefixLength -DefaultGateway $DefaultGateway -InterfaceAlias $InterfaceAlias
    Set-DnsClientServerAddress-InterfaceAlias $InterfaceAlias -ServerAddresses $DNSServerAddress
}

function BlockICMPRequests {
    Write-Host "Proceeding to block ICMP requests."
    netsh advfirewall firewall add rule name="ICMP Block incoming V4 echo request" protocol=icmpv4:8, any dir=in action=block
}

function ConfigureServerName {
    Rename-Computer -NewName "$NewName" -DomainCredential $DomainCredential
}

function AddLocalUser {
    New-LocalUser "$LocalUserUsername" -Password $LocalUserPassword -FullName "$LocalUserFullName" -Description "$LocalUserDescription"
}

function ConfigureSSH {
    Get-WindowsCapability -Online | Where-Object Name -like 'OpenSSH.Server*' | Add-WindowsCapability -Online
    Set-Service -Name sshd -StartupType 'Automatic'
    Start-Service sshd
    Install-Module -Force OpenSSHUtils -Scope AllUsers
    Set-Service -Name ssh-agent -StartupType 'Automatic'
    Start-Service ssh-agent
    Set-Location ~\.ssh\
    ssh-keygen
}

# Call functions
if ($ConfigureTime -eq 'y') {
    ConfigureTime
}

if ($ConfigureNetwork -eq 'y') {
    ConfigureNetwork
}

if ($ICMPRequest -eq 'y') {
    BlockICMPRequests
}

if ($ConfigureServerName -eq 'y') {
    ConfigureServerName
}

if ($AddLocalUser -eq 'y') {
    AddLocalUser
}

if ($ConfigureSSH -eq 'y') {
    ConfigureSSH
}
