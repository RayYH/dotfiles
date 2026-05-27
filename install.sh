#!/usr/bin/env bash

WORKING_DIR=$(dirname "${BASH_SOURCE[0]}")
WORKING_DIR=$(cd "$WORKING_DIR" && pwd)

DOTFILES="$WORKING_DIR"

if [[ "$SHELL" == *bash ]]; then
    echo "Your current shell is bash"
else
    command -v bash | sudo tee -a /etc/shells
    chsh -s "$(command -v bash)"
fi

if [ -f "$HOME/.setuprc" ]; then
    echo "$HOME/.setuprc already exists"
else
    cp "$DOTFILES/.setuprc" "$HOME/.setuprc"
fi

mkdir -p "$HOME/.config"

BACKUP_FOLDER="$DOTFILES/backup/$(date +%Y%m%d%H%M%S)"
mkdir -p "$BACKUP_FOLDER"

backup_and_remove() {
    local target="$1"
    if [ -e "$target" ] || [ -L "$target" ]; then
        mv "$target" "$BACKUP_FOLDER"
    fi
    rm -rf "$target"
}

install_entry() {
    local src="$1"
    local dest="${2/#\~/$HOME}"
    local op="${3:-link}"
    mkdir -p "$(dirname "$dest")"
    if [[ "$op" == "copy" ]] && ( [ -e "$dest" ] || [ -L "$dest" ] ); then
        read -r -p "$dest already exists. Override? [y/N] " answer </dev/tty
        [[ "$answer" =~ ^[Yy]$ ]] || { echo "Skipping $dest"; return; }
    fi
    backup_and_remove "$dest"
    if [[ "$op" == "copy" ]]; then
        cp "$src" "$dest"
    else
        ln -s "$src" "$dest"
    fi
}

while IFS= read -r line; do
    [[ "$line" =~ ^[[:space:]]*# ]] && continue
    [[ "$line" =~ ^[[:space:]]*$ ]] && continue

    src=$(echo "$line" | sed 's/[[:space:]]*->.*$//' | sed 's/[[:space:]]*$//')
    rest=$(echo "$line" | sed 's/^.*->[[:space:]]*//')
    dest=$(echo "$rest" | awk '{print $1}')
    op=$(echo "$rest" | awk 'NF>1 {print $2}')

    if [[ "$src" == *\* ]]; then
        src_dir="$DOTFILES/${src%/*}"
        dest="${dest/#\~/$HOME}"
        mkdir -p "$dest"
        for item in "$src_dir"/*; do
            [ -e "$item" ] || continue
            backup_and_remove "$dest/$(basename "$item")"
            ln -s "$item" "$dest/$(basename "$item")"
        done
    else
        install_entry "$DOTFILES/$src" "$dest" "$op"
    fi
done < "$DOTFILES/MANIFEST"

case $OSTYPE in
darwin*)
    BASH_PROFILE="$HOME/.bash_profile"
    ;;
*)
    BASH_PROFILE="$HOME/.bashrc"
    ;;
esac

if grep -q "$DOTFILES/setup.bash" "$BASH_PROFILE"; then
    echo "You've already enabled setup"
else
    printf '\n' >>"$BASH_PROFILE"
    printf 'test -e "%s/setup.bash" && source "%s/setup.bash"\n' "$DOTFILES" "$DOTFILES" >>"$BASH_PROFILE"
    echo "setup done, restart your terminal!!"
fi
