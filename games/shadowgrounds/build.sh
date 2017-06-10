#!/bin/bash

set -e

source ../../lib/util.sh

version="$(date "+%Y%m%d")"
arch="$(uname -m)"
root_dir=$(pwd)
pkg_name="shadowgrounds"
source_dir="${root_dir}/${pkg_name}-src"
build_dir="${root_dir}/${pkg_name}-build"
bin_dir="${root_dir}/${pkg_name}"

GetSources() {
    clone https://github.com/vayerx/shadowgrounds $source_dir
}

InstallDependencies() {
    install_deps cmake libglew-dev libsdl-image1.2-dev libsdl-sound1.2-dev
}

Build() {
    cd $root_dir
    mkdir -p $build_dir
    cd $build_dir
    cmake $source_dir
    make
}

Package() {
    cd $root_dir
    rm -rf $bin_dir
    mkdir $bin_dir
    cp $build_dir/* $bin_dir
    tar czf ${pkg_name}-${version}-${arch}.tar.gz ${pkg_name}
}

Clean() {
    rm -rf $source_dir
    rm -rf $bin_dir
}

if [ $1 ]; then
    $1
else
    # InstallDependencies
    GetSources
    Build
    Package
    Clean
fi
