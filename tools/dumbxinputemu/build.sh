#!/bin/bash

set -e

source ../../lib/util.sh

pkg_name="dumbxinputemu"
version="0.3.3"
root_dir=$(pwd)
source_dir="${root_dir}/${pkg_name}-src"
bin_dir="${root_dir}/${pkg_name}"


GetSources() {
    mkdir ${bin_dir}
    cd ${bin_dir}
    dumb_archive="dumbxinputemu-v${version}-dlls.tar.gz"
    wget https://github.com/kozec/dumbxinputemu/releases/download/v${version}/${dumb_archive}
    tar xvzf $dumb_archive
    rm $dumb_archive
    mv 32 win32
    mv 64 win64
    cd $root_dir
    clone https://github.com/kozec/dumbxinputemu.git $source_dir
    cp $source_dir/README.md $bin_dir
    cp $source_dir/LICENSE $bin_dir
}


PackageProject() {
    cd "$root_dir"
    tar czf "${pkg_name}-${version}.tar.gz" "${pkg_name}"
}

Cleanup() {
    cd "$root_dir"
    rm -rf "$bin_dir"
    rm -rf "$source_dir"
}


if [ "$1" ]; then
    $1
else
    GetSources $version
    PackageProject
    Cleanup
fi
