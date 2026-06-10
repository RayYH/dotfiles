#!/usr/bin/env bash

set -euo pipefail

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

# Returns the latest tag from a GitHub repo (owner/repo)
__gh_latest() {
    curl -fsSL "https://api.github.com/repos/$1/releases/latest" \
        | grep '"tag_name"' | sed 's/.*"tag_name": "\(.*\)".*/\1/'
}

# Install a binary to /usr/local/bin (root) or ~/.local/bin (user)
__install_bin() {
    local src="$1" name
    name="$(basename "$src")"
    if [[ $EUID -eq 0 ]]; then
        install -m755 "$src" "/usr/local/bin/$name"
    else
        mkdir -p "$HOME/.local/bin"
        install -m755 "$src" "$HOME/.local/bin/$name"
    fi
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

# Initial system update
if [[ $EUID -eq 0 ]]; then
    pacman -Syu --noconfirm
else
    __command_exists "sudo" || __error "'sudo' is required. Please install sudo first."
    sudo pacman -Syu --noconfirm
    if ! sudo -nv &>/dev/null; then
        printf 'We need sudo access to continue\n'
        printf 'Enter your password for sudo access:\n'
        sudo /usr/bin/true
        while true; do sudo -n /usr/bin/true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &
    fi
fi

# Prefer yay as package manager; fall back to pacman when running as root
# (yay must not run as root)
if [[ $EUID -eq 0 ]]; then
    PKG="pacman -S --noconfirm --needed"
else
    PKG="yay -S --noconfirm --needed"
fi

step=1
__next_step() { __done "$step"; step=$((step + 1)); }

# ============================================================
# Package manager / essential packages  (keep at the top)
# ============================================================

__install_essential_packages() {
    __echo "Step $step: Installing essential packages..."
    if [[ $EUID -eq 0 ]]; then
        pacman -S --noconfirm --needed \
            base-devel lsb-release gnupg ca-certificates \
            curl git htop jq tmux wget zip unzip readline
    else
        sudo pacman -S --noconfirm --needed \
            base-devel lsb-release gnupg ca-certificates \
            curl git htop jq tmux wget zip unzip readline
    fi
    __next_step
}
__install_essential_packages

__install_yay() {
    __echo "Step $step: Installing yay (AUR helper)..."
    if [[ $EUID -eq 0 ]]; then
        __echo "Running as root — skipping yay (cannot run as root); using pacman instead"
        __next_step
        return
    fi
    if ! __command_exists "yay"; then
        git clone https://aur.archlinux.org/yay.git /tmp/yay
        cd /tmp/yay && makepkg -si --noconfirm
        cd /
        rm -rf /tmp/yay
    fi
    __next_step
}
__install_yay

__fix_locales() {
    __echo "Step $step: Fixing locales..."
    if [[ $EUID -eq 0 ]]; then
        pacman -S --noconfirm --needed glibc
        locale-gen
    else
        sudo pacman -S --noconfirm --needed glibc
        sudo locale-gen
    fi
    localectl set-locale LANG=en_US.UTF-8 2>/dev/null || true
    __next_step
}
__fix_locales

# ============================================================
# Shell
# ============================================================

__install_shell() {
    __echo "Step $step: Installing shell (bash)..."
    # shellcheck disable=SC2086
    $PKG bash
    if [[ "$SHELL" != *bash ]]; then
        command -v bash | tee -a /etc/shells >/dev/null
        chsh -s "$(command -v bash)"
    fi
    __next_step
}
__install_shell

# ============================================================
# Shell tools: starship, zoxide, yazi, bat
# ============================================================

__install_shell_tools() {
    __echo "Step $step: Installing shell tools (starship, zoxide, yazi, bat)..."

    mkdir -p "${HOME}/.local/bin"

    # starship
    if ! __command_exists "starship"; then
        curl -sS https://starship.rs/install.sh | sh -s -- -y --bin-dir "${HOME}/.local/bin"
    fi

    # zoxide
    if ! __command_exists "zoxide"; then
        curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
    fi

    local arch
    arch="$(uname -m)"
    local yazi_arch bat_arch
    case "$arch" in
        x86_64)  yazi_arch="x86_64-unknown-linux-musl";  bat_arch="x86_64-unknown-linux-musl"  ;;
        aarch64) yazi_arch="aarch64-unknown-linux-musl"; bat_arch="aarch64-unknown-linux-gnu"  ;;
        *) __error "Unsupported architecture: $arch" ;;
    esac

    # yazi
    if ! __command_exists "yazi"; then
        local yazi_ver
        yazi_ver="$(__gh_latest sxyazi/yazi)"
        curl -fsSL "https://github.com/sxyazi/yazi/releases/download/${yazi_ver}/yazi-${yazi_arch}.zip" \
            -o /tmp/yazi.zip
        unzip -qo /tmp/yazi.zip -d /tmp/yazi-extract
        __install_bin "/tmp/yazi-extract/yazi-${yazi_arch}/yazi"
        rm -rf /tmp/yazi.zip /tmp/yazi-extract
    fi

    # bat
    if ! __command_exists "bat"; then
        local bat_ver
        bat_ver="$(__gh_latest sharkdp/bat)"
        local bat_dir="bat-${bat_ver}-${bat_arch}"
        curl -fsSL "https://github.com/sharkdp/bat/releases/download/${bat_ver}/${bat_dir}.tar.gz" \
            -o /tmp/bat.tar.gz
        tar -xzf /tmp/bat.tar.gz -C /tmp/
        __install_bin "/tmp/${bat_dir}/bat"
        rm -rf /tmp/bat.tar.gz "/tmp/${bat_dir}"
    fi

    __next_step
}
__install_shell_tools

