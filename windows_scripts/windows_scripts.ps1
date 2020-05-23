# Copyright (c) Matthew David Miller. All rights reserved.
# Licensed under the MIT License.
# Functions and scripts for Windows.

function ConfigureComputerName {
    $ComputerName = Read-Host 'Enter computer hostname '
    $DomainCredential = Read-Host -AsSecureString "Enter domain credential."
    Rename-Computer -NewName "$ComputerName" -DomainCredential $DomainCredential
}

function ConfigureTime {
    $Date = Read-Host "Enter date in format xx/xx/xxxx"
    $Time = Read-Host "Enter time in format xx:xxpm"
    $Timezone = Read-Host "Enter timezone. A formatting example is: US Eastern Standard Time"
    Set-Date "($Date) ($Time)"
    Set-TimeZone "$Timezone"
}

function ConfigureNetwork {
    $IPAddress = Read-Host "Enter IP address"
    $PrefixLength = Read-Host "Enter prefix length"
    $DefaultGateway = Read-Host "Enter default gateway"
    $InterfaceAlias = Read-Host "Enter interface alias"
    $DNSServerAddress = Read-Host "Enter DNS servers"
    New-NetIPAddress $IPAddress -PrefixLength $PrefixLength -DefaultGateway $DefaultGateway -InterfaceAlias $InterfaceAlias
    Set-DnsClientServerAddress-InterfaceAlias $InterfaceAlias -ServerAddresses $DNSServerAddress
}

function BlockICMPRequests {
    Write-Host "Proceeding to block ICMP requests."
    netsh advfirewall firewall add rule name="ICMP Block incoming V4 echo request" protocol=icmpv4:8, any dir=in action=block
}

function AddLocalUser {
    $LocalUserUsername = Read-Host -AsSecureString "Enter username for new user."
    $LocalUserPassword = Read-Host -AsSecureString "Enter password for new user."
    $LocalUserFullName = Read-Host -AsSecureString "Enter full name for new user."
    $LocalUserDescription = Read-Host -AsSecureString "Enter description for new user."
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
