#!/bin/bash

root_dir=$(pwd)
pkg_name="snes9x"
build_dir="${root_dir}/${pkg_name}"
source_dir="${root_dir}/${pkg_name}-src"
version="1.53"
arch=$(uname -m)
sudo apt-get install -y autoconf libtool gettext libglib2.0-dev \
    intltool libgtk2.0-dev libxml2-dev libsdl1.2-dev

git clone https://github.com/snes9xgit/snes9x.git $source_dir

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
tar cvzf ${pkg_name}-${version}-${arch}.tar.gz ${pkg_name}
rm -rf ${build_dir} ${source_dir}
