#!/bin/bash

# Setup log rotate to keep log files from getting too large in size.

function get_username() {
    user_name=$(logname)
}

function log_rotate_config_setup() {
    touch -a '/etc/logrotate.conf'
    mkdir -p "/home/$user_name/config_backups"
    cp '/etc/logrotate.conf' "/home/$user_name/config_backups/logrotate.conf.backup"
    grep -q "^\s*[#]*\s*daily|weekly|monthly\s*$" '/etc/logrotate.conf' && sed -i "s,^\s*[#]*\s*daily|weekly|monthly\s*$,daily," '/etc/logrotate.conf' || printf '%s\n' 'daily' >>'/etc/logrotate.conf'
    grep -q "^\s*[#]*\s*minsize.*$" '/etc/logrotate.conf' && sed -i "s,^\s*[#]*\s*minsize.*$,minsize 100M," '/etc/logrotate.conf' || printf '%s\n' 'minsize 100M' >>'/etc/logrotate.conf'
    grep -q "^\s*[#]*\s*rotate\s*[0-9]*$" '/etc/logrotate.conf' && sed -i "s,^\s*[#]*\s*rotate\s*[0-9]*$,rotate 4," '/etc/logrotate.conf' || printf '%s\n' 'rotate 4' >>'/etc/logrotate.conf'
    grep -q "^\s*[#]*\s*compress\s*$" '/etc/logrotate.conf' && sed -i "s,^\s*[#]*\s*compress\s*$,compress," '/etc/logrotate.conf' || printf '%s\n' 'compress' >>'/etc/logrotate.conf'

}

function log_rotate_install() {
    apt-get install -y logrotate
}

get_username
log_rotate_install
log_rotate_config_setup
