#!/bin/bash

set -e
lib_path="../../lib/"

source ${lib_path}path.sh
source ${lib_path}util.sh
source ${lib_path}upload_handler.sh

runner_name=$(get_runner)
root_dir="$(pwd)"
source_dir="${root_dir}/${runner_name}-src"
build_dir="${root_dir}/${runner_name}-build"
bin_dir="${root_dir}/${runner_name}"
arch="$(uname -m)"
version="0.3.0git"

repo_url="https://github.com/residualvm/residualvm.git"
clone $repo_url $source_dir

cd $source_dir
./configure --prefix=${build_dir}
make
make install

cd ..
mkdir -p ${bin_dir}
mv ${build_dir}/bin/residualvm ${bin_dir}
mv ${build_dir}/share/residualvm ${bin_dir}/data

dest_file=${runner_name}-${version}-${arch}.tar.gz
tar czf ${dest_file} ${runner_name}
runner_upload ${runner_name} ${version} ${arch} ${dest_file}
rm -rf ${build_dir} ${source_dir} ${bin_dir}
