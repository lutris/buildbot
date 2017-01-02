#!/bin/bash

set -e

source ../../lib/util.sh

version="0.96.4"
arch="$(uname -m)"
root_dir=$(pwd)
pkg_name="dunelegacy"
source_dir="${root_dir}/${pkg_name}-${version}"
bin_dir="${root_dir}/${pkg_name}"

GetSources() {
    archive="${pkg_name}-${version}-src.tar.bz2"
    wget https://pilotfiber.dl.sourceforge.net/project/dunelegacy/dunelegacy/${version}/${archive}
    tar xjf $archive
}

InstallBuildDependencies() {
    echo "TODO: Find dependencies"
    # install_deps 
}

Build() {
    cd $source_dir
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
    # InstallBuildDependencies
    GetSources
    Build
    Package
    CleanUp
fi
