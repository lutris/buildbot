#!/bin/bash

set -e

source ../../lib/util.sh

version="1.0"
arch="$(uname -m)"
root_dir=$(pwd)
pkg_name="zandronum"
source_dir="${root_dir}/${pkg_name}-src"
build_dir="${root_dir}/${pkg_name}-build"
bin_dir="${root_dir}/${pkg_name}"

GetSources() {
    cd $root_dir
    hg clone https://bitbucket.org/Torr_Samaho/zandronum-stable $source_dir
}

InstallBuildDependencies() {
    cd $root_dir
    install_deps mercurial cmake mesa-common-dev libgl1-mesa-dev libsdl2-dev
    wget https://zdoom.org/files/fmod/fmodapi375linux.tar.gz
    tar xzf fmodapi375linux.tar.gz
}

Build() {
    mkdir -p $build_dir
    cd $build_dir
    cmake -DCMAKE_BUILD_TYPE=Release $source_dir
    make -j$(nproc)
}

Package() {
    cd $root_dir
    mkdir -p $bin_dir
    # TODO
    tar czf ${pkg_name}${opts}-${version}-${arch}.tar.gz ${pkg_name}
}

CleanUp() {
    rm -rf $source_dir
    rm -rf $bin_dir
    rm -rf $root_dir/steamworks
}

if [ $1 ]; then
    $1
else
    InstallBuildDependencies
    GetSources
    Build
    Package
    CleanUp
fi
