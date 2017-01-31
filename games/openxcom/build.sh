#!/bin/bash

set -e

source ../../lib/util.sh

version="0.96.4"
arch="$(uname -m)"
root_dir=$(pwd)
pkg_name="openxcom"

source_dir="${root_dir}/${pkg_name}-src"
build_dir="${root_dir}/${pkg_name}-build"
bin_dir="${root_dir}/${pkg_name}"

GetSources() {
	clone https://github.com/SupSuper/OpenXcom.git $source_dir
}

InstallBuildDependencies() {
    install_deps libglade2-dev libsdl-gfx1.2-dev libyaml-cpp-dev
}

Build() {
    mkdir -p $build_dir
    cmake -DCMAKE_INSTALL_PREFIX="${bin_dir}" $source_dir
    make -j$(getconf _NPROCESSORS_ONLN)
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
    GetSources
    Build
    Package
    # CleanUp
fi
