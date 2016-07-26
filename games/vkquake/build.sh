#!/bin/bash

set -e
lib_path="../../lib/"

source ${lib_path}path.sh
source ${lib_path}util.sh
source ${lib_path}upload_handler.sh

root_dir=$(pwd)
package_name=vkquake
version=0.1.0
arch=$(uname -m)
source_dir=${root_dir}/${package_name}-src
bin_dir=${root_dir}/${package_name}

clone https://github.com/Novum/vkQuake $source_dir
cd $source_dir/Quake
make

mkdir -p $bin_dir
mv quakespasm quakespasm.pak $bin_dir

cd $root_dir
tar czf ${package_name}-${version}-${arch}.tar.gz $package_name
rm -rf $source_dir $bin_dir
