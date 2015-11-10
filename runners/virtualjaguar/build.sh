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
version="2.1.2"
repo_url="http://shamusworld.gotdns.org/git/virtualjaguar"

deps="qt5base-dev"
install_deps $deps

clone $repo_url $source_dir

cd $source_dir
QT_SELECT=5 qmake
make 

cd ..
rm -rf ${build_dir}
mkdir -p ${build_dir}
cp ${source_dir}/virtualjaguar ${build_dir}

dest_file="${runner_name}-${version}-${arch}.tar.gz"
tar czf ${dest_file} ${runner_name}
runner_upload ${runner_name} ${version} ${arch} ${dest_file}
