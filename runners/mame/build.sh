#!/bin/bash

set -e
lib_path="../../lib/"
source ${lib_path}path.sh
source ${lib_path}util.sh

runner_name=$(get_runner)
root_dir=$(pwd)
source_dir="${root_dir}/${runner_name}-src"
build_dir="${root_dir}/${runner_name}"
publish_dir="/builds/runners/${runner_name}"
arch=$(uname -m)
version=$(curl https://www.mamedev.org/release.html | grep -oP "(?<=MAME )[.0-9]+(?= Source)")
branch="mame$(echo $version | tr -d .)"

InstallDeps() {
    install_deps curl wget unzip libexpat1-dev libflac-dev libfontconfig1-dev \
        libjpeg62-turbo-dev libportmidi-dev qtbase5-dev libsdl2-ttf-dev libsdl2-dev \
        libxinerama-dev zlib1g-dev
}

Fetch() {
    git clone -b $branch --depth 1 https://github.com/mamedev/mame.git $source_dir
}

Build() {
    cd ${source_dir}
    unset FULLNAME
    make NO_OPENGL=0 REGENIE=1 TOOLS=1 -j$(nproc)
}

Install() {
    cd ${source_dir}
    mkdir -p ${build_dir}
    # Move binaries
    mv castool chdman floptool imgtool jedutil ldresample ldverify mame nltool nlwav pngcmp regrep romcmp split testkeys srcclean unidasm $build_dir
    strip ${build_dir}/*
    mv bgfx ctrlr hash hlsl ini keymaps language plugins roms samples scripts $build_dir
    cp -a ${root_dir}/shaders ${build_dir}
}

Package() {
    cd ${root_dir}
    dest_file=${runner_name}-${version}-${arch}.tar.gz
    tar czf ${dest_file} ${runner_name}
    mkdir -p $publish_dir
    cp ${dest_file} ${publish_dir}
}

Cleanup() {
    rm -rf ${build_dir} ${source_dir}
}

if [ $1 ]; then
    $1
else
    InstallDeps
    Fetch
    Build
    Install
    Package
    Cleanup
fi
