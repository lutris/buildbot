#!/bin/bash

set -e
lib_path="./lib/"
source ${lib_path}path.sh
source ${lib_path}util.sh

runner_name="scummvm"
root_dir="$(pwd)"
source_dir="${root_dir}/${runner_name}-src"
build_dir="${root_dir}/${runner_name}"
artifact_dir="${root_dir}/artifacts/"
arch="$(uname -m)"
version="2.2.0"

cd $root_dir
src_dir="scummvm-${version}"
src_archive="${src_dir}.tar.xz"
src_url="http://www.scummvm.org/frs/scummvm/${version}/${src_archive}"
wget $src_url -O $src_archive
tar xJf $src_archive

rm -rf $source_dir
mv $src_dir $source_dir

cd $source_dir
./configure --prefix=${build_dir}
make
make install

cd ..
dest_file=${runner_name}-${version}-${arch}.tar.gz
tar czf ${dest_file} ${runner_name}
cp $dest_file $artifact_dir