# ============================================================
# Fonts: Intel One Mono
# ============================================================

__install_fonts() {
    __echo "Step $step: Installing fonts (Intel One Mono)..."
    # shellcheck disable=SC2086
    $PKG ttf-intel-one-mono
    __next_step
}
__install_fonts

# ============================================================
# Git tools: git-delta
# ============================================================

__install_git_tools() {
    __echo "Step $step: Installing git tools (git-delta)..."
    # shellcheck disable=SC2086
    $PKG git-delta
    __next_step
}
__install_git_tools

# ============================================================
# Containers: Docker
# ============================================================

__install_docker() {
    __echo "Step $step: Installing Docker..."
    # shellcheck disable=SC2086
    $PKG docker docker-compose

    if [[ $EUID -eq 0 ]]; then
        systemctl enable --now docker
        getent group docker >/dev/null || groupadd docker
    else
        sudo systemctl enable --now docker
        getent group docker >/dev/null || sudo groupadd docker
    fi

    local docker_user
    docker_user="${S_DOCKER_USER:-${SUDO_USER:-${USER:-}}}"
    if [[ -n "$docker_user" && "$docker_user" != "root" ]]; then
        if [[ $EUID -eq 0 ]]; then
            usermod -aG docker "$docker_user"
        else
            sudo usermod -aG docker "$docker_user"
        fi
        __echo "Added %s to the docker group. Log out and back in before running Docker without sudo." "$docker_user"
    else
        __echo "Skipping docker group membership update for root"
    fi

    __next_step
}
__install_docker

# ============================================================
# Go dev
# ============================================================

__install_go_dev() {
    __echo "Step $step: Installing Go (latest from go.dev)..."
    if ! __command_exists "go"; then
        local arch
        arch="$(uname -m)"
        case "$arch" in
            x86_64)  arch="amd64"  ;;
            aarch64) arch="arm64"  ;;
            armv6l)  arch="armv6l" ;;
            *) __error "Unsupported architecture: $arch" ;;
        esac
        local version
        version="$(curl -fsSL 'https://go.dev/VERSION?m=text' | head -1)"
        local tarball="${version}.linux-${arch}.tar.gz"
        curl -fsSL "https://go.dev/dl/${tarball}" -o "/tmp/${tarball}"
        if [[ $EUID -eq 0 ]]; then
            rm -rf /usr/local/go
            tar -C /usr/local -xzf "/tmp/${tarball}"
        else
            sudo rm -rf /usr/local/go
            sudo tar -C /usr/local -xzf "/tmp/${tarball}"
        fi
        rm "/tmp/${tarball}"
    fi
    __next_step
}
__install_go_dev

# ============================================================
# Python: Miniforge + uv
# ============================================================

__install_python() {
    __echo "Step $step: Installing Python (Miniforge + uv)..."

    # Miniforge (conda)
    if ! __command_exists "conda"; then
        local installer="Miniforge3-$(uname)-$(uname -m).sh"
        curl -fsSL "https://github.com/conda-forge/miniforge/releases/latest/download/${installer}" \
            -o "/tmp/${installer}"
        bash "/tmp/${installer}" -b
        rm -f "/tmp/${installer}"
    fi

    # uv
    if ! __command_exists "uv"; then
        curl -LsSf https://astral.sh/uv/install.sh | sh
    fi

    __next_step
}
__install_python

# ============================================================
# Rust dev
# ============================================================

__install_rust_dev() {
    __echo "Step $step: Installing Rust (rustup)..."
    if ! __command_exists "rustc"; then
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    fi
    __next_step
}
__install_rust_dev

# ============================================================
# Web dev: nvm + Node.js LTS
# ============================================================

