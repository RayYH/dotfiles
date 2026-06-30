#!/usr/bin/env bash
# shellcheck disable=SC2059

SCRIPT_DIR=$(dirname "${BASH_SOURCE[0]}")
SCRIPT_DIR=$(cd "$SCRIPT_DIR" && pwd)

set -e

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
    printf "$fmt\n" "$@"
}

__error() {
    local fmt=$1; shift || true
    printf '\n%s[ERROR]%s ' "$__CLR_ERR" "$__CLR_RESET" >&2
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
    printf '*******                 Welcome to Mac Bootstrap!                 ******\n'
    printf '*******                                                           ******\n'
    printf '************************************************************************\n'
    printf '\n'
}

# ============================================================
# Brew helpers
# ============================================================

function __install_formula() {
    if brew list "$1" &>/dev/null; then
        __echo "$1 exists"
        if [[ "$S_UPGRADE" -eq "1" ]]; then
            brew upgrade "$1"
        fi
    else
        brew install "$1"
    fi
}

function __install_cask() {
    if brew list --cask "$1" &>/dev/null; then
        __echo "$1 exists"
        if [[ "$S_UPGRADE" -eq "1" ]]; then
            brew upgrade --cask "$1"
        fi
    else
        brew install --cask "$1"
    fi
}

# ============================================================
# Environment
# ============================================================

__confirm "Do you want to continue?" || exit 1

if [[ $(uname -m) == 'arm64' ]]; then
    export S_COMPUTER_NAME="$USER-M1-MBP"
else
    export S_COMPUTER_NAME="$USER-MBP"
fi

export S_GATEKEEPER_DISABLE="No"
export S_UPGRADE="${S_UPGRADE:-1}"
export S_CLEANUP="${S_CLEANUP:-1}"

[ -n "${S_ONLY_UPDATE+1}" ] && S_UPGRADE=1

[ "$(uname)" != "Darwin" ] && __error "Oops, this script only supports macOS."

__logo

sudo -v
if ! sudo -nv &>/dev/null; then
    printf 'Before we get started, we need to have sudo access\n'
    printf 'Enter your password (for sudo access):\n'
    sudo /usr/bin/true
    while true; do sudo -n /usr/bin/true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &
fi

set -e
step=1

# ============================================================
# Steps
# ============================================================

function __set_computer_name() {
    __echo "Step $step: Set computer name to $S_COMPUTER_NAME"
    sudo scutil --set ComputerName  "$S_COMPUTER_NAME"
    sudo scutil --set HostName      "$S_COMPUTER_NAME"
    sudo scutil --set LocalHostName "$S_COMPUTER_NAME"
    __done "$((step++))"
}
[ -z ${S_SET_COMPUTER_NAME+x} ] || __set_computer_name

function __install_apple_command_line_tools() {
    if command -v xcode-select >&- && xpath=$(xcode-select --print-path) &&
        test -d "${xpath}" && test -x "${xpath}"; then
        __echo "Step $step: Apple's command line tools are already installed."
    else
        __echo "Step $step: Installing Apple's command line tools"
        xcode-select --install
        while ! command -v xcode-select >&-; do sleep 60; done
    fi
    __done "$((step++))"
}
[ -n "${S_ONLY_UPDATE+1}" ] || __install_apple_command_line_tools

function __set_gatekeeper() {
    __echo "Step $step: Disable or enable Gatekeeper control"
    if [[ $S_GATEKEEPER_DISABLE =~ Yes ]]; then
        sudo spctl --master-disable
    else
        sudo spctl --master-enable
    fi
    __done "$((step++))"
}
[ -n "${S_ONLY_UPDATE+1}" ] || __set_gatekeeper

function __ensure_brew() {
    __echo "Step $step: Ensuring Homebrew is installed and updated"
    if ! command -v brew >/dev/null; then
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
    export PATH="/usr/local/bin:$PATH"
    export PATH="/opt/homebrew/bin:$PATH"
    brew update
    [[ "$S_UPGRADE" -eq "1" ]] && brew upgrade
    [[ "$S_CLEANUP" -eq "1" ]] && brew cleanup
    __done "$((step++))"
}
__ensure_brew

function __disable_brew_analytics() {
    __echo "Step $step: Disable Homebrew analytics"
    [ "$(brew analytics)" != "Analytics are disabled." ] && brew analytics off
    __done "$((step++))"
}
[ -n "${S_ONLY_UPDATE+1}" ] || __disable_brew_analytics

function __bash_and_curl() {
    __echo "Step $step: install bash and curl"
    for f in bash bash-completion@2 curl; do __install_formula "$f"; done
    export HOMEBREW_FORCE_BREWED_CURL=1
    __done "$((step++))"
}
__bash_and_curl

