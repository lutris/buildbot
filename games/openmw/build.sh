#!/bin/bash

set -e

source ../../lib/util.sh

version="0.37.0"
source_dir=$(pwd)/openmw-src
build_dir=$(pwd)/openmw-build
bin_dir=$(pwd)/openmw

install_deps libopenal-dev libopenscenegraph-dev \
 libsdl2-dev libqt4-dev libboost-filesystem-dev libboost-thread-dev \
 libboost-program-options-dev libboost-system-dev libav-tools \
 libavcodec-dev libavformat-dev libavutil-dev libswscale-dev libavresample-dev \
 libbullet-dev libmygui-dev libunshield-dev libtinyxml-dev cmake build-essential \
 libqt4-opengl-dev

clone https://github.com/OpenMW/openmw.git $source_dir
cd $source_dir
git checkout -b openmw-$version

mkdir -p $build_dir
cd $build_dir
cmake -DCMAKE_BUILD_TYPE=Release $source_dir

make -j$(getconf _NPROCESSORS_ONLN)

mkdir -p ${bin_dir}
mv bsatool data esmtool gamecontrollerdb.txt opencs.ini openmw openmw-cs \
   openmw-essimporter openmw-iniimporter openmw-launcher openmw-wizard resources \
   settings-default.cfg version ${bin_dir}
cd ..
cp openmw.cfg ${bin_dir}
tar cvzf openmw-${version}.tar.gz openmw
