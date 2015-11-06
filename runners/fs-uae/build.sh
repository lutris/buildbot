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
repo_url="https://github.com/FrodeSolheim/fs-uae.git"

deps="libglew-dev libmpeg2-4-dev libsdl2-dev zip"

install_deps $deps
clone $repo_url $source_dir

mkdir -p ${build_dir}

cd $source_dir

version=$(cat ChangeLog | head -n 1 | cut -d " " -f 2)
version=${version//:}

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

cd ..

dest_file="${runner_name}-${version}-${arch}.tar.gz"
tar czf ${dest_file} ${runner_name}

runner_upload fsuae ${version} ${arch} ${dest_file}

