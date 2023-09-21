#!/bin/bash

set -e
lib_path="../../lib/"

source ${lib_path}path.sh
source ${lib_path}util.sh

runner_name=$(get_runner)
root_dir=$(pwd)
source_dir="${root_dir}/${runner_name}-src"
build_dir="${root_dir}/${runner_name}-build"
bin_dir="${root_dir}/${runner_name}"
publish_dir="/builds/runners/${runner_name}"
arch=$(uname -m)
version="2.5.0-dev"

git clone https://git.tuxfamily.org/hatari/hatari.git/ $source_dir

mkdir -p $build_dir
cd $build_dir

cmake -DCMAKE_INSTALL_PREFIX=${bin_dir} ${source_dir}
make -j 8
make install

cd ..
dest_file="${runner_name}-${version}-${arch}.tar.gz"
tar czf ${dest_file} ${runner_name}
cp $dest_file $publish_dir
