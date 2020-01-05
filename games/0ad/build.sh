#!/bin/bash

set -e
set -x

source ../../lib/util.sh

version="0.23b-alpha"
arch="$(uname -m)"
root_dir=$(pwd)
source_dir="${root_dir}/0ad-src"
bin_dir="${root_dir}/0ad"

InstallBuildDependencies() {
    install_deps build-essential libboost-dev libboost-filesystem-dev \
    libcurl4-gnutls-dev libenet-dev libgloox-dev libicu-dev \
    libminiupnpc-dev libnspr4-dev libnvtt-dev libogg-dev libopenal-dev \
    libpng-dev libsdl2-dev libvorbis-dev libwxgtk3.0-dev libxcursor-dev \
    libxml2-dev subversion zlib1g-dev subversion
}

InstallLibSodium() {
    # The version of libsodium in Ubuntu 16.04 is not recent enough
    wget https://download.libsodium.org/libsodium/releases/LATEST.tar.gz
    tar xvzf LATEST.tar.gz
    cd libsodium-stable
    ./configure
    make && make check
    sudo make install
}

GetSources() {
    cd $root_dir
    rm -rf $source_dir

    engine_archive="0ad-0.${version}-unix-build.tar.xz"
    data_archive="0ad-0.${version}-unix-data.tar.xz"

    if [ ! -f $engine_archive ]; then
        wget "http://releases.wildfiregames.com/${engine_archive}"
    fi

    if [ ! -f $data_archive ]; then
        wget "http://releases.wildfiregames.com/${data_archive}"
    fi

    tar xvJf $engine_archive
    tar xvJf $data_archive
    mv 0ad-0.${version} $source_dir
}

BuildProject() {
    cd ${source_dir}/build/workspaces
    ./update-workspaces.sh -j$(getconf _NPROCESSORS_ONLN)
    cd gcc
    make -j$(getconf _NPROCESSORS_ONLN)
}

PackageProject() {
    rm -rf $bin_dir
    cd $source_dir
    cp -a binaries $bin_dir
    cd $bin_dir
    rm -f system/*.dll
    rm -f system/*.pdb
    rm -f system/*.exe
    rm -f system/*.sys
    rm -f system/*.bat
    rm -f system/test
    strip system/pyrogenesis
    strip system/ActorEditor
    strip system/*.so
    cd $root_dir
    tar czf 0ad-${version}-${arch}.tar.gz 0ad
}

Cleanup() {
    rm -rf $source_dir
    rm -rf $bin_dir
}

if [ $1 ]; then
    $1
else
    InstallBuildDependencies
    InstallLibSodium
    GetSources
    BuildProject
    PackageProject
fi
