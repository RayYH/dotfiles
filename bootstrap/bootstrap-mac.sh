#!/usr/bin/env bash
# shellcheck disable=SC2059

SCRIPT_DIR=$(dirname "${BASH_SOURCE[0]}")
SCRIPT_DIR=$(cd "$SCRIPT_DIR" && pwd)

set -e

source "$SCRIPT_DIR/helpers.sh"

# install formula via brew
function __install_formula() {
    if brew list "$1" &>/dev/null; then
        __echo "$1 exists"
        if [[ "$S_UPGRADE" -eq "1" ]]; then
            __echo "update $1 via brew"
            brew upgrade "$1"
        fi
    else
        brew install "$1"
    fi
}

# install cask via brew
function __install_cask() {
    if brew list --cask "$1" &>/dev/null; then
        __echo "$1 exists"
        if [[ "$S_UPGRADE" -eq "1" ]]; then
            __echo "update $1 via brew"
            brew upgrade --cask "$1"
        fi
    else
        brew install --cask "$1"
    fi
}

__confirm "Do you want to continue?" || exit 1

################################################################################
# Environment variables
################################################################################
if [[ $(uname -m) == 'arm64' ]]; then
    export S_COMPUTER_NAME="$USER-M1-MBP"
else
    export S_COMPUTER_NAME="$USER-MBP"
fi

# Do not disable gatekeeper
export S_GATEKEEPER_DISABLE="No"
export S_UPGRADE="${S_UPGRADE:-1}"
export S_CLEANUP="${S_CLEANUP:-1}"

if [ -n "${S_ONLY_UPDATE+1}" ]; then
    S_UPGRADE=1
fi

################################################################################
# Detect if running on mac
################################################################################
if [ "$(uname)" != "Darwin" ]; then
    __error "Oops, this script only supports macOS."
fi

################################################################################
# Welcome and setup
################################################################################
printf '\n'
printf '************************************************************************\n'
printf '*******                                                           ******\n'
printf '*******                 Welcome to Mac Bootstrap!                 ******\n'
printf '*******                                                           ******\n'
printf '************************************************************************\n'
printf '\n'

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

################################################################################
# Set the computer name
################################################################################
function __set_computer_name() {
    __echo "Step $step: Set computer name to $S_COMPUTER_NAME"
    sudo scutil --set ComputerName "$S_COMPUTER_NAME"
    sudo scutil --set HostName "$S_COMPUTER_NAME"
    sudo scutil --set LocalHostName "$S_COMPUTER_NAME"
    __done "$((step++))"
}

[ -z ${S_SET_COMPUTER_NAME+x} ] || __set_computer_name

################################################################################
# Install Apple's Command Line Tools
################################################################################
function __install_apple_command_line_tools() {
    if command -v xcode-select >&- && xpath=$(xcode-select --print-path) &&
        test -d "${xpath}" && test -x "${xpath}"; then
        __echo "Step $step: Apple's command line tools are already installed."
    else
        __echo "Step $step: Installing Apple's command line tools"
        xcode-select --install
        while ! command -v xcode-select >&-; do
            sleep 60
        done
    fi
    __done "$((step++))"
}

[ -n "${S_ONLY_UPDATE+1}" ] || __install_apple_command_line_tools

################################################################################
# Gatekeeper
################################################################################
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

