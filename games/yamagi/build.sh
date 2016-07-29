#!/bin/bash

set -e
lib_path="../../lib/"

source ${lib_path}path.sh
source ${lib_path}util.sh
source ${lib_path}upload_handler.sh

root_dir=$(pwd)
package_name=yamagi
version=5.34
tag=QUAKE2_5_34
arch=$(uname -m)
game=yquake2

params=$(getopt -n $0 -o rx --long rogue,xatrix -- "$@")
eval set -- $params
while true ; do
    case "$1" in
        -r|--rogue) game=rogue; shift ;;
        -x|--xatrix) game=xatrix; shift ;;
        *) shift; break ;;
    esac
done

source_dir=${root_dir}/${package_name}-${game}-src
clone https://github.com/yquake2/${game}.git ${source_dir} "" ${tag}

cd $source_dir
make -j$(getconf _NPROCESSORS_ONLN)
cp -a release ../${game}
cd ..

tar czf ${package_name}-${game}-${version}-${arch}.tar.gz ${game}
