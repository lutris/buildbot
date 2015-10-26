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
version="1.7.53"
repo_url="git://source.winehq.org/git/wine.git"

sudo apt-get install -y flex bison libfreetype6-dev \
                        libpulse-dev libattr1-dev libtxc-dxtn-dev \
                        libva-dev libva-drm1 autoconf

clone ${repo_url} ${source_dir}

echo "Checking out wine ${version}"
git checkout wine-${version}

if [ $STAGING ]; then
    echo "Adding Wine Staging patches"
    wget https://github.com/wine-compholio/wine-staging/archive/v${version}.tar.gz
    tar xvzf v${version}.tar.gz --strip-components 1
    ./patches/patchinstall.sh DESTDIR="$(pwd)" --all
    configure_opts="--with-xattr"
    filename_opts="staging-"
fi

dest_dir="${filename_opts}${version}-${arch}"
mkdir -p $build_dir
cd $build_dir
$source_dir/configure ${configure_opts} --prefix=${root_dir}/${dest_dir}
make -j4
make install

cd ${root_dir}
find . -type f -exec strip {} \;

dest_file="wine-${filename_opts}${version}-${arch}.tar.gz"
tar czf ${dest_file} ${dest_dir}
rm -rf ${build_dir} ${source_dir}

if [ ! $NOUPLOAD ]; then
    runner_upload ${runner_name} ${filename_opts}${version} ${arch} ${dest_file}
fi
