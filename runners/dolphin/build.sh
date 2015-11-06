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
repo_url="https://github.com/dolphin-emu/dolphin.git"

deps="libwxbase3.0-dev libwxgtk3.0-dev libgtk2.0-dev libxext-dev libreadline-dev libgl1-mesa-dev libevdev-dev libudev-dev"

install_deps $deps
clone $repo_url $source_dir

mkdir -p ${build_dir}

cd ${build_dir}

cmake \
    -DCMAKE_INSTALL_PREFIX=${bin_dir} \
    ${source_dir}
