# Copyright (c) 2019 Matthew David Miller. All rights reserved.

# Licensed under the MIT License.

# Script is currently a work in progress.  Some portions of the script may not work yet.

# Run the script as admin.

# Set the time, date, and timezone.

$Date = Read-Host "Enter date in format xx/xx/xxxx"
$Time = Read-Host "Enter time in format xx:xxpm"
$Timezone = Read-Host "Enter timezone. A formatting example is: US Eastern Standard Time"

Set-Date "$Date $Time"
Set-TimeZone "$Timezone"

# Configure Network settings.

$IP_address = Read-Host "Enter IP address"
$Prefix_length = Read-Host "Enter prefix length"
$Default_gateway = Read-Host "Enter default gateway"
$Interface_alias = Read-Host "Enter interface alias"
$DNS_server_address = Read-Host "Enter DNS servers"

New-NetIPAddress $IP_address -PrefixLength $Prefix_length -DefaultGateway $Default_gateway -InterfaceAlias $Interface_alias
Set-DnsClientServerAddress-InterfaceAlias $Interface_alias -ServerAddresses $DNS_server_address

# Block ICMP requests.

$ICMP_request = Read-Host "Block ICMP requests? Yes (y) or No (n)"

while("y","n" -notcontains $ICMP_request)
{
$ICMP_request = "Answer with y or n"
}

If ($ICMP_request = "y")
{
Write-Host "Proceeding to block ICMP requests."
netsh advfirewall firewall add rule name="ICMP Block incoming V4 echo request" protocol=icmpv4:8,any dir=in action=block
}

If ($ICMP_request = "n")
{
Write-Host "Moving on to next portion of the script."
}

# Configure the Server's name.

$New_name = Read-Host "Enter the name for the server."
$Domain_credential = Read-Host -AsSecureString "Enter domain credential."
Read-Host "Restart after name change? Yes (y) or No (n)."

while("y","n" -notcontains $Domain_credential)
{
$Domain_credential = "Answer with y or n"
}

If ($Domain_credential = "y")
{
Write-Host "Prepare for restart."
Rename-Computer -NewName "$New_name" -DomainCredential $Domain_credential -Restart
}

If ($Domain_credential = "n")
{
Write-Host "Moving on to the next portion of the script."
Rename-Computer -NewName "$New_name" -DomainCredential $Domain_credential
}

# Add a local user
$Local_user_username = Read-Host -AsSecureString "Enter username for new user."
$Local_user_password = Read-Host -AsSecureString "Enter password for new user."
$Local_user_full_name = Read-Host -AsSecureString "Enter full name for new user."
$Local_user_description = Read-Host -AsSecureString "Enter description for new user."

New-LocalUser "$Local_user_username" -Password $Local_user_password -FullName "$Local_user_full_name" -Description "$Local_user_description"

## Install and configure SSH
Get-WindowsCapability -Online | ? Name -like 'OpenSSH*'
$OpenSSH = Read-Host "Enter OpenSSH Server full name."

Add-WindowsCapability -Online -Name $OpenSSH
Set-Service -Name sshd -StartupType 'Automatic'
Start-Service sshd
Install-Module -Force OpenSSHUtils -Scope AllUsers
Set-Service -Name ssh-agent -StartupType 'Automatic'
Start-Service ssh-agent
cd ~\.ssh\
ssh-keygen