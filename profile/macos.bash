#!/usr/bin/env bash
# shellcheck source=/dev/null

if [ "$(uname)" != "Darwin" ]; then
  return
fi

###############################################################################
# Aliases
###############################################################################

alias ic="cd ~/Library/Mobile\ Documents/com~apple~CloudDocs"                                                                                                                                    # icloud
alias flush="dscacheutil -flushcache && killall -HUP mDNSResponder"                                                                                                                              # Flush Directory Service cache
alias clear_files="sudo rm -rfv /private/var/log/asl/*.asl; sqlite3 ~/Library/Preferences/com.apple.LaunchServices.QuarantineEventsV* 'delete from LSQuarantineEvent'"                           # Clear Apple’s System Logs to improve shell startup speed, clear download history from quarantine.
alias ls_cleanup="/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -kill -r -domain local -domain system -domain user && killall Finder" # Clean up LaunchServices to remove duplicates in the “Open With” menu
alias show="defaults write com.apple.finder AppleShowAllFiles -bool true && killall Finder"                                                                                                      # Show hidden files in Finder
alias hide="defaults write com.apple.finder AppleShowAllFiles -bool false && killall Finder"                                                                                                     # Hide hidden files in Finder
alias showdesktop="defaults write com.apple.finder CreateDesktop -bool true && killall Finder"                                                                                                   # Show all desktop icons (useful when presenting)
alias hidedesktop="defaults write com.apple.finder CreateDesktop -bool false && killall Finder"                                                                                                  # Hide all desktop icons (useful when presenting)
alias spotoff="sudo mdutil -a -i off"                                                                                                                                                            # Disable Spotlight
alias spoton="sudo mdutil -a -i on"                                                                                                                                                              # Enable Spotlight
alias say="say -v Alex "
alias chrome='/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome'       # open google chrome
alias mergepdf='gs -q -dNOPAUSE -dBATCH -sDEVICE=pdfwrite -sOutputFile=_merged.pdf' # Merge PDF files, preserving hyperlinks, Usage: `mergepdf input{1,2,3}.pdf`

###############################################################################
# Path
###############################################################################

[ -d "/Library/TeX/texbin" ] && PATH="/Library/TeX/texbin:$PATH"

###############################################################################
# Completions
###############################################################################

if ! complete -p git &>/dev/null; then
  _git_bash_completion_paths=(
    # MacOS non-system locations
    '/Library/Developer/CommandLineTools/usr/share/git-core/git-completion.bash'
    '/Applications/Xcode.app/Contents/Developer/usr/share/git-core/git-completion.bash'
  )

  # Load the first completion file found
  for _comp_path in "${_git_bash_completion_paths[@]}"; do
    if [ -r "$_comp_path" ]; then
      source "$_comp_path"
      break
    fi
  done

  unset _git_bash_completion_paths
fi

complete -W "NSGlobalDomain" defaults
complete -o "nospace" -W "Contacts Calendar Dock Finder Mail Safari iTunes SystemUIServer Terminal Twitter" killall

###############################################################################
# Applications
###############################################################################

# Orbstack
# shellcheck disable=SC2015
[ -f "${HOME}/.orbstack/shell/init.bash" ] && source "${HOME}/.orbstack/shell/init.bash" 2>/dev/null || :

# Brave Browser
export CHROME_EXECUTABLE="/Applications/Brave Browser.app/Contents/MacOS/Brave Browser"

###############################################################################
# Functions
###############################################################################

# change dir to the folder opened in Finder
function cdf() {
  cd "$(osascript -e 'tell app "Finder" to POSIX path of (insertion location as alias)')" || return
}
