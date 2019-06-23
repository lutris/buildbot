#!/bin/bash

set -e
lib_path="../../lib/"

source ${lib_path}path.sh
source ${lib_path}util.sh
source ${lib_path}upload_handler.sh

runner_name=$(get_runner)
root_dir=$(pwd)
source_dir="${root_dir}/${runner_name}-src"
build_dir="${root_dir}/${runner_name}-build"
bin_dir="${root_dir}/${runner_name}"
arch=$(uname -m)
version="2.2.1"

git clone https://git.tuxfamily.org/hatari/hatari.git/ $source_dir

mkdir -p $build_dir
cd $build_dir

cmake -DCMAKE_INSTALL_PREFIX=${bin_dir} ${source_dir}
make -j 8
make install

cd ..
dest_file="${runner_name}-${version}-${arch}.tar.gz"
tar czf ${dest_file} ${runner_name}
runner_upload ${runner_name} ${version} ${arch} ${dest_file}
