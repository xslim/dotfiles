
#!/bin/bash
# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)

# If not running interactively, don't do anything
case $- in
	*i*) ;;
	*) return;;
esac


export LANG=en_US.UTF-8
export LANGUAGE=en_US.UTF-8
export LC_ALL=en_US.UTF-8



# Faster, but make break stuff
#export MAKEFLAGS='-j 3'

complete -d cd mkdir rmdir

#  export GREP_OPTIONS='--color=auto'
# awesome history tracking
export HISTSIZE=100000
export HISTFILESIZE=100000
export HISTCONTROL=ignoredups
export HISTTIMEFORMAT="%Y-%m-%d %H:%M:%S  "
export PROMPT_COMMAND='history -a'
shopt -s histappend
PROMPT_COMMAND='history -a; echo "$$ $USER $(history 1)" >> ~/.bash_eternal_history'

# notify of bg job completion immediately
set -o notify

# use Vi mode instead of Emacs mode
#set -o vi

# no mail notifications
shopt -u mailwarn
unset MAILCHECK

# check for window resizing whenever the prompt is displayed
shopt -s checkwinsize

_has_cmd () { command -v "$1" >/dev/null 2>&1 ; }
_is_macos () { [ "$(uname -s)" == 'Darwin' ] ; }
_is_linux () { [ "$(uname -s)" == 'Linux' ] ; }

_has_cmd vim && export EDITOR='vim' || _has_cmd vi && export EDITOR='vi'

function _git_bits {
  _has_cmd git || return
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

function __git_ps1_bits {
  local out=`_git_bits -b`
  [ -n "$out" ] && echo "($out)" || echo
}

PS1="\[\033[01;34m\]\W";
#PS1="\[\033]0;\W\007\]"; # working directory base name
PS1+='\[\e[1;33m\] $(__git_ps1_bits " (%s)")\[\e[0m\]';
PS1+="\[\033[00m\]\$ "
export PS1;

# PATH
_has_cmd gem && PATH="$(ruby -r rubygems -e 'puts Gem.user_dir')/bin:$PATH"
[ -d /opt/homebrew ] && PATH=/opt/homebrew/bin:${HOME}/homebrew/sbin:$PATH
[ -d ${HOME}/homebrew ] && PATH=${HOME}/homebrew/bin:${HOME}/homebrew/sbin:$PATH
[ -d ${HOME}/Library/Python/2.7 ] && PATH=${HOME}/Library/Python/2.7/bin:$PATH
[ -d ${HOME}/bin_local ] && PATH=${HOME}/bin_local:$PATH
[ -d ${HOME}/.local/bin ] && PATH=${HOME}/.local/bin:$PATH
export PATH="${HOME}/bin:${PATH}"

# [ -d /usr/local/adyen/lib ] && export DYLD_FALLBACK_LIBRARY_PATH=/usr/local/adyen/lib:$DYLD_FALLBACK_LIBRARY_PATH



if _has_cmd brew ; then
  BREW_PREFIX="$(brew --prefix)"
  export HOMEBREW_CASK_OPTS="--appdir=~/Applications"
  [ -f ${BREW_PREFIX}/etc/bash_completion ] && source ${BREW_PREFIX}/etc/bash_completion
  [ -d ${BREW_PREFIX}/opt/android-sdk ] && export ANDROID_HOME=${BREW_PREFIX}/opt/android-sdk
  [ -d ${BREW_PREFIX}/opt/go/ ] && export PATH=$PATH:${BREW_PREFIX}/opt/go/libexec/bin
fi

# set JAVA_HOME if on Mac OS
if [ -z "$JAVA_HOME" -a -d /System/Library/Frameworks/JavaVM.framework/Home ]; then
  export JAVA_HOME=/System/Library/Frameworks/JavaVM.framework/Home
fi

_has_cmd rbenv && eval "$(rbenv init -)"
[ -d ${HOME}/.nvm ] && export NVM_DIR=${HOME}/.nvm
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"

[ -f ~/bin/z.sh ] && source ~/bin/z.sh


# for file in ~/.{bash_prompt,aliases,functions,path,dockerfunc,extra,exports}; do
for file in ~/.{bash_colors,aliases,dockerfunc}; do
	if [[ -r "$file" ]] && [[ -f "$file" ]]; then
		# shellcheck source=/dev/null
		source "$file"
	fi
done
unset file