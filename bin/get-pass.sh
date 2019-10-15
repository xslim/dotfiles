#!/usr/bin/env bash

password=

getpass_pass() {
  local query="$1"
  [ ! -z "$2" ] && query="$1/$2"
  password=$(pass $query 2> /dev/null)
}

getpass_security() {
  vquery="-s $1"
  [ ! -z "$2" ] && query="${query} -a $2"
  [ ! -z "$3" ] && query="${query} -l $3"

  password=$(security find-internet-password -w $query 2> /dev/null)
  [ -z "$password" ] && password=$(security find-generic-password -w $query 2> /dev/null)
}

getpass_keepassxc() {
  local query="$1"
  [ ! -z "$2" ] && query="${query} -a $2"
  local db_file="~/Documents/KeePass.kdbx"
  keepassxc-cli show $db_file $query
}

[ -z "$password" ] && getpass_pass $@
[ -z "$password" ] && getpass_security $@
[ -z "$password" ] && getpass_keepassxc $@
[ -z "$password" ] && exit 1
echo -n $password
