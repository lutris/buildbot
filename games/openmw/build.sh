#!/bin/bash

set -e

source ../../lib/util.sh

version="0.40.0"
root_dir=$(pwd)
source_dir="${root_dir}/openmw-src"
build_dir="${root_dir}/openmw-build"
bin_dir="${root_dir}/openmw"

InstallBuildDependencies() {
    sudo add-apt-repository ppa:openmw/openmw
    sudo apt update
    install_deps libopenal-dev \
        libsdl2-dev libqt4-dev libboost-filesystem-dev libboost-thread-dev \
        libboost-program-options-dev libboost-system-dev libav-tools \
        libavcodec-dev libavformat-dev libavutil-dev libswscale-dev libavresample-dev \
        libbullet-dev libmygui-dev libunshield-dev libtinyxml-dev cmake build-essential \
        libqt4-opengl-dev libswresample-dev libopenscenegraph-3.4-dev
}

GetSources() {
    clone https://github.com/OpenMW/openmw.git $source_dir
    cd $source_dir
    if [ $1 ]; then
        git checkout -b openmw-$1
    fi
}

BuildOpenSceneGraph() {
    cd $root_dir
    osg_version="3.4.0"
    osg_dir="OpenSceneGraph-${osg_version}"
    osg_archive="${osg_dir}.zip"

    mkdir osg
    git clone https://github.com/openscenegraph/OpenSceneGraph/tree/OpenSceneGraph-3.4.0 osg/src
    mkdir osg/build
    cd osg/build
    cmake ../src
    make
    sudo make install
}

BuildProject() {
    rm -rf ${build_dir}
    mkdir $build_dir
    cd $build_dir
    cmake -DCMAKE_BUILD_TYPE=Release $source_dir
    make -j$(getconf _NPROCESSORS_ONLN)
}

PackageProject() {
    rm -rf ${bin_dir}
    mkdir -p ${bin_dir}
    cd ${build_dir}
    mv bsatool esmtool gamecontrollerdb.txt openmw-cs.cfg openmw openmw-cs \
    openmw-essimporter openmw-iniimporter openmw-launcher openmw-wizard resources \
    settings-default.cfg ${bin_dir}
    cd ${root_dir}
    cp openmw.cfg ${bin_dir}
    mkdir ${bin_dir}/data
    tar cvzf openmw-${version}.tar.gz openmw
}

if [ $1 ]; then
    $1
else
    InstallBuildDependencies
    GetSources $version
    BuildProject
    PackageProject
fi
