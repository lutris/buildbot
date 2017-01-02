#!/bin/bash

set -e

source ../../lib/util.sh

version="1.13.6"
arch="$(uname -m)"
root_dir=$(pwd)
source_dir="${root_dir}/wesnoth-src"
build_dir="${root_dir}/wesnoth-build"
bin_dir="${root_dir}/wesnoth"

InstallBuildDependencies() {
    sudo apt-get build-dep wesnoth
    install_deps libboost-locale-dev libsdl2-mixer-dev
}

GetSources() {
    cd $root_dir
    dest="wesnoth-${version}.tar.bz2"
    if [ ! -f "$dest" ]; then
        wget https://sourceforge.net/projects/wesnoth/files/wesnoth/wesnoth-${version}/${dest}/download -O $dest
    fi
    tar xvjf $dest
    rm -rf $source_dir
    mv wesnoth-${version} ${source_dir}
}

Build() {
    cd $root_dir
    mkdir -p $build_dir
    cd $build_dir
    cmake $source_dir
    make
}

Package() {
    cd $build_dir
    mkdir -p $bin_dir
    cp wesnoth wesnothd $bin_dir
    cd $source_dir
    cp -a sounds $bin_dir
    cp -a misc $bin_dir
    cp -a data $bin_dir
    cp -a icons $bin_dir
    cp -a images $bin_dir
    cp -a fonts $bin_dir
    cd $root_dir
    tar czf wesnoth-${version}-${arch}.tar.gz wesnoth
}

Clean() {
    cd $root_dir
    rm -rf $source_dir
    rm -rf $build_dir
    rm -rf $bin_dir
}

if [ $1 ]; then
    $1
else
    InstallBuildDependencies
    GetSources $version
    Build
    Package
    Clean
fi
