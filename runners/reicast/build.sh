#!/bin/bash

set -e

pkg_name="reicast"
version="r7"
arch=$(uname -m)

root_dir="$(pwd)"
source_dir="${root_dir}/${pkg_name}-src"
build_dir="${root_dir}/${pkg_name}"

sudo apt-get install libegl1-mesa-dev libgles2-mesa-dev libasound2-dev mesa-common-dev freeglut3-dev

git clone https://github.com/lutris/reicast-emulator.git ${source_dir}

cd ${source_dir}/shell/lin86
make

mkdir -p ${build_dir}
mv reicast.elf nosym-reicast.elf ${build_dir}
cd ${root_dir}
tar czf ${pkg_name}-${version}-${arch}.tar.gz ${pkg_name}
