#!/usr/bin/env bash

set -euo pipefail

# Absolute path to this script's directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

bootstrap() {
    local script="$SCRIPT_DIR/bootstrap/$1"

    if [[ ! -f "$script" ]]; then
        echo "Bootstrap script not found: $script" >&2
        exit 1
    fi

    # shellcheck source=/dev/null
    source "$script"
}

ensure_sudo() {
    local distro_id="${1:-}"

    # If sudo already exists, we're done
    if command -v sudo >/dev/null 2>&1; then
        return 0
    fi

    echo "'sudo' command not found. Attempting to install it for '${distro_id:-unknown}'..."

    # If we don't have root, we usually can't install sudo
    if [[ "${EUID:-$(id -u)}" -ne 0 ]]; then
        echo "You are not root, and 'sudo' is not installed."
        echo "Please run this script as root once so it can install 'sudo'."
        exit 1
    fi

    case "${distro_id,,}" in
    ubuntu | debian)
        apt-get update
        apt-get install -y sudo
        ;;
    arch | archlinux)
        pacman -Sy --noconfirm sudo
        ;;
    darwin*)
        echo "On macOS, 'sudo' should normally be present. Please install/fix it manually." >&2
        exit 1
        ;;
    *)
        echo "Automatic 'sudo' installation is not supported for distro: '${distro_id:-unknown}'" >&2
        exit 1
        ;;
    esac

    if ! command -v sudo >/dev/null 2>&1; then
        echo "Failed to install 'sudo'. Please install it manually." >&2
        exit 1
    fi

    echo "'sudo' successfully installed."
}

# macOS first (no /etc/os-release needed)
if [[ "${OSTYPE:-}" == darwin* ]]; then
    ensure_sudo "darwin"
    bootstrap "bootstrap-mac.sh"

# Linux: use /etc/os-release
elif [[ -f /etc/os-release ]]; then
    # shellcheck disable=SC1091
    . /etc/os-release
    distro_id="${ID:-unknown}"

    ensure_sudo "${distro_id}"

    case "${distro_id,,}" in
    ubuntu)
        bootstrap "bootstrap-ubuntu.sh"
        ;;
    arch | archlinux)
        bootstrap "bootstrap-arch.sh"
        ;;
    *)
        echo "Unsupported Linux distribution: ${distro_id}" >&2
        exit 1
        ;;
    esac

else
    echo "Unsupported OS (no /etc/os-release and not macOS)" >&2
    exit 1
fi
