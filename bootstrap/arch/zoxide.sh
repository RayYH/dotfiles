#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../helpers.sh"

__command_exists curl || __error "curl is required"

__echo "Installing zoxide via official installer..."
curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh

__echo "✔ zoxide installed."
__echo "Add to your shell config: eval \"\$(zoxide init bash)\""
