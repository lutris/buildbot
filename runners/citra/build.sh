#!/bin/bash

set -e
lib_path="../../lib/"
source ${lib_path}path.sh
source ${lib_path}util.sh

runner_name=$(get_runner)
version="$(date "+%Y%m%d")"
arch=$(uname -m)
root_dir=$(pwd)
source_dir=$(pwd)/${runner_name}-src
build_dir=$(pwd)/${runner_name}-build
bin_dir=$(pwd)/${runner_name}
publish_dir="/builds/runners/${runner_name}"

InstallDependencies() {
    install_deps libsdl2-dev libfdk-aac-dev qtbase5-dev libqt5opengl5-dev gcc g++ \
        qt5-default libqt5opengl5-dev xorg-dev lib32stdc++6 libc++-dev clang qtmultimedia5-dev
}

GetSources() {
    clone https://github.com/citra-emu/citra ${source_dir} recurse
}

Build() {
    cd "${source_dir}"
    mkdir -p $build_dir
    cd $build_dir
    cmake \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_CXX_COMPILER=clang++ \
        -DCMAKE_C_COMPILER=clang \
        -DCMAKE_CXX_FLAGS="-O2 -g" $source_dir
    make -j$(nproc)
}


Package() {
    mkdir -p $bin_dir
    cp bin/* ${bin_dir}
    cd ${root_dir}
    dest_file="${runner_name}-${version}-${arch}.tar.gz"
    tar czf ${dest_file} ${runner_name}
    cp $dest_file $publish_dir
}

if [ $1 ]; then
    $1
else
    InstallDependencies
    GetSources
    Build
    Package
fi
