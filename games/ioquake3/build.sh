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
    sudo apt-get install -y make libsdl2-dev
}

Fetch() {
    clone https://github.com/ioquake/ioq3 $source_dir true
}

Build() {
    cd $source_dir
    make
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
