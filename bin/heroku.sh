#!/usr/bin/env bash

PROJECT=${PWD##*/}

fetch() {
  curl -n -s -H "Accept: application/vnd.heroku+json; version=3" https://api.heroku.com/apps/${PROJECT}/$@
}

fetch_post() {
  fetch $@ -X POST -H "Content-Type:application/json"
}

fetch_jq() {
  fetch $1 | jq
}

config() {
  fetch "config-vars" | jq -r 'keys[] as $k | "\($k)=\(.[$k])"'
}

dynos() {
  fetch "dynos" | jq
}

log_sessions() {
  data="{}" # '{"source":"app","dyno":"web.1"}'

  if [ "$1" == "-tail" ]; then
    data='{"tail":true}'
  fi
  fetch_post "log-sessions" -d $data

}

log() {
  logplex_url=$(log_sessions $1 | jq -r '.logplex_url')
  echo $logplex_url
  curl $logplex_url
}

push() {
  git push heroku master
}

deploy() {
  git status
  git add --all
  msg=$(git diff --cached --name-status --no-color | tr  '\t' ' ' | tr -s '\n' ',')
  git commit -am "Auto-commit: ${msg}"

  push
  log -tail
}

"$@"
