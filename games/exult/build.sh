#!/bin/bash

set -e 

version=1.6
arch="$(uname -m)"
root_dir=$(pwd)
source_dir="$root_dir/exult-$version"
build_dir="${root_dir}/exult-build"
bin_dir="${root_dir}/exult"

Deps() {
    sudo apt-get install -y libglade2-dev libvorbis-dev
}

Fetch() {
    archive=exult-$version.tar.gz
    wget https://sourceforge.net/projects/exult/files/exult-all-versions/1.6/exult-1.6.tar.gz/download -O $archive
    tar xvzf $archive
}

Build() {
    cd $source_dir
    ./autogen.sh
    ./configure --enable-exult-studio --enable-static-libraries --prefix=$build_dir
    make
    make install

}

Package() {
    mkdir -p $bin_dir
    cd $bin_dir
    mv $build_dir/share/exult ./data
    mv $build_dir/bin/* .

    cd $root_dir
    cp exult.cfg $bin_dir
    tar cJf exult-$version-$arch.tar.xz exult
}

if [ $1 ]; then
    $1
else
    Deps
    Fetch
    Build
    Package
fi
