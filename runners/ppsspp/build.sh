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
version="1.11"

deps="cmake libsdl2-dev"
install_deps $deps

clone https://github.com/hrydgard/ppsspp.git $source_dir
cd $source_dir
git submodule update --init --recursive

mkdir -p $build_dir
cd $build_dir
cmake ${source_dir}
make -j$(getconf _NPROCESSORS_ONLN)

cd ..
mkdir -p ${bin_dir}
cp -a ${build_dir}/assets ${bin_dir}
cp ${build_dir}/PPSSPPSDL ${bin_dir}

dest_file="${runner_name}-${version}-${arch}.tar.gz"
tar czf ${dest_file} ${runner_name}
rm -rf ${build_dir} ${source_dir} ${bin_dir}

runner_upload ${runner_name} ${version} ${arch} ${dest_file}
