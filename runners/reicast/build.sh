#!/bin/bash

set -e
lib_path="../../lib/"
source ${lib_path}path.sh
source ${lib_path}util.sh
source ${lib_path}upload_handler.sh

runner_name=$(get_runner)
root_dir="$(pwd)"
source_dir="${root_dir}/${runner_name}-src"
build_dir="${root_dir}/${runner_name}"
version="r19.07.4"
arch=$(uname -m)

deps="libegl1-mesa-dev libgles2-mesa-dev libasound2-dev mesa-common-dev freeglut3-dev pkg-config libudev-dev libpulse-dev"
install_deps $deps

repo_url="https://github.com/reicast/reicast-emulator.git"
clone $repo_url $source_dir true $version

export USE_PULSEAUDIO=1
cd ${source_dir}/reicast/linux
make

mkdir -p ${build_dir}
mv reicast.elf nosym-reicast.elf ${build_dir}
cp -a mappings ${build_dir}

cd ${root_dir}
dest_file=${runner_name}-${version}-${arch}.tar.gz
tar czf ${dest_file} ${runner_name}
runner_upload ${runner_name} ${version} ${arch} ${dest_file}
