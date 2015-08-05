#!/bin/bash

lib_path="../../lib/"
source ${lib_path}path.sh
source ${lib_path}upload_handler.sh
set -e

runner_name=$(get_runner)
root_dir=$(pwd)
source_dir="${runner_name}-src"
build_dir="${runner_name}"
arch=$(uname -m)
version="0.9.96"

sudo apt-get install libqt4-dev libqt4-dev-bin qt4-qmake

git clone https://github.com/lutris/osmose.git $source_dir
mkdir $build_dir
cd $build_dir
qmake-qt4 ../${source_dir}
make
make clean
rm Makefile

strip osmose
cp ../${source_dir}/README README
cp ../${source_dir}/License.txt LICENSE

cd ..
dest_file="${runner_name}-${version}-${arch}.tar.gz"
tar czf ${dest_file} ${runner_name}
rm -rf ${build_dir} ${source_dir}

runner_upload ${runner_name} ${version} ${arch} ${dest_file}
