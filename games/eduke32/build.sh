#!/bin/bash

set -e

source ../../lib/util.sh

version="7326"
arch=$(uname -m)
root_dir=$(pwd)
pkg_name="eduke32"
src_dir="${root_dir}/${pkg_name}-src"
bin_dir="${root_dir}/${pkg_name}"

InstallBuildDependencies() {
    install_deps git-svn build-essential nasm libgl1-mesa-dev libglu1-mesa-dev \
        libsdl1.2-dev libsdl-mixer1.2-dev libsdl2-dev libsdl2-mixer-dev flac \
        libflac-dev libvorbis-dev libvpx-dev libgtk2.0-dev freepats
}

GetSources() {
    cd $root_dir
    git svn clone -r HEAD https://svn.eduke32.com/eduke32/
    mv eduke32 eduke32-src
}

Build() {
    cd "${src_dir}"
    make 
}

Package() {
    cd $root_dir
    mkdir -p $bin_dir
    cp ${src_dir}/eduke32 $bin_dir
    cp ${src_dir}/mapster32 $bin_dir
    tar czf "${pkg_name}-${version}-${arch}.tar.gz" "${pkg_name}"
}

Clean() {
    cd "${root_dir}"
    rm -rf "${bin_dir}"
    rm -rf "${src_dir}"
}

if [ $1 ]; then
    $1
else
    InstallBuildDependencies
    # GetSources
    Build
    Package
    Clean
fi
