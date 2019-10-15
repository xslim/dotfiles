#!/usr/bin/env bash

set +o noclobber

CWD="$(cd -P -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"

download() {
  # name="${2:-$(basename $1)}"
  # curl -fSL -R "$1" > "$name";
  curl -L -R -J -O "$1"
}

apps=( \
"https://github.com/rupa/z/raw/master/z.sh" \ # Jump
# "https://raw.githubusercontent.com/stephencelis/ghi/master/ghi" \ # GH issues
  )

pushd "$CWD/bin"

for url in "${apps[@]}"; do
  echo "Updating from $url"
  download $url
done


popd
