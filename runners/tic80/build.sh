#!/bin/bash

set -e
lib_path="../../lib/"
source ${lib_path}path.sh
source ${lib_path}util.sh

runner_name=$(get_runner)
version="1.1.2736"
arch=$(uname -m)

root_dir=$(pwd)
source_dir=$(pwd)/${runner_name}-src
bin_dir=$(pwd)/${runner_name}
publish_dir="/builds/runners/${runner_name}"

InstallBuildDependencies() {
	install_deps "libgtk-3-dev libsdl2-dev zlib1g-dev"
}

GetSources() {
    clone https://github.com/nesbox/TIC-80.git $source_dir true v${version}
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
    cp $dest_file $publish_dir
}

if [ $1 ]; then
    $1
else
    InstallBuildDependencies
    GetSources
    Build
    Package
fi
