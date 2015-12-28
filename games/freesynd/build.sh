#!/bin/bash

set -e
lib_path="../../lib/"

source ${lib_path}path.sh
source ${lib_path}util.sh
source ${lib_path}upload_handler.sh

root_dir=$(pwd)
version=0.7.1
arch=$(uname -m)
package_name=freesynd
source_dir=${root_dir}/${package_name}-src
bin_dir=${root_dir}/${package_name}

deps="libsdl1.2-dev libsdl-image1.2-dev libsdl-mixer1.2-dev"
install_deps $deps

svn co svn://svn.code.sf.net/p/freesynd/code/freesynd/tags/release-${version} ${source_dir}

cd $source_dir
cmake .
make
