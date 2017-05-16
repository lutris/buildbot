#!/bin/bash

set -e

source ../../lib/util.sh

version="907"
arch="$(uname -m)"
root_dir=$(pwd)
pkg_name="quake2xp"
source_dir="${root_dir}/${pkg_name}-src"
build_dir="${root_dir}/${pkg_name}-build"
bin_dir="${root_dir}/${pkg_name}"


InstallBuildDependencies() {
    install_deps build-essential libvorbis-dev libdevil-dev libsdl1.2-dev libopenal-dev
}

GetSources() {
    cd $root_dir
    svn checkout svn://svn.code.sf.net/p/quake2xp/code/trunk $source_dir
}

Build() {
    mkdir -p $build_dir
    cd $source_dir
    python waf configure --prefix=${build_dir}
    python waf
    python waf install
}

Package() {
    cd $root_dir
    rm -rf $bin_dir
    mkdir $bin_dir
    mv $build_dir/share/quake2xp/* $bin_dir
    mv $build_dir/bin/quake2xp $bin_dir

    tar czf ${pkg_name}-${version}-${arch}.tar.gz ${pkg_name}
}

Clean() {
    cd $root_dir
    rm -rf $build_dir
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
