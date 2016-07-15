#!/bin/bash

set -e

source ../../lib/util.sh

version="0.58.1"
arch="$(uname -m)"
root_dir=$(pwd)
pkg_name="d2x-rebirth"
source_dir="${root_dir}/${pkg_name}-src"
bin_dir="${root_dir}/${pkg_name}"

GetSources() {
    wget http://www.dxx-rebirth.com/download/dxx/d2x-rebirth_v${version}-src.tar.gz
    tar xzf d2x-rebirth_v${version}-src.tar.gz
    rm d2x-rebirth_v${version}-src.tar.gz
    rm -rf $source_dir
    mv d2x-rebirth_v${version}-src $source_dir
}

InstallBuildDependencies() {
    install_deps scons libphysfs-dev libsdl-mixer1.2-dev
}

BuildProject() {
    cd $source_dir
    scons
}

PackageProject() {
    cd $root_dir
    rm -rf $bin_dir
    mkdir $bin_dir
    cp $source_dir/d2x-rebirth $bin_dir
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
