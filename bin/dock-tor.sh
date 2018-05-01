#!/bin/sh

ip=`docker-machine ip`
proxy="socks5://${ip}:9050"

echo "curl -s --proxy ${proxy} https://check.torproject.org | grep -m 1 Congratulations"
echo "open -a \"Google Chrome\" --args --proxy-server=${proxy}"

docker run --rm -p 9050:9050 --name tor osminogin/tor-simple
