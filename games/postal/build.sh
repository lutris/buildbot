#!/bin/bash

set -e

source ../../lib/util.sh

version="1.0"
arch="$(uname -m)"
root_dir=$(pwd)
pkg_name="postal"
source_dir="${root_dir}/${pkg_name}-src"
bin_dir="${root_dir}/${pkg_name}"

STEAMWORKS="1"

params=$(getopt -n $0 -o n --long no-steamworks -- "$@")
eval set -- $params
while true ; do
    case "$1" in
        -n|--no-steamworks) STEAMWORKS="0"; shift ;;
        *) shift; break ;;
    esac
done

GetSources() {
    cd $root_dir
    hg clone https://strycore@bitbucket.org/gopostal/postal-1-open-source $source_dir
    if [ $STEAMWORKS = "1" ]; then
        cp -a steamworks $source_dir
    fi
}

InstallBuildDependencies() {
    cd $root_dir
    install_deps mercurial
    if [ $STEAMWORKS = "1" ]; then
        mkdir steamworks
        cd steamworks
        wget https://partner.steamgames.com/downloads/steamworks_sdk_138a.zip
        unzip steamworks_sdk_138a.zip
        rm steamworks_sdk_138a.zip
    fi
}

Build() {
    cd $source_dir
    if [ $STEAMWORKS = "1" ]; then
        make target=linux_x86
    else
        make target=linux_x86 steamworks=false
    fi
}

Package() {
    cd $root_dir
    mkdir -p $bin_dir
    cp $source_dir/bin/postal1-bin $bin_dir
    opts=""
    if [ $STEAMWORKS = "1" ]; then
        cp $source_dir/steamworks/sdk/redistributable_bin/linux32/libsteam_api.so $bin_dir
    else
        opts="-nosteamworks"
    fi
    tar czf ${pkg_name}${opts}-${version}-${arch}.tar.gz ${pkg_name}
}

CleanUp() {
    rm -rf $source_dir
    rm -rf $bin_dir
    rm -rf $root_dir/steamworks
}

if [ $1 ]; then
    $1
else
    if [ "$STEAMWORKS" = "1" ]; then
        echo "Building with Steamworks enabled"
    else
        echo "Building with Steamworks disabled"
    fi
    InstallBuildDependencies
    GetSources
    Build
    Package
    CleanUp
fi
