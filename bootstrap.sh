#!/usr/bin/env bash

WORKING_DIR=$(dirname "${BASH_SOURCE[0]}")
SCRIPT_DIR=$(cd "$WORKING_DIR" && pwd)

set -e

# determine the OS
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    source "$SCRIPT_DIR/bootstrap/bootstrap-ubuntu.sh"
elif [[ "$OSTYPE" == "darwin"* ]]; then
    source "$SCRIPT_DIR/bootstrap/bootstrap-macos.sh"
elif [[ "$OSTYPE" == "linux-musl" ]]; then
    source "$SCRIPT_DIR/bootstrap/bootstrap-arch.sh"
else
    echo "Unsupported OS"
    exit 1
fi