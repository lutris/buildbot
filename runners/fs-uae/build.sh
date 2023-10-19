#!/bin/bash

set -e
lib_path="../../lib/"
source ${lib_path}path.sh
source ${lib_path}util.sh

runner_name=$(get_runner)
root_dir=$(pwd)
source_dir="${root_dir}/${runner_name}-src"
build_dir="${root_dir}/${runner_name}"
publish_dir="/builds/runners/${runner_name}"
arch=$(uname -m)

install_deps "automake libtool libglew-dev libmpeg2-4-dev \
    libsdl2-dev zip libopenal-dev"
clone "https://github.com/FrodeSolheim/fs-uae.git" $source_dir
cd "${source_dir}"
mkdir -p ${build_dir}

cd $source_dir
git checkout stable

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

mkdir -p $publish_dir
cp $dest_file $publish_dir

