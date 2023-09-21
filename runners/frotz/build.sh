#!/bin/bash
set -e
lib_path="../../lib/"

source ${lib_path}path.sh
source ${lib_path}util.sh

runner_name=$(get_runner)
root_dir=$(pwd)
bin_dir="${root_dir}/${runner_name}"
arch=$(uname -m)
version="2.44"

src_dir="${runner_name}-${version}"
src_archive="${src_dir}.tar.gz"
src_url="http://www.ifarchive.org/if-archive/infocom/interpreters/frotz/${src_archive}"
publish_dir="/builds/runners/${runner_name}"

deps="libncurses5-dev"
install_deps $deps

wget $src_url
tar xzf $src_archive
cd ${src_dir}
make

mkdir -p ${bin_dir}
cp frotz AUTHORS BUGS COPYING HOW_TO_PLAY README ${bin_dir}

cd ..
dest_file="${runner_name}-${version}-${arch}.tar.gz"
tar czf ${dest_file} ${runner_name}
cp $dest_file $publish_dir
rm -rf ${src_dir} ${src_archive} ${bin_dir}
