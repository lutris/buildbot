#!/bin/bash

set -e
lib_path="../../lib/"
source ${lib_path}path.sh
source ${lib_path}util.sh
source ${lib_path}upload_handler.sh

runner_name=$(get_runner)
root_dir=$(pwd)
version="4.2.0"
archive="atari800-${version}-src.tgz"
arch=$(uname -m)

wget https://github.com/atari800/atari800/releases/download/ATARI800_4_2_0/atari800-4.2.0-src.tgz
build_dir=$(pwd)/${runner_name}
tar xzf ${archive}
cd atari800-${version}
./configure --prefix=${build_dir}
make
make install 
cd ..
dest_file="${runner_name}-${version}-${arch}.tar.gz"
tar czf ${dest_file} ${runner_name}
runner_upload ${runner_name} ${version} ${arch} ${dest_file}
