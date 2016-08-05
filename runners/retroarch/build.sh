#!/bin/bash

set -e
lib_path="../../lib/"
source ${lib_path}path.sh
source ${lib_path}util.sh
source ${lib_path}upload_handler.sh

runner_name=$(get_runner)

InstallDeps() {
    deps="build-essential libxkbcommon-dev zlib1g-dev libfreetype6-dev \
        libegl1-mesa-dev libgbm-dev nvidia-cg-toolkit nvidia-cg-dev libavcodec-dev \
        libsdl2-dev libsdl-image1.2-dev libxml2-dev"
    install_deps $deps
}

root_dir="$(pwd)"
source_dir="${root_dir}/libretro-super"
bin_dir="${root_dir}/retroarch"
cores_dir="${bin_dir}/cores"

core="$1"

clone git://github.com/libretro/libretro-super.git $source_dir

mkdir -p ${cores_dir}

BuildRetroarch() {
    cd ${source_dir}
    SHALLOW_CLONE=1 ./libretro-fetch.sh retroarch
    ./libretro-super.sh retroarch
    cd ${source_dir}/retroarch
    cp retroarch $bin_dir
    cp tools/cg2glsl.py ${bin_dir}/retroarch-cg2glsl
    cp -a media/assets ${bin_dir}
}

BuildLibretroCore() {
    core="$1"
    cd ${source_dir}
    SHALLOW_CLONE=1 ./libretro-fetch.sh $core
    ./libretro-super.sh $core
    ./libretro-install.sh ${cores_dir}
}


if [ $1 ]; then
    BuildLibretroCore $1
else
    BuildRetroarch
fi
