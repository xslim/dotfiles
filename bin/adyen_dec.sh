#!/bin/sh

BIN="${HOME}/src/Adyen/server_bin"
DIST="${HOME}/src/Adyen/server_dist"

#java -jar ${BIN}/decodeLogLive.jar ${1} 2>/dev/null
java -jar ${BIN}/decodeLogLive.jar ${1} 2>/dev/null | xmllint --format -
