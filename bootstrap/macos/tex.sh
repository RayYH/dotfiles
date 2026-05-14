#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../helpers.sh"

__command_exists brew || __error "Homebrew not found. Install it from https://brew.sh/"

__echo "Installing BasicTeX via Homebrew..."
brew install --cask basictex

export PATH="/Library/TeX/texbin:$PATH"

__echo "Updating tlmgr and installing dvipng..."
sudo tlmgr update --self
sudo tlmgr install dvipng

__command_exists latex || __error "'latex' not found on PATH. Restart your terminal."
__command_exists dvipng || __error "'dvipng' not found on PATH."

__echo "✔ TeX installed."
