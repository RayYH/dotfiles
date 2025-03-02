#!/usr/bin/env bash

if ! command -v npm &>/dev/null; then
    echo "npm is not installed"
    exit 1
fi

packages=(
    "http-server"
    "eslint_d"
    "neovim"
)

for package in "${packages[@]}"; do
    npm install -g "$package"
done
