#!/bin/bash

set -e

lib_path="../../lib/"
source ${lib_path}upload_handler.sh
source ${lib_path}util.sh

project="cortex-command"
version=development
arch="$(uname -m)"
root_dir=$(pwd)
source_dir="$root_dir/$project-$version"
build_dir="${root_dir}/$project-build"
bin_dir="${root_dir}/$project"
build_archive="$project-$version-$arch.tar.xz"

Deps() {
    sudo apt-get install -y liballegro4-dev libloadpng4-dev libflac++-dev \
            luajit-5.1-dev libminizip-dev liblz4-dev libpng++-dev libx11-dev libboost-dev
}

Fetch() {
    clone https://github.com/cortex-command-community/Cortex-Command-Community-Project-Source.git $source_dir true $version
}

Build() {
    cd $source_dir
    meson builddir
    cd builddir
    meson compile CCCP
}

Package() {
    echo "TODO"
}

Upload() {
    spaces_upload $build_archive "games" "$project"
}

Clean() {
    rm -rf $source_dir $bin_dir $build_dir *.tar.gz
}

if [ $1 ]; then
    $1
else
    Deps
    Fetch
    Build
    Package
fi
