#!/usr/bin/env bash
# shellcheck source=/dev/null

if [ "$(uname)" != "Linux" ]; then
    return
fi

if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    if command -v xclip &>/dev/null; then
        alias pbcopy='xclip -selection clipboard'
        alias pbpaste='xclip -selection clipboard -o'
    fi
fi
