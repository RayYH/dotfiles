#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

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

[[ ! -f /etc/os-release ]] && __error "This script only works on Ubuntu"
# shellcheck disable=SC1091
. /etc/os-release
[[ "${ID,,}" != "ubuntu" ]] && __error "This script only works on Ubuntu (detected: ${ID:-unknown})"

__logo

__command_exists "apt-get" || __error "apt-get is not installed"

SUDO=""
if [[ $EUID -eq 0 ]]; then
    if ! __command_exists "sudo"; then
        apt-get update
        apt-get install -y sudo
    fi
else
    __command_exists "sudo" || __error "'sudo' is required. Please install sudo first."
    SUDO="sudo"
    if ! sudo -nv &>/dev/null; then
        printf 'We need sudo access to continue\n'
        printf 'Enter your password (for sudo access):\n'
        sudo /usr/bin/true
        while true; do sudo -n /usr/bin/true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &
    fi
fi

__echo "Updating and upgrading packages..."
$SUDO apt-get update -y
$SUDO apt-get upgrade -y

step=1
__next_step() { __done "$step"; step=$((step + 1)); }

# ============================================================
# Steps
# ============================================================

__add_ppas() {
    __echo "Step $step: Adding PPAs..."
    __command_exists "add-apt-repository" || $SUDO apt-get install -y software-properties-common
    $SUDO add-apt-repository -y ppa:neovim-ppa/unstable
    $SUDO add-apt-repository -y ppa:longsleep/golang-backports
    $SUDO add-apt-repository -y ppa:ondrej/php
    $SUDO apt-get update -y
    __next_step
}
__add_ppas

__install_essential_packages() {
    __echo "Step $step: Installing essential packages..."
    $SUDO apt-get install -y \
        build-essential lsb-release gnupg2 ca-certificates \
        apt-transport-https software-properties-common \
        curl git htop jq tmux wget zip unzip neovim
    __next_step
}
__install_essential_packages

__install_shell() {
    __echo "Step $step: Installing shell..."
    $SUDO apt-get install -y bash
    if [[ "$SHELL" != *bash ]]; then
        command -v bash | $SUDO tee -a /etc/shells >/dev/null
        chsh -s "$(command -v bash)"
    fi
    __next_step
}
__install_shell

__install_starship() {
    __echo "Step $step: Installing starship..."
    if ! __command_exists "starship"; then
        curl -sS https://starship.rs/install.sh | sh -s -- -y
    fi
    __next_step
}
__install_starship

__install_go() {
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
        $SUDO rm -rf /usr/local/go
        $SUDO tar -C /usr/local -xzf "/tmp/${tarball}"
        rm "/tmp/${tarball}"
    fi
    __next_step
}
__install_go

__install_python3() {
    __echo "Step $step: Installing Python3..."
    if ! __command_exists "python3"; then
        $SUDO apt-get install -y python3 python3-venv python3-pip
    fi
    __next_step
}
__install_python3

__install_rust() {
    __echo "Step $step: Installing Rust..."
    if ! __command_exists "rustc"; then
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    fi
    __next_step
}
__install_rust

