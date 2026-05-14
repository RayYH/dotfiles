#!/usr/bin/env bash

set -e

OS="$(uname -s)"

install_macos() {
    if ! command -v brew >/dev/null 2>&1; then
        echo "❌ Homebrew not found. Install it from https://brew.sh/"
        exit 1
    fi

    if brew tap | grep -q "d12frosted/emacs-plus"; then
        echo "➡️ emacs-plus tap already present."
    else
        echo "➡️ Tapping d12frosted/emacs-plus for latest GNU Emacs..."
        brew tap d12frosted/emacs-plus
    fi

    # Native compilation is enabled by default in emacs-plus@30+
    echo "➡️ Installing emacs-plus-app (latest GNU Emacs with native-comp)..."
    brew install --cask emacs-plus-app
}

install_ubuntu() {
    if command -v snap >/dev/null 2>&1; then
        echo "➡️ Installing latest GNU Emacs via snap..."
        sudo snap install emacs --classic
    else
        echo "➡️ snap not found; falling back to Kelleyk PPA for a recent Emacs..."
        sudo apt-get update -y
        sudo apt-get install -y software-properties-common
        sudo add-apt-repository -y ppa:kelleyk/emacs
        sudo apt-get update -y
        # Install the highest numbered emacs version available from the PPA
        local pkg
        pkg=$(apt-cache search '^emacs[0-9]' | awk '{print $1}' | sort -V | tail -1)
        echo "➡️ Installing ${pkg}..."
        sudo apt-get install -y "${pkg}"
    fi
}

install_arch() {
    if ! command -v pacman >/dev/null 2>&1; then
        echo "❌ pacman not found. Are you on Arch Linux?"
        exit 1
    fi

    echo "➡️ Installing GNU Emacs via pacman..."
    sudo pacman -Syu --noconfirm emacs
}

install_linux() {
    if [ -f /etc/os-release ]; then
        # shellcheck source=/dev/null
        . /etc/os-release
        case "${ID:-}" in
            ubuntu|debian|linuxmint|pop)
                install_ubuntu
                return
                ;;
            arch|manjaro|endeavouros)
                install_arch
                return
                ;;
        esac
        # Walk ID_LIKE for derivative distros (e.g. ID_LIKE="debian")
        for like in ${ID_LIKE:-}; do
            case "$like" in
                debian|ubuntu)
                    install_ubuntu
                    return
                    ;;
                arch)
                    install_arch
                    return
                    ;;
            esac
        done
    fi

    echo "❌ Unsupported Linux distribution. Install GNU Emacs manually from https://www.gnu.org/software/emacs/"
    exit 1
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
emacs --version 2>/dev/null || true
echo "✅ GNU Emacs installation complete!"
