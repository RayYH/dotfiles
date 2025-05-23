#!/usr/bin/env bash
# shellcheck disable=SC2145

# mkdir then cd in
function mkd() {
  mkdir -p "$@" && cd "$_" || return
}

# find file in current folder whose name matched provided string
function ff() {
  find . -name "$@"
}

# find file in current folder whose name starts with provided string
function ffs() {
  find . -name "$@"'*'
}

# find file in current folder whose name ends with provided string
function ffe() {
  find . -name '*'"$@"
}

# determine the size of file or folder
function fs() {
  if du -b /dev/null >/dev/null 2>&1; then
    local arg=-sbh
  else
    local arg=-sh
  fi
  # shellcheck disable=SC2199
  if [[ -n "$@" ]]; then
    du $arg -- "$@"
  else
    du $arg .[^.]* ./*
  fi
}

# search keyword in given dir
function search() {
  str="$1"
  dir=.
  if [ -n "$2" ]; then
    dir="$2"
  fi
  grep -rin "$str" "$dir"
}

# show datetime of given timestamp
function ts_d() {
  local d_format
  local ts
  local ms
  ts=${1:0:10}
  ms=${1:10:${#1}}
  d_format='"+%Y-%m-%d %H:%M:%S"'
  [[ -n "$ms" ]] && d_format="\"+%Y-%m-%d %H:%M:%S,$ms\""
  cmd="date --date @$ts"
  # we will install core utils
  if [ ! -e "/usr/local/opt/coreutils/libexec/gnubin/date" ]; then
    [[ $"OSTYPE" == "darwin"* ]] && cmd="date -d @$ts"
  fi
  eval "$cmd $d_format"
}

# create a dataurl of given file
function dataurl() {
  local mimeType
  mimeType=$(file -b --mime-type "$1")
  if [[ $mimeType == text/* ]]; then
    mimeType="${mimeType};charset=utf-8"
  fi
  echo "data:${mimeType};base64,$(openssl base64 -in "$1" | tr -d '\n')"
}

# extract file: extract *.tgz
function extract() {
  if [ -f "$1" ]; then
    case $1 in
    *.tar.bz2) tar xjf "$1" ;;
    *.tar.gz) tar xzf "$1" ;;
    *.bz2) bunzip2 "$1" ;;
    *.rar) unrar e "$1" ;;
    *.gz) gunzip "$1" ;;
    *.tar) tar xf "$1" ;;
    *.tbz2) tar xjf "$1" ;;
    *.tgz) tar xzf "$1" ;;
    *.zip) unzip "$1" ;;
    *.Z) uncompress "$1" ;;
    *.7z) 7z x "$1" ;;
    *) echo "'$1' cannot be extracted via extract()" ;;
    esac
  else
    echo "'$1' is not a valid file"
  fi
}

# create a `.tar.gz` archive
function targz() {
  local tmpFile="${*%/}.tar"
  tar -cvf "${tmpFile}" --exclude=".DS_Store" "${@}" || return 1

  size=$(
    stat -f"%z" "${tmpFile}" 2>/dev/null # macOS `stat`
    stat -c"%s" "${tmpFile}" 2>/dev/null # GNU `stat`
  )

  local cmd=""
  if ((size < 52428800)) && hash zopfli 2>/dev/null; then
    # the .tar file is smaller than 50 MB and Zopfli is available; use it
    cmd="zopfli"
  else
    if hash pigz 2>/dev/null; then
      cmd="pigz"
    else
      cmd="gzip"
    fi
  fi

  echo "Compressing .tar ($((size / 1000)) kB) using \`${cmd}\`…"
  "${cmd}" -v "${tmpFile}" || return 1
  [ -f "${tmpFile}" ] && rm "${tmpFile}"

  zippedSize=$(
    stat -f"%z" "${tmpFile}.gz" 2>/dev/null # macOS `stat`
    stat -c"%s" "${tmpFile}.gz" 2>/dev/null # GNU `stat`
  )

  echo "${tmpFile}.gz ($((zippedSize / 1000)) kB) created successfully."
}

# start a HTTP Server via http-server package (node) - `npm i http-server -g`
# if http-server not installed, use python instead
function server() {
  if command -v http-server &>/dev/null; then
    http-server -p "${1:-8000}" || return
  fi
  python3 -m http.server "${1:-8000}"
}

# show the compression ratio
function gz() {
  local origsize
  origsize=$(wc -c <"$1")
  local gzipsize
  gzipsize=$(gzip -c "$1" | wc -c)
  local ratio
  ratio=$(echo "$gzipsize * 100 / $origsize" | bc -l)
  printf "orig: %d bytes\n" "$origsize"
  printf "gzip: %d bytes (%2.2f%%)\n" "$gzipsize" "$ratio"
}

# get all subdomains, e.g. getcertnames baidu.com
function getcertnames() {
  if [ -z "${1}" ]; then
    echo "ERROR: No domain specified."
    return 1
  fi

  local domain="${1}"
  echo "Testing ${domain}…"
  echo "" # newline

  local tmp
  tmp=$(echo -e "GET / HTTP/1.0\nEOT" |
    openssl s_client -connect "${domain}:443" -servername "${domain}" 2>&1)

  if [[ "${tmp}" == *"-----BEGIN CERTIFICATE-----"* ]]; then
    local certText
    certText=$(echo "${tmp}" |
      openssl x509 -text -certopt "no_aux, no_header, no_issuer, no_pubkey, \
			no_serial, no_sigdump, no_signame, no_validity, no_version")
    echo "Common Name:"
    echo "" # newline
    echo "${certText}" | grep "Subject:" | sed -e "s/^.*CN=//" | sed -e "s/\/emailAddress=.*//"
    echo "" # newline
    echo "Subject Alternative Name(s):"
    echo "" # newline
    echo "${certText}" | grep -A 1 "Subject Alternative Name:" |
      sed -e "2s/DNS://g" -e "s/ //g" | tr "," "\n" | tail -n +2
    return 0
  else
    echo "ERROR: Certificate not found."
    return 1
  fi
}

