#!/usr/bin/env bash

start() {
  docker-machine start
  docker-machine env default
  eval "$(docker-machine env default)"
  docker-machine ip default

  docker system prune
}

create_vb() {
  docker-machine create --driver virtualbox default
}

stop() {
  docker-machine stop
}

ssh() {
  docker-machine ssh default
}

ip() {
  docker-machine ip default
}

screen() {
#  screen ~/Library/Containers/com.docker.docker/Data/vms/0/tty
  docker run -it --rm --privileged --pid=host justincormack/nsenter1
}

anaconda_jupyter() {
  echo "$(docker-machine ip default):8888"
  # docker run -it --rm -p 8888:8888 -v "$PWD":/opt/notebooks continuumio/anaconda3 /bin/bash -c "/opt/conda/bin/conda install jupyter -y --quiet && mkdir /opt/notebooks && /opt/conda/bin/jupyter notebook --notebook-dir=/opt/notebooks --ip='*' --port=8888 --no-browser --allow-root"
  docker run -it --rm -p 8888:8888 -v "$PWD":/opt/notebooks continuumio/anaconda3 /bin/bash -c "/opt/conda/bin/conda install jupyter -y --quiet && /opt/conda/bin/jupyter notebook --notebook-dir=/opt/notebooks --ip='*' --port=8888 --no-browser --allow-root"
}

pflix() {
  docker-machine ip
  docker run -it --rm -p 8888:8888 --name peerflix cdrage/peerflix $1
}

nettest() {
  docker run -it --rm --net=bridge praqma/network-multitool $@
}

runsh() {
  docker run -it --rm $@ sh
}

run() {
  PORT=${PORT:-8000}
  PORTS=${PORTS:-"${PORT}:${PORT}"}

  env_file_param=""
  if [ -f ".env" ]; then
    env_file_param="--env-file=.env"
  fi

  #set -x

  # -u "node" -m "300M" --memory-swap "1G"

  docker run -it --rm --pid=host --name ${PWD##*/} \
    ${env_file_param} -e "PORT=${PORT}" -p 3000:3000 -p 8080:8080 -p ${PORTS} \
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

  # docker run --rm -p 9050:9050 --name tor osminogin/tor-simple
  docker run --name='tor-privoxy' -d -p 9050:9050 -p 9051:9051 -p 8118:8118 dockage/tor-privoxy:latest
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

node() {
  docker run -it --rm --pid=host --name node \
    -v "$PWD":/usr/src/app -w /usr/src/app \
    -p "3000:3000" -p "8000:8000" -p "8080:8080" -p "8888:8888" \
    node:alpine $@
}

curl() {
  docker run -it --rm curlimages/curl --name curl $@
}

go() {
  name=${PWD##*/}
  pkg="github.com/xslim/${name}"
  workdir="/go/src/${pkg}"

  # image="golang"
  image="go-cobra"

  docker run -it --rm -v "$PWD":${workdir} -w ${workdir} ${image} $@
}

"$@"


# if [ "$1" ]; then
#   d_run "$@"
# elif [ -f "Dockerfile" ]; then
#   d_build
# else
#   d_start
# fi
