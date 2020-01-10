#!/bin/bash

# Copyright (c) 2019 Matthew David Miller. All rights reserved.
# Licensed under the MIT License.
# Needs to be run as root. Make sure you are logged in as a user instead of root.
# Configuration script for the pihole server. Run after installing with the install script.

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

# Get username
user_name=$(logname)

# Configure network
rm -f '/etc/network/interfaces'
cat <<EOF > '/etc/network/interfaces'
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

# Install recommended packages
apt-get update
apt-get upgrade
apt-get install -y wget vim git ufw ntp ssh apt-transport-https openssh-server

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

# Get scripts

# Script to archive config files for backup
wget 'https://raw.githubusercontent.com/MatthewDavidMiller/scripts/stable/linux_scripts/backup_configs.sh'
mv 'backup_configs.sh' '/usr/local/bin/backup_configs.sh'
chmod +x '/usr/local/bin/backup_configs.sh'

# Configure cron jobs
cat <<EOF > jobs.cron
* 0 * * 1 bash /usr/local/bin/backup_configs.sh &

EOF
crontab jobs.cron
rm -f jobs.cron

# Setup ssh

# Generate an ecdsa 521 bit key
ssh-keygen -f "/home/${user_name}/pihole_key" -t ecdsa -b 521

# Authorize the key for use with ssh
mkdir "/home/${user_name}/.ssh"
chmod 700 "/home/${user_name}/.ssh"
touch "/home/${user_name}/.ssh/authorized_keys"
chmod 600 "/home/${user_name}/.ssh/authorized_keys"
cat "/home/${user_name}/pihole_key.pub" >> "/home/${user_name}/.ssh/authorized_keys"
printf '%s\n' '' >> "/home/${user_name}/.ssh/authorized_keys"
chown -R "${user_name}" "/home/${user_name}"
read -r -p "Remember to copy the ssh private key to the client before restarting the device after install: " >> '/dev/null'

# Secure ssh access

# Turn off password authentication
sed -i 's,#PasswordAuthentication\s*yes,PasswordAuthentication no,' /etc/ssh/sshd_config
sed -i 's,#PasswordAuthentication\s*no,PasswordAuthentication no,' /etc/ssh/sshd_config
sed -i 's,PasswordAuthentication\s*yes,PasswordAuthentication no,' /etc/ssh/sshd_config

# Do not allow empty passwords
sed -i 's,#PermitEmptyPasswords\s*yes,PermitEmptyPasswords no,' /etc/ssh/sshd_config
sed -i 's,#PermitEmptyPasswords\s*no,PermitEmptyPasswords no,' /etc/ssh/sshd_config
sed -i 's,PermitEmptyPasswords\s*yes,PermitEmptyPasswords no,' /etc/ssh/sshd_config

# Turn off PAM
sed -i 's,#UsePAM\s*yes,UsePAM no,' /etc/ssh/sshd_config
sed -i 's,#UsePAM\s*no,UsePAM no,' /etc/ssh/sshd_config
sed -i 's,UsePAM\s*yes,UsePAM no,' /etc/ssh/sshd_config

# Turn off root ssh access
sed -i 's,#PermitRootLogin\s*prohibit-password,PermitRootLogin no,' /etc/ssh/sshd_config
sed -i 's,PermitRootLogin\s*prohibit-password,PermitRootLogin no,' /etc/ssh/sshd_config
sed -i 's,#PermitRootLogin\s*yes,PermitRootLogin no,' /etc/ssh/sshd_config
sed -i 's,PermitRootLogin\s*yes,PermitRootLogin no,' /etc/ssh/sshd_config
sed -i 's,#PermitRootLogin\s*no,PermitRootLogin no,' /etc/ssh/sshd_config

# Enable public key authentication
sed -i 's,#AuthorizedKeysFile\s*.ssh/authorized_keys\s*.ssh/authorized_keys2,AuthorizedKeysFile .ssh/authorized_keys,' /etc/ssh/sshd_config
sed -i 's,#PubkeyAuthentication\s*no,PubkeyAuthentication yes,' /etc/ssh/sshd_config
sed -i 's,#PubkeyAuthentication\s*yes,PubkeyAuthentication yes,' /etc/ssh/sshd_config
sed -i 's,PubkeyAuthentication\s*no,PubkeyAuthentication yes,' /etc/ssh/sshd_config

# Configure automatic updates

rm -f '/etc/apt/apt.conf.d/50unattended-upgrades'

