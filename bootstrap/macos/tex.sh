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
sudo tlmgr update --all || true  # mirror sync failures are non-fatal
# for org mode
sudo tlmgr install dvipng
sudo tlmgr install wrapfig capt-of

__echo "✔ TeX installed."
