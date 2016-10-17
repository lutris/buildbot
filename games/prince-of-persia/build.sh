#!/bin/bash

set -e

source ../../lib/util.sh

version="1.17"
arch=$(uname -m)
root_dir=$(pwd)
source_dir="${root_dir}/pop-src"
build_dir="${root_dir}/prince-of-persia"

install_deps libsdl2-image-dev libsdl2-mixer-dev

clone  https://github.com/NagyD/SDLPoP.git $source_dir

cd $source_dir
cd src
make all
cd ..
strip prince

mkdir -p $build_dir
mv prince $build_dir
cp -a data $build_dir

wget http://www.popot.org/get_the_games/various/PoP1_DOS_music.zip
unzip PoP1_DOS_music.zip
cp PoP1_DOS_music/ogg/* $build_dir/data/music/

cd $root_dir

tar czf prince-of-persia-${version}-${arch}.tar.gz prince-of-persia
