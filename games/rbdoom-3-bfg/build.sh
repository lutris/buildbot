#!/bin/bash

set -e
lib_path="../../lib/"

source ${lib_path}path.sh
source ${lib_path}util.sh
source ${lib_path}upload_handler.sh

root_dir=$(pwd)
package_name=rbdoom-3-bfg
version=1.0.3.1401
arch=$(uname -m)
source_dir=${root_dir}/${package_name}-src

InstallDependencies() {
    if [ "$(lsb_release -is)" = "Solus" ]; then
        sudo eopkg install cmake make g++ binutils ffmpeg-devel sdl2-devel openal-soft-devel libglu-devel
    else
        deps="libsdl2-dev libopenal-dev libavcodec-dev libavformat-dev libavutil-dev libswscale-dev"
        install_deps $deps
    fi
}

InstallDependencies

clone https://github.com/RobertBeckebans/RBDOOM-3-BFG.git ${source_dir}

cd $source_dir
cd neo
./cmake-eclipse-linux-profile.sh
cd ../build
make -j$(getconf _NPROCESSORS_ONLN)

cp RBDoom3BFG ${root_dir}
cd $root_dir
tar czf ${package_name}-${version}-${arch}.tar.gz RBDoom3BFG
rm -rf RBDoom3BFG ${source_dir}
