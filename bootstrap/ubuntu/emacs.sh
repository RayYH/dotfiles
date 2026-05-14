#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../helpers.sh"

EMACS_VERSION="${EMACS_VERSION:-30.1}"
BUILD_DIR="${BUILD_DIR:-/tmp/emacs-build}"

__echo "Installing build dependencies..."
sudo apt-get update -y
sudo apt-get install -y \
    autoconf make gcc g++ pkg-config \
    libgnutls28-dev libncurses-dev \
    libgtk-3-dev libxpm-dev libgif-dev libjpeg-dev libpng-dev libtiff-dev \
    libgccjit-dev libjansson-dev libtree-sitter-dev \
    texinfo

__echo "Downloading Emacs ${EMACS_VERSION} source..."
mkdir -p "$BUILD_DIR"
tarball="emacs-${EMACS_VERSION}.tar.xz"
curl -fL "https://ftp.gnu.org/gnu/emacs/${tarball}" -o "${BUILD_DIR}/${tarball}"
tar -xJf "${BUILD_DIR}/${tarball}" -C "$BUILD_DIR"

__echo "Configuring Emacs ${EMACS_VERSION} (native-comp, tree-sitter)..."
src="${BUILD_DIR}/emacs-${EMACS_VERSION}"
cd "$src"
./autogen.sh
./configure \
    --with-native-compilation=aot \
    --with-tree-sitter \
    --with-json \
    --with-gnutls \
    --with-x-toolkit=gtk3 \
    --with-xpm --with-gif --with-jpeg --with-png --with-tiff \
    --without-compress-install

__echo "Building Emacs (this will take a while)..."
make -j"$(nproc)"

__echo "Installing Emacs..."
sudo make install

cd /
rm -rf "$BUILD_DIR"

emacs --version 2>/dev/null || true
__echo "✔ Emacs ${EMACS_VERSION} installed."
