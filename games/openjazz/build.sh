#!/bin/bash

set -e

source ../../lib/util.sh

version="master"
arch="$(uname -m)"
root_dir=$(pwd)
pkg_name="openjazz"
source_dir="${root_dir}/${pkg_name}-src"
bin_dir="${root_dir}/${pkg_name}"

GetSources() {
    clone https://github.com/AlisterT/openjazz.git $source_dir
}

InstallBuildDependencies() {
    install_deps autoconf libmodplug-dev
}

BuildProject() {
    cd $source_dir
    autoreconf -fi 
    ./configure --prefix=$bin_dir
    sed 's|modplug.h|libmodplug/&|' -i src/io/sound.cpp
    make
    make install
}

PackageProject() {
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
    # InstallBuildDependencies
    GetSources
    BuildProject
    PackageProject
    CleanUp
fi
