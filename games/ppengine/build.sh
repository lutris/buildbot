#!/bin/bash

set -e

source ../../lib/util.sh

root_dir=$(pwd)
source_dir="${root_dir}/ppengine"

install_deps libsdl2-image-dev libsdl2-mixer-dev cmake

cd $root_dir

# Build Gorilla Audio
git clone "https://github.com/swistakm/gorilla-audio" gorilla-audio
cd gorilla-audio
git submodule init
git submodule update
cd build
cmake . 
make

export GORILLA_AUDIO_PATH="$source_dir/gorilla-audio/bin/linux/Release/"
git clone "https://github.com/jonathanopalise/ppengine.git" $source_dir
cd $source_dir
make 

# Build breaks here, some includes seem to be broken:

#  src/scene/scene.h:7:10: fatal error: engine.h: No such file or directory
#  #include "engine.h"
#           ^~~~~~~~~~

