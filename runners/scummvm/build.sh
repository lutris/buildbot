#!/bin/bash

set -e
lib_path="../../lib/"
source ${lib_path}path.sh
source ${lib_path}util.sh

runner_name="scummvm"
root_dir="$(pwd)"
source_dir="${root_dir}/${runner_name}-src"
build_dir="${root_dir}/${runner_name}"
publish_dir="/builds/runners/${runner_name}"
arch="$(uname -m)"
version="2.7.1"


InstallDependencies() {
    install_deps libgl1-mesa-dev \
        libglu1-mesa-dev libpng-dev libpng++-dev \
        libpulse-dev libsdl2-dev libsoundtouch-dev libx11-dev \
        zlib1g-dev liblzma-dev libfreetype6-dev libjpeg-dev libtheora-dev
}

GetSources() {
    cd $root_dir
    src_dir="scummvm-${version}"
    src_archive="${src_dir}.tar.xz"
    src_url="http://www.scummvm.org/frs/scummvm/${version}/${src_archive}"
    wget $src_url -O $src_archive
    tar xJf $src_archive
    rm -rf $source_dir
    mv $src_dir $source_dir
}

Build() {
    cd $source_dir
    ./configure --prefix=${build_dir}
    make
    make install
}

Package() {
    cd $root_dir
    dest_file=${runner_name}-${version}-${arch}.tar.gz
    tar czf ${dest_file} ${runner_name}
    mkdir -p $publish_dir
    cp $dest_file $publish_dir
}

if [ $1 ]; then
    $1
else
    InstallDeps
    GetSources
    Build
    Package
fi
