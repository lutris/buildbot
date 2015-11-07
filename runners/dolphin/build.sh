#!/bin/bash

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
version="4.0"
repo_url="https://github.com/lutris/dolphin.git"

deps="libwxbase3.0-dev libwxgtk3.0-dev libgtk2.0-dev libxext-dev libreadline-dev libgl1-mesa-dev libevdev-dev libudev-dev"

install_deps $deps
clone $repo_url $source_dir

mkdir -p ${build_dir}

cd ${build_dir}

cmake ${source_dir}

make -j 8
version=$(grep SCM_DESC_STR Source/Core/Common/scmrev.h | cut -f 3 -d " " | tr -d "\"")
version=${version%-dirty}

rm -rf ${bin_dir}
mv Binaries/* ${bin_dir}
cp -a ${source_dir}/Data/Sys ${bin_dir}

cd ..

dest_file="${runner_name}-${version}-${arch}.tar.gz"
tar czf ${dest_file} ${runner_name}

runner_upload ${runner_name} ${version} ${arch} ${dest_file}
