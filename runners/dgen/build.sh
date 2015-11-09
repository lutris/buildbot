#!/bin/bash

set -e
lib_path="../../lib/"
source ${lib_path}path.sh
source ${lib_path}util.sh
source ${lib_path}upload_handler.sh

runner_name=$(get_runner)
root_dir=$(pwd)
source_dir="${root_dir}/${runner_name}"
build_dir=${root_dir}/${runner_name}
version="1.33"
arch=$(uname -m)
repo_url="git://git.code.sf.net/p/dgen/dgen"

clone ${repo_url} ${source_dir}

cd ${source_dir}
./configure --prefix=${build_dir}
make
make install

cd ..

dest_file="${runner_name}-${version}-${arch}.tar.gz"
tar czf ${dest_file} ${runner_name}
runner_upload ${runner_name} ${version} ${arch} ${dest_file}
