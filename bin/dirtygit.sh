#!/usr/bin/env bash


function _git_bits {
# _has_cmd git || return
  git status --ignore-submodules --porcelain $1 2> /dev/null | (
      unset branch dirty deleted untracked newfile copied renamed
      while read line ; do
          case "${line//[[:space:]]/}" in
            '##'*)         branch=`expr "$line" : '## \(.[^\.]*\)'` ; ;;
            'M'*)          dirty='!' ; ;;
            'UU'*)         dirty='!' ; ;;
            'D'*)          deleted='x' ; ;;
            '??'*)         untracked='?' ; ;;
            'A'*)          newfile='+' ; ;;
            'C'*)          copied='*' ; ;;
            'R'*)          renamed='>' ; ;;
          esac
      done
      local out=""
      bits="$dirty$deleted$untracked$newfile$copied$renamed"
      [ -n "$branch" ] && out+=$branch
      [ -n "$branch" ] && [ -n "$bits" ] && out+=" "
      [ -n "$bits" ] && out+=$bits
      [ -n "$out" ] && echo $out
  )
}

# alias git_bits=_git_bits

function _git_ps1_bits {
  local out=`_git_bits -b`
  [ -n "$out" ] && echo "($out)" || echo
}

function echo_if_dirty_git {
  local out=`_git_bits`
  [ -n "$out" ] && echo "`basename ${PWD}` - $out"
}

export -f _git_bits
export -f echo_if_dirty_git

find . -type d -name '.git' -maxdepth 5 -execdir bash -c 'echo_if_dirty_git "$0"' {} \; 2>/dev/null
