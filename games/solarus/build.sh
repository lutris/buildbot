#!/bin/bash

set -e
lib_path="../../lib/"

source ${lib_path}path.sh
source ${lib_path}util.sh
source ${lib_path}upload_handler.sh

root_dir=$(pwd)
package='solarus'
version=1.5.0
arch=$(uname -m)
source_dir=${root_dir}/${package}-src
build_dir=${root_dir}/${package}-build
zsdx_src_dir=${root_dir}/zsdx-src
zsdx_dir=${root_dir}/zsdx

InstallDeps() {
    deps="build-essential cmake libsdl2-dev libsdl2-image-dev \
        libsdl2-ttf-dev libluajit-5.1-dev libphysfs-dev libopenal-dev libvorbis-dev \
        libmodplug-dev qtbase5-dev qttools5-dev qttools5-dev-tools"
    install_deps $deps
}

BuildSolarus() {
    cd ${root_dir}
    clone https://github.com/christopho/solarus.git $source_dir
    mkdir -p ${build_dir}
    cd ${build_dir}
    cmake ${source_dir}
    make
}

BuildZsdx(){ 
    cd ${root_dir}
    clone https://github.com/christopho/zsdx.git ${zsdx_src_dir}
    cd ${zsdx_src_dir}
    cmake .
    make
}

PackageZsdx() {
    cd ${root_dir}
    mkdir ${zsdx_dir}
    cd ${zsdx_dir}
    mv ${zsdx_src_dir}/data ${zsdx_dir}
    mv ${build_dir}/libsolarus.so ${zsdx_dir}
    mv ${build_dir}/solarus_run ${zsdx_dir}
}

InstallDeps
BuildSolarus
BuildZsdx
PackageZsdx
