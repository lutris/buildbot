#!/bin/bash
set -e
lib_path="../../lib/"

source ${lib_path}path.sh
source ${lib_path}util.sh

runner_name=$(get_runner)
root_dir=$(pwd)
build_dir="${root_dir}/${runner_name}"
source_dir="${root_dir}/${runner_name}-src"
publish_dir="/builds/runners/${runner_name}"
arch=$(uname -m)
version="1.63"

repo_url="https://github.com/snes9xgit/snes9x.git"
deps="autoconf libtool gettext libglib2.0-dev intltool libgtk2.0-dev libxml2-dev libsdl1.2-dev"

install_deps $deps
clone $repo_url $source_dir "" $version

cd ${source_dir}/gtk
./autogen.sh
./configure --prefix=${build_dir} --without-screenshot --without-xv
make
make install

cd ${build_dir}/bin
strip snes9x-gtk

cd ../..
dest_file="${runner_name}-${version}-${arch}.tar.gz"
tar czf $dest_file ${runner_name}
cp $dest_file $publish_dir
rm -rf ${build_dir} ${source_dir}
