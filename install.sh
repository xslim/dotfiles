#!/bin/sh

set -e

DOT_ROOT=$(pwd -P)
DOT_OLD=${HOME}/dotfiles_old

dryrun=false

while [ $# -ge 1 ]; do
  case "$1" in
    -d) dryrun=true ;;
  esac
  shift
done

$dryrun && echo "Performing Dry run !"

do_mv () {
  $dryrun && echo "mv $1\t\t-> $2" && return
  mv $1 $2
}

do_ln () {
  $dryrun && echo "ln $1\t\t-> $2" && return
  ln -s $1 $2
}

do_rm () {
  $dryrun && echo "rm $1" && return
  rm -rf $1
}


prepare () {
  [ -d ${DOT_OLD} ] && ! $dryrun && echo "Stopping! ${DOT_OLD} exists !" && exit
  echo "Installing from ${DOT_ROOT}"
  #do_rm ${DOT_OLD}
  ! $dryrun && mkdir -p ${DOT_OLD}
}

link_file () {
  local src=$1 dst=$2

  if [ -f "$dst" -o -d "$dst" -o -L "$dst" ]; then
    [ "$(readlink $dst)" != "$src" ] && do_mv $dst ${DOT_OLD}/ || echo "Skipping $dst" 
  fi

  do_ln $src $dst
}

prepare

FILES=("bashrc" "bash_profile" "tmux.conf" "gitconfig" "vimrc" "vim")

link_file "${DOT_ROOT}/bin" "${HOME}/bin"

for i in "${FILES[@]}"; do
  link_file "${DOT_ROOT}/${i}" "${HOME}/.${i}"
done

$dryrun || source ~/.bashrc

