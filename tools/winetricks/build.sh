#!/bin/bash

set -e

source ../../lib/util.sh

pkg_name="winetricks"
version="20180815"
arch=$(uname -m)
root_dir=$(pwd)
source_dir="${root_dir}/${pkg_name}-src"
bin_dir="${root_dir}/${pkg_name}"


GetSources() {
    filename="${version}.tar.gz"
    wget https://github.com/Winetricks/winetricks/archive/${filename}
    tar xzf ${filename}
    mv winetricks-${version} ${source_dir}
}

BuildProject() {
    echo "build"
    mkdir -p ${bin_dir}
    cp ${source_dir}/src/winetricks ${bin_dir}
}

PackageProject() {
    cd $root_dir
    tar czf ${pkg_name}-${version}-${arch}.tar.gz ${pkg_name}
}

Cleanup() {
    cd $root_dir
    rm -rf $bin_dir
    rm -rf $source_dir
}


if [ $1 ]; then
    $1
else
    GetSources $version
    BuildProject
    PackageProject
    # Cleanup
fi
