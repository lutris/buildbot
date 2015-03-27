#!/bin/bash

set -e

sudo apt-get install -y libsndfile-dev wget

pkg_name="mednafen"
version="0.9.38.3"
arch="$(uname -m)"

root_dir="$(pwd)"
source_dir="${root_dir}/${pkg_name}-src"
build_dir="${root_dir}/${pkg_name}"

src_archive="${pkg_name}-${version}.tar.bz2"
src_url="http://freefr.dl.sourceforge.net/project/mednafen/Mednafen/${version}/${src_archive}"

wget ${src_url}
tar xjf ${src_archive}
rm ${src_archive}

mv mednafen ${source_dir}
cd ${source_dir}

./configure --prefix=${build_dir}
make
make install

cd ${build_dir}
strip bin/mednafen

cd ..
tar czf ${pkg_name}-${version}-${arch}.tar.gz ${pkg_name}
rm -rf ${build_dir} ${source_dir}
