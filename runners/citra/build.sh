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
    install_deps libsdl2-dev qtbase5-dev libqt5opengl5-dev gcc-6 g++-6 \
        qt5-default libqt5opengl5-dev xorg-dev lib32stdc++6 libc++-dev clang
}


GetSources() {
    clone https://github.com/citra-emu/citra ${source_dir} recurse
}

Build() {
    cd "${source_dir}"
    mkdir -p $build_dir
    cd $build_dir
    cmake $source_dir \
        -DCMAKE_BUILD_TYPE=Release
        -DCMAKE_CXX_COMPILER=clang++-3.8 \
        -DCMAKE_C_COMPILER=clang-3.8 \
        -DCMAKE_CXX_FLAGS="-O2 -g -stdlib=libc++" \
    make -j$(getconf _NPROCESSORS_ONLN)
}


Package() {
    mkdir -p $bin_dir
    mv src/citra/citra ${bin_dir}
    mv src/citra_qt/citra-qt ${bin_dir}
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
