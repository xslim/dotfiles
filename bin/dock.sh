#!/bin/bash


start() {
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

stop() {
  docker-machine stop
}

#peerflix
pflix() {
  docker-machine ip

  docker run -it --rm -p 8888:8888 --name peerflix cdrage/peerflix $1

}

run() {
  docker-machine ip
  
  PORT=${PORT:-8000}
  PORTS=${PORTS:-"${PORT}:${PORT}"}
  
  env_file_param=""
  if [ -f ".env" ]; then
    env_file_param="--env-file=.env"
  fi
  
  #set -x
  
  # -u "node" -m "300M" --memory-swap "1G" 
  
  docker run -it --rm --name ${PWD##*/} \
    ${env_file_param} -e "PORT=${PORT}" -p 3000:3000 -p ${PORTS} \
    -v "$PWD":/src -w /src $@
  
  #set +x
  
  # Just to be sure
  # docker rm ${PWD##*/}
}

build() {
  name=${PWD##*/}
  
  # if [[ "$(docker images -q ${name} 2> /dev/null)" == "" ]]; then
    docker build  -t ${name} .
    docker images
  # else
  #   echo "${name} found"
  # fi
}

tor() {
  ip=`docker-machine ip`
  proxy="socks5://${ip}:9050"

  echo "curl -s --proxy ${proxy} https://check.torproject.org | grep -m 1 Congratulations"
  echo "open -a \"Google Chrome\" --args --proxy-server=${proxy}"

  docker run --rm -p 9050:9050 --name tor osminogin/tor-simple
}

dev() {
  
  env_file_param=""
  if [ -f ".env" ]; then
    env_file_param="--env-file=.env"
  fi

  docker run -it --rm --name dev dev $@
}

gitbook() {
  docker run --rm -v "$PWD":/gitbook -p 4000:4000 billryan/gitbook gitbook $@
}

jekyll() {
  echo "http://`docker-machine ip`:4000"
  
  env_file_param=""
  if [ -f ".env" ]; then
    env_file_param="--env-file=.env"
  fi
  
  docker run -it --rm -v "${PWD}:/site" -p "4000:4000" -p "35729:35729" ${env_file_param} --name jekyll gh-pages $@
}

"$@"


# if [ "$1" ]; then
#   d_run "$@"
# elif [ -f "Dockerfile" ]; then
#   d_build
# else
#   d_start
# fi
