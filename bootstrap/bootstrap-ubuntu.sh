#!/usr/bin/env bash

SCRIPT_DIR=$(dirname "${BASH_SOURCE[0]}")
SCRIPT_DIR=$(cd "$SCRIPT_DIR" && pwd)

source "$SCRIPT_DIR/helpers.sh"

__echo "Setting up the system..."

__confirm "Do you want to continue?" || exit 1

# make sure this only works on Ubuntu
if __command_exists "lsb_release"; then
    if [ "$(lsb_release -si)" != "Ubuntu" ]; then
        __error "This script only works on Ubuntu"
    fi
else
    # use cat /etc/*ease instead
    if [ ! -f /etc/os-release ]; then
        __error "This script only works on Ubuntu"
    fi

    if ! grep -q "ID=ubuntu" /etc/os-release; then
        __error "This script only works on Ubuntu"
    fi
fi

__logo

__command_exists "apt" || __error "apt is not installed"

__echo "Updating package lists..."
apt update

__echo "Upgrading packages..."
apt upgrade -y

# if sudo not available, install it
if ! __command_exists "sudo"; then
    __echo "Installing sudo..."
    apt install -y sudo
fi

sudo -v

# Authenticate
if ! sudo -nv &>/dev/null; then
    printf 'Before we get started, we need to have sudo access\n'
    printf 'If you not trust this bootstrap script, please press Ctrl+C to cancel\n'
    printf 'I recommend you to read the source code of this script before you continue\n'
    printf 'Enter your password (for sudo access):\n'
    sudo /usr/bin/true
    # Keep-alive: update existing `sudo` time stamp until bootstrap has finished
    while true; do
        sudo -n /usr/bin/true
        sleep 60
        kill -0 "$$" || exit
    done 2>/dev/null &
fi

set -e

step=1

function __add_ppas() {
    __echo "Adding PPAs"
    sudo add-apt-repository -y ppa:neovim-ppa/unstable
    __done "$step"
    step=$((step + 1))
}

function __install_essential_packages() {
    __echo "Installing essential packages..."
    sudo apt install -y \
        build-essential \
        curl \
        git \
        htop \
        jq \
        tmux \
        wget \
        neovim
    __done "$step"
    step=$((step + 1))
}
__install_essential_packages

function __install_shell() {
    __echo "Installing shell..."
    sudo apt install -y bash
    if [[ "$SHELL" != *bash ]]; then
        command -v bash | sudo tee -a /etc/shells
        chsh -s "$(command -v bash)"
    fi
    __done "$step"
    step=$((step + 1))
}
__install_shell

function __install_starship() {
    __echo "Installing starship if missing..."
    if __command_exists "starship"; then
        __done "$step"
        step=$((step + 1))
        return
    fi
    curl -sS https://starship.rs/install.sh | sh -s -- -y
    __done "$step"
    step=$((step + 1))
}
__install_starship

function __fix_locales() {
    __echo "Fixing locales..."
    apt-get install locales
    # use en_US.UTF-8 as default locale, and generate it
    sudo locale-gen en_US.UTF-8
    sudo update-locale LANG=en_US.UTF-8
    __done "$step"
}
__fix_locales

function __set_timezone() {
    __echo "Setting timezone..."
    sudo timedatectl set-timezone Asia/Shanghai
    __done "$step"
}
__set_timezone