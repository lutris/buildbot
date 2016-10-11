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
source ${lib_path}upload_handler.sh

runner_name=$(get_runner)
root_dir=$(pwd)
source_dir="${root_dir}/${runner_name}-src"
build_dir="${root_dir}/${runner_name}-build"
bin_dir="${root_dir}/${runner_name}"
arch=$(uname -m)
repo_url="https://github.com/dolphin-emu/dolphin"

InstallBuildDependencies() {
    install_deps cmake libwxbase3.0-dev libwxgtk3.0-dev libgtk2.0-dev libxext-dev \
        libreadline-dev libgl1-mesa-dev libevdev-dev libudev-dev libusb-1.0-0-dev
}

GetSources() {
    clone $repo_url $source_dir
}


BuildProject() {
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
    rm -rf ${bin_dir}
    mkdir -p ${bin_dir}
    mv Binaries/* ${bin_dir}
    cp -a ${source_dir}/Data/Sys ${bin_dir}
    cd ${root_dir}
    dest_file="${runner_name}-${version}-${arch}.tar.gz"
    tar czf ${dest_file} ${runner_name}
}

UploadPackage() {
    if [ ! $version ]; then
        GetVersion
    fi
    cd $root_dir
    dest_file="${runner_name}-${version}-${arch}.tar.gz"
    runner_upload ${runner_name} ${version} ${arch} ${dest_file}
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
