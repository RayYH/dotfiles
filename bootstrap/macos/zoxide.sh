#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../helpers.sh"

__command_exists brew || __error "Homebrew not found. Install it from https://brew.sh/"

__echo "Installing zoxide via Homebrew..."
brew install zoxide

__echo "✔ zoxide installed."
__echo "Add to your shell config: eval \"\$(zoxide init zsh)\""
