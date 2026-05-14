#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../helpers.sh"

__command_exists npm || __error "npm is not installed"

packages=(
    "http-server"
)

__echo "Installing global npm packages..."
for pkg in "${packages[@]}"; do
    npm install -g "$pkg"
done

__echo "✔ npm global packages installed."
