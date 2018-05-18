#!/bin/bash

set -e
lib_path="../../lib/"

source ${lib_path}path.sh
source ${lib_path}util.sh
source ${lib_path}upload_handler.sh

root_dir=$(pwd)
version=2.2.2
tag=v2.2.2
arch=$(uname -m)
source_dir=${root_dir}/commander-genius-src

deps="libsdl2-image-dev libboost-all-dev libsdl2-mixer-dev cmake"
install_deps $deps

clone https://github.com/gerstrong/Commander-Genius.git $source_dir true $tag

cd $source_dir
cmake -DUSE_SDL2=yes
make -j$(getconf _NPROCESSORS_ONLN)

cp src/CGeniusExe ..
cd ..

tar czf commander-genius-${version}-${arch}.tar.gz CGeniusExe
rm CGeniusExe
rm -rf $source_dir
