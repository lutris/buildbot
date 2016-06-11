#!/bin/bash

set -e

source ../../lib/util.sh

version="1.0.0"
root_dir=$(pwd)
pkg_name="nfs2se"
source_dir="${root_dir}/${pkg_name}-src"
build_dir="${root_dir}/${pkg_name}-build"
bin_dir="${root_dir}/${pkg_name}"

GetSources() {
    clone https://github.com/zaps166/NFSIISE $source_dir
}

InstallBuildDependencies() {
    install_deps yasm
}

BuildProject() {
    cd $source_dir
    ./compile_nfs
}

PackageProject() {
    rm -rf $bin_dir
    mkdir $bin_dir

    cd "${source_dir}/Need For Speed II SE"
    cp -a * $bin_dir
    cd $root_dir
    tar czf ${pkg_name}-${version}.tar.gz ${pkg_name}

}

if [ $1 ]; then
    $1
else
    InstallBuildDependencies
    GetSources
    BuildProject
    PackageProject
fi
