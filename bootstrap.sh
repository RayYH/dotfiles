#!/usr/bin/env bash

WORKING_DIR=$(dirname "${BASH_SOURCE[0]}")
SCRIPT_DIR=$(cd "$WORKING_DIR" && pwd)

set -e

# determine the OS
if [ -f /etc/os-release ] && grep -qi "ubuntu" /etc/os-release; then
    source "$SCRIPT_DIR/bootstrap/bootstrap-ubuntu.sh"
elif [ -f /etc/os-release ] && grep -qi "arch" /etc/os-release; then
    source "$SCRIPT_DIR/bootstrap/bootstrap-arch.sh"
elif [[ "$OSTYPE" == "darwin"* ]]; then
    source "$SCRIPT_DIR/bootstrap/bootstrap-mac.sh"
else
    echo "Unsupported OS"
    exit 1
fi
