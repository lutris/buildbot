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
    cd $root_dir
    hg clone https://strycore@bitbucket.org/gopostal/postal-1-open-source $source_dir
    cp -a steamworks $source_dir
}

InstallBuildDependencies() {
    cd $root_dir
    install_deps mercurial
    mkdir steamworks
    cd steamworks
    wget https://partner.steamgames.com/downloads/steamworks_sdk_138a.zip
    unzip steamworks_sdk_138a.zip
    rm steamworks_sdk_138a.zip
}

Build() {
    cd $source_dir
    make target=linux_x86
}

Package() {
    cd $root_dir
    rm -rf $bin_dir
    mkdir $bin_dir
    cp $source_dir/ $bin_dir
    tar czf ${pkg_name}-${version}-${arch}.tar.gz ${pkg_name}
}

CleanUp() {
    rm -rf $source_dir
    rm -rf $bin_dir
    rm -rf $root_dir/steamworks
}

if [ $1 ]; then
    $1
else
    InstallBuildDependencies
    GetSources
    Build
    Package
    # CleanUp
fi
