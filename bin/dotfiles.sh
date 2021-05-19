#!/bin/sh
set -e

# Config

DOTFILES_ROOT="$HOME/dotfiles" # $(pwd -P)
DOTFILES_OLD="$HOME/dotfiles_bak"

symlinks=("bin" \
  ".bashrc" ".bash_profile" ".bash_colors" ".aliases" \
  ".tmux.conf" ".curlrc" \
  ".gitconfig" ".gitignore" \
  ".vimrc" ".vim" \
  ".Brewfile" \
  ".mutt")

# Main code

# Link a file if it doesn't already exist
# SOURCE_DIR defaults to $HOME
# DESTINATION_DIR defaults to $DOTFILES_ROOT
# Usage: link_safe RELATIVE_PATH [SOURCE_DIR] [DESTINATION_DIR]
link_safe() {
  RELATIVE_PATH=$1
  SOURCE_DIR=${2:-$HOME}
  DESTINATION_DIR=${3:-$DOTFILES_ROOT}
  SOURCE_PATH="$SOURCE_DIR/$RELATIVE_PATH"
  DESTINATION_PATH="$DESTINATION_DIR/$RELATIVE_PATH"

  if [[ ! -f "$SOURCE_PATH" ]] || [[ $(ls -l "$SOURCE_PATH" | awk '{print $11}') != "$DESTINATION_PATH" ]]; then
    echo "Linking $SOURCE_PATH to $DESTINATION_PATH"
    rm -f "$SOURCE_PATH"
    ln -sf "$DESTINATION_PATH" "$SOURCE_PATH"
  fi
}

mkdir_safe() {
  if [[ ! -d "$HOME/$1" ]]; then
    echo "Creating $1 directory"
    mkdir -p "$HOME/$1"
  fi
}

_clone() {
  if [[ ! -d $DOTFILES_ROOT ]]; then
    git clone https://github.com/xslim/dotfiles $DOTFILES_ROOT
  fi
}



# dryrun=true
#
# while [ $# -ge 1 ]; do
#   case "$1" in
#     #-d) dryrun=true ;;
#     -f) dryrun=false; rm -rf ${DOTFILES_OLD} ;;
#   esac
#   shift
# done
#
# $dryrun && echo "Performing Dry run !"

do_mv () {
  echo "mv $1\t\t\t-> $2"
  $dryrun || mv $1 $2
}

do_ln () {
  echo "ln $1\t\t\t-> $2"
  $dryrun || ln -s $1 $2
}

do_rm () {
  echo "rm $1"
  $dryrun || rm -rf $1
}


prepare () {
  [ -d ${DOTFILES_OLD} ] && ! $dryrun && echo "Stopping! ${DOTFILES_OLD} exists !" && exit
  echo "Installing from ${DOTFILES_ROOT}"
  #do_rm ${DOTFILES_OLD}
  $dryrun || mkdir -p ${DOTFILES_OLD}
}

link_file () {
  local src=$1 dst=$2
  local move=false skip=false

  if [ -f "$dst" -o -d "$dst" -o -L "$dst" ]; then
    move=true
    # if [ "$(readlink $dst)" == "$src" ]; then
    #   skip=true
    #   move=false
    # fi
  fi

  $move && do_mv $dst ${DOTFILES_OLD}/
  $skip && echo "Skipping $src" || do_ln $src $dst
}

# prepare
# for i in "${FILES[@]}"; do
#   link_file "${DOTFILES_ROOT}/${i}" "${HOME}/${i}"
# done
# touch "$HOME/.hushlogin"
# $dryrun || source ~/.bashrc

_update_brewfile() {
  pushd $DOTFILES_ROOT
  brew bundle dump --global --description --force
  git add .Brewfile
  git commit -m 'Update Brewfile' && git push
  popd
}

_status() {
  echo "Checking status"

  if [ -d "$DOTFILES_ROOT" ]; then
    echo "Dir $DOTFILES_ROOT exist"

    pushd "$DOTFILES_ROOT"
    links=( $(find . -maxdepth 1 ! -path . ! -path ./README.md ! -path ./scripts | sort) )
    popd

    echo "Possible candidates:"
    for item in ${links[@]}; do
      echo "candidate: $item"
    done

  fi
}

# TODO - add support for -f and --force
link() {
  pushd "$DOTFILES_ROOT"
  for file in $( ls -A | grep -vE '\.exclude*|\.git$|\.gitignore|\.gitmodules|.*.md' ) ; do
    # Silently ignore errors here because the files may already exist
    ln -sfv "$PWD/$file" "$HOME" || true
  done
  popd
}

echo "Assuming DOTFILES_ROOT = $DOTFILES_ROOT"

action=${1}
case "$action" in
  install )
    echo "Installing"
    link
    ;;
  push )
    echo "pushing"
    ;;
  pull )
    ;;
  update )
    ;;
  update-brewfile )
    _update_brewfile
    ;;
  status )
    _status
    ;;
  * )
    echo "Usage: $0 status"
    ;;
esac
