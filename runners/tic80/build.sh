#!/bin/bash

set -e
lib_path="../../lib/"
source ${lib_path}path.sh
source ${lib_path}util.sh
source ${lib_path}upload_handler.sh

runner_name=$(get_runner)
version="0.90.1723"
arch=$(uname -m)

root_dir=$(pwd)
source_dir=$(pwd)/${runner_name}-src
bin_dir=$(pwd)/${runner_name}

InstallBuildDependencies() {
	deps="libgtk-3-dev libsdl2-dev zlib1g-dev"
	install_deps $deps
}

GetSources() {
    clone https://github.com/nesbox/TIC-80.git $source_dir true v${version)
}

Build() {
    cd $source_dir
    make linux
}

Package() {
    mkdir -p $bin_dir
    cd $source_dir
    cp -a bin/tic80 LICENSE $bin_dir
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
    InstallBuildDependencies
    GetSources
    Build
    Package
    # Upload
fi
