# vi: ft=sh

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
