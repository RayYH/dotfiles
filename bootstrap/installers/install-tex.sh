#!/usr/bin/env bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../helpers.sh"

OS="$(uname -s)"

install_macos() {
    if ! __command_exists brew; then
        __error "Homebrew not found. Install it from https://brew.sh/"
    fi

    __echo "Installing BasicTeX via Homebrew..."
    brew install --cask basictex

    export PATH="/Library/TeX/texbin:$PATH"

    __echo "Updating tlmgr and installing dvipng..."
    sudo tlmgr update --self
    sudo tlmgr install dvipng
}

install_debian() {
    __echo "Installing texlive and dvipng via apt..."
    sudo apt-get update -qq
    sudo apt-get install -y texlive dvipng
}

install_arch() {
    __echo "Installing texlive and dvipng via pacman..."
    sudo pacman -Sy --noconfirm texlive-core dvipng
}

install_fedora() {
    __echo "Installing texlive and dvipng via dnf..."
    sudo dnf install -y texlive dvipng
}

install_linux() {
    if __command_exists apt-get; then
        install_debian
    elif __command_exists pacman; then
        install_arch
    elif __command_exists dnf; then
        install_fedora
    else
        __error "No supported package manager found (apt, pacman, dnf)."
    fi
}

case "$OS" in
    Darwin) install_macos ;;
    Linux)  install_linux ;;
    *)      __error "Unsupported OS: $OS" ;;
esac

__echo "Verifying installation..."
if ! __command_exists latex; then
    __error "'latex' not found on PATH. You may need to restart your terminal."
fi
if ! __command_exists dvipng; then
    __error "'dvipng' not found on PATH."
fi

__done "TeX installation complete. 'latex' and 'dvipng' are available."
