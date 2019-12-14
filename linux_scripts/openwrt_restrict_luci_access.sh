#!/bin/bash
# Does not need to be executed as root.

# Set http port and ip to listen to.
sudo uci set uhttpd.main.listen_http='10.1.10.1:80'

# Set https port and ip to listen to.
sudo uci set uhttpd.main.listen_https='10.1.10.1:443'

# Redirect http to https.
sudo uci set uhttpd.main.redirect_https='1'

# Apply changes
sudo uci commit