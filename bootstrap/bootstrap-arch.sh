#!/usr/bin/env bash

set -e

SCRIPT_DIR=$(dirname "${BASH_SOURCE[0]}")
SCRIPT_DIR=$(cd "$SCRIPT_DIR" && pwd)

# ============================================================
# Helpers
# ============================================================

__CLR_INFO=$'\e[0;36m'
__CLR_ERR=$'\e[0;31m'
__CLR_OK=$'\e[0;32m'
__CLR_RESET=$'\e[0m'

__echo() {
    local fmt=$1; shift || true
    printf '\n%s[INFO]%s ' "$__CLR_INFO" "$__CLR_RESET"
    # shellcheck disable=SC2059
    printf "$fmt\n" "$@"
}

__error() {
    local fmt=$1; shift || true
    printf '\n%s[ERROR]%s ' "$__CLR_ERR" "$__CLR_RESET" >&2
    # shellcheck disable=SC2059
    printf "$fmt\n" "$@" >&2
    exit 1
}

__done() {
    local step=$1
    __echo "Step %s %s[✔]%s" "$step" "$__CLR_OK" "$__CLR_RESET"
}

__command_exists() { command -v "$1" >/dev/null 2>&1; }

__confirm() {
    local prompt=${1:-"Are you sure?"}
    local response
    read -r -p "$prompt [y/N] " response
    [[ $response =~ ^([yY]([eE][sS])?)$ ]]
}

__logo() {
    printf '\n'
    printf '************************************************************************\n'
    printf '*******                                                           ******\n'
    printf '*******                   Welcome to Bootstrap!                   ******\n'
    printf '*******                                                           ******\n'
    printf '************************************************************************\n'
    printf '\n'
}

# ============================================================
# Init
# ============================================================

__echo "Setting up the system..."
__confirm "Do you want to continue?" || exit 1

if [ ! -f /etc/os-release ] || ! grep -q "ID=arch" /etc/os-release; then
    __error "This script only works on Arch Linux"
fi

__logo

__command_exists "pacman" || __error "pacman is not installed"

if [[ $EUID -eq 0 ]]; then
    pacman -Syu --noconfirm
else
    __command_exists "sudo" || __error "'sudo' is required. Please install sudo first."
    sudo pacman -Syu --noconfirm
fi

if ! __command_exists "sudo"; then
    pacman -S --noconfirm sudo
fi

sudo -v
if ! sudo -nv &>/dev/null; then
    printf 'We need sudo access to continue\n'
    printf 'Enter your password for sudo access:\n'
    sudo /usr/bin/true
    while true; do sudo -n /usr/bin/true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &
fi

step=1

# ============================================================
# Steps
# ============================================================

function __install_essential_packages() {
    __echo "Step $step: Installing essential packages..."
    sudo pacman -S --noconfirm --needed \
        base-devel lsb-release gnupg ca-certificates \
        curl git htop jq tmux wget zip unzip neovim
    __done "$step"; step=$((step + 1))
}
__install_essential_packages

function __install_shell() {
    __echo "Step $step: Installing shell..."
    sudo pacman -S --noconfirm --needed bash
    if [[ "$SHELL" != *bash ]]; then
        command -v bash | sudo tee -a /etc/shells
        chsh -s "$(command -v bash)"
    fi
    __done "$step"; step=$((step + 1))
}
__install_shell

function __install_yay() {
    __echo "Step $step: Installing yay (AUR helper)..."
    if ! __command_exists "yay"; then
        git clone https://aur.archlinux.org/yay.git /tmp/yay
        cd /tmp/yay && makepkg -si --noconfirm
        cd "$SCRIPT_DIR"
        rm -rf /tmp/yay
    fi
    __done "$step"; step=$((step + 1))
}
__install_yay

function __install_starship() {
    __echo "Step $step: Installing starship..."
    if ! __command_exists "starship"; then
        sudo pacman -S --noconfirm starship
    fi
    __done "$step"; step=$((step + 1))
}
__install_starship

function __install_go() {
    __echo "Step $step: Installing Go..."
    if ! __command_exists "go"; then
        arch="$(uname -m)"
        case "$arch" in
            x86_64)  arch="amd64" ;;
            aarch64) arch="arm64" ;;
            armv6l)  arch="armv6l" ;;
            *) __error "Unsupported architecture: $arch" ;;
        esac
        version="$(curl -fsSL 'https://go.dev/VERSION?m=text' | head -1)"
        tarball="${version}.linux-${arch}.tar.gz"
        curl -fsSL "https://go.dev/dl/${tarball}" -o "/tmp/${tarball}"
        sudo rm -rf /usr/local/go
        sudo tar -C /usr/local -xzf "/tmp/${tarball}"
        rm "/tmp/${tarball}"
    fi
    __done "$step"; step=$((step + 1))
}
__install_go

