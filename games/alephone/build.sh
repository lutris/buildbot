#!/bin/bash

set -e

source ../../lib/util.sh

version="20150620"
arch="$(uname -m)"
root_dir=$(pwd)
pkg_name="alephone"
source_dir="${root_dir}/${pkg_name}-src"
bin_dir="${root_dir}/${pkg_name}"

GetStableSources() {
    archive="AlephOne-${version}.tar.bz2"
    wget https://github.com/Aleph-One-Marathon/alephone/releases/download/release-${version}/${archive}
    tar xjf $archive
    rm -rf $source_dir
    mv AlephOne-${version} $source_dir
}

GetGitSources() {
    cd $root_dir
    clone https://github.com/Aleph-One-Marathon/alephone.git $source_dir
    cd $source_dir
    version=$(git log -1 --format=%ci | awk '{print $1}' | tr -d -)
    cd $root_dir
}

InstallBuildDependencies() {
    sudo apt install libsdl2-net-dev
}

Build() {
    cd $source_dir
    if [ -f autogen.sh ]; then
        ./autogen.sh
    fi
    ./configure --prefix=$bin_dir
    make
    make install
}

Package() {
    cd $root_dir
    tar czf ${pkg_name}-${version}-${arch}.tar.gz ${pkg_name}
}

CleanUp() {
    rm -rf $source_dir
    rm -rf $bin_dir
}

if [ $1 ]; then
    $1
else
    InstallBuildDependencies
    GetGitSources
    Build
    Package
    CleanUp
fi
