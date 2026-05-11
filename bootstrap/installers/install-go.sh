#!/usr/bin/env bash

set -e

OS="$(uname -s)"

install_macos() {
    if ! command -v brew >/dev/null 2>&1; then
        echo "❌ Homebrew not found. Install it from https://brew.sh/"
        exit 1
    fi

    echo "➡️ Installing Go via Homebrew..."
    brew install go
}

install_linux() {
    if ! command -v curl >/dev/null 2>&1; then
        echo "❌ curl is required but not installed."
        exit 1
    fi

    local arch
    case "$(uname -m)" in
        x86_64)  arch="amd64" ;;
        aarch64) arch="arm64" ;;
        armv6l)  arch="armv6l" ;;
        *)
            echo "❌ Unsupported architecture: $(uname -m)"
            exit 1
            ;;
    esac

    local version
    version="$(curl -fsSL 'https://go.dev/VERSION?m=text' | head -1)"

    echo "➡️ Installing ${version} (linux/${arch}) from go.dev..."
    local tarball="${version}.linux-${arch}.tar.gz"
    curl -fsSL "https://go.dev/dl/${tarball}" -o "/tmp/${tarball}"
    sudo rm -rf /usr/local/go
    sudo tar -C /usr/local -xzf "/tmp/${tarball}"
    rm "/tmp/${tarball}"

    echo ""
    echo "Add /usr/local/go/bin to your PATH if not already set:"
    echo "  export PATH=\$PATH:/usr/local/go/bin"
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

echo "✅ Go installation complete!"