__install_web_dev() {
    __echo "Step $step: Installing web dev (nvm + Node.js 24)..."
    if [[ ! -s "$HOME/.nvm/nvm.sh" ]]; then
        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
    fi
    export NVM_DIR="$HOME/.nvm"
    # shellcheck disable=SC1090
    [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
    if ! nvm ls 24 &>/dev/null; then
        nvm install 24
    fi
    nvm use 24
    __next_step
}
__install_web_dev

# ============================================================
# AI coding tools: Codex + Claude Code
# ============================================================

__install_ai_code_tools() {
    __echo "Step $step: Installing AI coding tools (Codex + Claude Code)..."

    if ! __command_exists "codex"; then
        curl -fsSL https://chatgpt.com/codex/install.sh | sh
    fi

    if ! __command_exists "claude"; then
        curl -fsSL https://claude.ai/install.sh | bash
    fi

    __next_step
}
__install_ai_code_tools

# ============================================================
# Java dev: SDKMAN + latest LTS Java
# ============================================================

__sdkman_latest_lts_java() {
    __sdkman_sdk list java \
        | awk -F'|' '
            NF >= 6 {
                id = $NF
                gsub(/^[[:space:]]+|[[:space:]]+$/, "", id)
                if (id ~ /^[0-9]/) print id
            }
        ' \
        | awk -F'[.-]' '
            {
                major = $1 + 0
                if (major == 8 || (major >= 11 && (major - 1) % 4 == 0)) print
            }
        ' \
        | sort -V \
        | awk '
            /-tem$/ { tem = $0 }
            { latest = $0 }
            END {
                if (tem != "") print tem
                else print latest
            }
        '
}

__sdkman_sdk() {
    set +eu
    sdk "$@"
    local status=$?
    set -eu
    return "$status"
}

__install_java() {
    __echo "Step $step: Installing Java (SDKMAN + latest LTS)..."

    if [[ ! -s "$HOME/.sdkman/bin/sdkman-init.sh" ]]; then
        curl -s "https://get.sdkman.io" | bash
    fi

    export SDKMAN_DIR="${SDKMAN_DIR:-$HOME/.sdkman}"
    export PAGER="${PAGER:-cat}"
    [[ -s "$SDKMAN_DIR/bin/sdkman-init.sh" ]] || __error "SDKMAN init script was not found"
    # shellcheck disable=SC1091
    set +eu
    . "$SDKMAN_DIR/bin/sdkman-init.sh"
    local sdkman_status=$?
    set -eu
    [[ $sdkman_status -eq 0 ]] || __error "Could not initialize SDKMAN"

    local java_version
    java_version="${JAVA_VERSION:-$(__sdkman_latest_lts_java)}"
    [[ -n "$java_version" ]] || __error "Could not determine the latest LTS Java version from SDKMAN"

    __sdkman_sdk install java "$java_version"
    __sdkman_sdk default java "$java_version"

    __next_step
}
__install_java

# ============================================================
# PHP dev: php + Composer  (via yay for AUR packages)
# ============================================================

__install_php_dev() {
    __echo "Step $step: Installing PHP dev (php + Composer)..."

    if ! __command_exists "php"; then
        # shellcheck disable=SC2086
        $PKG php php-fpm php-gd php-intl php-sqlite php-pgsql
    fi

    if ! __command_exists "composer"; then
        curl -fsSL https://getcomposer.org/installer | php -- --install-dir=/tmp --filename=composer
        __install_bin /tmp/composer
        rm -f /tmp/composer
    fi

    __next_step
}
__install_php_dev

# ============================================================
# Lua dev: compile from source
# ============================================================

__install_lua_dev() {
    __echo "Step $step: Installing Lua ${LUA_VERSION:-5.4.7} from source..."
    if ! __command_exists "lua"; then
        local version="${LUA_VERSION:-5.4.7}"
        local src_dir="/tmp/lua-${version}"
        curl -fsSL "https://www.lua.org/ftp/lua-${version}.tar.gz" -o "/tmp/lua-${version}.tar.gz"
        tar -xzf "/tmp/lua-${version}.tar.gz" -C /tmp/
        cd "$src_dir"
        make linux-readline
        if [[ $EUID -eq 0 ]]; then
            make install
        else
            sudo make install
        fi
        cd /
        rm -rf "$src_dir" "/tmp/lua-${version}.tar.gz"
    fi
    __next_step
}
__install_lua_dev

# ============================================================
# TeX  (opt-in: S_TEX=1)
# ============================================================

__install_tex() {
    __echo "Step $step: Installing TeX (texlive + dvipng)..."
    # shellcheck disable=SC2086
    $PKG texlive-core dvipng
    __command_exists latex  || __error "'latex' not found on PATH after install"
    __command_exists dvipng || __error "'dvipng' not found on PATH after install"
    __next_step
}
[ -z ${S_TEX+x} ] || __install_tex

# ============================================================
# Emacs  (opt-in: S_EMACS=1)
# ============================================================

__install_emacs() {
    __echo "Step $step: Installing Emacs (via yay/pacman)..."
    # shellcheck disable=SC2086
    $PKG emacs
    __next_step
}
[ -z ${S_EMACS+x} ] || __install_emacs

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
