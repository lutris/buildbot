#!/bin/bash

set -e
lib_path="../../lib/"

source ${lib_path}path.sh
source ${lib_path}util.sh
source ${lib_path}upload_handler.sh

root_dir=$(pwd)
package_name='serious-engine'
arch=$(uname -m)
source_dir=${root_dir}/${package_name}-src
bin_dir=${root_dir}/${package_name}

clone https://github.com/rcgordon/Serious-Engine.git $source_dir

cd $source_dir/Sources
./build-linux.sh

mkdir -p $bin_dir
mkdir -p $bin_dir/Debug

cd cmake-build
mv ecc ssam libShadersD.so $bin_dir
mv libEntitiesMPD.so $bin_dir/Debug/libEntitiesD.so
mv libGameMPD.so $bin_dir/Debug/libGameD.so

cd root_dir
tar cJf ${package_name}-${arch}.tar.bz2 ${package_name}
