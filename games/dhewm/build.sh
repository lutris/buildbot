#!/bin/bash

set -e

source ../../lib/util.sh

version="master"
arch="$(uname -m)"
root_dir=$(pwd)
pkg_name="dhewm"
source_dir="${root_dir}/${pkg_name}-src"
build_dir="${root_dir}/${pkg_name}-build"
bin_dir="${root_dir}/${pkg_name}"

GetSources() {
    clone https://github.com/dhewm/dhewm3.git $source_dir
}

InstallBuildDependencies() {
    install_deps libvorbis-dev libjpeg8-dev zlib1g-dev libogg-dev libopenal-dev libcurl4-gnutls-dev libsdl2-dev
}

Build() {
    cd $root_dir
    mkdir -p $build_dir
    cd $build_dir
    cmake $source_dir/neo
    make
}

Package() {
    mkdir -p $bin_dir
    cd $build_dir
    mv base.so d3xp.so dhewm3 $bin_dir
    cd $root_dir
    tar czf ${pkg_name}-${version}-${arch}.tar.gz ${pkg_name}
}

Clean() {
    rm -rf $source_dir
    rm -rf $build_dir
    rm -rf $bin_dir
}

if [ $1 ]; then
    $1
else
    InstallBuildDependencies
    GetSources
    Build
    Package
    Clean
fi
