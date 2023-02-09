#!/bin/bash

set -e
lib_path="../../lib/"

source ${lib_path}path.sh
source ${lib_path}util.sh
source ${lib_path}upload_handler.sh


root_dir=$(pwd)
project="TheForceEngine"
version=1.08.100
arch=$(uname -m)

source_dir=${root_dir}/${project}-src
build_dir=${root_dir}/${project}-build
bin_dir=${root_dir}/${project}-dist
build_archive="$project-$version-$arch.tar.xz"
Deps() {
    deps="libsdl2-dev libdevil-dev librtaudio-dev librtmidi-dev libglew-dev cmake build-essential"
    install_deps $deps
}

Fetch() {
    clone https://github.com/luciusDXL/TheForceEngine.git $source_dir
}


Build() {
    mkdir -p $build_dir
    cd $build_dir
    cmake -S $source_dir -DCMAKE_INSTALL_PREFIX="${bin_dir}"
    make
    make install
    mv ${bin_dir}/bin/tfelnx ${bin_dir}/share/TheForceEngine
    mv ${bin_dir}/share/TheForceEngine $root_dir

}
Package() {
    cd $root_dir
    tar cJf $build_archive $project
}

Upload() {
    spaces_upload $build_archive "games" "$project"
}

Clean() {
    cd $root_dir
    rm -rf TheForceEngine*
}

if [ $1 ]; then
    $1
else
    Deps
    Fetch
    Build
    Package
    Upload
fi
