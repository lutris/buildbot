#!/bin/bash

set -e
lib_path="../../lib/"
source ${lib_path}path.sh
source ${lib_path}util.sh
source ${lib_path}upload_handler.sh

if [ "$RUNNER" = "mess" ]; then
    runner_name="mess"
else
    runner_name=$(get_runner)
fi
root_dir=$(pwd)
source_dir="${root_dir}/${runner_name}-src"
build_dir="${root_dir}/${runner_name}"
arch=$(uname -m)

deps="curl wget unzip debhelper libexpat1-dev libflac-dev libfontconfig1-dev libjpeg8-dev libportmidi-dev libqt4-dev libsdl2-ttf-dev libsdl2-dev libxinerama-dev subversion python-dev zlib1g-dev"
install_deps $deps

release=$(curl http://mamedev.org/release.html | grep -E "href.*s.zip" | cut -d"\"" -f 2)
version=$(curl http://mamedev.org/release.html | grep -E -o "release is version [\.0-9]+" | grep -E -o 0.[0-9]+)
archive=$(echo ${release} | cut -d"/" -f 9)

wget "${release}" -O ${archive}
unzip -o $archive

mkdir -p ${source_dir}
mv mame.zip ${source_dir}
cd ${source_dir}
unzip -o mame.zip
rm mame.zip

unset FULLNAME

if [ "$RUNNER" = "mess" ]; then
    NO_OPENGL=0 make -j 8 SUBTARGET=mess
    if [ "$arch" = "x86_64" ]; then
        mv mess64 mess
    fi
else
    NO_OPENGL=0 make -j 8
    if [ "$arch" = "x86_64" ]; then
        mv mame64 mame
    fi
fi

mkdir -p ${build_dir}
mv ${runner_name} ${build_dir}

cd ..
dest_file=${runner_name}-${version}-${arch}.tar.gz
tar czf ${dest_file} ${runner_name}
runner_upload ${runner_name} ${version} ${arch} ${dest_file}
# rm -rf ${build_dir} ${source_dir}
