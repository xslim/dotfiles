#!/bin/bash

# set -x

function d_start() {
  docker-machine start

  docker-machine env default

  eval "$(docker-machine env default)"

  docker-machine ip default

  docker images -a 
  echo "Use docker rmi image"

  docker images --filter "dangling=true"
  echo "Remove dangling: docker rmi $(docker images -f \"dangling=true\" -q)"


  docker ps -a
  # echo "Use docker kill container && docker rm container"
  
  return 0
}

function d_run() {
  docker-machine ip
  
  PORT=${PORT:-8000}
  PORTS=${PORTS:-"${PORT}:${PORT}"}
  
  env_file_param=""
  if [ -f ".env" ]; then
    env_file_param="--env-file=.env"
  fi
  
  set -x
  
  docker run -it --rm --name ${PWD##*/} \
    ${env_file_param} -e "PORT=${PORT}" -p ${PORTS} \
    -v "$PWD":/src -w /src $@
  
  set +x
  
  # Just to be sure
  # docker rm ${PWD##*/}
  
  return 0
}

if [ "$1" ]; then
  d_run "$@"
else
  d_start
fi



