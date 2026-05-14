#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../helpers.sh"

__command_exists brew || __error "Homebrew not found. Install it from https://brew.sh/"

__echo "Installing Go via Homebrew..."
brew install go

go version
__echo "✔ Go installed."
