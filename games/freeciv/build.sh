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

deps="pkg-config autoconf automake libgtk-3-dev"
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

# TODO: Fix other dependencies so that we can build at least one client.
