#!/bin/bash

set -e
lib_path="../../lib/"

source ${lib_path}path.sh
source ${lib_path}util.sh
source ${lib_path}upload_handler.sh

root_dir=$(pwd)
version=1.7
arch=$(uname -m)
source_dir=${root_dir}/wolf4sdl-src

clone https://github.com/ljbade/wolf4sdl.git $source_dir
cd $source_dir

DATADIR= make

tar czf ../wolf4sdl-${version}-${arch}.tar.gz wolf3d
cd ..
rm -rf $source_dir
