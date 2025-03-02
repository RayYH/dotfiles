#!/usr/bin/env bash

if ! command -v pip &>/dev/null; then
    echo "pip is not installed"
    exit 1
fi

packages=(
    "black"
    "flake8"
    "isort"
    "neovim"
)

for package in "${packages[@]}"; do
    pip install "$package"
done