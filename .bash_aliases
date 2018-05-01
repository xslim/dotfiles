# vi: ft=sh

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

# macOS has no `md5sum`, so use `md5` as a fallback
_has_cmd md5 && alias md5sum="md5"

# macOS has no `sha1sum`, so use `shasum` as a fallback
_has_cmd shasum && alias sha1sum="shasum"

# alias Debian's `ack-grep` to `ack`
_has_cmd ack-grep && alias ack=ack-grep


alias timestamp='date +"%s"'
alias datestamp='date +"%F %T"'
alias ll='ls -lAh'
alias tm='tmux attach || tmux new'
alias mkdir="mkdir -p"

alias myip="ifconfig | sed -En 's/127.0.0.1//;s/.*inet (addr:)?(([0-9]*\.){3}[0-9]*).*/\2/p'"

alias mypubkey="gpg2 --export-ssh-key $(gpg --card-status | sed '/^Authentication/!d;s/ //g;s/.*:[A-Z0-9]*\([A-Z0-9]\{16\}\)$/\1/')"

_a_ssht () { ssh $@ -t 'tmux has-session && exec tmux attach -d || exec tmux' -t 0 ; }
alias ssht=_a_ssht
