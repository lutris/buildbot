#!/bin/bash

set -e
lib_path="../../lib/"
source ${lib_path}path.sh
source ${lib_path}util.sh
source ${lib_path}upload_handler.sh

runner_name=$(get_runner)
version="0.7.71"
arch=$(uname -m)

root_dir=$(pwd)
source_dir=$(pwd)/${runner_name}-src
build_dir=$(pwd)/${runner_name}-build
bin_dir=$(pwd)/${runner_name}

deps="git build-essential libsdl2-dev libepoxy-dev libpixman-1-dev libgtk-3-dev libssl-dev libsamplerate0-dev libpcap-dev ninja-build python3-yaml"
install_deps $deps


DownloadGit() {
    git clone --recurse-submodules https://github.com/mborgerson/xemu ${source_dir}
}

BuildProject() {
    cd "${source_dir}"
    ./build.sh
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
