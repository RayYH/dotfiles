#!/usr/bin/env bash

function __echo() {
    local fmt="$1"
    shift
    printf "\\n\\e[0;36m[INFO]\\e[0m $fmt\\n" "$@"
}

function __error() {
    local fmt="$1"
    shift
    printf "\\n\\e[0;31m[ERROR]\\e[0m $fmt\\n" "$@"
    exit 1
}

function __done() {
    __echo "Step $1 \\e[0;32m[✔]\\e[0m"
}

function __command_exists() {
    command -v "$1" &>/dev/null
}

function __confirm() {
    read -r -p "$1 [y/N] " response
    if [[ $response =~ ^([yY][eE][sS]|[yY])$ ]]; then
        return 0
    fi
    return 1
}

function __logo() {
    printf '\n'
    printf '************************************************************************\n'
    printf '*******                                                           ******\n'
    printf '*******                    Welcome to Bootstrap!                  ******\n'
    printf '*******                                                           ******\n'
    printf '************************************************************************\n'
    printf '\n'
}
