#!/usr/bin/env bash

# set -e
set -o pipefail

shopt -s expand_aliases

PREFIX="${PASSWORD_STORE_DIR:-$HOME/.password-store}"
GPG="gpg -q --no-tty --batch --use-agent --yes"

_has_cmd () { command -v "$1" >/dev/null 2>&1 ; }
_is_macos () { [ "$(uname -s)" == 'Darwin' ] ; }
_is_linux () { [ "$(uname -s)" == 'Linux' ] ; }

_has_cmd sha1sum || alias sha1sum="shasum"
_has_cmd pbcopy || alias pbcopy='xclip -selection clipboard'

trim() {
    local var="$*"
    # remove leading whitespace characters
    var="${var#"${var%%[![:space:]]*}"}"
    # remove trailing whitespace characters
    var="${var%"${var##*[![:space:]]}"}"
    echo -n "$var"
}

_check_pwnedpasswords() {
  local pass pass_hash short_hash suffix_hash times
  pass="$1"
  pass_hash=$(echo -n $pass | sha1sum | cut -d' ' -f1 | tr '[:lower:]' '[:upper:]')
  short_hash=$(echo "$pass_hash" | cut -c-5)
	suffix_hash=$(echo "$pass_hash" | cut -c6-)
  times=$(curl -sL "https://api.pwnedpasswords.com/range/$short_hash" | grep $suffix_hash | cut -d':' -f2)
  [[ -n "$times" ]] && echo $times || echo "0"
}

_tree() {
  local path=$1; shift
  local query="$@"
  # [ ! -z $query ] && query="-P \"${query}*|*\" --prune --matchdirs --ignore-case"

  tree -C -l --noreport "$path" | tail -n +2 | sed -E 's/\.gpg(\x1B\[[0-9]+m)?( ->|$)/\1\2/g' # remove .gpg at end of line, but keep colors
  # [ ! -z $query ]  && $res=$(echo "$res" | grep -i "$query")
  # echo $res

  # local terms="*$(printf '%s*|*' "$@")"
	# tree -C -l --noreport -P "${terms%|*}" --prune --matchdirs --ignore-case "$PREFIX"

  # find "$1" -path "**.gpg" | cut -c $(expr ${#1} + 2)- | rev | cut -d '.' -f 2- | rev | xargs -n1 -I{} -P 4 echo "* {}" | sort
}

 _shuf() {
   # shuf --random-source=/dev/urandom -i 0-9 -r -n 6
   # shuf /usr/share/dict/words --repeat --random-source /dev/random -n 5
   # for i in *pruned*; do echo "$i:";shuf -n4 "$i"| awk NF=NF RS= OFS=' ';echo "-----";done

   # jot produces a random number from 1 to the number of lines in FILE for each line
   # paste pastes the random number to each line in FILE
   # sort sorts numeric each line
   # cut removes the random number from each line
   # head outputs the first 10 lines
   local file=$1
   jot -r "$(wc -l $file)" 1 | paste - $file | sort -n | cut -f 2- | head -n 10
 }

random_word() {
  local max_len="10"
  local fname=/usr/share/dict/words
  local mungle

  while getopts 'f:n:m:' c; do
    case $c in
      n) n="$OPTARG" ;;
      f) fname="$OPTARG" ;;
      m) mungle="$OPTARG" ;;
    esac
  done

  local total=$( sed -E -n "/^.{1,$max_len}$/p" $fname | wc -l | awk '{ print $1 }')
  local ndx=$RANDOM
  [[ "$total" -lt "$ndx" ]] && ndx=$(( $ndx % $total ))
  local word=$(sed -E -n "/^.{1,$max_len}$/p" $fname \
    | sed -n "${ndx}p" \
    | tr A-Z a-z \
    | sed -e "s/'//g" -e 's/"//g' -e 's/-//g' \
    | cut -f2 \
    )
  [[ "$mungle" -eq "3" ]] && word=$(echo "$word" | tr 'iletoas' '11370@$')

  echo "$word"
}

cmd_gen() {
  local type=${1:-short}; shift
  local n=12

  case $type in
    "word") random_word $* ;;
    "dice")
      # https://xkcd.com/936/
      local num="4"
      local words=""
      local sep="-"
      for i in $(seq $num); do
        word=$(random_word $*)
        [[ $i -eq 1 ]] && words="$word" || words="${words}${sep}$word"
      done
      echo $words
      ;;
    *)
      head -c $n /dev/random | base64 | tr -d '\n='
      # openssl rand -base64 300 | tr -dc 'a-zA-Z0-9.-' | cut -c -$n
      # openssl rand -base64 300 | tr -d '\n' | cut -c -$size
      ;;
  esac
}

cmd_audit() {
  local pass=$(cmd_show $1 -w)
  local times=$(_check_pwnedpasswords "$pass")
  local len=${#pass}

  if [ "$len" -lt 10 ] || [  -n "$times" ] ; then
    echo "${1}: len: $len, pwn: $times"
  fi
}

clip() {
  echo -n "$1" | pbcopy
}

cmd_find() {
  _tree "$PREFIX" $1
}

cmd_show() {
  local pass clip show_pass_only label_or_line
  local path="$1"; shift
  local passfile="$PREFIX/$path.gpg"

  while getopts 'wcl:' c; do
    case $c in
      w) show_pass_only=true ;;
      c) clip=true ;;
      l) label_or_line="$OPTARG" ;;
    esac
  done

  if [[ -f $passfile ]]; then
    pass="$($GPG -d "$passfile")" || exit $?

    [ "$clip" = true ] && [ -z $label_or_line ] && show_pass_only=true

    if [ "$show_pass_only" = true ]; then
      pass="$(echo "$pass" | head -n 1)"
    elif [[ $label_or_line =~ ^[0-9]+$ ]]; then
      pass="$(echo "$pass" | tail -n +${label_or_line} | head -n 1)"
    elif [ ! -z "$label_or_line" ]; then
      pass="$(echo "$pass" | grep -i ${label_or_line} | head -n 1 | cut -d':' -f2-)"
      pass=$(trim $pass)
    fi

    [ "$clip" = true ] && clip "$pass" || echo "$pass"

  elif [[ -d $PREFIX/$path ]]; then
		[[ -z $path ]] && echo "Password Store" || echo "${path%\/}"
    _tree "$PREFIX/$path"
  fi
}

"cmd_${@}"
