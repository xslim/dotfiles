
# Settings

# Helper functions
_has_cmd () { command -v "$1" >/dev/null 2>&1 ; }

export LANG=en_US.UTF-8
export LC_CTYPE=en_US.UTF-8
export CLICOLOR=1
export EDITOR='vim'


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

# set JAVA_HOME if on Mac OS
if [ -z "$JAVA_HOME" -a -d /System/Library/Frameworks/JavaVM.framework/Home ]; then
  export JAVA_HOME=/System/Library/Frameworks/JavaVM.framework/Home
fi


function __git_ps1_bits {
  _has_cmd git || return 
  git status --ignore-submodules --porcelain -b 2> /dev/null | (
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
      [ -n "$bits" ] && out+=" $bits"
      [ -n "$out" ] && echo "($out)" || echo
  )
}

PS1="\[\033[01;34m\]\W";
#PS1="\[\033]0;\W\007\]"; # working directory base name
PS1+='\[\e[1;33m\] $(__git_ps1_bits " (%s)")\[\e[0m\]';

# finish off the prompt
PS1+="\[\033[00m\]\$ "
export PS1;

# If Homebrew
if [ -d ${HOME}/homebrew ]; then
  export VIM_APP_DIR="${HOME}/Applications"
  export PATH=${HOME}/homebrew/bin:$PATH
  export PATH=${HOME}/homebrew/sbin:$PATH
  export HOMEBREW_CASK_OPTS="--appdir=~/Applications --caskroom=~/Caskroom"
fi


export PATH="${HOME}/bin_local:${HOME}/bin:${PATH}"

if _has_cmd brew ; then
  BREW_PREFIX=`brew --prefix`

  if [ -f ${BREW_PREFIX}/etc/bash_completion ]; then
    . ${BREW_PREFIX}/etc/bash_completion
  fi

  [ -d ${BREW_PREFIX}/opt/android-sdk ] && export ANDROID_HOME=${BREW_PREFIX}/opt/android-sdk
  [ -d ${BREW_PREFIX}/opt/go/ ] && export PATH=$PATH:${BREW_PREFIX}/opt/go/libexec/bin

  #  AUTOJUMP_SCRIPT="$(brew --prefix)/etc/autojump"
  #  if [ -e "$AUTOJUMP_SCRIPT" ]; then
  #    source "$AUTOJUMP_SCRIPT"
  #  fi
fi


# lesspipe lets us do cool things like view gzipped files
#_has_cmd lesspipe && eval "$(lesspipe)"


# enable rvm if available
if [[ -s "$HOME/.rvm/scripts/rvm" ]]; then
  source "$HOME/.rvm/scripts/rvm"
  PATH=$PATH:$HOME/.rvm/bin # Add RVM to PATH for scripting
  [[ -n "$rvm_path" ]] && [[ -r "$rvm_path/scripts/completion" ]] && source "$rvm_path/scripts/completion"
  export rvm_pretty_print_flag=1
fi
_has_cmd rbenv && eval "$(rbenv init -)"

[ -f ~/bin/z.sh ] && source ~/bin/z.sh
[ -f ~/.bash_aliases ] && source ~/.bash_aliases

[ -f ~/.bash_colors ] && source ~/.bash_colors

[ -d ${HOME}/.nvm ] && export NVM_DIR=${HOME}/.nvm
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"

#export GOPATH=${HOME}/src/gocode

if [ -d "${HOME}/.gnupg" ]; then
  export GPG_TTY=$(tty)
  export SSH_AUTH_SOCK="${HOME}/.gnupg/S.gpg-agent.ssh"
fi

# load local shell configuration if present
[ -f ~/.bashrc.local ] && source ~/.bashrc.local

