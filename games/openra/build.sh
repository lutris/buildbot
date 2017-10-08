#!/bin/bash

set -e

source ../../lib/util.sh

version="20170527"
root_dir=$(pwd)
source_dir="${root_dir}/openra-src"
build_dir="${root_dir}/openra-build"

clone https://github.com/OpenRA/OpenRA.git $source_dir
cd $source_dir
git checkout -b release-${version}

mozroots --import --sync
make dependencies
make all
make prefix=$build_dir install

cd $build_dir/lib
tar czf ${root_dir}/openra-${version}.tar.gz openra
