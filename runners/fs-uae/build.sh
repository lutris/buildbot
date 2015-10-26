#!/bin/bash

set -e
lib_path="../../lib/"
source ${lib_path}path.sh
source ${lib_path}util.sh
source ${lib_path}upload_handler.sh

runner_name=$(get_runner)
root_dir=$(pwd)
source_dir="${root_dir}/${runner_name}-src"
build_dir="${root_dir}/${runner_name}"
arch=$(uname -m)
version="2.6.1"
repo_url="https://github.com/FrodeSolheim/fs-uae.git"

deps="libglew-dev libmpeg2-4-dev"

install_deps $deps
clone $repo_url $source_dir

mkdir -p ${build_dir}

cd $source_dir
./bootstrap
./configure
make

strip fs-uae
strip fs-uae-device-helper

cp -a fs-uae ${build_dir}
cp -a fs-uae.dat ${build_dir}
cp -a fs-uae-device-helper ${build_dir}
cp -a share ${build_dir}
cp -a licenses ${build_dir}
cp -a README ${build_dir}


