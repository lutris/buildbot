#!/bin/bash
set -e
lib_path="./lib/"

source ${lib_path}path.sh
source ${lib_path}util.sh

runner_name="snes9x"
root_dir=$(pwd)
build_dir="${root_dir}/${runner_name}"
source_dir="${root_dir}/${runner_name}-src"
publish_dir="/build/artifacts/"
arch=$(uname -m)
version="1.63"

repo_url="https://github.com/snes9xgit/snes9x.git"

clone $repo_url $source_dir --recursive $version

cd ${source_dir}
git submodule update --init --recursive

cmake_build_dir="${root_dir}/${runner_name}-cmake-build"
mkdir -p ${cmake_build_dir}
cd ${cmake_build_dir}
cmake -DCMAKE_INSTALL_PREFIX=${build_dir} -DUSE_XV=OFF ${source_dir}/gtk
make -j$(nproc)
make install

cd ${build_dir}/bin
strip snes9x-gtk

cd ${root_dir}
dest_file="${runner_name}-${version}-${arch}.tar.gz"
tar czf $dest_file ${runner_name}
cp $dest_file $publish_dir
rm -rf ${build_dir} ${source_dir} ${cmake_build_dir}
