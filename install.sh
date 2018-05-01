#!/bin/sh

set -e

FILES=("bin" \
  ".bashrc" ".bash_profile" ".bash_colors" \
  ".tmux.conf" \
  ".gitconfig" ".gitignore" \
  ".vimrc" ".vim" \
  ".mutt")

DOT_ROOT=$(pwd -P)
DOT_OLD=${HOME}/dotfiles_old

dryrun=true

while [ $# -ge 1 ]; do
  case "$1" in
    #-d) dryrun=true ;;
    -f) dryrun=false; rm -rf ${DOT_OLD} ;;
  esac
  shift
done

$dryrun && echo "Performing Dry run !"

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
  [ -d ${DOT_OLD} ] && ! $dryrun && echo "Stopping! ${DOT_OLD} exists !" && exit
  echo "Installing from ${DOT_ROOT}"
  #do_rm ${DOT_OLD}
  $dryrun || mkdir -p ${DOT_OLD}
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

  $move && do_mv $dst ${DOT_OLD}/
  $skip && echo "Skipping $src" || do_ln $src $dst
}

prepare


for i in "${FILES[@]}"; do
  link_file "${DOT_ROOT}/${i}" "${HOME}/${i}"
done

$dryrun || source ~/.bashrc

