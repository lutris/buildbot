#!/bin/bash

set -e

lib_path="../../lib/"
source ${lib_path}upload_handler.sh
source ${lib_path}util.sh

project="ioquake3"
version=main
arch="$(uname -m)"
root_dir=$(pwd)
source_dir="$root_dir/$project-$version"
build_dir="${root_dir}/$project-build"
bin_dir="${root_dir}/$project"
build_archive="$project-$version-$arch.tar.xz"

Deps() {
    sudo apt-get install -y make libsdl2-dev \
     libxxf86dga-dev libxrandr-dev libxxf86vm-dev libasound-dev \
     make gcc libcurl4-openssl-dev mesa-common-dev
}

Fetch() {
    clone https://github.com/ec-/Quake3e.git $source_dir true
}

Build() {
    cd $source_dir
    make
}


if [ $1 ]; then
    $1
else
    Deps
    Fetch
    Build
fi
