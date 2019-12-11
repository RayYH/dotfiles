#!/usr/bin/env bash

cd "$(dirname "${BASH_SOURCE}")" || return;

# git pull origin master;

function doIt() {
	rsync --exclude ".git/" \
        --exclude "licenses/" \
		--exclude ".DS_Store" \
		--exclude ".osx" \
		--exclude "bootstrap.sh" \
		--exclude "README.md" \
		--exclude "LICENSE" \
        --exclude "brew.sh" \
		--exclude "config.sh" \
		-avh --no-perms . ~;
	source ~/.bash_profile;
}

if [ "$1" == "--force" -o "$1" == "-f" ]; then
	doIt;
else
	read -rp "This may overwrite existing files in your home directory. Are you sure? (y/n) " -n 1;
	echo "";
	if [[ $REPLY =~ ^[Yy]$ ]]; then
		doIt;
	fi;
fi;

unset doIt;