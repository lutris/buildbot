#!/bin/bash

set -e

source ../../lib/util.sh

version="0.0.1"
root_dir=$(pwd)
pkg_name="openwar"
source_dir="${root_dir}/${pkg_name}-src"
build_dir="${root_dir}/${pkg_name}-build"
bin_dir="${root_dir}/${pkg_name}"
export GOPATH=$source_dir

GetSources() {
    repo_url="https://github.com/andreas-jonsson/openwar"
    clone $repo_url $source_dir
}

InstallBuildDependencies() {
    install_deps
}

BuildProject() {
    cd $source_dir
    go get
}

PackageProject() {
    rm -rf $bin_dir
    mkdir $bin_dir

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
