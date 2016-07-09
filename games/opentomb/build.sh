#!/bin/bash

set -e

source ../../lib/util.sh

version="master"
root_dir=$(pwd)
source_dir="${root_dir}/opentomb-src"
build_dir="${root_dir}/opentomb-build"

install_deps liblua5.3-dev \
    libbullet-dev libfreetype6-dev libglu1-mesa-dev libglew-dev \
    libopenal-dev libogg-dev libvorbis-dev libsndfile1-dev libsdl2-dev \
    libsdl2-image-dev

# git clone --recursive https://github.com/opentomb/OpenTomb.git $source_dir
git clone --recursive https://github.com/stohrendorf/OpenTomb.git $source_dir
#mkdir -p $build_dir
#cd $build_dir

cd $source_dir
cmake .
make
