#!/bin/bash

set -e

source ../../lib/util.sh

version="0.3.0"
root_dir=$(pwd)
pkg_name="openage"
source_dir="${root_dir}/${pkg_name}-src"
build_dir="${root_dir}/${pkg_name}-build"
bin_dir="${root_dir}/${pkg_name}"

InstallBuildDependencies() {
    install_deps cmake libfreetype6-dev python3-dev libepoxy-dev libsdl2-dev \
        libsdl2-image-dev libopusfile-dev libfontconfig1-dev libharfbuzz-dev \
        opus-tools python3-pil python3-numpy python3-pygments python3-pip \
        qtdeclarative5-dev qml-module-qtquick-controls cython3
}

GetSources() {
    repo_url="https://github.com/SFTtech/openage"
    clone $repo_url $source_dir
}

BuildProject() {
    cd $source_dir
    ./configure --mode=release --compiler=gcc
    make
}

PackageProject() {
    rm -rf $bin_dir
    mkdir $bin_dir

    cd $root_dir
    tar czf ${pkg_name}-${version}.tar.gz ${pkg_name}

}

if [ $1 ]; then
    $1
else
    InstallBuildDependencies
    GetSources
    BuildProject
    #PackageProject
fi
