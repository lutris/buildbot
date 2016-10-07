#!/bin/bash

set -e
lib_path="../../lib/"

source ${lib_path}path.sh
source ${lib_path}util.sh
source ${lib_path}upload_handler.sh

root_dir=$(pwd)
version=2.5.1
arch=$(uname -m)
source_dir=${root_dir}/freeciv-${version}
build_dir=${root_dir}/freeciv-build
bin_dir=${root_dir}/freeciv

deps="pkg-config autoconf automake libgtk-3-dev gettext gnulib libbz2-dev libcurl4-gnutls-dev libesd0-dev libgtk-3-dev libgtk2.0-dev liblua5.2-dev liblzma-dev libpng-dev libreadline-dev libsdl-gfx1.2-dev libsdl-image1.2-dev libsdl-mixer1.2-dev libsdl-ttf2.0-dev libsqlite3-dev libtolua-dev libx11-dev python-minimal qtbase5-dev qtbase5-dev-tools x11proto-core-dev zlib1g-dev libgtk-3-dev libgtk2.0-dev"
install_deps $deps

#clone https://github.com/SuperTux/supertux.git $source_dir
mkdir -p $source_dir
cd $source_dir
wget -nc http://download.gna.org/freeciv/stable/freeciv-${version}.tar.bz2
rm -rf freeciv-${version}
tar xvjf freeciv-${version}.tar.bz2
cd freeciv-${version}
./autogen.sh
./configure
make

# TODO: Move compiled peices into a package folder.
