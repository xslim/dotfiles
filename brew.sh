#!/bin/sh

cd ~
#git clone https://github.com/mxcl/homebrew.git


#tap thoughtbot/formulae
#install rcm

apps=( tree tmux jq npm bash-completion rbenv ruby-build )

for i in ${apps[@]}; do
  brew install ${i}
done


#Cask

# Specify your defaults in this environment variable
export HOMEBREW_CASK_OPTS="--appdir=~/Applications --caskroom=~/Caskroom"

brew install caskroom/cask/brew-cask

# 1password
apps=( dropbox transmission ) 

for i in ${apps[@]}; do
  brew cask install ${i}
done


