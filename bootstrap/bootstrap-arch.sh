#!/usr/bin/env bash

SCRIPT_DIR=$(dirname "${BASH_SOURCE[0]}")
SCRIPT_DIR=$(cd "$SCRIPT_DIR" && pwd)

set -e

source "$SCRIPT_DIR/helpers.sh"

__echo "Setting up the system..."
__confirm "Do you want to continue?" || exit 1

# Ensure the script is running on Arch Linux
if [ ! -f /etc/os-release ] || ! grep -q "ID=arch" /etc/os-release; then
    __error "This script only works on Arch Linux"
fi

__logo

__echo "Updating package lists..."
__command_exists "pacman" || __error "pacman is not installed"
sudo pacman -Syu --noconfirm

# Install sudo if missing
if ! __command_exists "sudo"; then
    __echo "Installing sudo..."
    pacman -S --noconfirm sudo
fi

sudo -v

# Authenticate sudo
if ! sudo -nv &>/dev/null; then
    printf 'We need sudo access to continue\n'
    printf 'If you do not trust this script, press Ctrl+C to cancel\n'
    printf 'Enter your password for sudo access:\n'
    sudo /usr/bin/true
    while true; do
        sudo -n /usr/bin/true
        sleep 60
        kill -0 "$$" || exit
    done 2>/dev/null &
fi

step=1

function __install_essential_packages() {
    __echo "Installing essential packages..."
    sudo pacman -S --noconfirm --needed \
        base-devel \
        lsb-release \
        gnupg \
        ca-certificates \
        curl \
        git \
        htop \
        jq \
        tmux \
        wget \
        zip \
        unzip \
        neovim
    __done "$step"
    step=$((step + 1))
}
__install_essential_packages

function __install_shell() {
    __echo "Installing shell..."
    sudo pacman -S --noconfirm --needed bash
    if [[ "$SHELL" != *bash ]]; then
        command -v bash | sudo tee -a /etc/shells
        chsh -s "$(command -v bash)"
    fi
    __done "$step"
    step=$((step + 1))
}
__install_shell

function __install_yay() {
    __echo "Installing yay (AUR helper)..."
    if __command_exists "yay"; then
        __done "$step"
        step=$((step + 1))
        return
    fi
    git clone https://aur.archlinux.org/yay.git /tmp/yay
    cd /tmp/yay && makepkg -si --noconfirm
    cd "$SCRIPT_DIR"
    rm -rf /tmp/yay
    __done "$step"
}
__install_yay

function __install_starship() {
    __echo "Installing starship if missing..."
    if __command_exists "starship"; then
        __done "$step"
        step=$((step + 1))
        return
    fi
    sudo pacman -S --noconfirm starship
    __done "$step"
    step=$((step + 1))
}
__install_starship

function __install_go() {
    __echo "Installing Go..."
    if __command_exists "go"; then
        __done "$step"
        step=$((step + 1))
        return
    fi
    sudo pacman -S --noconfirm go
    __done "$step"
}
__install_go

function __install_python3() {
    __echo "Installing Python3..."
    if __command_exists "python3"; then
        __done "$step"
        step=$((step + 1))
        return
    fi
    sudo pacman -S --noconfirm python python-pip
    __done "$step"
}
__install_python3

function __install_rust() {
    __echo "Installing Rust..."
    if __command_exists "rustc"; then
        __done "$step"
        step=$((step + 1))
        return
    fi
    sudo pacman -S --noconfirm rust
    __done "$step"
}
__install_rust

function __install_nvm_and_nodejs() {
    __echo "Installing NVM and Node.js..."
    if __command_exists "nvm"; then
        __done "$step"
        step=$((step + 1))
        return
    fi
    yay -S --noconfirm nvm
    source /usr/share/nvm/init-nvm.sh
    nvm install 22
    nvm use 22
    __done "$step"
    step=$((step + 1))
}
__install_nvm_and_nodejs

function __install_npm_packages_global() {
    __echo "Installing npm packages globally..."
    if __command_exists "yarn"; then
        __done "$step"
        step=$((step + 1))
        return
    fi
    npm install -g yarn http-server
    __done "$step"
    step=$((step + 1))
}
__install_npm_packages_global

function __install_deno() {
    __echo "Installing Deno..."
    if __command_exists "deno"; then
        __done "$step"
        step=$((step + 1))
        return
    fi
    curl -fsSL https://deno.land/install.sh | sh -s -- -y
    __done "$step"
}
__install_deno

function __install_php() {
    __echo "Installing PHP..."
    if __command_exists "php"; then
        __done "$step"
        step=$((step + 1))
        return
    fi
    sudo pacman -S --noconfirm php php-fpm php-gd php-intl php-sqlite php-redis xdebug
    __done "$step"
}
__install_php

function __install_composer() {
    __echo "Installing Composer..."
    if __command_exists "composer"; then
        __done "$step"
        step=$((step + 1))
        return
    fi
    curl -sS https://getcomposer.org/installer | php
    sudo mv composer.phar /usr/local/bin/composer
    __done "$step"
}
__install_composer


function __fix_locales() {
    __echo "Fixing locales..."
    sudo pacman -S --noconfirm --needed glibc
    sudo locale-gen
    sudo localectl set-locale LANG=en_US.UTF-8
    __done "$step"
}
__fix_locales