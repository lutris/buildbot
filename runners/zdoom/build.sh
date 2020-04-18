#!/bin/bash

set -e
lib_path="../../lib/"

source ${lib_path}path.sh
source ${lib_path}util.sh
source ${lib_path}upload_handler.sh

root_dir=$(pwd)
package_name=$(get_runner)
arch=$(uname -m)
source_dir=${root_dir}/${package_name}-src
build_dir=${root_dir}/${package_name}-build
bin_dir=${root_dir}/${package_name}


InstallDependencies() {
    install_deps zlib1g-dev libsdl1.2-dev libsdl2-dev libjpeg-dev \
        nasm libbz2-dev libgtk-3-dev cmake libfluidsynth-dev libgme-dev \
        libopenal-dev libmpg123-dev libsndfile1-dev timidity libwildmidi-dev \
        libgl1-mesa-dev libglew-dev
}

GetSources() {
    cd $root_dir
    clone https://github.com/coelckers/gzdoom $source_dir
    cd $source_dir
    git config --local --add remote.origin.fetch +refs/tags/*:refs/tags/*
    git pull
    wget -nc http://zdoom.org/files/fmod/fmodapi44464linux.tar.gz && \
    tar -xvzf fmodapi44464linux.tar.gz -C ${source_dir}

    version="$(git tag -l | grep -v 9999 | grep -E '^g[0-9]+([.][0-9]+)*$' | \
                sed 's/^g//' | sort -n -t . -k 1,1 -k 2,2 -k 3,3 -k 4,4 | \
                tail -n 1)"
    git checkout --detach refs/tags/"$version"
}

Build() {
    mkdir -p $build_dir
    cd $build_dir
    a='' && [ "$(uname -m)" = x86_64 ] && a=64
    cmake -DCMAKE_BUILD_TYPE=Release \
        -DFMOD_LIBRARY=$source_dir/fmodapi44464linux/api/lib/libfmodex"$a"-4.44.64.so \
        -DFMOD_INCLUDE_DIR=$source_dir/fmodapi44464linux/api/inc $source_dir
    make -j$(getconf _NPROCESSORS_ONLN)
}

Package() {
    cd $build_dir
    mkdir -p ${bin_dir}
    mv gzdoom gzdoom.pk3 ${bin_dir}
    mv lights.pk3 brightmaps.pk3 $bin_dir
    a='' && [ "$(uname -m)" = x86_64 ] && a=64
    cp ${source_dir}/fmodapi44464linux/api/lib/libfmodex"$a"-4.44.64.so $bin_dir
    cd ${bin_dir}
    strip gzdoom
    cd ${root_dir}
    dest_file="gzdoom-${version}-${arch}.tar.gz"
    tar czf ${dest_file} ${package_name}
}

CleanUp() {
    rm -rf $bin_dir $source_dir $build_dir
}

Upload() {
    runner_upload ${package_name} gzdoom-${version} ${arch} ${dest_file}
}

if [ $1 ]; then
    $1
else
    GetSources
    Build
    Package
    Upload
    CleanUp
fi
