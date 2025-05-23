#!/usr/bin/env bash

SCRIPT_DIR=$(dirname "${BASH_SOURCE[0]}")
SCRIPT_DIR=$(cd "$SCRIPT_DIR" && pwd)

set -e

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

__echo "Updating package lists..."
__command_exists "apt" || __error "apt is not installed"
sudo apt update
__echo "Upgrading packages..."
sudo apt upgrade -y

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

step=1

function __install_essential_packages() {
    __echo "Installing essential packages..."
    sudo apt install -y \
        build-essential \
        lsb-release \
        gnupg2 \
        ca-certificates \
        apt-transport-https \
        software-properties-common \
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

function __add_ppas() {
    __echo "Adding PPAs"
    if ! __command_exists "add-apt-repository"; then
        sudo apt install -y software-properties-common
    fi
    sudo add-apt-repository -y ppa:neovim-ppa/unstable
    sudo add-apt-repository -y ppa:longsleep/golang-backports
    sudo add-apt-repository -y ppa:ondrej/php
    __done "$step"
    step=$((step + 1))
}
__add_ppas

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

function __install_go() {
    __echo "Installing Go..."
    if __command_exists "go"; then
        __done "$step"
        step=$((step + 1))
        return
    fi
    sudo apt install -y golang-go
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
    sudo apt install -y python3
    sudo apt install -y python3-venv python3-pip
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
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
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
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
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
    npm install -g \
        yarn \
        http-server
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
    # --no-modify-path
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
    sudo apt install -y php8.4-{common,readline,bcmath,fpm,xml,mysql,zip,intl,ldap,gd,cli,bz2,curl,mbstring,pgsql,opcache,soap,cgi,redis}
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

function __install_miniforge() {
    __echo "Installing Miniforge..."
    if __command_exists "conda"; then
        __done "$step"
        step=$((step + 1))
        return
    fi
    curl -L -O "https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-$(uname)-$(uname -m).sh" && \
        bash Miniforge3-$(uname)-$(uname -m).sh -b
    rm -f Miniforge3-$(uname)-$(uname -m).sh
    __done "$step"
}
__install_miniforge


function __fix_locales() {
    __echo "Fixing locales..."
    DEBIAN_FRONTEND=noninteractive sudo apt-get install -y --no-install-recommends tzdata locales
    sudo locale-gen en_US.UTF-8
    sudo update-locale LANG=en_US.UTF-8
    __done "$step"
}
__fix_locales
