#!/bin/bash

set -e
lib_path="../../lib/"

source ${lib_path}path.sh
source ${lib_path}util.sh
source ${lib_path}upload_handler.sh

root_dir=$(pwd)
package_name=zdoom
version=2.8.1
arch=$(uname -m)
source_dir=${root_dir}/${package_name}-src
build_dir=${root_dir}/${package_name}-build

clone https://github.com/rheit/zdoom.git ${source_dir}
cd $source_dir
git checkout $version

mkdir -p $build_dir
cd $build_dir
cmake $source_dir
make -j$(getconf _NPROCESSORS_ONLN)

mv zdoom zdoom.pk3 ${root_dir}
cd ${root_dir}

tar czf ${package_name}-${version}-${arch}.tar.gz zdoom zdoom.pk3
rm -rf zdoom zdoom.pk3 $source_dir $build_dir
