#!/usr/bin/env bash

# Build the module and test it.
# PAM library has to be already installed on your system.

set -e

if [[ ! -e /etc/pam.d/pam-okh ]]; then
    echo "Missing /etc/pam.d/pam-okh, make sure PAM module is installed."
    echo "On NixOS, run './nixos_test.sh' once first using 'dev' target."
    exit 1
fi

cargo build
pamtester -v pam-okh "${USER}" authenticate

