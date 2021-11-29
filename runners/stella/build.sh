#!/bin/bash
set -e
lib_path="../../lib/"

source ${lib_path}path.sh
source ${lib_path}util.sh
source ${lib_path}upload_handler.sh

runner_name=$(get_runner)
root_dir=$(pwd)
bin_dir="${root_dir}/${runner_name}"
arch=$(uname -m)
version="6.6"

src_dir="${runner_name}-${version}"
src_archive="${src_dir}-src.tar.gz"
src_url="http://prdownloads.sourceforge.net/stella/${src_archive}?download"
wget ${src_url} -O $src_archive
tar xzf ${src_archive}
cd ${src_dir}

./configure --prefix=${bin_dir}
make
make install

cd ..
dest_file="${runner_name}-${version}-${arch}.tar.gz"
tar czf ${dest_file} ${runner_name}
runner_upload ${runner_name} ${version} ${arch} ${dest_file}
rm -rf ${src_dir} ${src_archive} ${bin_dir}
