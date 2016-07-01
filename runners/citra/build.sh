#!/bin/bash

set -e
lib_path="../../lib/"
source ${lib_path}path.sh
source ${lib_path}util.sh
source ${lib_path}upload_handler.sh

runner_name=$(get_runner)
version="$(date "+%Y%m%d")"
archive="${runner_name}-${version}.tar.gz"
arch=$(uname -m)

root_dir=$(pwd)
source_dir=$(pwd)/${runner_name}-src
build_dir=$(pwd)/${runner_name}-build
bin_dir=$(pwd)/${runner_name}

deps="libsdl2-dev qtbase5-dev libqt5opengl5-dev"
install_deps $deps

clone https://github.com/citra-emu/citra ${source_dir} recurse

mkdir -p $build_dir
cmake $source_dir -DCMAKE_BUILD_TYPE=Release

make -j$(getconf _NPROCESSORS_ONLN)


mkdir -p $bin_dir
mv src/citra/citra ${bin_dir}
mv src/citra_qt/citra-qt ${bin_dir}

cd ${root_dir}

dest_file="${runner_name}-${version}-${arch}.tar.gz"
tar czf ${dest_file} ${runner_name}
runner_upload ${runner_name} ${version} ${arch} ${dest_file}
