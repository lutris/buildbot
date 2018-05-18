#!/bin/bash

set -e
lib_path="../../lib/"
source ${lib_path}path.sh
source ${lib_path}util.sh
source ${lib_path}upload_handler.sh

runner_name=$(get_runner)
version="1.0.13"
arch=$(uname -m)

root_dir=$(pwd)
source_dir=$(pwd)/${runner_name}-src
bin_dir=$(pwd)/${runner_name}

InstallDependencies() {
    echo "TODO"
    # install_deps
}


GetSources() {
    clone https://github.com/DavidGriffith/daphne.git $source_dir
}

Build() {
    cd $source_dir
    cd src/vldp2
    ./configure --disable-accel-detect
    make -f Makefile.linux_x64
    cd ..
    ln -s Makefile.vars.linux_x64 Makefile.vars
    make
}


Package() {
    mkdir -p $bin_dir
    cd $source_dir
    cp -a daphne.bin COPYING daphne-changelog.txt libvldp2.so doc pics roms README.md run.sh singe.sh sound theory $bin_dir
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
    # Upload
fi
