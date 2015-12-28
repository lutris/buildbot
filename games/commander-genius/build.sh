#!/bin/bash

set -e
lib_path="../../lib/"

source ${lib_path}path.sh
source ${lib_path}util.sh
source ${lib_path}upload_handler.sh

root_dir=$(pwd)
version=1.9
arch=$(uname -m)
source_dir=${root_dir}/commander-genius-src

deps="libsdl2-image-dev libboost-all-dev"
install_deps $deps

clone https://github.com/gerstrong/Commander-Genius.git $source_dir

cd $source_dir
cmake -DUSE_SDL2=yes
make -j$(getconf _NPROCESSORS_ONLN)

