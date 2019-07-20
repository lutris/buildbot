#!/bin/bash

set -e

source ../../lib/util.sh

pkg_name="innoextract"
version="1.8-pre"
arch=$(uname -m)
root_dir=$(pwd)
source_dir="${root_dir}/${pkg_name}-src"
build_dir="${root_dir}/${pkg_name}-build"
bin_dir="${root_dir}/${pkg_name}"


GetSources() {
    clone https://github.com/dscharrer/innoextract $source_dir
}

BuildProject() {
    cd "${source_dir}"
    mkdir -p $build_dir
    cd $build_dir
    cmake $source_dir
    make
}

PackageProject() {
    mkdir -p $bin_dir
    mv ${build_dir}/innoextract $bin_dir
    cp ${source_dir}/CHANGELOG $bin_dir
    cp ${source_dir}/LICENSE $bin_dir
    cp ${source_dir}/README.md $bin_dir
    cp ${source_dir}/VERSION $bin_dir
    cd ${root_dir}
    tar czf ${pkg_name}-${version}-${arch}.tar.gz ${pkg_name}
}

Cleanup() {
    cd $root_dir
    rm -rf $bin_dir
    rm -rf $build_dir
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
