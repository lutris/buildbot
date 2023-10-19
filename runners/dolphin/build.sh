#!/bin/bash

set -e
lib_path="../../lib/"

source ${lib_path}path.sh
source ${lib_path}util.sh

runner_name=$(get_runner)
root_dir=$(pwd)
source_dir="${root_dir}/${runner_name}-src"
build_dir="${root_dir}/${runner_name}-build"
bin_dir="${root_dir}/${runner_name}"
arch=$(uname -m)
repo_url="https://github.com/dolphin-emu/dolphin"
publish_dir="/builds/runners/${runner_name}"

InstallBuildDependencies() {
    sudo -S apt install -y build-essential git cmake ffmpeg libavcodec-dev libavformat-dev \
        libavutil-dev libswscale-dev libevdev-dev libusb-1.0-0-dev libxrandr-dev libxi-dev \
        libpangocairo-1.0-0 qt6-base-private-dev libqt6svg6-dev libbluetooth-dev libasound2-dev \
        libpulse-dev libgl1-mesa-dev libcurl4-openssl-dev libudev-dev libsystemd-dev
}

GetSources() {
    if [[ -d $source_dir ]]; then
        rm -rf $source_dir
    fi
    clone $repo_url $source_dir
    cd $source_dir
    git submodule update --init --recursive \
        Externals/mGBA \
        Externals/spirv_cross \
        Externals/zlib-ng \
        Externals/libspng \
        Externals/VulkanMemoryAllocator \
        Externals/cubeb \
        Externals/implot \
        Externals/gtest \
        Externals/rcheevos
    git pull --recurse-submodules
    cd ..
}

BuildProject() {
    cd "${source_dir}"
    mkdir -p ${build_dir}
    cd ${build_dir}
    cmake -DLINUX_LOCAL_DEV=1 ${source_dir}
    make -j$(nproc)
    cp -r ${source_dir}/Data/Sys/ Binaries/
    touch Binaries/portable.txt
}

GetVersion() {
    cd ${build_dir}
    version=$(grep SCM_DESC_STR Source/Core/Common/scmrev.h | cut -f 3 -d " " | tr -d "\"")
    export version=${version%-dirty}
}

PackageProject() {
    cd ${build_dir}
    rm -rf ${bin_dir}
    mkdir -p ${bin_dir}
    mv Binaries/* ${bin_dir}
    mkdir -p ${bin_dir}/lib
    cp /usr/lib/x86_64-linux-gnu/libav* ${bin_dir}/lib
    cd ${root_dir}
    dest_file="${runner_name}-${version}-${arch}.tar.xz"
    tar cJf ${dest_file} ${runner_name}
    mkdir -p $publish_dir
    cp $dest_file $publish_dir
}

Clean() {
    rm -rf $build_dir $source_dir
}

if [ $1 ]; then
    $1
else
    InstallBuildDependencies
    GetSources
    BuildProject
    GetVersion
    PackageProject
fi
