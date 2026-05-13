#!/usr/bin/env bash
# Install and update the system package manager.
# macOS  → Homebrew (install if missing, update sources + taps)
# Ubuntu → apt     (update sources + PPAs)
# Arch   → pacman  (update sources) + yay AUR helper

set -euo pipefail

OS="$(uname -s)"

_detect_distro() {
    if [[ -f /etc/os-release ]]; then
        # shellcheck disable=SC1091
        . /etc/os-release
        echo "${ID:-unknown}"
    else
        echo "unknown"
    fi
}

_install_macos() {
    if ! command -v brew >/dev/null 2>&1; then
        echo "➡️ Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    else
        echo "✅ Homebrew already installed."
    fi

    # Ensure brew is on PATH (differs between Apple Silicon and Intel)
    if [[ "$(uname -m)" == "arm64" ]]; then
        export PATH="/opt/homebrew/bin:$PATH"
    else
        export PATH="/usr/local/bin:$PATH"
    fi

    echo "➡️ Updating Homebrew and package sources..."
    brew update
    brew upgrade
    brew cleanup

    echo "➡️ Disabling Homebrew analytics..."
    brew analytics off
}

_install_ubuntu() {
    local SUDO=""
    if [[ $EUID -ne 0 ]]; then
        command -v sudo >/dev/null 2>&1 || { echo "❌ sudo is required but not installed."; exit 1; }
        SUDO="sudo"
    fi

    echo "➡️ Updating apt package sources..."
    $SUDO apt-get update -y

    echo "➡️ Upgrading installed packages..."
    $SUDO apt-get upgrade -y

    echo "➡️ Ensuring apt prerequisites are present..."
    $SUDO apt-get install -y \
        apt-transport-https \
        software-properties-common \
        ca-certificates \
        gnupg2 \
        curl
}

_install_arch() {
    local SUDO=""
    if [[ $EUID -ne 0 ]]; then
        command -v sudo >/dev/null 2>&1 || { echo "❌ sudo is required but not installed."; exit 1; }
        SUDO="sudo"
    fi

    echo "➡️ Updating pacman package sources and upgrading..."
    $SUDO pacman -Syu --noconfirm

    if ! command -v yay >/dev/null 2>&1; then
        echo "➡️ Installing yay (AUR helper)..."
        $SUDO pacman -S --noconfirm --needed git base-devel
        git clone https://aur.archlinux.org/yay.git /tmp/yay
        cd /tmp/yay && makepkg -si --noconfirm
        cd - >/dev/null
        rm -rf /tmp/yay
    else
        echo "✅ yay already installed."
    fi

    echo "➡️ Refreshing AUR sources via yay..."
    yay -Syu --noconfirm
}

case "$OS" in
    Darwin)
        _install_macos
        ;;
    Linux)
        distro="$(_detect_distro)"
        case "$distro" in
            ubuntu)  _install_ubuntu ;;
            arch) _install_arch ;;
            *)
                echo "❌ Unsupported Linux distro: $distro"
                exit 1
                ;;
        esac
        ;;
    *)
        echo "❌ Unsupported OS: $OS"
        exit 1
        ;;
esac

echo ""
echo "✅ Package manager setup complete!"
