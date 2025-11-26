#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$SCRIPT_DIR/helpers.sh"

__echo "Setting up the system..."
__confirm "Do you want to continue?" || exit 1

# Ensure this is Ubuntu
if [[ ! -f /etc/os-release ]]; then
    __error "This script only works on Ubuntu"
fi

# shellcheck disable=SC1091
. /etc/os-release
if [[ "${ID,,}" != "ubuntu" ]]; then
    __error "This script only works on Ubuntu (detected: ${ID:-unknown})"
fi

__logo

# Ensure apt-get exists
__command_exists "apt-get" || __error "apt-get is not installed"

# Handle sudo logic
SUDO=""
if [[ $EUID -eq 0 ]]; then
    # Running as root; sudo is optional
    if ! __command_exists "sudo"; then
        __echo "Installing sudo (running as root)..."
        apt-get update
        apt-get install -y sudo
    fi
else
    # Not root -> sudo is required
    __command_exists "sudo" || __error "'sudo' is required when not running as root. Please install sudo first."
    SUDO="sudo"

    # Warm up sudo and keep it alive
    if ! sudo -nv &>/dev/null; then
        printf 'Before we get started, we need to have sudo access\n'
        printf 'If you do not trust this bootstrap script, press Ctrl+C to cancel\n'
        printf 'I recommend you read the source code of this script before continuing\n'
        printf 'Enter your password (for sudo access):\n'
        sudo /usr/bin/true
        # Keep-alive: update existing `sudo` time stamp until bootstrap has finished
        while true; do
            sudo -n /usr/bin/true
            sleep 60
            kill -0 "$$" || exit
        done 2>/dev/null &
    fi
fi

__echo "Updating package lists..."
$SUDO apt-get update -y
__echo "Upgrading packages..."
$SUDO apt-get upgrade -y

step=1
__next_step() {
    __done "$step"
    step=$((step + 1))
}

__install_essential_packages() {
    __echo "Installing essential packages..."
    $SUDO apt-get install -y \
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
    __next_step
}
__install_essential_packages

__add_ppas() {
    __echo "Adding PPAs..."
    if ! __command_exists "add-apt-repository"; then
        $SUDO apt-get install -y software-properties-common
    fi
    $SUDO add-apt-repository -y ppa:neovim-ppa/unstable
    $SUDO add-apt-repository -y ppa:longsleep/golang-backports
    $SUDO add-apt-repository -y ppa:ondrej/php
    $SUDO apt-get update -y
    __next_step
}
__add_ppas

__install_shell() {
    __echo "Installing shell..."
    $SUDO apt-get install -y bash
    if [[ "$SHELL" != *bash ]]; then
        command -v bash | $SUDO tee -a /etc/shells >/dev/null
        chsh -s "$(command -v bash)"
    fi
    __next_step
}
__install_shell

__install_starship() {
    __echo "Installing starship if missing..."
    if __command_exists "starship"; then
        __next_step
        return
    fi
    curl -sS https://starship.rs/install.sh | sh -s -- -y
    __next_step
}
__install_starship

__install_go() {
    __echo "Installing Go..."
    if __command_exists "go"; then
        __next_step
        return
    fi
    $SUDO apt-get install -y golang-go
    __next_step
}
__install_go

__install_python3() {
    __echo "Installing Python3..."
    if __command_exists "python3"; then
        __next_step
        return
    fi
    $SUDO apt-get install -y python3 python3-venv python3-pip
    __next_step
}
__install_python3

__install_rust() {
    __echo "Installing Rust..."
    if __command_exists "rustc"; then
        __next_step
        return
    fi
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    __next_step
}
__install_rust

__install_nvm_and_nodejs() {
    __echo "Installing NVM and Node.js..."
    # Prefer checking the installed NVM dir; nvm is often a shell function
    if [[ -s "$HOME/.nvm/nvm.sh" ]]; then
        __next_step
        return
    fi
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash

    export NVM_DIR="$HOME/.nvm"
    # shellcheck disable=SC1090
    [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"

    nvm install 24
    nvm use 24
    __next_step
}
__install_nvm_and_nodejs

__install_npm_packages_global() {
    __echo "Installing npm packages globally..."
    if __command_exists "yarn"; then
        __next_step
        return
    fi
    npm install -g \
        pnpm \
        yarn \
        http-server
    __next_step
}
__install_npm_packages_global

__install_deno() {
    __echo "Installing Deno..."
    if __command_exists "deno"; then
        __next_step
        return
    fi
    curl -fsSL https://deno.land/install.sh | sh -s -- -y
    __next_step
}
__install_deno

__install_php() {
    __echo "Installing PHP..."
    if __command_exists "php"; then
        __next_step
        return
    fi
    $SUDO apt-get install -y \
        php8.4-{common,readline,bcmath,fpm,xml,mysql,zip,intl,ldap,gd,cli,bz2,curl,mbstring,pgsql,opcache,soap,cgi,redis}
    __next_step
}
__install_php

__install_composer() {
    __echo "Installing Composer..."
    if __command_exists "composer"; then
        __next_step
        return
    fi
    curl -sS https://getcomposer.org/installer | php
    $SUDO mv composer.phar /usr/local/bin/composer
    __next_step
}
__install_composer

__install_miniforge() {
    __echo "Installing Miniforge..."
    if __command_exists "conda"; then
        __next_step
        return
    fi
    local installer
    installer="Miniforge3-$(uname)-$(uname -m).sh"
    curl -L -O "https://github.com/conda-forge/miniforge/releases/latest/download/${installer}"
    bash "${installer}" -b
    rm -f "${installer}"
    __next_step
}
__install_miniforge

__fix_locales() {
    __echo "Fixing locales..."
    DEBIAN_FRONTEND=noninteractive $SUDO apt-get install -y --no-install-recommends tzdata locales
    $SUDO locale-gen en_US.UTF-8
    $SUDO update-locale LANG=en_US.UTF-8
    __next_step
}
__fix_locales
