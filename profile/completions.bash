#!/usr/bin/env bash

# tab completion for many Bash commands
if command -v brew &>/dev/null && [ -r "$(brew --prefix)/etc/profile.d/bash_completion.sh" ]; then
  # Ensure existing Homebrew v1 completions continue to work
  BASH_COMPLETION_COMPAT_DIR="$(brew --prefix)/etc/bash_completion.d"
  export BASH_COMPLETION_COMPAT_DIR
  # shellcheck disable=SC1091
  source "$(brew --prefix)/etc/profile.d/bash_completion.sh"
  for file in "$BASH_COMPLETION_COMPAT_DIR"/*; do
    # shellcheck disable=SC1090
    [[ -x $file ]] && source "$file"
  done
elif [ -f /etc/bash_completion ]; then
  # shellcheck disable=SC1091
  source /etc/bash_completion
fi

# ubuntu bash-completion: /usr/share/bash-completion/bash_completion
if [ -f /usr/share/bash-completion/bash_completion ]; then
  # shellcheck disable=SC1091
  source /usr/share/bash-completion/bash_completion
fi

# export
complete -o nospace -S = -W "$(printenv | awk -F= "{print \$1}")" export

# Add tab completion for SSH hostnames based on ~/.ssh/config, ignoring wildcards
# https://dev.to/ahmedmusallam/how-to-autocomplete-ssh-hosts-1hob
[ -e "$HOME/.ssh/config" ] && complete -o "default" -o "nospace" -W "$(grep "^Host" "$HOME/.ssh/config" | grep -v "[?*]" | cut -d " " -f2- | tr ' ' '\n')" scp sftp ssh
