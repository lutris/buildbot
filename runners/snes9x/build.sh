#!/bin/bash
set -e
lib_path="../../lib/"

source ${lib_path}path.sh
source ${lib_path}util.sh
source ${lib_path}upload_handler.sh

runner_name=$(get_runner)
root_dir=$(pwd)
build_dir="${root_dir}/${runner_name}"
source_dir="${root_dir}/${runner_name}-src"
arch=$(uname -m)
version="1.53"

repo_url="https://github.com/snes9xgit/snes9x.git"
deps="autoconf libtool gettext libglib2.0-dev intltool libgtk2.0-dev libxml2-dev libsdl1.2-dev"

install_deps $deps
clone $repo_url $source_dir

cd ${source_dir}/gtk
./autogen.sh

# Compiling with gtk3 produces lots of warning messages
# and a segfault on 2 Ubuntu 15.04 machines
# ./configure --prefix=${build_dir} --without-screenshot --without-xv --with-gtk3
./configure --prefix=${build_dir} --without-screenshot --without-xv
make
make install

cd ${build_dir}/bin
strip snes9x-gtk

cd ../..
dest_file="${runner_name}-${version}-${arch}.tar.gz"
tar czf $dest_file ${runner_name}
runner_upload ${runner_name} ${version} ${arch} ${dest_file}
rm -rf ${build_dir} ${source_dir}
