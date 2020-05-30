#!/usr/bin/env bash

WORKING_DIR=$(dirname "${BASH_SOURCE[0]}")
WORKING_DIR=$(cd "$WORKING_DIR" && pwd)

git pull origin master

function syncFiles() {
    rsync --exclude ".git/" \
        --exclude "resources" \
        --exclude ".DS_Store" \
        --exclude "bootstrap.sh" \
        --exclude "README.md" \
        --exclude "LICENSE" \
        --exclude "brew.sh" \
        -avh --no-perms . ~
    # shellcheck disable=SC1090
    source ~/.bash_profile
}

if [ "$1" == "--force" ] || [ "$1" == "-f" ]; then
    syncFiles
else
    read -rp "This may overwrite existing files in your home directory. Are you sure? (y/n) " -n 1
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        syncFiles
    fi
fi

unset syncFiles
