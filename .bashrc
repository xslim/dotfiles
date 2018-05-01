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

if [ -d "${HOME}/.gnupg" ]; then
  export GPG_TTY=$(tty)
  export SSH_AUTH_SOCK="${HOME}/.gnupg/S.gpg-agent.ssh"
fi


_has_cmd () { command -v "$1" >/dev/null 2>&1 ; }
_is_macos () { [ "$(uname -s)" == 'Darwin' ] ; }
_is_linux () { [ "$(uname -s)" == 'Linux' ] ; }

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
PS1+="\[\033[00m\]\$ "
export PS1;

# PATH
[ -d ${HOME}/homebrew ] && export PATH=${HOME}/homebrew/bin:${HOME}/homebrew/sbin:$PATH
export PATH="${HOME}/bin_local:${HOME}/bin:${PATH}"

if _has_cmd brew ; then
  BREW_PREFIX=`brew --prefix`

  export VIM_APP_DIR="${HOME}/Applications"
  export HOMEBREW_CASK_OPTS="--appdir=~/Applications --caskroom=~/Caskroom"

  [ -f ${BREW_PREFIX}/etc/bash_completion ] && source ${BREW_PREFIX}/etc/bash_completion
  [ -d ${BREW_PREFIX}/opt/android-sdk ] && export ANDROID_HOME=${BREW_PREFIX}/opt/android-sdk
  [ -d ${BREW_PREFIX}/opt/go/ ] && export PATH=$PATH:${BREW_PREFIX}/opt/go/libexec/bin
fi

_has_cmd rbenv && eval "$(rbenv init -)"
[ -d ${HOME}/.nvm ] && export NVM_DIR=${HOME}/.nvm
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"

[ -f ~/bin/z.sh ] && source ~/bin/z.sh
[ -f ~/.bash_colors ] && source ~/.bash_colors
[ -f ~/.bashrc.local ] && source ~/.bashrc.local

# Aliases

_is_linux && alias ls='ls --color=auto'

# macOS has no stuff
if _is_macos; then
  _has_cmd md5 && alias md5sum="md5"
  _has_cmd shasum && alias sha1sum="shasum"
  _has_cmd ack-grep && alias ack=ack-grep

  alias free="top -s 0 -l 1 -pid 0 -stats pid | grep '^PhysMem: ' | cut -d : -f 2- | tr ',' '\n'"
fi

alias timestamp='date +"%s"'
alias datestamp='date +"%F %T"'
alias ll='ls -lAh'
alias tm='tmux attach || tmux new'
alias mkdir="mkdir -p"

alias myip="ifconfig | sed -En 's/127.0.0.1//;s/.*inet (addr:)?(([0-9]*\.){3}[0-9]*).*/\2/p'"

alias mypubkey="gpg2 --export-ssh-key $(gpg --card-status | sed '/^Authentication/!d;s/ //g;s/.*:[A-Z0-9]*\([A-Z0-9]\{16\}\)$/\1/')"

_a_ssht () { ssh $@ -t 'tmux has-session && exec tmux attach -d || exec tmux' -t 0 ; }
alias ssht=_a_ssht