function __install_python3() {
    __echo "Step $step: Installing Python3..."
    if ! __command_exists "python3"; then
        sudo pacman -S --noconfirm python python-pip
    fi
    __done "$step"; step=$((step + 1))
}
__install_python3

function __install_rust() {
    __echo "Step $step: Installing Rust..."
    if ! __command_exists "rustc"; then
        sudo pacman -S --noconfirm rust
    fi
    __done "$step"; step=$((step + 1))
}
__install_rust

function __install_nvm_and_nodejs() {
    __echo "Step $step: Installing NVM and Node.js..."
    if [[ ! -s "$HOME/.nvm/nvm.sh" ]]; then
        yay -S --noconfirm nvm
        source /usr/share/nvm/init-nvm.sh
        nvm install 24
        nvm use 24
    fi
    __done "$step"; step=$((step + 1))
}
__install_nvm_and_nodejs

function __install_npm_packages_global() {
    __echo "Step $step: Installing global npm packages..."
    if ! __command_exists "yarn"; then
        npm install -g yarn http-server pnpm eslint_d neovim tree-sitter-cli
    fi
    __done "$step"; step=$((step + 1))
}
__install_npm_packages_global

function __install_pip_packages() {
    __echo "Step $step: Installing global pip packages..."
    __command_exists pip || __error "pip is not installed"
    pip install black flake8 isort neovim
    __done "$step"; step=$((step + 1))
}
__install_pip_packages

function __install_deno() {
    __echo "Step $step: Installing Deno..."
    if ! __command_exists "deno"; then
        curl -fsSL https://deno.land/install.sh | sh -s -- -y
    fi
    __done "$step"; step=$((step + 1))
}
__install_deno

function __install_php() {
    __echo "Step $step: Installing PHP..."
    if ! __command_exists "php"; then
        sudo pacman -S --noconfirm php php-fpm php-gd php-intl php-sqlite php-redis xdebug
    fi
    __done "$step"; step=$((step + 1))
}
__install_php

function __install_composer() {
    __echo "Step $step: Installing Composer..."
    if ! __command_exists "composer"; then
        curl -sS https://getcomposer.org/installer | php
        sudo mv composer.phar /usr/local/bin/composer
    fi
    __done "$step"; step=$((step + 1))
}
__install_composer

function __install_lua() {
    __echo "Step $step: Installing Lua 5.1 (via mise)..."
    __command_exists mise || __error "mise is not installed. See https://mise.jdx.dev/"
    mise plugins add lua
    mise use -g lua@5.1
    ln -sf ~/.local/share/mise/installs/lua/5.1/bin/lua ~/.local/bin/lua5.1
    __done "$step"; step=$((step + 1))
}
[ -z ${S_LUA+x} ] || __install_lua

function __install_emacs() {
    __echo "Step $step: Installing Emacs..."
    __command_exists pacman || __error "pacman not found."
    sudo pacman -S --noconfirm emacs
    __done "$step"; step=$((step + 1))
}
[ -z ${S_EMACS+x} ] || __install_emacs

function __install_tex() {
    __echo "Step $step: Installing TeX..."
    sudo pacman -Sy --noconfirm texlive-core dvipng
    __command_exists latex || __error "'latex' not found on PATH"
    __command_exists dvipng || __error "'dvipng' not found on PATH"
    __done "$step"; step=$((step + 1))
}
[ -z ${S_TEX+x} ] || __install_tex

function __install_zoxide() {
    __echo "Step $step: Installing zoxide..."
    if ! __command_exists "zoxide"; then
        curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
    fi
    __done "$step"; step=$((step + 1))
}
__install_zoxide

function __fix_locales() {
    __echo "Step $step: Fixing locales..."
    sudo pacman -S --noconfirm --needed glibc
    sudo locale-gen
    sudo localectl set-locale LANG=en_US.UTF-8
    __done "$step"; step=$((step + 1))
}
__fix_locales

# ============================================================
# Done
# ============================================================

printf '\n'
printf '************************************************************************\n'
printf '****                                                              ******\n'
printf '**** Arch Bootstrap complete! Restart your terminal.              ******\n'
printf '****                                                              ******\n'
printf '************************************************************************\n'
printf '\n'
