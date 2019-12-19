#!/usr/bin/env bash

# Install zsh first: https://github.com/ohmyzsh/ohmyzsh

# If you come from bash you might have to change your $PATH.
export PATH=$HOME/.bin:/usr/local/bin:$PATH:$HOME/.composer/vendor/bin

# Path to your oh-my-zsh installation.
export ZSH="/Users/ray/.oh-my-zsh"

# Theme
ZSH_THEME="agnoster"

# Plugins
# git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
# git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
plugins=(
	git
	gitignore
	laravel
	node
	npm
	docker
	github
	osx
	autojump
	sublime
	zsh-autosuggestions
	zsh-syntax-highlighting
)

# source oh-my-zsh
source $ZSH/oh-my-zsh.sh

# load below dotfiles
for file in ~/.{path,exports,aliases,functions,extra}; do
    # shellcheck disable=SC1090
    [ -r "$file" ] && [ -f "$file" ] && source "$file"
done

# change default .zcompdump-* file, make sure you've created .cache/zsh folder
compinit -d ~/.cache/zsh/zcompdump-$ZSH_VERSION

# fix tail % symbol
export PROMPT_EOL_MARK=''