#!/bin/bash

set -e

source ../../lib/util.sh

version="$(date +"%Y%m%d")"
arch="$(uname -m)"
root_dir=$(pwd)
pkg_name="mechcommander-2"
source_dir="${root_dir}/${pkg_name}-src"
build_dir="${root_dir}/${pkg_name}-build"
bin_dir="${root_dir}/${pkg_name}"


InstallBuildDependencies() {
    install_deps libsdl2-dev
}

GetSources() {
    cd $root_dir
    clone  https://github.com/alariq/mc2.git $source_dir
}

Build() {
    cd $source_dir
    mkdir -p build
    cd build
    cmake ..
    make -j4
}

Package() {
    cd $root_dir
    rm -rf $bin_dir
    mkdir $bin_dir

    # tar czf ${pkg_name}-${version}-${arch}.tar.gz ${pkg_name}
}

Clean() {
    cd $root_dir
    rm -rf $build_dir
    rm -rf $bin_dir
    rm -rf $source_dir
}

if [ $1 ]; then
    $1
else
    InstallBuildDependencies
    GetSources
    Build
    # Package
    # Clean
fi
