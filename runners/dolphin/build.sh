#!/bin/bash
#
# Compiling Dolphin on Ubuntu 14.04 requires a newer version of GCC with C++11
# support. It is available here:
# https://launchpad.net/~dolphin-emu/+archive/ubuntu/gcc-for-dolphin
#


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
    sudo apt install -y cmake libxext-dev libreadline-dev libgl1-mesa-dev libevdev-dev \
        libudev-dev libusb-1.0-0-dev qtbase5-dev qtbase5-private-dev
}

GetSources() {
    clone $repo_url $source_dir
}

BuildProject() {
    cd "${source_dir}"
    mkdir -p ${build_dir}
    cd ${build_dir}
    cmake -DLINUX_LOCAL_DEV=1 ${source_dir}
    make -j 8
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
    cp -a ${source_dir}/Data/Sys ${bin_dir}
    mkdir -p ${bin_dir}/lib
    # cp ${build_dir}/Externals/**/*.so* ${bin_dir}/lib
    cp /usr/lib/x86_64-linux-gnu/libav* ${bin_dir}/lib
    cd ${root_dir}
    dest_file="${runner_name}-${version}-${arch}.tar.xz"
    tar cJf ${dest_file} ${runner_name}
    mkdir -p $publish_dir
    cp $dest_file $publish_dir
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
