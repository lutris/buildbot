#!/bin/bash

set -e

source ../../lib/util.sh

version="master"
root_dir=$(pwd)
source_dir="${root_dir}/xoreos-src"
build_dir="${root_dir}/xoreos-build"

install_deps "libfaad-dev libxvidcore-dev"

clone https://github.com/xoreos/xoreos.git $source_dir

mkdir  -p $build_dir
cd $build_dir
cmake $source_dir
make
