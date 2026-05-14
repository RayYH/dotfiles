#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../helpers.sh"

__command_exists pacman || __error "pacman not found. Are you on Arch Linux?"

__echo "Installing GNU Emacs via pacman..."
sudo pacman -S --noconfirm emacs

emacs --version 2>/dev/null || true
__echo "✔ Emacs installed."