# open folder
function o() {
  if command -v open &>/dev/null; then
    if [ $# -eq 0 ]; then
      open .
    else
      open "$@"
    fi
  fi
}

# optimized tree command，omit some folder: please run brew install tree first
function tre() {
  tree -aC -I '.git|node_modules|bower_components|vendor' --dirsfirst "$@" | less -FRNX
}

# compress json
function cjson() {
  local str res
  str="$1"
  if command -v pbpaste &>/dev/null; then
    [ -z "$str" ] && str=$(pbpaste)
  fi
  [ -f "$str" ] && str=$(cat "$str")
  res=$(echo "${str//[[:blank:]]/}" | tr -d '\n')
  if command -v pbcopy &>/dev/null; then
    echo "$res" | pbcopy
    # when compress, don't display the info
    # pbpaste
  else
    echo "$res"
  fi
}

# pretty json
function pjson() {
  local str res
  str="$1"
  if command -v pbpaste &>/dev/null; then
    [ -z "$str" ] && str=$(pbpaste)
  elif command -v paste &>/dev/null; then
    [ -z "$str" ] && str=$(paste)
  fi
  # if jq installed
  if command -v jq &>/dev/null; then
    if [ -f "$str" ]; then
      res=$(jq . <"$str")
    else
      res=$(echo "$str" | jq .)
    fi
  else
    if [ -f "$str" ]; then
      res=$(python -m json.tool "$str")
    else
      res=$(echo "$str" | python -m json.tool)
    fi
  fi
  if command -v pbcopy &>/dev/null; then
    echo "$res" | pbcopy
    pbpaste
  elif command -v clip &>/dev/null; then
    echo "$res" | clip
  else
    echo "$res"
  fi
}

# urlencode
function urlencode() {
  old_lc_collate=$LC_COLLATE
  LC_COLLATE=C

  local length="${#1}"
  for ((i = 0; i < length; i++)); do
    local c="${1:$i:1}"
    case $c in
    [a-zA-Z0-9.~_-]) printf '%s' "$c" ;;
    *) printf '%%%02X' "'$c" ;;
    esac
  done

  LC_COLLATE=$old_lc_collate
}

# urldecode
function urldecode() {
  local url_encoded="${1//+/ }"
  printf '%b' "${url_encoded//%/\\x}"
}

# show git aliases
function git-aliases() {
  git config --get-regexp alias | awk '{first = $1; $1 = ""; printf "%-20s %s\n", first, $0; }'
}

# use git diff to diff files/folders
if [ ! "$(hash git &>/dev/null)" ]; then
  function diff() {
    git diff --no-index --color-words "$@"
  }
fi

function git-dv() {
  git diff -w "$@" | vim -R -
}

