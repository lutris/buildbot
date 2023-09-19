#!/bin/bash

set -e
lib_path="../../lib/"
source ${lib_path}path.sh
source ${lib_path}util.sh
source ${lib_path}upload_handler.sh

runner_name=$(get_runner)
version="0.7.111"
arch=$(uname -m)

root_dir=$(pwd)
source_dir=$(pwd)/${runner_name}-src
build_dir=$(pwd)/${runner_name}-build
bin_dir=$(pwd)/${runner_name}

deps="libsdl2-dev libslirp-dev libglu1-mesa-dev libepoxy-dev libpixman-1-dev libgtk-3-dev libssl-dev libsamplerate0-dev libpcap-dev ninja-build python3-yaml"
install_deps $deps


DownloadGit() {
    git clone --recurse-submodules https://github.com/mborgerson/xemu ${source_dir}
}

BuildProject() {
    cd "${source_dir}"
    ./build.sh
}

PackageProject() {
    mkdir -p $source_dir
    mv dist $bin_dir
    cd ${root_dir}
    dest_file="${runner_name}-${version}-${arch}.tar.gz"
    tar czf ${dest_file} ${runner_name}
    runner_upload ${runner_name} ${version} ${arch} ${dest_file}
}

DownloadGit
BuildProject
PackageProject
