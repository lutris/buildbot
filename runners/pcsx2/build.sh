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
log_file="${root_dir}/${runner_name}.log"
arch=$(uname -m)
version="1.4.0"

deps="wx3.0-headers libaio-dev libasound2-dev libbz2-dev libgl1-mesa-dev \
    libglu1-mesa-dev libgtk2.0-dev libpng12-dev libpng++-dev libpulse-dev libsdl2-dev \
    libsoundtouch-dev libwxbase3.0-dev libwxgtk3.0-dev libx11-dev portaudio19-dev zlib1g-dev"
install_deps $deps

clone https://github.com/PCSX2/pcsx2.git $source_dir
cd $source_dir

mkdir -p $build_dir
cd $build_dir
cmake \
    -DCMAKE_BUILD_TYPE=Release \
    ${source_dir} 2>&1 | tee -a $log_file
make -j$(getconf _NPROCESSORS_ONLN)
make install

rm -rf ${bin_dir}
mv ${source_dir}/bin ${bin_dir}

dest_file="${runner_name}-${version}-${arch}.tar.gz"
tar czf ${dest_file} ${runner_name}
rm -rf ${build_dir} ${source_dir} ${bin_dir}

runner_upload ${runner_name} ${version} ${arch} ${dest_file}
