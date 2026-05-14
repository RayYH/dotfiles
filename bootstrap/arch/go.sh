#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../helpers.sh"

__command_exists curl || __error "curl is required"

arch="$(uname -m)"
case "$arch" in
    x86_64)  arch="amd64" ;;
    aarch64) arch="arm64" ;;
    armv6l)  arch="armv6l" ;;
    *) __error "Unsupported architecture: $arch" ;;
esac

version="$(curl -fsSL 'https://go.dev/VERSION?m=text' | head -1)"
__echo "Installing ${version} (linux/${arch}) from go.dev..."

tarball="${version}.linux-${arch}.tar.gz"
curl -fsSL "https://go.dev/dl/${tarball}" -o "/tmp/${tarball}"
sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf "/tmp/${tarball}"
rm "/tmp/${tarball}"

__echo "✔ Go installed."
__echo "Add to PATH: export PATH=\$PATH:/usr/local/go/bin"
