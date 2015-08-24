#!/bin/sh

BIN="${HOME}/src/Adyen/server_bin"
DIST="${HOME}/src/Adyen/server_dist"

HEX=`java -jar ${BIN}/decodeLogLive.jar -hex ${1} 2>/dev/null`

java -cp ${BIN}/adyen.jar:/usr/local/tomcat/lib/shared/*:/usr/local/tomcat/lib/*:${DIST}/* com.adyen.protocol.iso8583.fifththird.FifthThirdMessage ${HEX}
