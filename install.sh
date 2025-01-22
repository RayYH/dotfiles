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

# make sure .config exists
mkdir -p "$HOME/.config"

# kitty
rm -rf "$HOME/.config/kitty"
ln -s "$DOTFILES/config/kitty" "$HOME/.config/kitty"

# tmux
rm -rf "$HOME/.tmux.conf"
ln -s "$DOTFILES/config/tmux/tmux.conf" "$HOME/.tmux.conf"

# nvim
rm -rf "$HOME/.config/nvim"
ln -s "$DOTFILES/config/nvim" "$HOME/.config/nvim"

# alacritty
rm -rf "$HOME/.config/alacritty"
ln -s "$DOTFILES/config/alacritty" "$HOME/.config/alacritty"

# starship
rm -rf "$HOME/.config/starship.toml"
ln -s "$DOTFILES/config/starship/starship.toml" "$HOME/.config/starship.toml"

# curl
rm -rf "$HOME/.curlrc"
ln -s "$DOTFILES/config/curl/.curlrc" "$HOME/.curlrc"

# wget
rm -rf "$HOME/.wgetrc"
ln -s "$DOTFILES/config/wget/.wgetrc" "$HOME/.wgetrc"

# shell check
rm -rf "$HOME/.shellcheckrc"
ln -s "$DOTFILES/config/shellcheck/.shellcheckrc" "$HOME/.shellcheckrc"

# editorconfig
rm -rf "$HOME/.editorconfig"
ln -s "$DOTFILES/config/editorconfig/.editorconfig" "$HOME/.editorconfig"

# conda
rm -rf "$HOME/.condarc"
ln -s "$DOTFILES/config/conda/.condarc" "$HOME/.condarc"

# ideavimrc
rm -rf "$HOME/.ideavimrc"
ln -s "$DOTFILES/config/jetbrains/.ideavimrc" "$HOME/.ideavimrc"

# scripts
mkdir -p "$HOME/.local/bin"

rm -rf "$HOME/.local/bin/t"
ln -s "$DOTFILES/scripts/t" "$HOME/.local/bin/t"

rm -rf "$HOME/.local/bin/u"
ln -s "$DOTFILES/scripts/u" "$HOME/.local/bin/u"

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
    # write empty line first
    echo >>"$BASH_PROFILE"
    # shellcheck disable=SC2016
    echo "test -e "$DOTFILES/setup.bash" && source "$DOTFILES/setup.bash"" >>"$BASH_PROFILE"
    echo "setup done, restart your terminal!!"
fi