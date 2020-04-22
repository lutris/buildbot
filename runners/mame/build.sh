#!/bin/bash

set -e
lib_path="../../lib/"
source ${lib_path}path.sh
source ${lib_path}util.sh
source ${lib_path}upload_handler.sh

runner_name=$(get_runner)
root_dir=$(pwd)
source_dir="${root_dir}/${runner_name}-src"
build_dir="${root_dir}/${runner_name}"
arch=$(uname -m)

InstallDeps() {
    install_deps curl wget unzip debhelper libexpat1-dev libflac-dev libfontconfig1-dev \
        libjpeg8-dev libportmidi-dev qtbase5-dev qt5-default libsdl2-ttf-dev libsdl2-dev \
        libxinerama-dev subversion python-dev zlib1g-dev gcc-5
}

Fetch() {
    version=$(curl https://www.mamedev.org/release.html | grep -oP "(?<=MAME )[.0-9]+(?= Source)")
    branch="mame$(echo $version | tr -d .)"
    git clone -b $branch --depth 1 https://github.com/mamedev/mame.git $source_dir
    cd ${source_dir}
}

Build() {
    unset FULLNAME
    make NO_OPENGL=0 REGENIE=1 TOOLS=1 -j8
    if [ "$arch" = "x86_64" ]; then
        mv mame64 mame
    fi
}

Package() {
    mkdir -p ${build_dir}
    # Move binaries
    mv castool chdman floptool imgtool jedutil ldresample ldverify mame nltool nlwav pngcmp regrep romcmp split src2html srcclean unidasm $build_dir
    strip ${build_dir}/*
}

Package() {
    cd ${root_dir}
    dest_file=${runner_name}-${version}-${arch}.tar.gz
    tar czf ${dest_file} ${runner_name}
    runner_upload ${runner_name} ${version} ${arch} ${dest_file}
    rm -rf ${build_dir} ${source_dir}
}


if [ $1 ]; then
    $1
else
    InstallDeps
    Fetch
    Build
    Package
    GetVersion
    PackageProject
    UploadPackage
fi
