#!/bin/bash

set -e
lib_path="../../lib/"
source ${lib_path}path.sh
source ${lib_path}util.sh
source ${lib_path}upload_handler.sh

runner_name=$(get_runner)
version="$(date "+%Y%m%d")"
arch=$(uname -m)

root_dir=$(pwd)
source_dir=$(pwd)/${runner_name}-src
build_dir=$(pwd)/${runner_name}-build
bin_dir=$(pwd)/${runner_name}

InstallDependencies() {
    install_deps cmake build-essential libasound2-dev libopenal-dev libwxgtk3.0-dev libglew-dev \
        zlib1g-dev libedit-dev libvulkan-dev libudev-dev git
}


GetSources() {
    clone https://github.com/RPCS3/rpcs3.git ${source_dir} recurse
}

Build() {
    cd $source_dir
    cmake CMakeLists.txt 
    make GitVersion
    make -j$(getconf _NPROCESSORS_ONLN)
}


Package() {
    mkdir -p $bin_dir
    cd ${root_dir}
    dest_file="${runner_name}-${version}-${arch}.tar.gz"
    tar czf ${dest_file} ${runner_name}
}

Upload() {
    runner_upload ${runner_name} ${version} ${arch} ${dest_file}
}


if [ $1 ]; then
    $1
else
    InstallDependencies
    GetSources
    Build
    Package
    Upload
fi
