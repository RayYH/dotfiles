#!/usr/bin/env bash

set -e

OS="$(uname -s)"

install_macos() {
    if ! command -v brew >/dev/null 2>&1; then
        echo "❌ Homebrew not found. Install it from https://brew.sh/"
        exit 1
    fi

    echo "➡️ Installing zoxide via Homebrew..."
    brew install zoxide
}

install_linux() {
    if ! command -v curl >/dev/null 2>&1; then
        echo "❌ curl is required but not installed."
        exit 1
    fi

    echo "➡️ Installing zoxide using official installer..."
    curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
}

case "$OS" in
    Darwin)
        install_macos
        ;;
    Linux)
        install_linux
        ;;
    *)
        echo "❌ Unsupported OS: $OS"
        exit 1
        ;;
esac

echo ""
echo "✅ zoxide installation complete!"
echo ""
echo "Add this to your shell config:"
echo "  eval \"\$(zoxide init zsh)\""
echo "  # or bash/fish/etc."

