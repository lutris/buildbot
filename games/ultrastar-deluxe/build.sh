#!/bin/bash

set -e
set -x

source ../../lib/util.sh

version="master"
arch="$(uname -m)"
root_dir=$(pwd)
source_dir="${root_dir}/usdx-src"
bin_dir="${root_dir}/usdx"

InstallBuildDependencies() {
    install_deps \
        fpc liblua5.3-dev libopencv-highgui-dev \
        cmake ftgl-dev libglew-dev \
        build-essential autoconf automake \
        libtool libasound2-dev libpulse-dev libaudio-dev libx11-dev libxext-dev \
        libxrandr-dev libxcursor-dev libxi-dev libxinerama-dev libxxf86vm-dev \
        libxss-dev libgl1-mesa-dev libdbus-1-dev libudev-dev \
        libgles1-mesa-dev libgles2-mesa-dev libegl1-mesa-dev libibus-1.0-dev \
        fcitx-libs-dev libsamplerate0-dev \
        libwayland-dev libxkbcommon-dev ibus \
        chrpath curl
}

GetSources() {
    cd $root_dir
    rm -rf $source_dir
    wget https://github.com/UltraStar-Deluxe/USDX/archive/${version}.tar.gz -O usdx.tar.gz
    tar xvf usdx.tar.gz
    rm -f usdx.tar.gz
    mv USDX-${version} $source_dir
}

BuildProject() {
    cd ${source_dir}/dists/linux
    make build
}

PackageProject() {
    rm -rf $bin_dir
    cd ${source_dir}/dists/linux
    cp -a output $bin_dir
    cd $bin_dir
    cd $root_dir
    tar czf usdx-${version}-${arch}.tar.gz usdx
}

Cleanup() {
    rm -rf $source_dir
    rm -rf $bin_dir
}

if [ $1 ]; then
    $1
else
    InstallBuildDependencies
    GetSources
    BuildProject
    PackageProject
fi
