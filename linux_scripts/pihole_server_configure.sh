#!/bin/bash

# Copyright (c) 2019 Matthew David Miller. All rights reserved.
# Licensed under the MIT License.
# Needs to be run as root. Make sure you are logged in as a user instead of root.
# Configuration script for the pihole server. Run after installing with the install script.

# Get username
user_name=$(logname)

function configure_network() {
    # Set server ip
    read -r -p "Enter server ip address. Example '10.1.10.5': " ip_address
    # Set network
    read -r -p "Enter network ip address. Example '10.1.10.0': " network_address
    # Set subnet mask
    read -r -p "Enter netmask. Example '255.255.255.0': " subnet_mask
    # Set gateway
    read -r -p "Enter gateway ip. Example '10.1.10.1': " gateway_address
    # Set dns server
    read -r -p "Enter dns server ip. Example '1.1.1.1': " dns_address

    # Get the interface name
    interface="$(ip route get 8.8.8.8 | sed -nr 's/.*dev ([^\ ]+).*/\1/p')"
    echo "Interface name is ${interface}"

    # Configure network
    rm -f '/etc/network/interfaces'
    cat <<EOF >'/etc/network/interfaces'
auto lo
iface lo inet loopback
auto ${interface}
iface ${interface} inet static
    address ${ip_address}
    network ${network_address}
    netmask ${subnet_mask}
    gateway ${gateway_address}
    dns-nameservers ${dns_address}

EOF

    # Restart network interface
    ifdown "${interface}" && ifup "${interface}"
}

function configure_packages() {
    # Fix all packages
    dpkg --configure -a

    # Install recommended packages
    apt-get update
    apt-get upgrade -y
    apt-get install -y wget vim git ufw ntp ssh openssh-server unbound unattended-upgrades
}

function configure_firewall() {
    # Configure ufw
    # Set default inbound to deny
    ufw default deny incoming

    # Set default outbound to allow
    ufw default allow outgoing

    # Limit max connections to ssh server and allow it only on private networks
    ufw limit proto tcp from 10.0.0.0/8 to any port 22
    ufw limit proto tcp from fe80::/10 to any port 22

    # Allow DNS
    ufw allow proto tcp from 10.0.0.0/8 to any port 53
    ufw allow proto tcp from fe80::/10 to any port 53
    ufw allow proto udp from 10.0.0.0/8 to any port 53
    ufw allow proto udp from fe80::/10 to any port 53

    # Allow unbound
    ufw allow proto udp from 127.0.0.1 to any port 5353
    ufw allow proto udp from ::1 to any port 5353
    ufw allow proto tcp from 127.0.0.1 to any port 5353
    ufw allow proto tcp from ::1 to any port 5353

    # Allow HTTP
    ufw allow proto tcp from 10.0.0.0/8 to any port 80
    ufw allow proto tcp from fe80::/10 to any port 80

    # Allow HTTPS
    ufw allow proto tcp from 10.0.0.0/8 to any port 443
    ufw allow proto tcp from fe80::/10 to any port 443

    # Allow port 4711 tcp
    ufw allow proto tcp from 10.0.0.0/8 to any port 4711
    ufw allow proto tcp from fe80::/10 to any port 4711

    # Enable ufw
    systemctl enable ufw.service
    ufw enable
}

function configure_scripts() {
    # Script to archive config files for backup
    wget 'https://raw.githubusercontent.com/MatthewDavidMiller/scripts/stable/linux_scripts/backup_configs.sh'
    mv 'backup_configs.sh' '/usr/local/bin/backup_configs.sh'
    chmod +x '/usr/local/bin/backup_configs.sh'

    # Configure cron jobs
    cat <<EOF >jobs.cron
* 0 * * 1 bash /usr/local/bin/backup_configs.sh &

EOF
    crontab jobs.cron
    rm -f jobs.cron
}

