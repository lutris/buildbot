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
arch="$(uname -m)"
version="1.8.0"

src_dir="scummvm-${version}"
src_archive="${src_dir}.tar.gz"
src_url="http://prdownloads.sourceforge.net/scummvm/${src_archive}?download"
wget $src_url -O $src_archive
tar xzf $src_archive

rm -rf $source_dir
mv $src_dir $source_dir

cd $source_dir
./configure --prefix=${build_dir}
make
make install

cd ..
dest_file=${runner_name}-${version}-${arch}.tar.gz
tar czf ${dest_file} ${runner_name}
runner_upload ${runner_name} ${version} ${arch} ${dest_file}
rm -rf ${build_dir} ${source_dir}
