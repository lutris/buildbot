#!/bin/bash

set -e

source ../../lib/util.sh

root_dir=$(pwd)
source_dir="${root_dir}/ppengine"

install_deps libsdl2-image-dev libsdl2-mixer-dev libopenscenegraph-dev libalut-dev cmake

cd $root_dir

# Build Gorilla Audio
git clone "https://github.com/swistakm/gorilla-audio" gorilla-audio
cd gorilla-audio
git submodule init
git submodule update
cd build
cmake .
make

# build le ppengine
export CPATH="${source_dir}/src/ppengine:${root_dir}/gorilla-audio/include"
export GORILLA_AUDIO_PATH="${root_dir}/gorilla-audio"
git clone "https://github.com/jonathanopalise/ppengine.git" $source_dir
cd $source_dir
make
