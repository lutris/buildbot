#!/bin/bash

set -e

sudo apt-get install -y flex bison

root_dir=$(pwd)
source_dir="${root_dir}/wine-src"
build_dir="${root_dir}/wine"
version="1.7.39"
arch=$(uname -m)

dest_dir="${version}-${arch}"

if [ -d ${source_dir} ]; then
    cd ${source_dir}
    git checkout master
    git pull
else
    git clone git://source.winehq.org/git/wine.git $source_dir
    cd $source_dir
fi
git checkout wine-${version}

mkdir -p $build_dir
cd $build_dir
$source_dir/configure --prefix=${root_dir}/${dest_dir}
make -j4
make install

cd ${root_dir}
find . -type f -exec strip {} \;
tar cvzf wine-${version}-${arch}.tar.gz ${dest_dir}
rm -rf ${build_dir} ${source_dir}
