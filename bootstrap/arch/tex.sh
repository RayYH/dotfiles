#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../helpers.sh"

__command_exists pacman || __error "pacman not found."

__echo "Installing texlive-core and dvipng via pacman..."
sudo pacman -Sy --noconfirm texlive-core dvipng

__command_exists latex || __error "'latex' not found on PATH"
__command_exists dvipng || __error "'dvipng' not found on PATH"

__echo "✔ TeX installed."
