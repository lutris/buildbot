#!/bin/bash

set -e

source ../../lib/util.sh

pkg_name="p7zip"
version="16.02"
arch=$(uname -m)
root_dir=$(pwd)
source_dir="${root_dir}/${pkg_name}-src"
bin_dir="${root_dir}/${pkg_name}"


GetSources() {
    source_archive="p7zip_${version}_src_all.tar.bz2"
    wget "http://pilotfiber.dl.sourceforge.net/project/p7zip/p7zip/${version}/${source_archive}"
    tar xjf $source_archive
    rm -rf $source_dir
    mv "p7zip_${version}" $source_dir
    rm ${source_archive}
}

BuildProject() {
    cd $source_dir
    make clean
    make 7z
    make 7za
    rm -rf $bin_dir
    mv ./bin $bin_dir
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
    Cleanup
fi
