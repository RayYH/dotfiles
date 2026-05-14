#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../helpers.sh"

__command_exists brew || __error "Homebrew not found. Install it from https://brew.sh/"

__echo "Installing Lua 5.1 via Homebrew..."
brew install lua@5.1
brew link lua@5.1 --force

__echo "✔ Lua 5.1 installed."
