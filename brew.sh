#!/bin/sh

cd ~
#git clone https://github.com/mxcl/homebrew.git


#tap thoughtbot/formulae
#install rcm



brew install tree
brew install tmux
brew install jq

brew install nvn 
brew install npm 

brew install bash-completion

#Cask

# Specify your defaults in this environment variable
export HOMEBREW_CASK_OPTS="--appdir=~/Applications --caskroom=~/Caskroom"

brew install caskroom/cask/brew-cask

brew cask install dropbox
brew cask install 1password


