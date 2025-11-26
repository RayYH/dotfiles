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

if [ -d "$HOME/.config/kitty" ]; then
    mv "$HOME/.config/kitty" "$BACKUP_FOLDER"
fi
rm -rf "$HOME/.config/kitty"
ln -s "$DOTFILES/config/kitty" "$HOME/.config/kitty"

# tmux
if [ -f "$HOME/.tmux.conf" ]; then
    mv "$HOME/.tmux.conf" "$BACKUP_FOLDER"
fi
rm -rf "$HOME/.tmux.conf"
ln -s "$DOTFILES/config/tmux/tmux.conf" "$HOME/.tmux.conf"

if [ -d "$HOME/.config/nvim" ]; then
    mv "$HOME/.config/nvim" "$BACKUP_FOLDER"
fi
rm -rf "$HOME/.config/nvim"
ln -s "$DOTFILES/config/nvim" "$HOME/.config/nvim"

if [ -d "$HOME/.config/alacritty" ]; then
    mv "$HOME/.config/alacritty" "$BACKUP_FOLDER"
fi
rm -rf "$HOME/.config/alacritty"
ln -s "$DOTFILES/config/alacritty" "$HOME/.config/alacritty"

if [ -f "$HOME/.config/starship.toml" ]; then
    mv "$HOME/.config/starship.toml" "$BACKUP_FOLDER"
fi
rm -rf "$HOME/.config/starship.toml"
ln -s "$DOTFILES/config/starship/starship.toml" "$HOME/.config/starship.toml"

if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    if [[ -f "$DOTFILES/config/starship/ubuntu/starship.toml" ]]; then
        rm -rf "$HOME/.config/starship.toml"
        ln -s "$DOTFILES/config/starship/ubuntu/starship.toml" "$HOME/.config/starship.toml"
    fi
elif [[ "$OSTYPE" == "darwin"* ]]; then
    if [[ -f "$DOTFILES/config/starship/macos/starship.toml" ]]; then
        rm -rf "$HOME/.config/starship.toml"
        ln -s "$DOTFILES/config/starship/macos/starship.toml" "$HOME/.config/starship.toml"
    fi
elif [[ "$OSTYPE" == "linux-musl" ]]; then
    if [[ -f "$DOTFILES/config/starship/arch/starship.toml" ]]; then
        rm -rf "$HOME/.config/starship.toml"
        ln -s "$DOTFILES/config/starship/arch/starship.toml" "$HOME/.config/starship.toml"
    fi
fi

if [ -f "$HOME/.curlrc" ]; then
    mv "$HOME/.curlrc" "$BACKUP_FOLDER"
fi
rm -rf "$HOME/.curlrc"
ln -s "$DOTFILES/config/curl/.curlrc" "$HOME/.curlrc"

if [ -f "$HOME/.wgetrc" ]; then
    mv "$HOME/.wgetrc" "$BACKUP_FOLDER"
fi
rm -rf "$HOME/.wgetrc"
ln -s "$DOTFILES/config/wget/.wgetrc" "$HOME/.wgetrc"

if [ -f "$HOME/.shellcheckrc" ]; then
    mv "$HOME/.shellcheckrc" "$BACKUP_FOLDER"
fi
rm -rf "$HOME/.shellcheckrc"
ln -s "$DOTFILES/config/shellcheck/.shellcheckrc" "$HOME/.shellcheckrc"

if [ -f "$HOME/.config/uv/uv.toml" ]; then
    mv "$HOME/.config/uv/uv.toml" "$BACKUP_FOLDER"
fi
mkdir -p "$HOME/.config/uv"
rm -rf "$HOME/.config/uv/uv.toml"
ln -s "$DOTFILES/config/uv/uv.toml" "$HOME/.config/uv/uv.toml"

if [ -f "$HOME/.editorconfig" ]; then
    mv "$HOME/.editorconfig" "$BACKUP_FOLDER"
fi
rm -rf "$HOME/.editorconfig"
ln -s "$DOTFILES/config/editorconfig/.editorconfig" "$HOME/.editorconfig"

if [ -f "$HOME/.condarc" ]; then
    mv "$HOME/.condarc" "$BACKUP_FOLDER"
fi
rm -rf "$HOME/.condarc"
ln -s "$DOTFILES/config/conda/.condarc" "$HOME/.condarc"

if [ -f "$HOME/.ideavimrc" ]; then
    mv "$HOME/.ideavimrc" "$BACKUP_FOLDER"
fi
rm -rf "$HOME/.ideavimrc"
ln -s "$DOTFILES/config/jetbrains/.ideavimrc" "$HOME/.ideavimrc"

if [ -f "$HOME/.gitignore" ]; then
    mv "$HOME/.gitignore" "$BACKUP_FOLDER"
fi
rm -rf "$HOME/.gitignore"
ln -s "$DOTFILES/config/git/.gitignore" "$HOME/.gitignore"

if [ -f "$HOME/.gitconfig" ]; then
    mv "$HOME/.gitconfig" "$BACKUP_FOLDER"
fi
cp "$DOTFILES/config/git/.gitconfig" "$HOME/.gitconfig"

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
    echo >>"$BASH_PROFILE"
    # shellcheck disable=SC2016,SC2086
    echo "test -e "$DOTFILES/setup.bash" && source "$DOTFILES/setup.bash"" >>"$BASH_PROFILE"
    echo "setup done, restart your terminal!!"
fi
