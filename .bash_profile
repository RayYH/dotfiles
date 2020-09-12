#!/usr/bin/env bash

# Add `~/Bin` to the `$PATH`
export PATH="$HOME/Bin:$PATH"

# Load the shell dotfiles, and then some:
# ~/.path can be used to extend `$PATH`.
# ~/.extra can be used for other settings you don’t want to commit.
for file in ~/.{path,bash_prompt,exports,aliases,functions,extra}; do
    # shellcheck disable=SC1090
    [ -r "$file" ] && [ -f "$file" ] && source "$file"
done

unset file

# -s (set) -u (unset)
# http://www.hep.by/gnu/bash/The-Shopt-Builtin.html#The-Shopt-Builtin
# Case-insensitive globbing (used in pathname expansion)
shopt -s nocaseglob

# Append to the Bash history file, rather than overwriting it
shopt -s histappend

# Autocorrect typos in path names when using `cd`
shopt -s cdspell

# Enable some Bash 4 features when possible:
# `autocd`, e.g. `**/qux` will enter `./foo/bar/baz/qux`
# Recursive globbing, e.g. `echo **/*.txt`
for option in autocd globstar; do
    shopt -s "$option" 2>/dev/null
done

# Add tab completion for many Bash commands
if command -v brew &>/dev/null && [ -r "$(brew --prefix)/etc/profile.d/bash_completion.sh" ]; then
    # Ensure existing Homebrew v1 completions continue to work
    BASH_COMPLETION_COMPAT_DIR="$(brew --prefix)/etc/bash_completion.d"
    export BASH_COMPLETION_COMPAT_DIR
    # shellcheck disable=SC1090
    source "$(brew --prefix)/etc/profile.d/bash_completion.sh"
elif [ -f /etc/bash_completion ]; then
    # shellcheck disable=SC1091
    source /etc/bash_completion
fi

# Add tab completion for SSH hostnames based on ~/.ssh/config, ignoring wildcards
# https://dev.to/ahmedmusallam/how-to-autocomplete-ssh-hosts-1hob
[ -e "$HOME/.ssh/config" ] && complete -o "default" -o "nospace" -W "$(grep "^Host" ~/.ssh/config | grep -v "[?*]" | cut -d " " -f2- | tr ' ' '\n')" scp sftp ssh

# Add tab completion for `defaults read|write NSGlobalDomain`
# You could just use `-g` instead, but I like being explicit
complete -W "NSGlobalDomain" defaults

# Add `killall` tab completion for common apps
complete -o "nospace" -W "Contacts Calendar Dock Finder Mail Safari iTunes SystemUIServer Terminal Twitter" killall

# for iTerm2
test -e "${HOME}/.iterm2_shell_integration.bash" && source "${HOME}/.iterm2_shell_integration.bash"
