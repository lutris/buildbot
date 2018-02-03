#!/bin/bash

set -e
lib_path="../../lib/"
source ${lib_path}path.sh
source ${lib_path}util.sh
source ${lib_path}upload_handler.sh

runner_name=$(get_runner)
version="0.9.14"
arch=$(uname -m)

root_dir=$(pwd)
source_dir=$(pwd)/${runner_name}-src
build_dir=$(pwd)/${runner_name}-build
bin_dir=$(pwd)/${runner_name}

deps="freeglut3 freeglut3-dev libgtkglext1-dev libmini18n-dev libmini18n1 libpangox-1.0-dev qtmultimedia5-dev"
install_deps $deps


DownloadStable() {
    wget https://download.tuxfamily.org/yabause/releases/${version}/yabause-${version}.tar.gz
    tar xvzf yabause-${version}.tar.gz
    rm yabause-${version}.tar.gz
    mv yabause-${version} ${source_dir}
}

DownloadGit() {
    clone https://github.com/Yabause/yabause.git ${source_dir}
    cd "${source_dir}"
}

BuildProject() {
    mkdir -p $build_dir
    cd $build_dir
    cmake ${source_dir}/yabause -DCMAKE_BUILD_TYPE=Release
    make -j$(getconf _NPROCESSORS_ONLN)
}

PackageProject() {
    mkdir -p $bin_dir
    
    # TODO

    cd ${root_dir}
    dest_file="${runner_name}-${version}-${arch}.tar.gz"
    tar czf ${dest_file} ${runner_name}
    runner_upload ${runner_name} ${version} ${arch} ${dest_file}
}

DownloadGit
BuildProject
