#!/bin/bash

set -e
lib_path="../../lib/"

source ${lib_path}path.sh
source ${lib_path}util.sh

runner_name=$(get_runner)
root_dir=$(pwd)
source_dir="${root_dir}/${runner_name}-src"
bin_dir="${root_dir}/${runner_name}"
publish_dir="/builds/runners/${runner_name}"
arch=$(uname -m)
version="20150213"
repo_url="https://github.com/lutris/jzintv.git"

bin_dir="jzintv-20150213-linux-x86-64"
archive="${bin_dir}.zip"
wget "http://spatula-city.org/~im14u2c/intv/dl/${archive}"
unzip $archive
mv ${bin_dir} ${runner_name}

dest_file="${runner_name}-${version}-${arch}.tar.gz"
tar czf ${dest_file} ${runner_name}
cp $dest_file $publish_dir
