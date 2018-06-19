#!/bin/bash

set -e
lib_path="../../lib/"
source ${lib_path}path.sh
source ${lib_path}util.sh
source ${lib_path}upload_handler.sh

runner_name=$(get_runner)
version="0.60.3"
arch=$(uname -m)

root_dir=$(pwd)
source_dir=$(pwd)/${runner_name}-src
bin_dir=$(pwd)/${runner_name}

InstallBuildDependencies() {
	deps="libgtk-3-dev libsdl2-dev zlib1g-dev"
	install_deps $deps
}

GetSources() {
	# TODO: Update to 0.60.4 once it's out. See https://github.com/nesbox/TIC-80/issues/577
    # clone https://github.com/nesbox/TIC-80.git $source_dir true v${version}
    clone https://github.com/nesbox/TIC-80.git $source_dir true a783eae76b050bc78f72eb2fc984bd8a60d51774
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
