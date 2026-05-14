#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../helpers.sh"

__echo "Installing texlive and dvipng..."
sudo apt-get update -qq
sudo apt-get install -y texlive dvipng

__command_exists latex || __error "'latex' not found on PATH"
__command_exists dvipng || __error "'dvipng' not found on PATH"

__echo "✔ TeX installed."
