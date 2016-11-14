#!/bin/bash

set -e

source ../../lib/util.sh

version="0.9.4"
arch="$(uname -m)"
root_dir=$(pwd)
pkg_name="endless-sky"
source_dir="${root_dir}/${pkg_name}-${version}"
bin_dir="${root_dir}/${pkg_name}"

GetSources() {
    archive_name="v${version}.tar.gz"
    wget https://github.com/endless-sky/endless-sky/archive/${archive_name}
    tar xzf $archive_name
    rm $archive_name
}

InstallBuildDependencies() {
    install_deps scons
}

BuildProject() {
    cd $source_dir
    scons
}

PackageProject() {
    cd $root_dir
    rm -rf $bin_dir
    mkdir $bin_dir
    cp -a $source_dir/endless-sky $bin_dir
    cp -a $source_dir/data $bin_dir
    cp -a $source_dir/images $bin_dir
    cp -a $source_dir/sounds $bin_dir
    cp -a $source_dir/credits.txt $bin_dir
    cp -a $source_dir/copyright $bin_dir
    cp -a $source_dir/changelog $bin_dir
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
    CleanUp
fi
