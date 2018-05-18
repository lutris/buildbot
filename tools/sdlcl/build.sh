#!/bin/bash

set -e

source ../../lib/util.sh

pkg_name="sdlcl"
version="1.0"
arch=$(uname -m)
root_dir=$(pwd)
source_dir=${root_dir}/${pkg_name}-src
bin_dir=${root_dir}/${pkg_name}


GetSources() {
    clone https://github.com/MrAlert/sdlcl $source_dir
}

Build() {
    cd $source_dir
    make
}

Package() {
    mkdir -p ${bin_dir}
    cp $source_dir/libSDL-1.2.so.0 $bin_dir
    cd $root_dir
    tar czf ${pkg_name}-${version}-${arch}.tar.gz $pkg_name
}


if [ $1 ]; then
    $1
else
    GetSources
    Build
    Package
fi
