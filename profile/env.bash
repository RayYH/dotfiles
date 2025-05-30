#!/usr/bin/env bash

HOMEBREW_PREFIX="/usr/local"
if [[ $(uname -m) == 'arm64' ]]; then
  HOMEBREW_PREFIX="/opt/homebrew"
fi

if command -v brew &>/dev/null; then
  HOMEBREW_PREFIX="$(brew --prefix)"
fi

# see https://cs.symfony.com/doc/usage.html#environment-options
PHP_CS_FIXER_IGNORE_ENV=1

# reset path --- otherwise conda will not work due to some reasons
PATH=$(getconf PATH)

# paths
[ -d "/usr/local/bin" ] && PATH="/usr/local/bin:$PATH"                                                               # sys
[ -d "$HOMEBREW_PREFIX/bin" ] && PATH="$HOMEBREW_PREFIX/bin:$PATH"                                                   # brew
[ -d "$HOMEBREW_PREFIX/sbin" ] && PATH="$HOMEBREW_PREFIX/sbin:$PATH"                                                 # brew
[ -d "$HOME/.composer/vendor/bin" ] && PATH="$HOME/.composer/vendor/bin:$PATH"                                       # composer
[ -d "$HOME/.cargo/bin" ] && PATH="$HOME/.cargo/bin:$PATH"                                                           # rust
[ -d "$HOME/Bundles/flutter/bin" ] && PATH="$HOME/Bundles/flutter/bin:$PATH"                                         # rust
[ -d "$HOME/Bin" ] && PATH="$HOME/Bin:$PATH"                                                                         # custom path (jetbrains shell scripts path)
[ -d "$HOMEBREW_PREFIX/opt/curl/bin" ] && PATH="$HOMEBREW_PREFIX/opt/curl/bin:$PATH"                                 # curl
[ -d "$HOMEBREW_PREFIX/opt/gnu-sed/libexec/gnubin" ] && PATH="$HOMEBREW_PREFIX/opt/gnu-sed/libexec/gnubin:$PATH"     # sed: illegal option -- r, you should install gnu-sed first via command: brew install gnu-sed
[ -d "$HOMEBREW_PREFIX/opt/make/libexec/gnubin" ] && PATH="$HOMEBREW_PREFIX/opt/make/libexec/gnubin:$PATH"           # make
[ -d "$HOMEBREW_PREFIX/opt/coreutils/libexec/gnubin" ] && PATH="$HOMEBREW_PREFIX/opt/coreutils/libexec/gnubin:$PATH" # coreutils
[ -d "$HOMEBREW_PREFIX/opt/findutils/libexec/gnubin" ] && PATH="$HOMEBREW_PREFIX/opt/findutils/libexec/gnubin:$PATH" # findutils
[ -d "$HOMEBREW_PREFIX/opt/grep/libexec/gnubin" ] && PATH="$HOMEBREW_PREFIX/opt/grep/libexec/gnubin:$PATH"           # grep
[ -d "$HOMEBREW_PREFIX/opt/mysql-client/bin" ] && PATH="$HOMEBREW_PREFIX/opt/mysql-client/bin:$PATH"                 # mysql
[ -d "$HOME/Code/snippets/bin" ] && PATH="$HOME/Code/snippets/bin:$PATH"                                             # snippets
[ -d "/Library/TeX/texbin" ] && PATH="/Library/TeX/texbin:$PATH"                                                     # latex
[ -d "$HOME/.deno/bin" ] && PATH="$HOME/.deno/bin:$PATH"                                                             # deno
[ -d "$HOME/.local/bin" ] && PATH="$HOME/.local/bin:$PATH"

# Ubuntu path
[ -d "/sbin" ] && PATH="/sbin:$PATH"
[ -d "/usr/sbin" ] && PATH="/usr/sbin:$PATH"
[ -d "/snap/bin" ] && PATH="/snap/bin:$PATH"

# pnpm
export PNPM_HOME="$HOME/Library/pnpm"
export PATH="$PNPM_HOME:$PATH"

# cargo
[ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"

[ -x "$HOME/miniforge3/bin/conda" ] && eval "$("$HOME/miniforge3/bin/conda" shell.bash hook)"

# avoid duplicate path
PATH=$(printf "%s" "$PATH" | awk -v RS=':' '!a[$1]++ { if (NR > 1) printf RS; printf $1 }')

# Common
export EDITOR='vim'         # Make vim the default editor.
export LANG='en_US.UTF-8'   # Prefer US English and use UTF-8.
export LC_ALL='en_US.UTF-8' # Prefer US English and use UTF-8.

# TERM
if [[ $COLORTERM == gnome-* && $TERM == xterm ]] &&
  infocmp gnome-256color >/dev/null 2>&1; then
  export TERM='gnome-256color'
elif infocmp xterm-256color >/dev/null 2>&1; then
  export TERM='xterm-256color'
fi

# force using Go modules
export GO111MODULE=on

# avoid issues with `gpg` as installed via Homebrew, see https://stackoverflow.com/a/42265848/96656
GPG_TTY="$(tty)" && export GPG_TTY

# history
shopt -s histappend                                      # append to bash_history if Terminal.app quits
export HISTSIZE=${HISTSIZE:-32768}                       # Increase Bash history size.
export HISTFILESIZE="${HISTSIZE}"                        # Increase Bash history size.
export HISTCONTROL=${HISTCONTROL:-ignorespace:erasedups} # erase duplicates; alternative option: export HISTCONTROL=ignoredups
export HISTCONTROL='ignoreboth'                          # Omit duplicates and commands that begin with a space from history.
export AUTOFEATURE=${AUTOFEATURE:-true autotest}         # Cucumber / Autotest integration
export PROMPT_COMMAND="history -a; history -n"
export HISTTIMEFORMAT="%F %T "
export HISTIGNORE="&:ls:[bf]g:exit:clear:reset:history:pwd:df:du:ls:ll:la:l:cd:cd -:cd ..:cd ~:cd /:cd -"

# Less Colors for Man Pages
export LESS_TERMCAP_mb=$'\e[01;31m'       # begin blinking
export LESS_TERMCAP_md=$'\e[01;38;5;74m'  # begin bold
export LESS_TERMCAP_me=$'\e[0m'           # end mode
export LESS_TERMCAP_se=$'\e[0m'           # end standout-mode
export LESS_TERMCAP_so=$'\e[38;5;246m'    # begin standout-mode - info box
export LESS_TERMCAP_ue=$'\e[0m'           # end underline
export LESS_TERMCAP_us=$'\e[04;38;5;146m' # begin underline
export MANPAGER='less -X'                 # don’t clear the screen after quitting a manual page

export LESSHISTFILE="${HOME}/.cache/less/history" # where history file will be saved

# node
export NODE_REPL_HISTORY=~/.node_history # Enable persistent REPL history for `node`, see https://nodejs.org/api/repl.html
export NODE_REPL_HISTORY_SIZE='32768'    # Allow 32³ entries; the default is 1000.
export NODE_REPL_MODE='sloppy'           # Use sloppy mode by default, matching web browsers.

# osx
export SAVEHIST=0
export BASH_SILENCE_DEPRECATION_WARNING=1 # hide the ‘default interactive shell is now zsh’

# python
export PYTHONIOENCODING='UTF-8' # Make Python use UTF-8 encoding for output to stdin, stdout, and stderr.
export MNT="$HOME/.mnt"

# php-cs-fixer lint
export PHP_CS_FIXER_IGNORE_ENV=1
