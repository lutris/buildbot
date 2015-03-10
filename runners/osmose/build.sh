#!/bin/bash

source_dir="osmose-src"
build_dir="osmose"
version="0.9.96"
arch=$(uname -m)

git clone https://github.com/lutris/osmose.git $source_dir
cd $source_dir
make

mkdir ../${build_dir}
strip Osmose-0-9-96-QT
mv Osmose-0-9-96-QT ../${build_dir}/osmose
cp README ../${build_dir}/README
cp License.txt ../${build_dir}/LICENSE

cd ../
tar cvzf osmose-${version}-${arch}.tar.gz ${build_dir}
rm -rf ${build_dir} ${source_dir}
