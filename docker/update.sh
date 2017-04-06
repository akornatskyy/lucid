#!/bin/bash
set -eo pipefail


cd "$(dirname "$(readlink -f "$BASH_SOURCE")")"

for version in dev ; do
  cd $version
  modules=( */ )
  for module in "${modules[@]%/}" ; do
    for os in alpine ; do
      image=akorn/lucid:${version}-${module}-${os}
      echo building $image ...
      docker build -q -t ${image} ${module}/${os}
      echo lucid version: `docker run --rm ${image} luarocks show --mversion lucid`
    done
  done
done