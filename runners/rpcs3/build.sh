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
dest_file="${runner_name}-${version}-${arch}.tar.gz"

# Change to the base path of your Qt installation
QT_BASE_DIR=/opt/Qt/5.10.1/gcc_64

InstallDependencies() {
    install_deps cmake build-essential libasound2-dev libpulse-dev libopenal-dev libglew-dev \
        zlib1g-dev libedit-dev libvulkan-dev libudev-dev git qt5-default
}


GetSources() {
    clone https://github.com/RPCS3/rpcs3.git ${source_dir} recurse
}

Build() {
    export QTDIR=$QT_BASE_DIR
    export PATH=$QT_BASE_DIR/bin:$PATH
    export LD_LIBRARY_PATH=$QT_BASE_DIR/lib:$LD_LIBRARY_PATH
    export PKG_CONFIG_PATH=$QT_BASE_DIR/lib/pkgconfig:$PKG_CONFIG_PATH

    cd $root_dir
    mkdir -p $build_dir
    cd $build_dir
    cmake $source_dir
    make GitVersion
    make -j$(getconf _NPROCESSORS_ONLN)
}


Package() {
    cd ${root_dir}
    mkdir -p $bin_dir
    cp -a $build_dir/bin/* $bin_dir
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
