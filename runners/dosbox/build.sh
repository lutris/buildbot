#!/bin/bash

set -e
lib_path="../../lib/"
source ${lib_path}path.sh
source ${lib_path}util.sh

runner_name="$(get_runner)"
root_dir=$(pwd)
source_dir="${root_dir}/${runner_name}-src"
dist_dir="${root_dir}/${runner_name}"
dosbox_ece_revision=4280
arch=$(uname -m)
version=0.80.1
dest_file="${runner_name}-${version}-${arch}.tar.gz"
publish_dir="/builds/runners/${runner_name}"

InstallDeps() {
    install_deps "ccache build-essential libasound2-dev libatomic1 libpng-dev \
                 libsdl2-dev libsdl2-image-dev libsdl2-net-dev libopusfile-dev \
                 libfluidsynth-dev libslirp-dev libspeexdsp-dev libxi-dev"
    sudo apt install python3-setuptools python3-pip
    sudo pip3 install --upgrade meson ninja
}

GetSources() {
    clone https://github.com/dosbox-staging/dosbox-staging.git $source_dir
}

Build() {
    cd $source_dir
    meson setup build -Dtry_static_libs=iir,mt32emu,opusfile,speexdsp,tracy
    meson compile -C build
}

Package() {
    mkdir -p $dist_dir/bin
    cp $source_dir/build/dosbox $dist_dir/bin
    cp -a $source_dir/build/resources $dist_dir
    cp $source_dir/README $dist_dir
    cd ${root_dir}
    tar czf ${dest_file} ${runner_name}
    mkdir -p $publish_dir
    cp $dest_file $publish_dir
}

InstallDeps
GetSources
Build
Package
