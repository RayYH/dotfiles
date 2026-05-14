#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../helpers.sh"

__command_exists mise || __error "mise is not installed. See https://mise.jdx.dev/"

__echo "Installing Lua 5.1 via mise..."
mise plugins add lua
mise use -g lua@5.1
ln -sf ~/.local/share/mise/installs/lua/5.1/bin/lua ~/.local/bin/lua5.1

__echo "✔ Lua 5.1 installed."
