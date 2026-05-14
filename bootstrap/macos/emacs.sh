#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../helpers.sh"

__command_exists brew || __error "Homebrew not found. Install it from https://brew.sh/"

if ! brew tap | grep -q "d12frosted/emacs-plus"; then
    __echo "Tapping d12frosted/emacs-plus..."
    brew tap d12frosted/emacs-plus
fi

__echo "Installing emacs-plus (latest GNU Emacs with native-comp)..."
brew install --cask emacs-plus-app

emacs --version 2>/dev/null || true
__echo "✔ Emacs installed."
