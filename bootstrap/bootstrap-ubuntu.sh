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
# Package manager / PPAs  (keep at the top, not reordered)
# ============================================================

__add_ppas() {
    __echo "Step $step: Adding PPAs..."
    __command_exists "add-apt-repository" || $SUDO apt-get install -y software-properties-common
    $SUDO add-apt-repository -y ppa:neovim-ppa/unstable
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
        curl git htop jq tmux wget zip unzip \
        libreadline-dev libssl-dev zlib1g-dev
    __next_step
}
__install_essential_packages

__fix_locales() {
    __echo "Step $step: Fixing locales..."
    DEBIAN_FRONTEND=noninteractive $SUDO apt-get install -y --no-install-recommends tzdata locales
    $SUDO locale-gen en_US.UTF-8
    $SUDO update-locale LANG=en_US.UTF-8
    __next_step
}
__fix_locales

# ============================================================
# Shell
# ============================================================

__install_shell() {
    __echo "Step $step: Installing shell (bash)..."
    $SUDO apt-get install -y bash
    if [[ "$SHELL" != *bash ]]; then
        command -v bash | $SUDO tee -a /etc/shells >/dev/null
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
# System info: fastfetch
# ============================================================

__install_fastfetch() {
    __echo "Step $step: Installing fastfetch..."
    if ! __command_exists "fastfetch"; then
        if apt-cache show fastfetch >/dev/null 2>&1; then
            $SUDO apt-get install -y fastfetch
        else
            local arch deb_arch ver
            arch="$(uname -m)"
            case "$arch" in
                x86_64)  deb_arch="amd64"   ;;
                aarch64) deb_arch="aarch64" ;;
                *) __error "Unsupported architecture for fastfetch: $arch" ;;
            esac
            ver="$(__gh_latest fastfetch-cli/fastfetch)"
            curl -fsSL "https://github.com/fastfetch-cli/fastfetch/releases/download/${ver}/fastfetch-linux-${deb_arch}.deb" \
                -o /tmp/fastfetch.deb
            $SUDO dpkg -i /tmp/fastfetch.deb
            rm -f /tmp/fastfetch.deb
        fi
    fi
    __next_step
}
__install_fastfetch

# ============================================================
# Containers: Docker
# ============================================================

__install_docker() {
    __echo "Step $step: Installing Docker..."
    if ! __command_exists "docker"; then
        curl -fsSL https://get.docker.com -o /tmp/get-docker.sh
        $SUDO sh /tmp/get-docker.sh
        rm -f /tmp/get-docker.sh
    fi

    if [[ "$(cat /proc/1/comm 2>/dev/null)" == "systemd" ]]; then
        $SUDO systemctl enable --now docker
    else
        __echo "systemd not running — skipping Docker service enablement"
    fi
    getent group docker >/dev/null || $SUDO groupadd docker

    local docker_user
    docker_user="${S_DOCKER_USER:-${SUDO_USER:-${USER:-}}}"
    if [[ -n "$docker_user" && "$docker_user" != "root" ]]; then
        $SUDO usermod -aG docker "$docker_user"
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
        $SUDO rm -rf /usr/local/go
        $SUDO tar -C /usr/local -xzf "/tmp/${tarball}"
        rm "/tmp/${tarball}"
    fi
    __next_step
}
__install_go_dev

# ============================================================
# Go tools: sqlc + buf
# ============================================================

__install_go_tools() {
    __echo "Step $step: Installing Go tools (sqlc, buf)..."

    # sqlc
    if ! __command_exists "sqlc"; then
        local arch go_arch sqlc_ver sqlc_ver_plain
        arch="$(uname -m)"
        case "$arch" in
            x86_64)  go_arch="amd64" ;;
            aarch64) go_arch="arm64" ;;
            *) __error "Unsupported architecture for sqlc: $arch" ;;
        esac
        sqlc_ver="$(__gh_latest sqlc-dev/sqlc)"
        sqlc_ver_plain="${sqlc_ver#v}"
        curl -fsSL "https://github.com/sqlc-dev/sqlc/releases/download/${sqlc_ver}/sqlc_${sqlc_ver_plain}_linux_${go_arch}.tar.gz" \
            -o /tmp/sqlc.tar.gz
        tar -xzf /tmp/sqlc.tar.gz -C /tmp/ sqlc
        __install_bin /tmp/sqlc
        rm -f /tmp/sqlc.tar.gz /tmp/sqlc
    fi

    # buf (official pattern: buf-$(uname -s)-$(uname -m))
    if ! __command_exists "buf"; then
        local buf_ver
        buf_ver="$(__gh_latest bufbuild/buf)"
        curl -fsSL "https://github.com/bufbuild/buf/releases/download/${buf_ver}/buf-$(uname -s)-$(uname -m)" \
            -o /tmp/buf
        __install_bin /tmp/buf
        rm -f /tmp/buf
    fi

    __next_step
}
__install_go_tools

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
[ -z ${S_AI_TOOLS+x} ] || __install_ai_code_tools

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
# PHP dev: php8.5 + Composer
# ============================================================

__install_php_dev() {
    __echo "Step $step: Installing PHP dev (php8.5 + Composer)..."

    if ! __command_exists "php"; then
        $SUDO apt-get install -y \
            php8.5-cli php8.5-common php8.5-fpm \
            php8.5-bcmath php8.5-bz2 php8.5-curl php8.5-gd \
            php8.5-intl php8.5-mbstring php8.5-mysql php8.5-pgsql \
            php8.5-soap php8.5-xml php8.5-zip
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
        $SUDO make install
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
    $SUDO apt-get install -y texlive dvipng
    __command_exists latex  || __error "'latex' not found on PATH after install"
    __command_exists dvipng || __error "'dvipng' not found on PATH after install"
    __next_step
}
[ -z ${S_TEX+x} ] || __install_tex

# ============================================================
# Emacs  (opt-in: S_EMACS=1)
# ============================================================

__install_emacs() {
    __echo "Step $step: Building Emacs ${EMACS_VERSION:-30.1} from source..."
    local version="${EMACS_VERSION:-30.1}"
    local build_dir="/tmp/emacs-build"
    local gcc_ver
    gcc_ver=$(gcc -dumpversion | cut -d. -f1)
    $SUDO apt-get install -y \
        autoconf make gcc g++ pkg-config \
        libgnutls28-dev libncurses-dev \
        libgtk-3-dev libxpm-dev libgif-dev libjpeg-dev libpng-dev libtiff-dev \
        "libgccjit-${gcc_ver}-dev" libjansson-dev libtree-sitter-dev texinfo
    mkdir -p "$build_dir"
    curl -fL "https://ftp.gnu.org/gnu/emacs/emacs-${version}.tar.xz" \
        -o "${build_dir}/emacs-${version}.tar.xz"
    tar -xJf "${build_dir}/emacs-${version}.tar.xz" -C "$build_dir"
    cd "${build_dir}/emacs-${version}"
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
