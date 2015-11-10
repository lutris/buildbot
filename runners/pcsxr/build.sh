#!/bin/bash

set -e
lib_path="../../lib/"

source ${lib_path}path.sh
source ${lib_path}util.sh
source ${lib_path}upload_handler.sh

runner_name=$(get_runner)
root_dir="$(pwd)"
source_dir="${root_dir}/${runner_name}-src"
build_dir="${root_dir}/${runner_name}"
arch="$(uname -m)"
version="1.9.95"

# repo_url="https://pcsxr.svn.codeplex.com/svn/pcsxr"
# svn checkout $repo_url $source_dir
repo_url="https://github.com/lutris/pcsxr"
clone $repo_url

cd ${source_dir}
./autogen.sh
./configure --prefix=${build_dir}
make
make install

cd ..
dest_file=${runner_name}-${version}-${arch}.tar.gz
tar czf ${dest_file} ${runner_name}
runner_upload ${runner_name} ${version} ${arch} ${dest_file}
rm -rf ${build_dir} ${source_dir}
