#!/bin/sh

# Simple script to clear log files I have setup.

# Variables
reload_ufw_log="/home/matthew/logs/cronlog_reloadufw.log"
update_log="/home/matthew/logs/cronlog_update.log"
send_ip_address_log="/home/matthew/logs/cronlog_send_ip_address.log"
freedns_log="/home/matthew/logs/freedns_matthewmiller_us_to.log"
email_vpn_connections_log="/home/matthew/logs/get_email_from_vpn_connections.log"

# Script to delete logs
/usr/bin/find "${reload_ufw_log}" -mtime +30 -delete
/usr/bin/find "${update_log}" -mtime +30 -delete
/usr/bin/find "${send_ip_address_log}" -mtime +30 -delete
/usr/bin/find "${freedns_log}" -mtime +30 -delete
/usr/bin/find "${email_vpn_connections_log}" -mtime +30 -delete
