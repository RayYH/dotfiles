#!/usr/bin/env bash

# 添加 .bin 目录到路径变量之中
export PATH="$HOME/.bin:$PATH"

# 加载 dotfiles
# * ~/.path 用于扩展 `$PATH`
# * ~/.extra 用于包含一些额外的配置
for file in ~/.{path,bash_prompt,exports,aliases,functions,extra}; do
    # shellcheck disable=SC1090
    [ -r "$file" ] && [ -f "$file" ] && source "$file"
done

unset file

# -s (set) -u (unset)
# 查看 http://www.hep.by/gnu/bash/The-Shopt-Builtin.html#The-Shopt-Builtin 获取更多选项
# 以不区分大小写的方式匹配扩展文件名
shopt -s nocaseglob

# 追加到 HISTFILE 而不是覆盖它
shopt -s histappend

# 自动纠正 cd 时的输入
shopt -s cdspell

# 开启 Bash 4 的一些特性
for option in autocd globstar; do
    shopt -s "$option" 2>/dev/null
done

# bash 命令补全
if command -v brew &>/dev/null && [ -r "$(brew --prefix)/etc/profile.d/bash_completion.sh" ]; then
    # 确保现有的 Homebrew v1 补全仍能正常工作
    BASH_COMPLETION_COMPAT_DIR="$(brew --prefix)/etc/bash_completion.d"
    export BASH_COMPLETION_COMPAT_DIR
    # shellcheck disable=SC1090
    source "$(brew --prefix)/etc/profile.d/bash_completion.sh"
elif [ -f /etc/bash_completion ]; then
    # shellcheck disable=SC1091
    source /etc/bash_completion
fi

# 对 `g` 命令使用补全时，标记 `g` 为 `git`
if type _git &>/dev/null; then
    complete -o default -o nospace -F _git g
fi

# 添加基于 ~/.ssh/config 的命令补全，查看 https://dev.to/ahmedmusallam/how-to-autocomplete-ssh-hosts-1hob
[ -e "$HOME/.ssh/config" ] && complete -o "default" -o "nospace" -W "$(grep "^Host" ~/.ssh/config | grep -v "[?*]" | cut -d " " -f2- | tr ' ' '\n')" scp sftp ssh