function __taps() {
    __echo "Step $step: add 3rd repos via brew tap"
    for t in "shivammathur/php" "rayyh/neovim-nightly"; do brew tap "$t" && brew trust "$t"; done
    __done "$((step++))"
}
__taps

function __formulas() {
    __echo "Step $step: install formulas"
    declare -a frs=(
        "ack"               # https://beyondgrep.com
        "bash-completion@2"
        "bat"               # https://github.com/sharkdp/bat
        "cmake"
        "coreutils"
        "composer"
        "dive"
        "fastfetch"
        "ffmpeg"
        "findutils"
        "fzf"
        "gawk"
        "gh"
        "git"
        "git-delta"
        "git-lfs"
        "glab"
        "gnu-sed"
        "gnu-tar"
        "gnupg"
        "go"
        "gradle"
        "grep"
        "htop"
        "httpie"
        "imagemagick"
        "jq"
        "julia"
        "jesseduffield/lazydocker/lazydocker"
        "lazygit"
        "lua"
        "luajit"
        "kubectx"
        "loc"
        "make"
        "mysql-client"
        "neovim-nightly"
        "nmap"
        "ninja"
        "php"
        "pinentry-mac"
        "pngpaste"
        "r"
        "ripgrep"
        "rsync"
        "shellcheck"
        "shfmt"
        "starship"
        "telnet"
        "terminal-notifier"
        "tmux"
        "tree"
        "unzip"
        "vim"
        "websocat"
        "wget"
        "zenith"
        "zoxide"
        "protobuf"
    )
    for f in "${frs[@]}"; do __install_formula "$f"; done
    unset frs
    yes | /bin/bash "$(brew --prefix)"/opt/fzf/install &>/dev/null
    [ -f "$HOME/.bashrc" ] && /usr/bin/sed -i '' '/fzf\.bash/d' "$HOME/.bashrc"
    [ -f "$HOME/.zshrc" ]  && /usr/bin/sed -i '' '/fzf\.zsh/d'  "$HOME/.zshrc"
    __done "$((step++))"
}
__formulas

function __ai_code_tools() {
    __echo "Step $step: install AI coding tools"
    if ! __command_exists codex; then
        curl -fsSL https://chatgpt.com/codex/install.sh | sh
    fi
    if ! __command_exists claude; then
        curl -fsSL https://claude.ai/install.sh | bash
    fi
    __done "$((step++))"
}
__ai_code_tools

function __casks() {
    __echo "Step $step: install casks"
    declare -a guis=(
        "anki"
        "chromedriver"
        "the-unarchiver"
        "keycastr"
        "kitty"
        "raycast"
        "rstudio"
        "visual-studio-code"
        "orbstack"
    )
    for c in "${guis[@]}"; do __install_cask "$c"; done
    unset guis
    __done "$((step++))"
}
[ -z ${S_CASKS+x} ] || __casks

function __rust() {
    __echo "Step $step: setup rust"
    if ! __command_exists rustup; then
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    fi
    rustup update
    [ -d "$HOME/.cargo/bin" ] && export PATH="$HOME/.cargo/bin:$PATH"
    cargo install -- cargo-outdated
    cargo install -- cargo-release
    __done "$((step++))"
}
__rust

function __emacs() {
    __echo "Step $step: install Emacs (emacs-plus)"
    if ! brew tap | grep -q "d12frosted/emacs-plus"; then
        brew tap d12frosted/emacs-plus
        brew trust d12frosted/emacs-plus
    fi
    __install_cask emacs-plus-app
    __done "$((step++))"
}
[ -z ${S_EMACS+x} ] || __emacs

function __tex() {
    __echo "Step $step: install TeX (BasicTeX)"
    __install_cask basictex
    export PATH="/Library/TeX/texbin:$PATH"
    sudo tlmgr update --self
    sudo tlmgr update --all || true
    sudo tlmgr install dvipng wrapfig capt-of
    __done "$((step++))"
}
[ -z ${S_TEX+x} ] || __tex

function __preferences() {
    __echo "Step $step: Setting macOS preferences..."
    defaults write NSGlobalDomain KeyRepeat        -int 1
    defaults write NSGlobalDomain InitialKeyRepeat -int 10

	# https://git.sr.ht/~foosoft/anki-connect#notes-for-macos-users
	defaults write net.ankiweb.dtop NSAppSleepDisabled -bool true
	defaults write net.ichi2.anki NSAppSleepDisabled -bool true
	defaults write org.qt-project.Qt.QtWebEngineCore NSAppSleepDisabled -bool true
    __done "$((step++))"
}
[ -n "${S_ONLY_UPDATE+1}" ] || __preferences

# ============================================================
# Done
# ============================================================

printf '\n'
printf '************************************************************************\n'
printf '****                                                              ******\n'
printf '**** Mac Bootstrap complete! Please restart your computer.        ******\n'
printf '****                                                              ******\n'
printf '************************************************************************\n'
printf '\n'
