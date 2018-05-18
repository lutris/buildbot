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

install_deps curl wget unzip debhelper libexpat1-dev libflac-dev libfontconfig1-dev \
     libjpeg8-dev libportmidi-dev qtbase5-dev qt5-default libsdl2-ttf-dev libsdl2-dev \
     libxinerama-dev subversion python-dev zlib1g-dev gcc-5

release=$(curl http://mamedev.org/release.html | grep -E "href.*s.zip" | cut -d"\"" -f 2)
version=$(curl http://mamedev.org/release.html | grep -E -o "release is version [\.0-9]+" | grep -E -o 0.[0-9]+)
archive=$(echo ${release} | cut -d"/" -f 9)

wget "${release}" -O ${archive}
unzip -o $archive

mkdir -p ${source_dir}
mv mame.zip ${source_dir}
cd ${source_dir}
unzip -o mame.zip || true
rm mame.zip

unset FULLNAME

make NO_OPENGL=0 REGENIE=1 TOOLS=1 -j8
if [ "$arch" = "x86_64" ]; then
    mv mame64 mame
fi

mkdir -p ${build_dir}
mv castool chdman floptool imgtool jedutil ldresample ldverify mame nltool nlwav pngcmp regrep romcmp split src2html srcclean unidasm $build_dir
strip ${build_dir}/*

cd ${root_dir}
dest_file=${runner_name}-${version}-${arch}.tar.gz
tar czf ${dest_file} ${runner_name}
runner_upload ${runner_name} ${version} ${arch} ${dest_file}
# rm -rf ${build_dir} ${source_dir}
