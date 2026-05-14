#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../helpers.sh"

__command_exists pip || __error "pip is not installed"

packages=(
    "black"
    "flake8"
    "isort"
    "neovim"
)

__echo "Installing global pip packages..."
for pkg in "${packages[@]}"; do
    pip install "$pkg"
done

__echo "✔ pip global packages installed."
