#!/bin/bash

set -e
lib_path="../../lib/"
source ${lib_path}path.sh
source ${lib_path}util.sh
source ${lib_path}upload_handler.sh

runner_name=$(get_runner)
version="0.9.11"
archive="${runner_name}-${version}.tar.gz"
arch=$(uname -m)
wget https://sourceforge.net/projects/desmume/files/latest/download -O ${archive}

root_dir=$(pwd)
build_dir=$(pwd)/${runner_name}-src
bin_dir=$(pwd)/${runner_name}


tar xzf ${archive}
cd ${runner_name}-${version}
./configure --prefix=${bin_dir}
make
make install

cd ${root_dir}

dest_file="${runner_name}-${version}-${arch}.tar.gz"
tar czf ${dest_file} ${runner_name}
runner_upload ${runner_name} ${version} ${arch} ${dest_file}
