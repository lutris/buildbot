#!/bin/bash

set -e

source ../../lib/util.sh

pkg_name="sdl-openglhq"
version="1.2.15"
arch=$(uname -m)
root_dir=$(pwd)
source_dir=${root_dir}/SDL-1.2.15
bin_dir=${root_dir}/${pkg_name}


GetSources() {
    wget "https://www.syntax-k.de/projekte/sdl-opengl-hq/archive/openglhq-1.2.15-2016-10-25.diff"
    wget "https://www.libsdl.org/release/SDL-1.2.15.tar.gz"
    tar xvzf "SDL-1.2.15.tar.gz"
    cd SDL-1.2.15
    patch -p1 < ../openglhq-1.2.15-2016-10-25.diff
}

Build() {
    cd $source_dir
    ./configure --prefix=${bin_dir}
    make
    make install
}

Package() {
    cd ${bin_dir}/lib
    tar czf ${root_dir}/${pkg_name}-${version}-${arch}.tar.gz *so*
}

Cleanup() {
    cd $root_dir
    rm -rf $bin_dir
    rm -rf $source_dir
    rm -f openglhq-1.2.15-2016-10-25.diff
    rm -f SDL-1.2.15.tar.gz
}


if [ $1 ]; then
    $1
else
    GetSources
    Build
    Package
    # Cleanup
fi
