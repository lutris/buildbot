#!/bin/bash

set -e
lib_path="../../lib/"
source ${lib_path}path.sh
source ${lib_path}util.sh
source ${lib_path}upload_handler.sh

runner_name=$(get_runner)
root_dir=$(pwd)
version="3.1.0"
archive="atari800-${version}.tar.gz"
arch=$(uname -m)
wget http://sourceforge.net/projects/atari800/files/atari800/3.1.0/${archive}/download -O ${archive}

build_dir=$(pwd)/${runner_name}

tar xzf ${archive}
cd atari800-${version}/src
./configure --prefix=${build_dir}
make
make install 

cd ../..

dest_file="${runner_name}-${version}-${arch}.tar.gz"
tar czf ${dest_file} ${runner_name}
runner_upload ${runner_name} ${version} ${arch} ${dest_file}
