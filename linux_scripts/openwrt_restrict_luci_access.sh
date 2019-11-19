#!/bin/bash

# Set http port and ip to listen to.
uci set uhttpd.main.listen_http='10.1.10.1:80'

# Set https port and ip to listen to.
uci set uhttpd.main.listen_https='10.1.10.1:443'

# Redirect http to https.
uci set uhttpd.main.redirect_https='1'

# Apply changes
uci commit