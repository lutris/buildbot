#!/bin/bash

set -e

source ../../lib/util.sh

version="0.0.1"
arch="$(uname -m)"
root_dir=$(pwd)
pkg_name="postal"
source_dir="${root_dir}/${pkg_name}-src"
bin_dir="${root_dir}/${pkg_name}"

GetSources() {
    hg clone ssh://hg@bitbucket.org/gopostal/postal-1-open-source $source_dir
}

InstallBuildDependencies() {
    install_deps make
}

BuildProject() {
    cd $source_dir
    make
}

PackageProject() {
    cd $root_dir
    rm -rf $bin_dir
    mkdir $bin_dir
    cp $source_dir/ $bin_dir
    tar czf ${pkg_name}-${version}-${arch}.tar.gz ${pkg_name}
}

CleanUp() {
    rm -rf $source_dir
    rm -rf $bin_dir
}

if [ $1 ]; then
    $1
else
    # InstallBuildDependencies
    GetSources
    BuildProject
    PackageProject
    # CleanUp
fi
