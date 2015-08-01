#!/bin/bash

sudo apt-get install libqt4-dev libqt4-dev-bin qt4-qmake

source_dir="osmose-src"
build_dir="osmose"

pkg_name="osmose"
version="0.9.96"
arch=$(uname -m)

git clone https://github.com/lutris/osmose.git $source_dir
mkdir $build_dir
cd $build_dir
qmake-qt4 ../${source_dir}
make
make clean
rm Makefile

strip osmose
cp ../${source_dir}/README README
cp ../${source_dir}/License.txt LICENSE

cd ..
tar cvf ${pkg_name}-${version}-${arch}.tar.gz ${pkg_name}
rm -rf ${build_dir} ${source_dir}
