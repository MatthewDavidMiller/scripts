#!/bin/bash
# Does not need to be executed as root.

function configure_wsl() {
    bash -c "echo export DISPLAY=localhost:0.0" >>~/.bashrc
}

# Call functions
configure_wsl
