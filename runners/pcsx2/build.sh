#!/bin/bash

set -e

lib_path="./lib/"
source ${lib_path}path.sh
source ${lib_path}util.sh
source ${lib_path}upload_handler.sh

runner_name="pcsx2"
root_dir=$(pwd)
source_dir="${root_dir}/${runner_name}-src"
build_dir="${root_dir}/${runner_name}-build"
bin_dir="${root_dir}/${runner_name}"
log_file="${root_dir}/${runner_name}.log"
artifact_dir="${root_dir}/artifacts/"
arch=$(uname -m)
version="1.6.0"

GetSources() {
    clone https://github.com/PCSX2/pcsx2.git $source_dir true v1.6.0
}

Build() {
    cd $root_dir
    mkdir -p $build_dir
    cd $build_dir
    cmake \
        -DCMAKE_BUILD_TYPE=Release \
        -DENABLE_TESTS=0 \
        ${source_dir} 2>&1 | tee -a $log_file
    make -j$(getconf _NPROCESSORS_ONLN)
    make install
}

Package() {
    cd $root_dir
    mkdir -p $bin_dir
    mv ${source_dir}/bin/* ${bin_dir}
    dest_file="${runner_name}-${version}-${arch}.tar.gz"
    tar czf ${dest_file} ${runner_name}
    mkdir -p $artifact_dir
    cp $dest_file $artifact_dir
}

GetSources
Build
Package
