#!/bin/bash

set -e
lib_path="../../lib/"

source ${lib_path}path.sh
source ${lib_path}util.sh
source ${lib_path}upload_handler.sh

root_dir=$(pwd)
version=2.1.15
arch=$(uname -m)
pkg_name="srb2"
source_dir="${root_dir}/${pkg_name}-src"
data_dir="${root_dir}/${pkg_name}-data"
build_dir="${root_dir}/${pkg_name}"

deps="libsdl2-mixer-dev"
install_deps $deps

clone https://github.com/STJr/SRB2.git $source_dir
cd $source_dir

if [ $arch = "x86_64" ]; then
    make -C src LINUX64=1
    bin_dir="${source_dir}/bin/Linux64/Release"
else
    make -C src LINUX=1
    bin_dir="${source_dir}/bin/Linux/Release"
fi

mkdir -p $build_dir

mkdir -p $data_dir
cd $data_dir
wget "http://rosenthalcastle.org/srb2/SRB2-v2115-Installer.exe"
7z e SRB2-v2115-Installer.exe
mv *.dta $build_dir
mv srb2.srb $build_dir
mv $bin_dir/lsdl2srb2 $build_dir

cd $root_dir
tar czf sonic-robo-blast-2-${version}-${arch}.tar.gz ${pkg_name}