__install_nvm_and_nodejs() {
    __echo "Step $step: Installing NVM and Node.js..."
    if [[ ! -s "$HOME/.nvm/nvm.sh" ]]; then
        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
        export NVM_DIR="$HOME/.nvm"
        # shellcheck disable=SC1090
        [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
        nvm install 24
        nvm use 24
    fi
    __next_step
}
__install_nvm_and_nodejs

__install_npm_packages_global() {
    __echo "Step $step: Installing global npm packages..."
    if ! __command_exists "yarn"; then
        npm install -g pnpm yarn http-server eslint_d neovim tree-sitter-cli
    fi
    __next_step
}
__install_npm_packages_global

__install_pip_packages() {
    __echo "Step $step: Installing global pip packages..."
    __command_exists pip || __error "pip is not installed"
    pip install black flake8 isort neovim
    __next_step
}
__install_pip_packages

__install_deno() {
    __echo "Step $step: Installing Deno..."
    if ! __command_exists "deno"; then
        curl -fsSL https://deno.land/install.sh | sh -s -- -y
    fi
    __next_step
}
__install_deno

__install_php() {
    __echo "Step $step: Installing PHP..."
    if ! __command_exists "php"; then
        $SUDO apt-get install -y \
            php8.4-{common,readline,bcmath,fpm,xml,mysql,zip,intl,ldap,gd,cli,bz2,curl,mbstring,pgsql,opcache,soap,cgi,redis}
    fi
    __next_step
}
__install_php

__install_composer() {
    __echo "Step $step: Installing Composer..."
    if ! __command_exists "composer"; then
        curl -sS https://getcomposer.org/installer | php
        $SUDO mv composer.phar /usr/local/bin/composer
    fi
    __next_step
}
__install_composer

__install_lua() {
    __echo "Step $step: Installing Lua 5.1 (via mise)..."
    __command_exists mise || __error "mise is not installed. See https://mise.jdx.dev/"
    mise plugins add lua
    mise use -g lua@5.1
    ln -sf ~/.local/share/mise/installs/lua/5.1/bin/lua ~/.local/bin/lua5.1
    __next_step
}
[ -z ${S_LUA+x} ] || __install_lua

__install_emacs() {
    __echo "Step $step: Building Emacs from source..."
    local version="${EMACS_VERSION:-30.1}"
    local build_dir="${BUILD_DIR:-/tmp/emacs-build}"
    $SUDO apt-get install -y \
        autoconf make gcc g++ pkg-config \
        libgnutls28-dev libncurses-dev \
        libgtk-3-dev libxpm-dev libgif-dev libjpeg-dev libpng-dev libtiff-dev \
        libgccjit-dev libjansson-dev libtree-sitter-dev texinfo
    mkdir -p "$build_dir"
    local tarball="emacs-${version}.tar.xz"
    curl -fL "https://ftp.gnu.org/gnu/emacs/${tarball}" -o "${build_dir}/${tarball}"
    tar -xJf "${build_dir}/${tarball}" -C "$build_dir"
    local src="${build_dir}/emacs-${version}"
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
    make -j"$(nproc)"
    $SUDO make install
    cd /
    rm -rf "$build_dir"
    __next_step
}
[ -z ${S_EMACS+x} ] || __install_emacs

__install_tex() {
    __echo "Step $step: Installing TeX..."
    $SUDO apt-get install -y texlive dvipng
    __command_exists latex || __error "'latex' not found on PATH"
    __command_exists dvipng || __error "'dvipng' not found on PATH"
    __next_step
}
[ -z ${S_TEX+x} ] || __install_tex

__install_zoxide() {
    __echo "Step $step: Installing zoxide..."
    if ! __command_exists "zoxide"; then
        curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
    fi
    __next_step
}
__install_zoxide

__install_miniforge() {
    __echo "Step $step: Installing Miniforge..."
    if ! __command_exists "conda"; then
        local installer="Miniforge3-$(uname)-$(uname -m).sh"
        curl -L -O "https://github.com/conda-forge/miniforge/releases/latest/download/${installer}"
        bash "${installer}" -b
        rm -f "${installer}"
    fi
    __next_step
}
__install_miniforge

__fix_locales() {
    __echo "Step $step: Fixing locales..."
    DEBIAN_FRONTEND=noninteractive $SUDO apt-get install -y --no-install-recommends tzdata locales
    $SUDO locale-gen en_US.UTF-8
    $SUDO update-locale LANG=en_US.UTF-8
    __next_step
}
__fix_locales

# ============================================================
# Done
# ============================================================

printf '\n'
printf '************************************************************************\n'
printf '****                                                              ******\n'
printf '**** Ubuntu Bootstrap complete! Restart your terminal.            ******\n'
printf '****                                                              ******\n'
printf '************************************************************************\n'
printf '\n'
