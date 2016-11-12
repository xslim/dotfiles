
# Settings

# Helper functions
has_cmd () {
  command -v "$1" >/dev/null 2>&1 ;
}


export LANG=en_US.UTF-8
export LC_CTYPE=en_US.UTF-8
export CLICOLOR=1
export EDITOR='vim'

export PATH="${HOME}/bin:/usr/local/bin:/usr/local/sbin:${PATH}"

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
  has_cmd git || return 
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
if has_cmd brew ; then
  BREW_PREFIX=`brew --prefix`
  export HOMEBREW_CASK_OPTS="--appdir=~/Applications --caskroom=~/Caskroom"

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
#has_cmd lesspipe && eval "$(lesspipe)"


# enable rvm if available
if [[ -s "$HOME/.rvm/scripts/rvm" ]]; then
  source "$HOME/.rvm/scripts/rvm"
  PATH=$PATH:$HOME/.rvm/bin # Add RVM to PATH for scripting
  [[ -n "$rvm_path" ]] && [[ -r "$rvm_path/scripts/completion" ]] && source "$rvm_path/scripts/completion"
  export rvm_pretty_print_flag=1
fi
has_cmd rbenv && eval "$(rbenv init -)"

[ -f ~/bin/z.sh ] && source ~/bin/z.sh

# Base16 Default - Console color setup script

color00="15/15/15" # Base 00 - Black
color01="ac/41/42" # Base 08 - Red
color02="90/a9/59" # Base 0B - Green
color03="f4/bf/75" # Base 0A - Yellow
color04="6a/9f/b5" # Base 0D - Blue
color05="aa/75/9f" # Base 0E - Magenta
color06="75/b5/aa" # Base 0C - Cyan
color07="d0/d0/d0" # Base 05 - White
color08="50/50/50" # Base 03 - Bright Black
color09=$color01 # Base 08 - Bright Red
color10=$color02 # Base 0B - Bright Green
color11=$color03 # Base 0A - Bright Yellow
color12=$color04 # Base 0D - Bright Blue
color13=$color05 # Base 0E - Bright Magenta
color14=$color06 # Base 0C - Bright Cyan
color15="f5/f5/f5" # Base 07 - Bright White
color16="d2/84/45" # Base 09
color17="8f/55/36" # Base 0F
color18="20/20/20" # Base 01
color19="30/30/30" # Base 02
color20="b0/b0/b0" # Base 04
color21="e0/e0/e0" # Base 06

if [ -n "$TMUX" ]; then
  # tell tmux to pass the escape sequences through
  # (Source: http://permalink.gmane.org/gmane.comp.terminal-emulators.tmux.user/1324)
  printf_template="\033Ptmux;\033\033]4;%d;rgb:%s\007\033\\"
elif [ "${TERM%%-*}" = "screen" ]; then
  # GNU screen (screen, screen-256color, screen-256color-bce)
  printf_template="\033P\033]4;%d;rgb:%s\007\033\\"
else
  printf_template="\033]4;%d;rgb:%s\033\\"
fi

# 16 color space
printf $printf_template 0  $color00
printf $printf_template 1  $color01
printf $printf_template 2  $color02
printf $printf_template 3  $color03
printf $printf_template 4  $color04
printf $printf_template 5  $color05
printf $printf_template 6  $color06
printf $printf_template 7  $color07
printf $printf_template 8  $color08
printf $printf_template 9  $color09
printf $printf_template 10 $color10
printf $printf_template 11 $color11
printf $printf_template 12 $color12
printf $printf_template 13 $color13
printf $printf_template 14 $color14
printf $printf_template 15 $color15

# 256 color space
if [ "$TERM" != linux ]; then
  printf $printf_template 16 $color16
  printf $printf_template 17 $color17
  printf $printf_template 18 $color18
  printf $printf_template 19 $color19
  printf $printf_template 20 $color20
  printf $printf_template 21 $color21
fi

# clean up
unset printf_template
unset color00
unset color01
unset color02
unset color03
unset color04
unset color05
unset color06
unset color07
unset color08
unset color09
unset color10
unset color11
unset color12
unset color13
unset color14
unset color15
unset color16
unset color17
unset color18
unset color19
unset color20
unset color21





[ -d ${HOME}/.nvm ] && export NVM_DIR=${HOME}/.nvm
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"

#export GOPATH=${HOME}/src/gocode

# Aliases

# add a poor facsimile for Linux's `free` if we're on Mac OS
if ! type free > /dev/null 2>&1 && [[ "$(uname -s)" == 'Darwin' ]]; then
  alias free="top -s 0 -l 1 -pid 0 -stats pid | grep '^PhysMem: ' | cut -d : -f 2- | tr ',' '\n'"
fi

#  alias ls="ls --color=auto --classify --block-size=\'1"
if [[ "$OSTYPE" == "linux-gnu" ]]; then
   alias ls='ls --color=auto'
#elif [ $platform == 'freebsd' ] || [ $platform == 'mac' ] ; then
#   alias ls='ls -G'
fi

# alias Debian's `ack-grep` to `ack`
if type -t ack-grep > /dev/null
then
  alias ack=ack-grep
fi

alias timestamp='date +"%s"'
alias datestamp='date +"%F %T"'
alias ll='ls -lah'
alias tm='tmux attach || tmux new'
alias mkdir="mkdir -p"

alias localip="ipconfig getifaddr en0"

# macOS has no `md5sum`, so use `md5` as a fallback
command -v md5sum > /dev/null || alias md5sum="md5"

# macOS has no `sha1sum`, so use `shasum` as a fallback
command -v sha1sum > /dev/null || alias sha1sum="shasum"

# load local shell configuration if present
if [[ -f ~/.bashrc.local ]]; then
   source ~/.bashrc.local
fi