################################################################################
# Homebrew
################################################################################
function __ensure_brew() {
    __echo "Step $step: Ensuring Homebrew is installed and updated"
    if ! command -v brew >/dev/null; then
        __echo "Installing Homebrew"
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

################################################################################
# disable brew analytics
################################################################################
function __disable_brew_analytics() {
    __echo "Step $step: Disable Homebrew analytics"
    if [ "$(brew analytics)" != "Analytics are disabled." ]; then
        brew analytics off
    fi
    __done "$((step++))"
}
[ -n "${S_ONLY_UPDATE+1}" ] || __disable_brew_analytics

#============================================================
# install curl and bash first
#============================================================
function __bash_and_curl() {
    __echo "Step $step: install bash and curl"
    declare -a frs=(
        "bash"
        "bash-completion@2"
        "curl"
    )
    for i in "${frs[@]}"; do
        __install_formula "$i"
    done
    unset frs
    export HOMEBREW_FORCE_BREWED_CURL=1
    __done "$((step++))"
}

__bash_and_curl

#============================================================
# tap 3rd repos
#============================================================
function __taps() {
    __echo "Step $step: add 3rd repos via bre tap"
    declare -a taps=(
        "shivammathur/php"          # multiple php versions
        "benjiwolff/neovim-nightly" # neovim nightly
    )
    for i in "${taps[@]}"; do
        brew tap "$i"
    done
    unset taps
    __done "$((step++))"
}
__taps

#============================================================
# install common formulas first
#============================================================
function __formulas() {
    declare -a frs=(
        "ack"               # https://beyondgrep.com
        "bash-completion@2" # https://github.com/scop/bash-completion
        "bat"               # https://github.com/sharkdp/bat
        "cmake"             # https://cmake.org/
        "coreutils"         # https://www.gnu.org/software/coreutils/
        "composer"          # https://getcomposer.org/
        "dive"              # https://github.com/wagoodman/dive
        "ffmpeg"            # https://ffmpeg.org/
        "findutils"         # https://www.gnu.org/software/findutils/
        "fzf"               # https://github.com/junegunn/fzf
        "gawk"              # https://www.gnu.org/software/gawk/
        "gh"                # https://github.com/cli/cli
        "git"               # https://git-scm.com
        "git-delta"         # https://dandavison.github.io/delta/
        "git-lfs"           # https://git-lfs.github.com/
        "glab"              # https://gitlab.com/gitlab-org/cli
        "gnu-sed"           # https://www.gnu.org/software/sed/
        "gnu-tar"           # https://www.gnu.org/software/tar/
        "gnupg"             # https://gnupg.org/
        "go"                # https://golang.org/
        "gradle"            # https://gradle.org/
        "grep"              # https://www.gnu.org/software/grep/
        "htop"              # https://htop.dev/
        "httpie"            # https://httpie.io/
        "imagemagick"       # https://imagemagick.org/index.php
        "jq"                # https://jqlang.github.io/jq/
        "lua"               # https://www.lua.org/
        "luagit"            # https://luajit.org/luajit.html
        "kubectx"           # https://github.com/ahmetb/kubectx
        "loc"               # https://github.com/cgag/loc
        "make"              # https://www.gnu.org/software/make/
        "mysql-client"      # https://dev.mysql.com/doc/refman/8.0/en/
        "neovim-nightly"    # https://neovim.io/
        "nmap"              # https://nmap.org/
        "ninja"             # https://ninja-build.org/
        "php"               # https://www.php.net/
        "pinentry-mac"      # https://github.com/GPGTools/pinentry -- gnupg needs this
        "pngpaste"          # https://github.com/jcsalterego/pngpaste
        "r"                 # https://www.r-project.org/
        "ripgrep"           # https://github.com/BurntSushi/ripgrep
        "rsync"             # https://rsync.samba.org/
        "shellcheck"        # https://www.shellcheck.net/
        "shfmt"             # https://github.com/mvdan/sh
        "starship"          # https://starship.rs/
        "telnet"            # https://github.com/apple-oss-distributions/remote_cmds
        "terminal-notifier" # https://github.com/julienXX/terminal-notifier
        "tmux"              # https://github.com/tmux/tmux
        "tree"              # http://mama.indstate.edu/users/ice/tree/
        "unzip"             # https://infozip.sourceforge.net/UnZip.html
        "vim"               # https://www.vim.org/
        "websocat"          # https://github.com/vi/websocat
        "wget"              # https://www.gnu.org/software/wget/
        "zenith"            # https://github.com/bvaisvil/zenith/
        "zoxide"            # https://github.com/ajeetdsouza/zoxide
        "protobuf"          # https://protobuf.dev/
    )
    for i in "${frs[@]}"; do
        __install_formula "$i"
    done
    unset frs

    yes | /bin/bash "$(brew --prefix)"/opt/fzf/install &>/dev/null
    # we will load this file in setup.bash
    [ -f "$HOME/.bashrc" ] && /usr/bin/sed -i '' '/fzf\.bash/d' "$HOME/.bashrc"
    [ -f "$HOME/.zshrc" ] && /usr/bin/sed -i '' '/fzf\.zsh/d' "$HOME/.zshrc"
}
__formulas

#============================================================
# Other GUIs
#============================================================
function __casks() {
    __echo "Step $step: install some casks"
    declare -a guis=(
        "anki"               # https://apps.ankiweb.net/
        "chromedriver"       # https://chromedriver.chromium.org/
        "obsidian"           # https://obsidian.md/
        "the-unarchiver"     # https://theunarchiver.com/
        "keycastr"           # https://github.com/keycastr/keycastr
        "kitty"              # https://sw.kovidgoyal.net/kitty/
        "raycast"            # https://raycast.com/
        "rstudio"            # https://rstudio.com/
        "visual-studio-code" # https://code.visualstudio.com/
        "orbstack"           # https://orbstack.dev
    )
    for i in "${guis[@]}"; do
        __install_cask "$i"
    done
    unset guis
    __done "$((step++))"
}
[ -z ${S_CASKS+x} ] || __casks

################################################################################
# rust
################################################################################
function __rust() {
    __echo "Step $step: setup rust development"
    if ! __command_exists rustup &>/dev/null; then
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    fi
    rustup update
    if [ -d "$HOME/.cargo/bin" ]; then
        export PATH="$HOME/.cargo/bin:$PATH"
    fi
    cargo install -- cargo-outdated
    cargo install -- cargo-release
    __done "$((step++))"
}
__rust

# We will use OrbStack, skip this funciton for now
# ################################################################################
# # docker plugins
# ################################################################################
# function __docker_plugins() {
#     # make sure $HOME/.docker/cli-plugins exists
#     mkdir -p "$HOME/.docker/cli-plugins"
#     __echo "Step $step: install docker plugins"
#     declare -a dps=(buildx compose)
#     for i in "${dps[@]}"; do
#         __install_formula "docker-$i"
#         ln -sfn "$(brew --prefix)/opt/docker-$i/bin/docker-$i" "$HOME/.docker/cli-plugins/docker-$i"
#         chmod +x "$HOME/.docker/cli-plugins/docker-$i"
#     done
# }
# __docker_plugins

################################################################################
# ql plugins
################################################################################
# function __ql_plugins() {
#     __echo "Step $step: install quicklook plugins"
#     declare -a qps=(qlstephen quicklook-json qlprettypatch quicklook-csv webpquicklook suspicious-package webpquicklook)
#     for i in "${qps[@]}"; do
#         __install_cask "$i"
#     done
#     unset qps
#     __done "$((step++))"
# }
# __ql_plugins

################################################################################
# preferences
################################################################################
function __preferences() {
    __echo "Step $step: Setting macOS preferences..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/RayYH/dotfiles/refs/heads/main/bootstrap/mac-defaults.sh)"
    __done "$((step++))"
}
[ -n "${S_ONLY_UPDATE+1}" ] || __preferences

################################################################################
# End
################################################################################
printf '\n'
printf '************************************************************************\n'
printf '****                                                              ******\n'
printf '**** Mac Bootstrap complete! Please restart your computer.        ******\n'
printf '****                                                              ******\n'
printf '************************************************************************\n'
printf '\n'