function configure_ssh() {
    # Generate an ecdsa 521 bit key
    ssh-keygen -f "/home/${user_name}/pihole_key" -t ecdsa -b 521

    # Authorize the key for use with ssh
    mkdir "/home/${user_name}/.ssh"
    chmod 700 "/home/${user_name}/.ssh"
    touch "/home/${user_name}/.ssh/authorized_keys"
    chmod 600 "/home/${user_name}/.ssh/authorized_keys"
    cat "/home/${user_name}/pihole_key.pub" >>"/home/${user_name}/.ssh/authorized_keys"
    printf '%s\n' '' >>"/home/${user_name}/.ssh/authorized_keys"
    chown -R "${user_name}" "/home/${user_name}"
    python -m SimpleHTTPServer 40080 &
    server_pid=$!
    read -r -p "Copy the key from the webserver on port 40080 before continuing: " >>'/dev/null'
    kill "${server_pid}"

    # Secure ssh access
    # Turn off password authentication
    grep -q ".*PasswordAuthentication" '/etc/ssh/sshd_config' && sed -i "s,.*PasswordAuthentication.*,PasswordAuthentication no," '/etc/ssh/sshd_config' || printf '%s\n' 'PasswordAuthentication no' >>'/etc/ssh/sshd_config'

    # Do not allow empty passwords
    grep -q ".*PermitEmptyPasswords" '/etc/ssh/sshd_config' && sed -i "s,.*PermitEmptyPasswords.*,PermitEmptyPasswords no," '/etc/ssh/sshd_config' || printf '%s\n' 'PermitEmptyPasswords no' >>'/etc/ssh/sshd_config'

    # Turn off PAM
    grep -q ".*UsePAM" '/etc/ssh/sshd_config' && sed -i "s,.*UsePAM.*,UsePAM no," '/etc/ssh/sshd_config' || printf '%s\n' 'UsePAM no' >>'/etc/ssh/sshd_config'

    # Turn off root ssh access
    grep -q ".*PermitRootLogin" '/etc/ssh/sshd_config' && sed -i "s,.*PermitRootLogin.*,PermitRootLogin no," '/etc/ssh/sshd_config' || printf '%s\n' 'PermitRootLogin no' >>'/etc/ssh/sshd_config'

    # Enable public key authentication
    grep -q ".*AuthorizedKeysFile" '/etc/ssh/sshd_config' && sed -i "s,.*AuthorizedKeysFile\s*.ssh/authorized_keys\s*.ssh/authorized_keys2,AuthorizedKeysFile .ssh/authorized_keys," '/etc/ssh/sshd_config' || printf '%s\n' 'AuthorizedKeysFile .ssh/authorized_keys' >>'/etc/ssh/sshd_config'
    grep -q ".*PubkeyAuthentication" '/etc/ssh/sshd_config' && sed -i "s,.*PubkeyAuthentication.*,PubkeyAuthentication yes," '/etc/ssh/sshd_config' || printf '%s\n' 'PubkeyAuthentication yes' >>'/etc/ssh/sshd_config'
}

function configure_auto_updates() {
    rm -f '/etc/apt/apt.conf.d/50unattended-upgrades'

    cat <<\EOF >'/etc/apt/apt.conf.d/50unattended-upgrades'
Unattended-Upgrade::Origins-Pattern {
        "origin=Debian,n=buster,l=Debian";
        "origin=Debian,n=buster,l=Debian-Security";
        "origin=Debian,n=buster-updates";
};

Unattended-Upgrade::Package-Blacklist {

};

// Automatically reboot *WITHOUT CONFIRMATION* if
//  the file /var/run/reboot-required is found after the upgrade
Unattended-Upgrade::Automatic-Reboot "true";

// If automatic reboot is enabled and needed, reboot at the specific
// time instead of immediately
//  Default: "now"
Unattended-Upgrade::Automatic-Reboot-Time "04:00";

EOF
}

function configure_unbound() {
    wget -O root.hints https://www.internic.net/domain/named.root
    mv root.hints /var/lib/unbound/
    systemctl enable unbound
    systemctl start unbound
    rm -f '/etc/unbound/unbound.conf.d/pi-hole.conf'
    cat <<\EOF >'/etc/unbound/unbound.conf.d/pi-hole.conf'
server:
    # If no logfile is specified, syslog is used
    # logfile: "/var/log/unbound/unbound.log"
    verbosity: 0

    port: 5353
    do-ip4: yes
    do-udp: yes
    do-tcp: yes

    # May be set to yes if you have IPv6 connectivity
    do-ip6: yes

    # Use this only when you downloaded the list of primary root servers!
    root-hints: "/var/lib/unbound/root.hints"

    # Trust glue only if it is within the servers authority
    harden-glue: yes

    # Require DNSSEC data for trust-anchored zones, if such data is absent, the zone becomes BOGUS
    harden-dnssec-stripped: yes

    # Don't use Capitalization randomization as it known to cause DNSSEC issues sometimes
    # see https://discourse.pi-hole.net/t/unbound-stubby-or-dnscrypt-proxy/9378 for further details
    use-caps-for-id: no

    # Reduce EDNS reassembly buffer size.
    # Suggested by the unbound man page to reduce fragmentation reassembly problems
    edns-buffer-size: 1472

    # Perform prefetching of close to expired message cache entries
    # This only applies to domains that have been frequently queried
    prefetch: yes

    # One thread should be sufficient, can be increased on beefy machines. In reality for most users running on small networks or on a single machine it should be unnecessary to seek performance enhancement by increasing num-threads above 1.
    num-threads: 1

    # Ensure kernel buffer is large enough to not lose messages in traffic spikes
    so-rcvbuf: 1m

    # Ensure privacy of local IP ranges
    private-address: 192.168.0.0/16
    private-address: 169.254.0.0/16
    private-address: 172.16.0.0/12
    private-address: 10.0.0.0/8
    private-address: fd00::/8
    private-address: fe80::/10

EOF
}

