#!/bin/bash

set -e

source ../../lib/util.sh

version="0.23"
arch="$(uname -m)"
root_dir=$(pwd)
pkg_name="rrootage"
source_dir="${root_dir}/${pkg_name}-src"
bin_dir="${root_dir}/${pkg_name}"


InstallBuildDependencies() {
    # install_deps 
    echo "TODO"
}

GetSources() {
    cd $root_dir
    clone https://github.com/lutris/rRootage.git $source_dir
}

Build() {
    cd $source_dir/src
    make
}

Package() {
    cd $root_dir
    rm -rf $bin_dir
    mkdir $bin_dir
    cp -a $source_dir/src/data $bin_dir
    mv $source_dir/src/rrootage $bin_dir
    tar czf ${pkg_name}-${version}-${arch}.tar.gz ${pkg_name}
}

Clean() {
    cd $root_dir
    rm -rf $bin_dir
    rm -rf $source_dir
}

if [ $1 ]; then
    $1
else
    InstallBuildDependencies
    GetSources
    Build
    Package
    Clean
fi
