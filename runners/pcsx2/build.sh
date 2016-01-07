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
version="1.4.0"

deps="wx3.0-headers:i386 libaio-dev:i386"
install_deps $deps

clone https://github.com/PCSX2/pcsx2.git $source_dir
cd $source_dir

mkdir -p $build_dir
cd $build_dir
cmake ${source_dir}
make -j$(getconf _NPROCESSORS_ONLN)

cd ..
mkdir -p ${bin_dir}
#
#dest_file="${runner_name}-${version}-${arch}.tar.gz"
#tar czf ${dest_file} ${runner_name}
#rm -rf ${build_dir} ${source_dir} ${bin_dir}
#
#runner_upload ${runner_name} ${version} ${arch} ${dest_file}
