#!/bin/bash

set -e

source ../../lib/util.sh

version="master"
arch="$(uname -m)"
root_dir=$(pwd)
pkg_name="gemrb"
source_dir="${root_dir}/${pkg_name}-src"
build_dir="${root_dir}/${pkg_name}-build"
bin_dir="${root_dir}/${pkg_name}"

InstallBuildDependencies() {
    # install_deps libvorbis-dev libjpeg8-dev zlib1g-dev libogg-dev libopenal-dev libcurl4-gnutls-dev libsdl2-dev
    echo "Figure out dependencies"
}

GetSources() {
    echo "Cloning ${pkg_name}"
    clone https://github.com/gemrb/gemrb $source_dir
}

Build() {
    echo "Building ${pkg_name}"
    cd $source_dir
    ./autogen.sh
    ./configure
    make 
}

Package() {
    echo "Packaging ${pkg_name}"
    cd $root_dir
    tar czf ${pkg_name}-${version}-${arch}.tar.gz ${pkg_name}
}

Clean() {
    echo "Cleaning up"
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
    # Clean
fi
