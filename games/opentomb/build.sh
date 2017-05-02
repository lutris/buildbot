#!/bin/bash

set -e

source ../../lib/util.sh

version="master"
root_dir=$(pwd)
source_dir="${root_dir}/opentomb-src"
bin_dir="${root_dir}/opentomb"

install_deps liblua5.3-dev \
    libbullet-dev libfreetype6-dev libglu1-mesa-dev libglew-dev \
    libopenal-dev libogg-dev libvorbis-dev libsndfile1-dev libsdl2-dev \
    libsdl2-image-dev

clone https://github.com/opentomb/OpenTomb.git $source_dir true

cd $source_dir
cmake .
make

mkdir -p $bin_dir
mv OpenTomb $bin_dir
cp *.lua $bin_dir
cp *.md $bin_dir
cp -a scripts $bin_dir
cp -a shaders $bin_dir
cp -a resource $bin_dir
