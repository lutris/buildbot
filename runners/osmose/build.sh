#!/bin/bash

source_dir="osmose-src"
build_dir="osmose"
version="0.9.96"
arch=$(uname -m)

git clone https://github.com/lutris/osmose.git $source_dir
mkdir $build_dir
cd $build_dir
qmake-qt4 ../${source_dir}
make

strip osmose
cp ../${source_dir}/README README
cp ../${source_dir}/License.txt LICENSE

cd ../
tar cvzf osmose-${version}-${arch}.tar.gz ${build_dir}
rm -rf ${build_dir} ${source_dir}
