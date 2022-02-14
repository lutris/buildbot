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
build_dir=${source_dir}/build
bin_dir=${root_dir}/${package_name}
zmusic_dir=${root_dir}/zmusic-build

InstallDependencies() {
    install_deps  g++ make cmake libsdl2-dev git zlib1g-dev \
    libbz2-dev libjpeg-dev libfluidsynth-dev libgme-dev libopenal-dev \
    libmpg123-dev libsndfile1-dev libgtk-3-dev timidity nasm \
    libgl1-mesa-dev tar libsdl1.2-dev libglew-dev
}

GetVersion() {
    cwd="$(pwd)"
    cd $source_dir
    version="$(git tag -l | grep -v 9999 | grep -E '^g[0-9]+([.][0-9]+)*$' | \
                sed 's/^g//' | sort -n -t . -k 1,1 -k 2,2 -k 3,3 -k 4,4 | \
                tail -n 1)"
    cd $cwd
}

GetSources() {
    cd $root_dir
    clone https://github.com/coelckers/gzdoom $source_dir
    cd $source_dir
    git config --local --add remote.origin.fetch +refs/tags/*:refs/tags/*
    git pull
    GetVersion
    git checkout --detach refs/tags/g"$version"
}

BuildZmusic() {
    mkdir -pv $zmusic_dir
    cd $zmusic_build
    git clone https://github.com/coelckers/ZMusic.git zmusic
    mkdir -pv zmusic/build
    cd zmusic/build
    cmake .. -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr
    make
    sudo make install
}

Build() {
    mkdir -p $build_dir
    cd $source_dir
    cmake -B build \
        -D CMAKE_BUILD_TYPE=Release \
        -D DYN_GTK=OFF \
        -D DYN_OPENAL=OFF
    make -C build
}

Package() {
    GetVersion
    cd $build_dir
    mkdir -p ${bin_dir}
    cp gzdoom *.pk3 $bin_dir
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
    GetVersion
    runner_upload ${package_name} gzdoom-${version} ${arch} ${dest_file}
}

if [ $1 ]; then
    $1
else
    GetSources
    BuildZmusic
    Build
    Package
    Upload
    CleanUp
fi
