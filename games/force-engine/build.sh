#!/bin/bash

set -e
lib_path="../../lib/"

source ${lib_path}path.sh
source ${lib_path}util.sh
source ${lib_path}upload_handler.sh

root_dir=$(pwd)
version=0.7.1
arch=$(uname -m)
package_name="TheForceEngine"

source_dir=${root_dir}/${package_name}-src
build_dir=${root_dir}/${package_name}-build
bin_dir=${root_dir}/${package_name}

Deps() {
    deps="libsdl2-dev libdevil-dev librtaudio-dev librtmidi-dev libglew-dev cmake build-essential"
    install_deps $deps

}

Fetch() {
    clone https://github.com/luciusDXL/TheForceEngine.git $source_dir
}


Build() {
    mkdir -p $build_dir
    cd $build_dir
    cmake -S $source_dir -DCMAKE_INSTALL_PREFIX="${bin_dir}"
    make
    make install
}


if [ $1 ]; then
    $1
else
    Deps
    Fetch
    Build
fi
