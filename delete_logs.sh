#!/bin/sh

# Simple script to clear log files I have setup.
/usr/bin/find /home/matthew/logs/cronlog_reloadufw.log -mtime +30 -delete
/usr/bin/find /home/matthew/logs/cronlog_update.log -mtime +30 -delete
/usr/bin/find /home/matthew/logs/cronlog_send_ip_address.log -mtime +30 -delete
/usr/bin/find /home/matthew/logs/freedns_matthewmiller_us_to.log -mtime +30 -delete
/usr/bin/find /home/matthew/logs/get_email_from_vpn_connections.log -mtime +30 -delete
