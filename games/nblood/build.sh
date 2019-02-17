#!/bin/bash

set -e

source ../../lib/util.sh

version="20190216"
arch=$(uname -m)
root_dir=$(pwd)
pkg_name="nblood"
src_dir="${root_dir}/${pkg_name}-src"
bin_dir="${root_dir}/${pkg_name}"

InstallBuildDependencies() {
    install_deps git-svn build-essential nasm libgl1-mesa-dev libglu1-mesa-dev \
        libsdl1.2-dev libsdl-mixer1.2-dev libsdl2-dev libsdl2-mixer-dev flac \
        libflac-dev libvorbis-dev libvpx-dev libgtk2.0-dev freepats
}

GetSources() {
    cd $root_dir
    clone https://github.com/nukeykt/NBlood $src_dir
}

Build() {
    cd "${src_dir}"
    make
}

Package() {
    cd $root_dir
    mkdir -p $bin_dir
    cp ${src_dir}/nblood $bin_dir
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
    GetSources
    Build
    Package
    Clean
fi