cat <<\EOF > '/etc/apt/apt.conf.d/50unattended-upgrades'
Unattended-Upgrade::Origins-Pattern {
        "origin=Debian,a=stable";
        "origin=Debian,a=stable-updates";
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

# Install pihole
git clone --depth 1 https://github.com/pi-hole/pi-hole.git Pi-hole
cd 'Pi-hole/automated install/' || exit
bash basic-install.sh
cd || exit

# Setup unbound
wget -O root.hints https://www.internic.net/domain/named.root
mv root.hints /var/lib/unbound/
systemctl enable unbound
systemctl start unbound
rm -f '/etc/unbound/unbound.conf.d/pi-hole.conf'
cat <<\EOF > '/etc/unbound/unbound.conf.d/pi-hole.conf'
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

# Setup whitelisted sites
rm -f '/etc/pihole/whitelist.txt'
cat <<\EOF > '/etc/pihole/whitelist.txt'

# Config for whitelist used with pihole
# File location is /etc/pihole/whitelist.txt
0.client-channel.google.com
1drv.com
2.android.pool.ntp.org
akamaihd.net
akamaitechnologies.com
akamaized.net
alluremedia.com.au
amazonaws.com
android.clients.google.com
api.ipify.org
api.rlje.net
app-api.ted.com
app.plex.tv
appleid.apple.com
apps.skype.com
appsbackup-pa.clients6.google.com
appsbackup-pa.googleapis.com
apt.sonarr.tv
aspnetcdn.com
attestation.xboxlive.com
ax.phobos.apple.com.edgesuite.net
brightcove.net
bufferapp.com
c.s-microsoft.com
cdn.cloudflare.net
cdn.embedly.com
cdn.optimizely.com
cdn.vidible.tv
cdn2.optimizely.com
cdn3.optimizely.com
cdnjs.cloudflare.com
cert.mgt.xboxlive.com
clientconfig.passport.net
clients1.google.com
clients2.google.com
clients3.google.com
clients4.google.com
clients5.google.com
clients6.google.com
cpms.spop10.ams.plex.bz
cpms35.spop10.ams.plex.bz
cse.google.com
ctldl.windowsupdate.com
d2c8v52ll5s99u.cloudfront.net
d2gatte9o95jao.cloudfront.net
dashboard.plex.tv
dataplicity.com
def-vef.xboxlive.com
delivery.vidible.tv
dev.virtualearth.net
device.auth.xboxlive.com
display.ugc.bazaarvoice.com
displaycatalog.mp.microsoft.com
dl.delivery.mp.microsoft.com
dl.dropbox.com
dl.dropboxusercontent.com
dns.msftncsi.com
download.sonarr.tv
drift.com
driftt.com
dynupdate.no-ip.com
ec-ns.sascdn.com
ecn.dev.virtualearth.net
edge.api.brightcove.com
eds.xboxlive.com
fonts.gstatic.com
forums.sonarr.tv
g.live.com
geo-prod.do.dsp.mp.microsoft.com
geo3.ggpht.com
giphy.com
github.com
github.io
googleapis.com
gravatar.com
gstatic.com
help.ui.xboxlive.com
hls.ted.com
i.s-microsoft.com
i.ytimg.com
i1.ytimg.com
imagesak.secureserver.net
img.vidible.tv
imgix.net
imgs.xkcd.com
instantmessaging-pa.googleapis.com
intercom.io
j.mp
jquery.com
jsdelivr.net
keystone.mwbsys.com
lastfm-img2.akamaized.net
licensing.xboxlive.com
live.com
login.aliexpress.com
login.live.com
login.microsoftonline.com
manifest.googlevideo.com
meta-db-worker02.pop.ric.plex.bz
meta.plex.bz
meta.plex.tv
microsoftonline.com
msftncsi.com
my.plexapp.com
nexusrules.officeapps.live.com
npr-news.streaming.adswizz.com
nine.plugins.plexapp.com
no-ip.com
node.plexapp.com
notify.xboxlive.com
ns1.dropbox.com
ns2.dropbox.com
o1.email.plex.tv
o2.sg0.plex.tv
ocsp.apple.com
office.com
office.net
office365.com
officeclient.microsoft.com
om.cbsi.com
onedrive.live.com
outlook.live.com
outlook.office365.com
pinterest.com
placehold.it
placeholdit.imgix.net
players.brightcove.net
pricelist.skype.com
products.office.com
proxy.plex.bz
proxy.plex.tv
proxy02.pop.ord.plex.bz
pubsub.plex.bz
pubsub.plex.tv
raw.githubusercontent.com
redirector.googlevideo.com
res.cloudinary.com
s.gateway.messenger.live.com
s.marketwatch.com
s.shopify.com
s.youtube.com
s.ytimg.com
s1.wp.com
s2.youtube.com
s3.amazonaws.com
sa.symcb.com
secure.avangate.com
secure.brightcove.com
secure.surveymonkey.com
services.sonarr.tv
sharepoint.com
skyhook.sonarr.tv
spclient.wg.spotify.com
ssl.p.jwpcdn.com
staging.plex.tv
status.plex.tv
t.co
t0.ssl.ak.dynamic.tiles.virtualearth.net
t0.ssl.ak.tiles.virtualearth.net
tawk.to
tedcdn.com
themoviedb.com
thetvdb.com
tinyurl.com
title.auth.xboxlive.com
title.mgt.xboxlive.com
traffic.libsyn.com
tvdb2.plex.tv
tvthemes.plexapp.com
twimg.com
twitter.com
ui.skype.com
v.shopify.com
video-stats.l.google.com
videos.vidible.tv
widget-cdn.rpxnow.com
wikipedia.org
win10.ipv6.microsoft.com
wordpress.com
wp.com
ws.audioscrobbler.com
www.dataplicity.com
www.googleapis.com
www.msftncsi.com
www.no-ip.com
www.youtube-nocookie.com
xbox.ipv6.microsoft.com
xboxexperiencesprod.experimentation.xboxlive.com
xflight.xboxlive.com
xkms.xboxlive.com
xsts.auth.xboxlive.com
youtu.be
youtube-nocookie.com
yt3.ggpht.com
mirror.cedia.org.ec
ransomwaretracker.abuse.ch
rufus.ie
pcengines.ch
external-preview.redd.it
preview.redd.it

EOF

# Configure blocklists
rm -f '/etc/pihole/adlists.list'
cat <<\EOF > '/etc/pihole/adlists.list'

# Config for urls that contain blocklist used with pihole
# File location is /etc/pihole/adlists.list

https://s3.amazonaws.com/lists.disconnect.me/simple_malvertising.txt
https://mirror1.malwaredomains.com/files/justdomains
https://hosts-file.net/exp.txt
https://hosts-file.net/emd.txt
https://hosts-file.net/psh.txt
https://mirror.cedia.org.ec/malwaredomains/immortal_domains.txt
https://www.malwaredomainlist.com/hostslist/hosts.txt
https://bitbucket.org/ethanr/dns-blacklists/raw/8575c9f96e5b4a1308f2f12394abd86d0927a4a0/bad_lists/Mandiant_APT1_Report_Appendix_D.txt
https://v.firebog.net/hosts/Prigent-Malware.txt
https://v.firebog.net/hosts/Prigent-Phishing.txt
https://phishing.army/download/phishing_army_blocklist_extended.txt
https://gitlab.com/quidsup/notrack-blocklists/raw/master/notrack-malware.txt
https://ransomwaretracker.abuse.ch/downloads/RW_DOMBL.txt
https://ransomwaretracker.abuse.ch/downloads/CW_C2_DOMBL.txt
https://ransomwaretracker.abuse.ch/downloads/LY_C2_DOMBL.txt
https://ransomwaretracker.abuse.ch/downloads/TC_C2_DOMBL.txt
https://ransomwaretracker.abuse.ch/downloads/TL_C2_DOMBL.txt
https://v.firebog.net/hosts/Shalla-mal.txt
https://raw.githubusercontent.com/StevenBlack/hosts/master/data/add.Risk/hosts
https://www.squidblacklist.org/downloads/dg-malicious.acl
https://gitlab.com/curben/urlhaus-filter/raw/master/urlhaus-filter-hosts.txt
https://raw.githubusercontent.com/DandelionSprout/adfilt/master/Alternate%20versions%20Anti-Malware%20List/AntiMalwareHosts.txt
https://raw.githubusercontent.com/HorusTeknoloji/TR-PhishingList/master/url-lists.txt
https://v.firebog.net/hosts/Airelle-hrsk.txt

EOF

# Configure blacklist
rm -f '/etc/pihole/blacklist.txt'
cat <<\EOF > '/etc/pihole/blacklist.txt'

# Config for blacklist used with pihole
# File location is /etc/pihole/blacklist.txt

watson.telemetry.microsoft.com
self.events.data.microsoft.com
activity.windows.com

EOF

# Configure regex
rm -f '/etc/pihole/regex.list'
cat <<\EOF > '/etc/pihole/regex.list'

^.+\.(ru|cn|ro|ml|ga|gq|cf|tk|pw|ua|ug|ve|)$

EOF
