#!/usr/bin/env bash

# link
ln -s "/Applications/Sublime Text.app/Contents/SharedSupport/bin/subl" /usr/local/bin/sublime
ln -s "/Applications/Sublime Text.app/Contents/SharedSupport/bin/subl" /usr/local/bin/subl

defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool TRUE