function configure_pihole() {
    git clone --depth 1 https://github.com/pi-hole/pi-hole.git Pi-hole
    cd 'Pi-hole/automated install/' || exit
    bash basic-install.sh
    cd || exit

    # Setup whitelisted sites
    rm -f '/etc/pihole/whitelist.txt'
    cat <<\EOF >'/etc/pihole/whitelist.txt'

EOF

    # Configure blocklists
    rm -f '/etc/pihole/adlists.list'
    cat <<\EOF >'/etc/pihole/adlists.list'
https://mirror1.malwaredomains.com/files/justdomains

EOF

    # Configure blacklist
    rm -f '/etc/pihole/blacklist.txt'
    cat <<\EOF >'/etc/pihole/blacklist.txt'

EOF

    # Configure regex
    rm -f '/etc/pihole/regex.list'
    cat <<\EOF >'/etc/pihole/regex.list'
^.+\.(ru|cn|ro|ml|ga|gq|cf|tk|pw|ua|ug|ve|)$
porn
sex

EOF

    # Configure pihole settings
    grep -q 'DNSSEC=' '/etc/pihole/setupVars.conf' && sed -i "s/DNSSEC=.*/DNSSEC=true/g" '/etc/pihole/setupVars.conf' || printf '%s\n' 'DNSSEC=true' >>'/etc/pihole/setupVars.conf'
    grep -q 'PIHOLE_DNS_1=' '/etc/pihole/setupVars.conf' && sed -i "s/PIHOLE_DNS_1=.*/PIHOLE_DNS_1=127.0.0.1#5353/g" '/etc/pihole/setupVars.conf' || printf '%s\n' 'PIHOLE_DNS_1=127.0.0.1#5053' >>'/etc/pihole/setupVars.conf'
    grep -q 'PIHOLE_DNS_2=' '/etc/pihole/setupVars.conf' && sed -i "s/PIHOLE_DNS_2=.*/PIHOLE_DNS_2=::1#5353/g" '/etc/pihole/setupVars.conf' || printf '%s\n' 'PIHOLE_DNS_2=::1#5053' >>'/etc/pihole/setupVars.conf'
    grep -q 'DNSMASQ_LISTENING=' '/etc/pihole/setupVars.conf' && sed -i "s/DNSMASQ_LISTENING=.*/DNSMASQ_LISTENING=all/g" '/etc/pihole/setupVars.conf' || printf '%s\n' 'DNSMASQ_LISTENING=all' >>'/etc/pihole/setupVars.conf'
    grep -q 'CONDITIONAL_FORWARDING=' '/etc/pihole/setupVars.conf' && sed -i "s/CONDITIONAL_FORWARDING=.*/CONDITIONAL_FORWARDING=true/g" '/etc/pihole/setupVars.conf' || printf '%s\n' 'CONDITIONAL_FORWARDING=true' >>'/etc/pihole/setupVars.conf'
    grep -q 'CONDITIONAL_FORWARDING_IP=' '/etc/pihole/setupVars.conf' && sed -i "s/CONDITIONAL_FORWARDING_IP=.*/CONDITIONAL_FORWARDING_IP=${gateway_address}/g" '/etc/pihole/setupVars.conf' || printf '%s\n' "CONDITIONAL_FORWARDING_IP=${gateway_address}" >>'/etc/pihole/setupVars.conf'
    grep -q 'CONDITIONAL_FORWARDING_DOMAIN=' '/etc/pihole/setupVars.conf' && sed -i "s/CONDITIONAL_FORWARDING_DOMAIN=.*/CONDITIONAL_FORWARDING_DOMAIN=lan/g" '/etc/pihole/setupVars.conf' || printf '%s\n' 'CONDITIONAL_FORWARDING_DOMAIN=lan' >>'/etc/pihole/setupVars.conf'
    grep -q 'DNS_FQDN_REQUIRED=' '/etc/pihole/setupVars.conf' && sed -i "s/DNS_FQDN_REQUIRED=.*/DNS_FQDN_REQUIRED=false/g" '/etc/pihole/setupVars.conf' || printf '%s\n' 'DNS_FQDN_REQUIRED=false' >>'/etc/pihole/setupVars.conf'
    grep -q 'DNS_BOGUS_PRIV=' '/etc/pihole/setupVars.conf' && sed -i "s/DNS_BOGUS_PRIV=.*/DNS_BOGUS_PRIV=false/g" '/etc/pihole/setupVars.conf' || printf '%s\n' 'DNS_BOGUS_PRIV=false' >>'/etc/pihole/setupVars.conf'

    echo 'Set pihole password'
    pihole -a -p

    # Setup pihole folder permissions
    chown -R pihole:pihole '/etc/pihole'
    chmod 777 -R '/etc/pihole'
}

# Call functions
configure_network
configure_packages
configure_ssh
configure_firewall
configure_auto_updates
configure_scripts
configure_unbound
configure_pihole