function transform-git-ro() {
  origin=$(git remote -v | grep "origin" | head -n1)
  url=""
  # convert git to https
  if echo "$origin" | grep "git@" &>/dev/null; then
    regex=".+git@([0-9a-zA-Z\-\_\.]+):([0-9a-zA-Z\-\_]+)/([0-9a-zA-Z\-]+)\.git"
    if [[ $origin =~ $regex ]]; then
      hostname="${BASH_REMATCH[1]}"
      username="${BASH_REMATCH[2]}"
      repo="${BASH_REMATCH[3]}"
      url="https://$hostname/$username/$repo"
    fi
  # convert https to git
  else
    regex=".+https://([0-9a-zA-Z\-\_\.]+)/([0-9a-zA-Z\-\_]+)/([0-9a-zA-Z\-]+)"
    if [[ $origin =~ $regex ]]; then
      hostname="${BASH_REMATCH[1]}"
      username="${BASH_REMATCH[2]}"
      repo="${BASH_REMATCH[3]}"
      repo=${repo%".git"}
      url="git@$hostname:$username/$repo.git"
    fi
  fi
  [ -n "$url" ] && echo "set origin: $url" && git remote set-url origin "$url"
}

# Show top input commands
function rh() {
  history | awk '{a[$2]++}END{for(i in a){print a[i] " " i}}' | sort -rn | head
}

# quick look file via default Preview program provided by macos
function ql() {
  qlmanage -p "$*" >&/dev/null
}

# Open chrome window behind a socks proxy
function chromep() {
  if [ -z "${1}" ]; then
    echo "ERROR: No socks port specified."
    return 1
  fi
  if lsof -i ":$1" >/dev/null 2>&1; then
    chrome --user-data-dir="$HOME/.cache/chrome/proxy-profile" \
      --proxy-server="socks5://localhost:$1"
  else
    echo "ERROR: invalid socks port."
    return 1
  fi
}

# Set permission for your terminals
# System Preferences > Security & Privacy > Privacy > Full Disk Access
# move file to Trash bin
function trash() {
  command mv "$@" ~/.Trash
}

function set_p() {
  local port=${SET_UP_PROXY_HTTP_PORT:=1088}
  local sock_port=${SET_UP_PROXY_SOCKS_PORT:=1086}
  local host=${SET_UP_PROXY_HTTP_HOST:=127.0.0.1}
  local sock_host=${SET_UP_PROXY_SOCKS_HOST:=127.0.0.1}
  # socks proxy in gnome
  export all_proxy=socks5://${sock_host}:${sock_port}
  export ftp_proxy=http://${host}:${port}
  export http_proxy=http://${host}:${port}
  export https_proxy=http://${host}:${port}
  export HTTP_PROXY=${http_proxy}
  export HTTPS_PROXY=${https_proxy}
  # see https://minikube.sigs.k8s.io/docs/handbook/vpn_and_proxy/
  export NO_PROXY=localhost,127.0.0.1,10.96.0.0/12,192.168.99.0/24,192.168.39.0/24
}

function unset_p() {
  unset all_proxy
  unset ftp_proxy
  unset http_proxy
  unset https_proxy
  unset HTTP_PROXY
  unset HTTPS_PROXY
  unset NO_PROXY
}

function randS() {
  local len=32
  if [ -z "${1}" ]; then
    len=32
  else
    len="$1"
  fi
  tr -dc A-Za-z0-9 </dev/urandom | head -c "$len"
  echo ''
}

function xl() {
  if [ ! -f "$1" ]; then
    echo "file $1 not exists"
  fi
  if command -v xelatex &>/dev/null; then
    xelatex -synctex=1 -interaction=nonstopmode -file-line-error -shell-escape "$1"
  fi
}

function mman() {
  man "$@" 2>/dev/null
}
alias man="mman"

function yy() {
  # yazi support: https://yazi-rs.github.io/docs/quick-start
  local tmp
  tmp="$(mktemp -t "yazi-cwd.XXXXX")"
  yazi "$@" --cwd-file="$tmp"
  if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
    cd -- "$cwd" || return
  fi
  rm -f -- "$tmp"
}

# myZip <folder>
function myZip() {
  if [ -z "${1}" ]; then
    echo "ERROR: No file specified."
    return 1
  fi

  zip -vr "${1}.zip" "${1}/" -x "*.DS_Store" -x "__MACOSX" -x "*.git" -x "*.svn" -x "*.idea" -x "*.vscode" -x "*.vs" -x "*.cache" -x "*.log" -x "*.tmp"
}
