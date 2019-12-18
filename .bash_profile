#!/usr/bin/env bash

# 加载 dotfiles
# * ~/.path 用于扩展 `$PATH`
# * ~/.extra 用于包含一些额外的配置
for file in ~/.{path,bash_prompt,exports,aliases,functions,extra}; do
	# shellcheck disable=SC1090
	[ -r "$file" ] && [ -f "$file" ] && source "$file"
done

unset file
