#!/usr/bin/env bash

# https://mise.jdx.dev/getting-started.html

if ! command -v mise &> /dev/null; then
    echo "mise is not installed"
    exit 1
fi

mise plugins add lua
mise use -g lua@5.1
ln -s ~/.local/share/mise/installs/lua/5.1/bin/lua ~/.local/bin/lua5.1